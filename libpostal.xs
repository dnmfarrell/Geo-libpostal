#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdio.h>
#include <stdlib.h>
#include <libpostal/libpostal.h>

MODULE = Geo::libpostal      PACKAGE = Geo::libpostal PREFIX = lp_
PROTOTYPES: ENABLED

SV *
lp_setup()
  CODE:
  if (!libpostal_setup() || !libpostal_setup_language_classifier() || !libpostal_setup_parser()) {
    // add EXIT_FAILURE to this msg
    croak("libpostal setup failed");
  }
  ST(0) = sv_newmortal();

SV *
lp_teardown()
  CODE:
  libpostal_teardown();
  libpostal_teardown_language_classifier();
  libpostal_teardown_parser();
  ST(0) = sv_newmortal();

void
lp_expand_address(SV *address)
  PREINIT:
    char *src;
    size_t len;
  PPCODE:
    /* call fetch() if a tied variable to populate the sv */
    SvGETMAGIC(address);

    /* check for undef */
    if (!SvOK(address))
    {
      croak("expand_adderess() requires a scalar argument to expand!");
    }

    /* copy the sv without the magic struct */
    src = SvPV_nomg_const(address, len);

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
lp_parse_address(SV *address)
  PREINIT:
    char *src;
    size_t len;
  PPCODE:
    /* call fetch() if a tied variable to populate the sv */
    SvGETMAGIC(address);

    /* check for undef */
    if (!SvOK(address))
    {
      croak("parse_address() requires a scalar argument to parse!");
    }

    /* copy the sv without the magic struct */
    src = SvPV_nomg_const(address, len);

    address_parser_options_t options = get_libpostal_address_parser_default_options();
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
