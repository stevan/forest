use strict;
use warnings;

use Test::More;

#use t::tests qw( %runs );

plan tests => 5;

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

use_ok( 'Tree' );

use DBI;
my $dbh = DBI->connect(
    'dbi:mysql:tree', 'tree', 'tree', {
        AutoCommit => 1,
        RaiseError => 1,
        PrintError => 0,
    },
);

$dbh->do( <<"__END_SQL__" );
CREATE TEMPORARY TABLE 006_tree (
    id INT NOT NULL PRIMARY KEY
   ,parent_id INT REFERENCES 006_tree (id)
   ,class VARCHAR(255) NOT NULL
   ,value VARCHAR(255)
)
__END_SQL__

$dbh->do( <<"__END_SQL__" );
INSERT INTO 006_tree
    ( id, parent_id, value, class )
VALUES 
    ( 1, NULL, 'root', 'Tree' )
   ,( 2, NULL, 'root2', 'Tree' )
   ,( 3, 2, 'child', 'Tree' )
__END_SQL__

sub get_values {
    my $dbh = shift;

    my $sth = $dbh->prepare_cached( "SELECT * FROM 006_tree WHERE id > 3 ORDER BY id" );
    $sth->execute;
    return $sth->fetchall_arrayref( {} );
}

{
    my $tree = Tree->new( 'root' );

    my $persist = $CLASS->create_datastore({
        type  => 'DB',
        tree  => $tree,
        dbh   => $dbh,
        table => '006_tree',
    });

    my $values = get_values( $dbh );
    is_deeply(
        $values,
        [
            { id => 4, parent_id => undef, class => 'Tree', value => 'root' },
        ],
        "We got back what we put in.",
    );

    $dbh->do( "DELETE FROM 006_tree WHERE id > 3" );
}

{
    my $tree = Tree->new( 'A' )->add_child(
        Tree->new( 'B' ),
        Tree->new( 'C' )->add_child(
            Tree->new( 'D' ),
        ),
        Tree->new( 'E' ),
    );

    my $persist = $CLASS->create_datastore({
        type  => 'DB',
        tree  => $tree,
        dbh   => $dbh,
        table => '006_tree',
    });

    my $values = get_values( $dbh );
    is_deeply(
        $values,
        [
            { id => 4, parent_id => undef, class => 'Tree', value => 'A' },
            { id => 5, parent_id =>     4, class => 'Tree', value => 'B' },
            { id => 6, parent_id =>     4, class => 'Tree', value => 'C' },
            { id => 7, parent_id =>     4, class => 'Tree', value => 'E' },
            { id => 8, parent_id =>     6, class => 'Tree', value => 'D' },
        ],
        "We got back what we put in.",
    );

    $dbh->do( "DELETE FROM 006_tree WHERE id > 3" );
}

{
    my $tree = Tree->new( 'A' )->add_child(
        Tree->new( 'B' ),
        Tree->new( 'C' )->add_child(
            Tree->new( 'D' ),
            Tree->new( 'E' ),
        ),
    );

    my $persist = $CLASS->create_datastore({
        type  => 'DB',
        tree  => $tree,
        dbh   => $dbh,
        table => '006_tree',
    });

    my $values = get_values( $dbh );
    is_deeply(
        $values,
        [
            { id => 4, parent_id => undef, class => 'Tree', value => 'A' },
            { id => 5, parent_id =>     4, class => 'Tree', value => 'B' },
            { id => 6, parent_id =>     4, class => 'Tree', value => 'C' },
            { id => 7, parent_id =>     6, class => 'Tree', value => 'D' },
            { id => 8, parent_id =>     6, class => 'Tree', value => 'E' },
        ],
        "We got back what we put in.",
    );

    $dbh->do( "DELETE FROM 006_tree WHERE id > 3" );
}
