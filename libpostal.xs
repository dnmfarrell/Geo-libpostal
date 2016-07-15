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
lp_expand_address(SV *address)
  PREINIT:
    char *src;
    size_t len;
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
      croak("expand_adderess() requires a scalar argument to expand!");
    }

    /* copy the sv without the magic struct */
    src = SvPV_nomg(address, len);

    size_t num_expansions;
    normalize_options_t options = get_libpostal_default_options();
    char **expansions = expand_address(src, options, &num_expansions);

    EXTEND(SP, num_expansions);

    for (size_t i = 0; i < num_expansions; i++) {
      size_t exp_len = strlen(expansions[i]);
      PUSHs( sv_2mortal(newSVpvn(expansions[i], exp_len)) );
    }

    // Free expansions
    expansion_array_destroy(expansions, num_expansions);

void
lp_parse_address(address, ...)
    SV *address
  PREINIT:
    char *src, *option_name, *language, *country;
    size_t address_len, option_len, language_len, country_len, i;
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

    /* copy the sv without the magic struct */
    src = SvPV_nomg(address, address_len);

    /* parse optional args */
    if (((items - 1) % 2) != 0)
      croak("Odd number of options in call to parse_address()");

    address_parser_options_t options = get_libpostal_address_parser_default_options();

    for (i = 1; i < items; i += 2) {
      if (!SvOK(ST(i)))
        croak("parse_address() option names cannot be undef");

      SvGETMAGIC(ST(i));
      option_name = SvPV_nomg(ST(i), option_len);

      if (option_len && !strncmp("language", option_name, option_len)) {
        SvGETMAGIC(ST(i+1));
        options.language = SvPV_nomg(ST(i), language_len);
      }
      else if (option_len && !strncmp("country", option_name, option_len)) {
        SvGETMAGIC(ST(i+1));
        options.country = SvPV_nomg(ST(i), country_len);
      }
      else {
        croak("Unrecognised parameter: '%"SVf"'", ST(i));
      }
    }

    address_parser_response_t *parsed = parse_address(src, options);

    EXTEND(SP, parsed->num_components * 2);
    for (size_t i = 0; i < parsed->num_components; i++) {
      size_t label_len = strlen(parsed->labels[i]);
      PUSHs( sv_2mortal(newSVpvn(parsed->labels[i], label_len)) );
      size_t component_len = strlen(parsed->components[i]);
      PUSHs( sv_2mortal(newSVpvn(parsed->components[i], component_len)) );
    }

    // Free parse result
    address_parser_response_destroy(parsed);
