package Tree::Persist::DB::SelfReferential;

use strict;
use warnings;

use base qw( Tree::Persist::DB );

use Tree;

sub new {
    my $class = shift;
    my ($opts) = @_;

    my $self = $class->SUPER::new( $opts );

    $self->{_id} = $opts->{id};

    $self->{_id_col} = 'id';
    $self->{_parent_id_col} = 'parent_id';
    $self->{_value_col} = 'value';
    $self->{_class_col} = 'class';

    return $self;
}

sub reload {
    my $self = shift;

    my %sql = $self->_build_sql;

    my $sth = $self->{_dbh}->prepare( $sql{ fetch } );
    $sth->execute( $self->{_id} );

    my ($id, $parent, $class, $value) = $sth->fetchrow_array();

    $sth->finish;

    my $tree = $class->new( $value );
    $self->set_tree( $tree );

    $self->{_mapping} = {
        $id => $tree,
    };

    my @parents = ( $id );
    while ( my $parent_id = shift @parents ) {
        my $sth_child = $self->{_dbh}->prepare( $sql{ fetch_children } );
        $sth_child->execute( $parent_id );

        my $parent = $self->{_mapping}{ $parent_id };

        $sth_child->bind_columns( \my ($id, $class, $value) );

        while ($sth_child->fetch) {
            my $node = $class->new( $value );
            $parent->add_child( $node );
            push @parents, $id;
            $self->{_mapping}{$id} = $node;
        }

        $sth_child->finish;
    }

    return $self;
}

sub _build_sql {
    my $self = shift;

    my %sql = (
        fetch => <<"__END_SQL__",
SELECT $self->{_id_col}        AS id
      ,$self->{_parent_id_col} AS parent_id
      ,$self->{_class_col}     AS class
      ,$self->{_value_col}     AS value
  FROM $self->{_table} AS tree
 WHERE tree.$self->{_id_col} = ?
__END_SQL__
        fetch_children => <<"__END_SQL__",
SELECT $self->{_id_col}        AS id
      ,$self->{_class_col}     AS class
      ,$self->{_value_col}     AS value
  FROM $self->{_table} AS tree
 WHERE tree.$self->{_parent_id_col} = ?
__END_SQL__
    );

    return %sql;
}

1;
__END__
