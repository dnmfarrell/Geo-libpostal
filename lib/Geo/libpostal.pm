package Geo::libpostal;

use strict;
use warnings;
use XSLoader;

use Exporter 5.57 'import';

our $VERSION     = '0.01';
our %EXPORT_TAGS = ( 'all' => [] );
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

=head1 DESCRIPTION

This is a embryonic stage release - no useful functions exposed yet. Do not use.

=head1 AUTHOR

E<copy> 2016 David Farrell

=head1 LICENSE

See LICENSE

=cut
