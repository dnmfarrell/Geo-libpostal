#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdio.h>
#include <stdlib.h>
#include <libpostal/libpostal.h>

MODULE = Geo::libpostal      PACKAGE = Geo::libpostal
PROTOTYPES: ENABLED

SV *
setup()
  CODE:
  if (!libpostal_setup() || !libpostal_setup_language_classifier()) {
    // add EXIT_FAILURE to this msg
    croak("libpostal setup failed");
  }
  ST(0) = sv_newmortal();

SV *
teardown()
  CODE:
  libpostal_teardown();
  libpostal_teardown_language_classifier();
  ST(0) = sv_newmortal();
