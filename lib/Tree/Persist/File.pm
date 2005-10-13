package Tree::Persist::File;

use Tree::Persist::Base;
our @ISA = qw( Tree::Persist::Base );

use Scalar::Util qw( blessed );

sub new {
    my $class = shift;
    my ($opts) = @_;

    my $self = $class->SUPER::new( $opts );

    $self->{_filename} = $opts->{filename};

    return $self;
}

sub commit {
    my $self = shift;

    return unless $self->{_changes};

    open my $fh, '>', $self->{_filename}
        or die "Cannot open '$self->{_filename}' for writing: $!\n";

    print $fh $self->_build_string( $self->{_tree} );

    close $fh;

    $self->{_changes} = 0;

    return $self;
}

1;
__END__
