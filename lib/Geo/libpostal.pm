package Geo::libpostal;

use strict;
use warnings;
use XSLoader;

use Exporter 5.57 'import';

our $VERSION     = '0.01';
our %EXPORT_TAGS = ( 'all' => ['expand_address', 'parse_address'] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );

XSLoader::load('Geo::libpostal', $VERSION);

# setup libpostal
Geo::libpostal::setup();

# cleanup libpostal
END { Geo::libpostal::teardown() }

1;

__END__
=encoding utf8

=head1 NAME

Geo::libpostal - Perl bindings for libpostal

=head1 SYNOPSIS

  use Geo::libpostal qw/parse_address expand_address/;

  # normalize an address
  my @addresses = expand_address('Quatre-vingt-douze Ave des Champs-Élysées');

  # parse addresses into their components
  my %address = parse_address('The Book Club 100-106 Leonard St Shoreditch London EC2A 4RH, United Kingdom');

  # %address contains:
  # (
  #   'road'         => 'leonard st',
  #   'postcode'     => 'ec2a 4rh',
  #   'house'        => 'the book club',
  #   'house_number' => '100-106',
  #   'suburb'       => 'shoreditch',
  #   'country'      => 'united kingdom',
  #   'city'         => 'london'
  # );

=head1 WARNING

libpostal uses C<setup()> and C<teardown()> functions - you may see delays in
start and end of your program due to this.

Currently this module just loads the default libpostal config.

=head1 SEE ALSO

L<libpostal|https://github.com/openvenues/libpostal> is required.

=head1 AUTHOR

E<copy> 2016 David Farrell

=head1 LICENSE

See LICENSE

=cut
