package Tree::Persist::Base;

use Scalar::Util qw( blessed );

sub new {
    my $class = shift;
    my ($opts) = @_;

    my $self = bless {
        _tree => (exists $opts->{tree} ? $opts->{tree} : undef),
        _autocommit => (exists $opts->{autocommit} ? $opts->{autocommit} : 1),
        _changes => 0,
    }, $class;

    return $self;
}

sub autocommit {
    my $self = shift;

    return 0 unless blessed $self;

    if ( @_ ) {
        (my $old, $self->{_autocommit}) = ($self->{_autocommit}, shift );
        return $old;
    }
    else {
        return $self->{_autocommit};
    }
}

sub rollback {
    my $self = shift;

    $self->reload if $self->{_changes};

    $self->{_changes} = 0;

    return $self;
}

sub tree {
    my $self = shift;
    return $self->{_tree};
}

1;
__END__
