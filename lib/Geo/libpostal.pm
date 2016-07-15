package Geo::libpostal;
use strict;
use warnings;
use XSLoader;
use Exporter 5.57 'import';

our $VERSION     = '0.03';
our %EXPORT_TAGS = ( 'all' => ['expand_address', 'parse_address'] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );

XSLoader::load('Geo::libpostal', $VERSION);

# cleanup libpostal
END { _teardown() }

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
  #   road         => 'leonard st',
  #   postcode     => 'ec2a 4rh',
  #   house        => 'the book club',
  #   house_number => '100-106',
  #   suburb       => 'shoreditch',
  #   country      => 'united kingdom',
  #   city         => 'london'
  # );

=head1 DESCRIPTION

libpostal is a C library for parsing/normalizing international street addresses.

Address strings can be normalized using C<expand_address> which returns a list
of valid variations so you can check for duplicates in your dataset. It
supports normalization in over L<60 languages|https://github.com/openvenues/libpostal/tree/master/resources/dictionaries>.

An address string can also be parsed into its constituent parts using
C<parse_address> such as house name, number, city and postcode.

=head1 FUNCTIONS

=head2 expand_address

  use Geo::libpostal 'expand_address';

  my @ny_addresses = expand_address('120 E 96th St New York');
  my @fr_addresses = expand_address('Quatre vingt douze R. de l\'Église');

Takes an address string and returns a list of known variants. Useful for
normalization. Accepts many boolean options:

  expand_address('120 E 96th St New York',
      latin_ascii => 1,
      transliterate => 1,
      strip_accents => 1,
      decompose => 1,
      lowercase => 1,
      trim_string => 1,
      drop_parentheticals => 1,
      replace_numeric_hyphens => 1,
      delete_numeric_hyphens => 1,
      split_alpha_from_numeric => 1,
      replace_word_hyphens => 1,
      delete_word_hyphens => 1,
      delete_final_periods => 1,
      delete_acronym_periods => 1,
      drop_english_possessives => 1,
      delete_apostrophes => 1,
      expand_numex => 1,
      roman_numerals => 1,
  );

B<Warning>: libpostal L<segfaults|https://github.com/openvenues/libpostal/issues/79> if all options are set to false.

Also accepts an arrayref of language codes per L<ISO 639-1|https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes>:

 expand_address('120 E 96th St New York', languages => [qw(en fr)]);

This is useful if you are normalizing addresses in multiple languages.

Will C<die> on C<undef> and empty addresses, odd numbers of options and
unrecognized options. Exported on request.

=head2 parse_address

  use Geo::libpostal 'parse_address';

  my %ny_address = parse_address('120 E 96th St New York');
  my %fr_address = parse_address('Quatre vingt douze R. de l\'Église');

#################################################
# options are ignored by libpostal
# https://github.com/openvenues/libpostal/blob/e816b4f77e8c6a7f35207ca77282ffab3712c5b6/src/address_parser.c#L837
# ##############################################
# Takes an address string and parses it, returning a list of labels and values.
# Accepts two optional named parameters:
# 
# =over 4
# 
# =item *
# 
# C<language> - 2 character language code per L<ISO 639-1|https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes>
# 
# =item *
# 
# C<country> - 2 character country code per L<ISO 3166-1 alpha-2|https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2>
# 
# =back
# 
# Currently these are ignored by libpostal!
# 
# Will C<die> on C<undef> and empty addresses, odd numbers of options and
# unrecognized options. Exported on request.

Will C<die> on C<undef> and empty addresses. Exported on request.

C<parse_address()> may return L<duplicate labels|https://github.com/openvenues/libpostal/issues/27> for invalid addresses
strings.

=head1 WARNING

libpostal uses C<setup()> and C<teardown()> functions. Setup is lazily
loaded. Teardown occurs in an C<END> block automatically. C<Geo::libpostal>
will C<die> if C<expand_address> or C<parse_address> is called after teardown.

=head1 EXTERNAL DEPENDENCIES

L<libpostal|https://github.com/openvenues/libpostal> is required.

=head1 INSTALLATION

You can install this module with CPAN:

  $ cpan Geo::libpostal

Or clone it from GitHub and install it manually:

  $ git clone https://github.com/dnmfarrell/Geo-libpostal
  $ cd Geo-libpostal
  $ perl Makefile.PL
  $ make
  $ make test
  $ make install

=head1 AUTHOR

E<copy> 2016 David Farrell

=head1 LICENSE

See LICENSE

=cut
