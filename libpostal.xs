#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <stdio.h>
#include <stdlib.h>
#include <libpostal/libpostal.h>

int LP_SETUP = 0,
    LP_SETUP_LANGCLASS = 0,
    LP_SETUP_PARSER = 0;

MODULE = Geo::libpostal      PACKAGE = Geo::libpostal PREFIX = lp_
PROTOTYPES: ENABLED

SV *
lp__teardown()
  CODE:
  /* if teardown is called twice, libpostal crashes */
  if (LP_SETUP == 1) {
    libpostal_teardown();
    LP_SETUP = -1;
  }
  if (LP_SETUP_LANGCLASS == 1) {
    libpostal_teardown_language_classifier();
    LP_SETUP_LANGCLASS  = -1;
  }
  if (LP_SETUP_PARSER == 1) {
    libpostal_teardown_parser();
    LP_SETUP_PARSER  = -1;
  }
  ST(0) = sv_newmortal();

void
lp_expand_address(address, ...)
  SV *address
  PREINIT:
    char *src, *option_name;
    size_t src_len, option_len, i, j, num_expansions, exp_len, language_len;
    AV *languages_av;
    SV **language;
  PPCODE:
    if (!LP_SETUP) {
      if (!libpostal_setup()) {
        croak("libpostal_setup() failed: %d", EXIT_FAILURE);
      }
      LP_SETUP = 1;
    }
    /* if setup is called twice, libpostal crashes */
    else if (LP_SETUP == -1) {
      croak("_teardown() already called, Geo::libpostal cannot be used");
    }

    if (!LP_SETUP_LANGCLASS) {
      if(!libpostal_setup_language_classifier()) {
        croak("libpostal_setup_language_classifier failed: %d", EXIT_FAILURE);
      }
      LP_SETUP_LANGCLASS = 1;
    }

    /* call fetch() if a tied variable to populate the sv */
    SvGETMAGIC(address);

    /* check for undef */
    if (!SvOK(address) || !SvCUR(address))
    {
      croak("expand_address() requires a scalar argument to expand!");
    }

    /* copy the sv without the magic struct and populate src_len*/
    src = SvPV_nomg(address, src_len);

    normalize_options_t options = get_libpostal_default_options();

    /* parse optional args */
    if (((items - 1) % 2) != 0)
      croak("Odd number of options in call to expand_address()");

    for (i = 1; i < items; i += 2) {
      if (!SvOK(ST(i)) || !SvCUR(ST(i)))
        croak("expand_address() option names cannot be empty");

      SvGETMAGIC(ST(i));
      option_name = SvPV_nomg(ST(i), option_len);
      SvGETMAGIC(ST(i+1));

      /* process arrayref of lang codes option */
      if (!strncmp("languages", option_name, option_len)) {

        /* check its an arrayref */
        if (!SvROK(ST(i+1)) || SvTYPE(SvRV(ST(i+1))) != SVt_PVAV)
          croak("expand_address() languages option must be an arrayref");

        /* dereference the arrayref */
        languages_av = (AV*)SvRV(ST(i+1));

        /* av_len returns the highest index, not the length */
        option_len = av_len(languages_av) + 1;

        char *languages[option_len];

        /* loop through the array assigning the languages */
        for (j = 0; j < option_len; j++) {
          language = av_fetch(languages_av, j, 0);
          if (language == NULL) {
            croak("expand_address() languages option value must not be undef");
          }
          else {
            languages[j] = SvPV_nomg(*language, language_len);
          }
        }
        options.languages = languages;
        options.num_languages = option_len;
      }
      /* process boolean options */
      else if (!strncmp("latin_ascii", option_name, option_len)) {
        options.latin_ascii = SvTRUE(ST(i+1));
      }
      else if (!strncmp("transliterate", option_name, option_len)) {
        options.transliterate = SvTRUE(ST(i+1));
      }
      else if (!strncmp("strip_accents", option_name, option_len)) {
        options.strip_accents = SvTRUE(ST(i+1));
      }
      else if (!strncmp("decompose", option_name, option_len)) {
        options.decompose = SvTRUE(ST(i+1));
      }
      else if (!strncmp("lowercase", option_name, option_len)) {
        options.lowercase = SvTRUE(ST(i+1));
      }
      else if (!strncmp("trim_string", option_name, option_len)) {
        options.trim_string = SvTRUE(ST(i+1));
      }
      else if (!strncmp("drop_parentheticals", option_name, option_len)) {
        options.drop_parentheticals = SvTRUE(ST(i+1));
      }
      else if (!strncmp("replace_numeric_hyphens", option_name, option_len)) {
        options.replace_numeric_hyphens = SvTRUE(ST(i+1));
      }
      else if (!strncmp("delete_numeric_hyphens", option_name, option_len)) {
        options.delete_numeric_hyphens = SvTRUE(ST(i+1));
      }
      else if (!strncmp("split_alpha_from_numeric", option_name, option_len)) {
        options.split_alpha_from_numeric = SvTRUE(ST(i+1));
      }
      else if (!strncmp("replace_word_hyphens", option_name, option_len)) {
        options.replace_word_hyphens = SvTRUE(ST(i+1));
      }
      else if (!strncmp("delete_word_hyphens", option_name, option_len)) {
        options.delete_word_hyphens = SvTRUE(ST(i+1));
      }
      else if (!strncmp("delete_final_periods", option_name, option_len)) {
        options.delete_final_periods = SvTRUE(ST(i+1));
      }
      else if (!strncmp("delete_acronym_periods", option_name, option_len)) {
        options.delete_acronym_periods = SvTRUE(ST(i+1));
      }
      else if (!strncmp("drop_english_possessives", option_name, option_len)) {
        options.drop_english_possessives = SvTRUE(ST(i+1));
      }
      else if (!strncmp("delete_apostrophes", option_name, option_len)) {
        options.delete_apostrophes = SvTRUE(ST(i+1));
      }
      else if (!strncmp("expand_numex", option_name, option_len)) {
        options.expand_numex = SvTRUE(ST(i+1));
      }
      else if (!strncmp("roman_numerals", option_name, option_len)) {
        options.roman_numerals = SvTRUE(ST(i+1));
      }
      else {
        croak("Unrecognised parameter: '%"SVf"'", ST(i));
      }
    }
    char **expansions = expand_address(src, options, &num_expansions);

    /* extend stack pointer with num of return values */
    EXTEND(SP, num_expansions);

    /* push return values onto stack pointer */
    for (i = 0; i < num_expansions; i++) {
      exp_len = strlen(expansions[i]);
      PUSHs( sv_2mortal(newSVpvn(expansions[i], exp_len)) );
    }

    /* Free expansions */
    expansion_array_destroy(expansions, num_expansions);

