package Tree::Persist::File;

use strict;
use warnings;

use base qw( Tree::Persist::Base );

use Scalar::Util qw( blessed );

sub new {
    my $class = shift;
    my ($opts) = @_;

    my $self = $class->SUPER::new( $opts );

    $self->{_filename} = $opts->{filename};

    return $self;
}

sub _create {
    my $self = shift;

    open my $fh, '>', $self->{_filename}
        or die "Cannot open '$self->{_filename}' for writing: $!\n";

    print $fh $self->_build_string( $self->{_tree} );

    close $fh;

    return $self;
}

*_commit = \&_create;

1;
__END__
