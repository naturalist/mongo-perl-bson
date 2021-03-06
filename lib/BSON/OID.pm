use 5.008001;
use strict;
use warnings;

package BSON::OID;
# ABSTRACT: BSON type wrapper for Object IDs

our $VERSION = '0.17';

use Carp;
use Digest::MD5 'md5';
use Sys::Hostname;
use threads::shared; # NOP if threads.pm not loaded

# OID generation
{
    my $_inc : shared;
    {
        lock($_inc);
        $_inc = int( rand(0xFFFFFF) );
    }

    my $_host = substr( md5(hostname), 0, 3 );

    #<<<
    sub _packed_oid {
        return pack(
            'Na3na3', time, $_host, $$ % 0xFFFF,
            substr( pack( 'N', do { lock($_inc); $_inc++; $_inc %= 0xFFFFFF }), 1, 3)
        );
    }
    #>>>

    # see if v1.x MongoDB::BSON can do OIDs for us
    BEGIN {
        if ( $INC{'MongoDB'} && MongoDB::BSON->can('generate_oid') ) {
            *generate_oid = sub { pack( "H*", MongoDB::BSON::generate_oid() ) };
        }
        else {
            *generate_oid = \&_packed_oid;
        }
    }
}

use Class::Tiny { oid => \&generate_oid };

sub BUILD {
    my ($self) = @_;
    croak "Invalid 'oid' field: OIDs must be 12 bytes"
      unless length( $self->oid ) == 12;
    return;
}

sub hex {
    my ($self) = @_;
    return defined $self->{hex}
      ? $self->{hex}
      : ( $self->{hex} = unpack( "H*", $self->{oid} ) );
}

sub get_time {
    return unpack( "N", substr( $_[0]->{oid}, 0, 4 ) );
}

# for testing purposes
sub _get_pid {
    return unpack( "n", substr( $_[0]->{oid}, 7, 2 ) );
}

=method TO_JSON

Returns a string for this OID, with the OID given as 24 hex digits.

If the C<BSON_EXTJSON> option is true, it will instead be compatible with
MongoDB's L<extended JSON|https://docs.mongodb.org/manual/reference/mongodb-extended-json/>
format, which represents it as a document as follows:

    {"$oid" : "012345678901234567890123"}

=cut

sub TO_JSON {
    return $_[0]->hex unless $ENV{BSON_EXTJSON};
    return {'$oid' => $_[0]->hex };
}


BEGIN {
    *to_string = \&hex;
    *value = \&hex;
}

use overload (
    '""'     => \&hex,
    fallback => 1,
);

1;

__END__

=for Pod::Coverage op_eq to_s

=head1 SYNOPSIS

    use BSON::Types;

    my $oid  = bson_oid();

    my $bytes = $oid->oid;
    my $hex   = $oid->hex;

=head1 DESCRIPTION

This module provides a wrapper around Object ID.  It will create new ones if
no C<oid> argument is provided to the constructor.

=head1 OVERLOAD

The string operator is overloaded so any string operations will actually use
the 24-character hex value of the OID.

=head1 THREADS

This module is thread safe.

=head1 SEE ALSO

L<BSON>

=cut
