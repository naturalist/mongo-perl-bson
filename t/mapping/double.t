use 5.008001;
use strict;
use warnings;

use Test::More 0.96;

use lib 't/lib';
use TestUtils;

use BSON qw/encode decode/;
use BSON::Types qw/bson_double/;

use JSON::MaybeXS;

my ($hash);

# test constructor
packed_is( "d", bson_double(), 0.0, "empty bson_double() is 0.0" );
packed_is( "d", BSON::Double->new, 0.0, "empty constructor is 0.0" );

# test overloading
packed_is( "d", bson_double(3.14159), 3.14159, "overloading correct" );

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

# test special doubles
for my $s ( qw/Inf -Inf NaN/ ) {
    $hash = decode( encode( { A => $s/1.0 } ) );
    is( sv_type( $hash->{A} ), 'PVNV', "$s as double->double" );
    packed_is( "d", $hash->{A}, $s/1.0, "value correct" );
}

for my $s ( qw/Inf -Inf NaN/ ) {
    $hash = decode( encode( { A => $s/1.0 } ), wrap_numbers => 1 );
    is( ref( $hash->{A} ), 'BSON::Double', "$s as double->BSON::Double" )
        or diag explain $hash;
    packed_is( "d", $hash->{A}, $s/1.0, "value correct" );
}

# test special BSON::Double
for my $s ( qw/Inf -Inf NaN/ ) {
    $hash = decode( encode( { A => bson_double($s) } ) );
    is( sv_type( $hash->{A} ), 'PVNV', "$s as BSON::Double->BSON::Double" );
    packed_is( "d", $hash->{A}, $s/1.0, "value correct" );
}

for my $s ( qw/Inf -Inf NaN/ ) {
    $hash = decode( encode( { A => bson_double($s) } ), wrap_numbers => 1 );
    is( ref( $hash->{A} ), 'BSON::Double', "$s as BSON::Double->BSON::Double" )
        or diag explain $hash;
    packed_is( "d", $hash->{A}, $s/1.0, "value correct" );
}

# to JSON
is( to_myjson({a=>bson_double(0.0)}), q[{"a":0}], 'bson_double(0.0) (XXX lossy!)' );
is( to_myjson({a=>bson_double(42)}), q[{"a":42}], 'bson_double(42) (XXX lossy!)' );
is( to_myjson({a=>bson_double(0.1)}), q[{"a":0.1}], 'bson_double(0.1)' );
eval { to_myjson({a=>bson_double("Inf"/1.0)}) };
like( $@, qr/illegal in JSON/, 'throws: bson_double("Inf"/1.0)' );

# to extended JSON; XXX not implemented yet by mognod;
# see https://jira.mongodb.org/browse/SERVER-23204
##is( to_extjson({a=>bson_double(0.0)}), q[{"a":0}], 'extjson: bson_double(0.0) (XXX lossy!)' );
##is( to_extjson({a=>bson_double(42)}), q[{"a":42}], 'extjson: bson_double(42) (XXX lossy!)' );
##is( to_extjson({a=>bson_double(0.1)}), q[{"a":0.1}], 'extjson: bson_double(0.1)' );
##is( to_extjson({a=>bson_double("Inf"/1.0)}), q[{"a":{"$numberDouble":"Inf"}}], 'extjson: bson_double("Inf"/1.0)' );

done_testing;

# COPYRIGHT
#
# vim: set ts=4 sts=4 sw=4 et tw=75:
