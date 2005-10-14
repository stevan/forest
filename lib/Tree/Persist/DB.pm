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

    return $self;
}

sub commit {
    my $self = shift;

    return unless $self->{_changes};

    $self->_commit;

    $self->{_changes} = 0;

    return $self;
}

1;
__END__
