use 5.008001;
use strict;
use warnings;

use Test::More 0.96;

use lib 't/lib';
use TestUtils;

use BSON qw/encode decode/;
use BSON::Types qw/bson_double/;

my ($hash);

# double -> double
$hash = decode( encode( { A => 3.14159 } ) );
is( sv_type( $hash->{A} ), 'NV', "double->double" );
packed_is( "d", $hash->{A}, 3.14159, "value correct" );

# BSON::Double -> double
$hash = decode( encode( { A => bson_double(3.14159) } ) );
is( sv_type( $hash->{A} ), 'NV', "BSON::Double->double" );
packed_is( "d", $hash->{A}, 3.14159, "value correct" );

# double -> BSON::Double
$hash = decode( encode( { A => 3.14159 } ), wrap_numbers => 1 );
is( ref( $hash->{A} ), 'BSON::Double', "double->BSON::Double" );
packed_is( "d", $hash->{A}->value, 3.14159, "value correct" );

# BSON::Double -> BSON::Double
$hash = decode( encode( { A => bson_double(3.14159) } ), wrap_numbers => 1 );
is( ref( $hash->{A} ), 'BSON::Double', "BSON::Double->BSON::Double" );
packed_is( "d", $hash->{A}->value, 3.14159, "value correct" );

# test overloading
packed_is( "d", $hash->{A}, 3.14159, "value correct" );

done_testing;

# COPYRIGHT
#
# vim: set ts=4 sts=4 sw=4 et tw=75:
