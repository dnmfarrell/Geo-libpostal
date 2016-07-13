#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Test::Fatal 'exception';

use Geo::libpostal ':all';
pass 'loaded Geo::libpostal';

subtest expand_address => sub {
  ok expand_address('120 E 96th St New York'), 'expand address';
  ok expand_address('The Book Club 100-106 Leonard St Shoreditch London EC2A 4RH, United Kingdom'), 'expand UK address';
};

subtest parse_address => sub {
  ok parse_address('120 E 96th St New York'), 'parse address';

  # languages
  ok parse_address('120 E 96th St New York', language => undef),
    'parse address undef language';
  ok parse_address('120 E 96th St New York', language => 'en'),
    'parse address en language';
  ok parse_address('C/ Ocho, P.I. 4', language => 'es'),
    'parse address es language';
  ok parse_address('Quatre vingt douze R. de l\'Église', language => 'fr'),
    'parse address fr language';

  # countries
  ok parse_address('120 E 96th St New York', country => undef),
    'parse address undef country';
  ok parse_address('120 E 96th St New York', country => 'US'),
    'parse address US country';
  ok parse_address('The Book Club 100-106 Leonard St Shoreditch London EC2A 4RH, United Kingdom', country => 'GB'),
    'parse address GB country';
  ok parse_address('C/ Ocho, P.I. 4', country => 'ES'),
    'parse address ES country';
  ok parse_address('Quatre vingt douze R. de l\'Église', country => 'FR'),
    'parse address FR country';

  # both
  ok parse_address(
    '120 E 96th St New York',
    language => undef,
    country  => undef,
  ), 'parse address undef';

  ok parse_address(
    '120 E 96th St New York',
    language => 'en',
    country  => 'US',
  ), 'parse address undef';

  ok parse_address(
    'The Book Club 100-106 Leonard St Shoreditch London EC2A 4RH, United Kingdom', 
    country   => 'GB',
    language  => 'en',
  ),'parse address GB en';

  ok parse_address(
    'C/ Ocho, P.I. 4',
    country   => 'ES',
    language  => 'es',
  ), 'parse address ES es';

  ok parse_address(
    'Quatre vingt douze R. de l\'Église',
    language => 'fr',
    country  => 'FR',
  ),'parse address fr FR';
};

subtest exceptions => sub {
  ok exception { expand_address(undef) }, 'expand_address() requires an address (undef)';
  ok exception { expand_address('') },    'expand_address() requires an address (empty)';

  ok exception { parse_address(undef)  }, 'parse_address() requires an address (undef)';
  ok exception { parse_address('')  },    'parse_address() requires an address (empty)';

  ok exception { parse_address('foo', undef)  }, 'parse_address() odd number of options (1)';
  ok exception { parse_address('foo', 1,2,3)  }, 'parse_address() odd number of options (3)';

  ok exception { parse_address('foo', undef, 'bar')  }, 'parse_address() option name invalid (undef)';
  ok exception { parse_address('foo', 'bar', 'dah')  }, 'parse_address() option name invalid (unrecog)';
  ok exception { parse_address('foo', '',    'dah')  }, 'parse_address() option name invalid (empty)';
  ok exception { parse_address('foo', 1,     'dah')  }, 'parse_address() option name invalid (type IV)';
  ok exception { parse_address('foo', sub{}, 'dah')  }, 'parse_address() option name invalid (type CV)';
  ok exception { parse_address('foo', \my $v,'dah')  }, 'parse_address() option name invalid (type RV)';
};
done_testing();
