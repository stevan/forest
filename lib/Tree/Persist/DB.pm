package Tree::Persist::DB;

use strict;
use warnings;

use base qw( Tree::Persist::Base );

sub new {
    my $class = shift;
    my ($opts) = @_;

    my $self = $class->SUPER::new( $opts );

    $self->{_dbh} = $opts->{dbh};
    $self->{_table} = $opts->{table};
    $self->{_actions} = [];

    return $self;
}

sub commit {
    my $self = shift;

    return unless $self->{_changes};

    $self->_commit;

    $self->{_changes} = 0;

    return $self;
}

sub _remove_child_handler {
    my $self = shift;

    return sub {
        $self->{_changes}++;
        $self->commit if $self->autocommit;
    };
}

1;
__END__