void
lp_parse_address(address, ...)
    SV *address
  PREINIT:
    char *src, *option_name;
    size_t src_len, option_len, i, label_len, component_len;
  PPCODE:
    if (!LP_SETUP) {
      if (!libpostal_setup()) {
        croak("libpostal_setup() failed: %d", EXIT_FAILURE);
      }
      LP_SETUP = 1;
    }
    else if (LP_SETUP == -1) {
      croak("_teardown() already called, Geo::libpostal cannot be used");
    }

    if (!LP_SETUP_PARSER) {
      if(!libpostal_setup_parser()) {
        croak("libpostal_setup_parser() failed: %d", EXIT_FAILURE);
      }
      LP_SETUP_PARSER = 1;
    }

    /* call fetch() if a tied variable to populate the sv */
    SvGETMAGIC(address);

    /* check for undef */
    if (!SvOK(address) || !SvCUR(address))
    {
      croak("parse_address() requires a scalar argument to parse!");
    }

    /* copy the sv without the magic struct and populate src_len*/
    src = SvPV_nomg(address, src_len);

    address_parser_options_t options = get_libpostal_address_parser_default_options();

    /* parse optional args */
    if (((items - 1) % 2) != 0)
      croak("Odd number of options in call to parse_address()");

    for (i = 1; i < items; i += 2) {
      if (!SvOK(ST(i)))
        croak("parse_address() option names cannot be undef");

      SvGETMAGIC(ST(i));
      option_name = SvPV_nomg(ST(i), option_len);

      if (option_len && !strncmp("language", option_name, option_len)) {
        SvGETMAGIC(ST(i+1));
        options.language = SvPV_nomg(ST(i), option_len);
      }
      else if (option_len && !strncmp("country", option_name, option_len)) {
        SvGETMAGIC(ST(i+1));
        options.country = SvPV_nomg(ST(i), option_len);
      }
      else {
        croak("Unrecognised parameter: '%"SVf"'", ST(i));
      }
    }

    address_parser_response_t *parsed = parse_address(src, options);

    /* extend stack pointer with num of return values */
    EXTEND(SP, parsed->num_components * 2);

    /* push return values onto stack pointer */
    for (i = 0; i < parsed->num_components; i++) {
      label_len = strlen(parsed->labels[i]);
      PUSHs( sv_2mortal(newSVpvn(parsed->labels[i], label_len)) );
      component_len = strlen(parsed->components[i]);
      PUSHs( sv_2mortal(newSVpvn(parsed->components[i], component_len)) );
    }

    /* Free parse result */
    address_parser_response_destroy(parsed);
