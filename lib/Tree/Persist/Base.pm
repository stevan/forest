package Tree::Persist::Base;

use strict;
use warnings;

use Scalar::Util qw( blessed );

sub new {
    my $class = shift;
    my ($opts) = @_;

    my $self = bless {
        _tree => undef,
        _autocommit => (exists $opts->{autocommit} ? $opts->{autocommit} : 1),
        _changes => 0,
    }, $class;

    if ( exists $opts->{tree} ) {
        $self->set_tree( $opts->{tree} );
    }

    return $self;
}

sub autocommit {
    my $self = shift;

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

sub set_tree {
    my $self = shift;
    my ($value) = @_;

    $self->{_tree} = $value;

    $self->_install_handlers;

    return $self;
}

sub _install_handlers {
    my $self = shift;

    $self->{_tree}->add_event_handler({
        add_child    => $self->_add_child_handler,
        remove_child => $self->_remove_child_handler,
        value        => $self->_value_handler,
    });

    return $self;
}

sub _add_child_handler {
    my $self = shift;
    return sub {
        $self->{_changes}++;
        $self->commit if $self->autocommit;
    };
}

sub _remove_child_handler {
    my $self = shift;
    return sub {
        $self->{_changes}++;
        $self->commit if $self->autocommit;
    };
}

sub _value_handler {
    my $self = shift;
    return sub {
        $self->{_changes}++;
        $self->commit if $self->autocommit;
    };
}

1;
__END__
