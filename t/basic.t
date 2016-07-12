#!/usr/bin/env perl
use Test::More;
use strict;
use warnings;

use Geo::libpostal qw/expand_address parse_address/;
pass 'loaded Geo::libpostal';

ok my @addresses = expand_address('The Book Club 100-106 Leonard St Shoreditch London EC2A 4RH, United Kingdom'), 'expand UK address';
ok my %address = parse_address('The Book Club 100-106 Leonard St Shoreditch London EC2A 4RH, United Kingdom'), 'parse UK address';

use Data::Dumper;
print STDERR Dumper(\%address);

done_testing();
