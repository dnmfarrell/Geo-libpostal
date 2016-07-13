package Geo::libpostal;
use strict;
use warnings;
use XSLoader;
use Exporter 5.57 'import';

our $VERSION     = '0.02';
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

  use Geo::libpostal ':all';

  # normalize an address
  my @addresses = expand_address('120 E 96th St New York');

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

=head1 FUNCTIONS

=head2 expand_address

  use Geo::libpostal 'expand_address';

  my @ny_addresses = expand_address('120 E 96th St New York');

  my @fr_addresses = expand_address('Quatre vingt douze R. de l\'Église');

Takes an address string and returns a list of known variants. Useful for
normalization. Dies on C<undef> and empty strings. Exported on request.

=head2 parse_address

  use Geo::libpostal 'parse_address';

  my %ny_address = parse_address('120 E 96th St New York');

  my %fr_address = parse_address(
    'Quatre vingt douze R. de l\'Église',
    language => 'fr',
    country  => 'FR',
  );

Takes an address string and parses it, returning a list of labels and values.
Accepts two optional named parameters:

=over 4

=item *

C<language> - 2 character language code per L<ISO 639-1|https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes>

=item *

C<country> - 2 character country code per L<ISO 3166-1 alpha-2|https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2>

=back

Will C<die> on C<undef> and empty addresses, odd numbers of options and
unrecognized options. Exported on request.

=head1 WARNING

libpostal uses C<setup()> and C<teardown()> functions - you may see delays in
start and end of your program due to this. Setup fires as soon as this module
is imported. Teardown occurs in an C<END> block automatically.

=head1 EXTERNAL DEPENDENCIES

L<libpostal|https://github.com/openvenues/libpostal> is required.

=head1 AUTHOR

E<copy> 2016 David Farrell

=head1 LICENSE

See LICENSE

=cut
