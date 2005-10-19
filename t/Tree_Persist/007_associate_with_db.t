use strict;
use warnings;

use Test::More;

use t::tests qw( %runs );

plan tests => 5 + 1 * $runs{stats}{plan};

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

use DBI;
my $dbh = DBI->connect(
    'dbi:mysql:tree', 'tree', 'tree', {
        AutoCommit => 1,
        RaiseError => 1,
        PrintError => 0,
    },
);

$dbh->do( <<"__END_SQL__" );
CREATE TEMPORARY TABLE 007_tree (
    id INT NOT NULL PRIMARY KEY
   ,parent_id INT REFERENCES 007_tree (id)
   ,value VARCHAR(255)
   ,class VARCHAR(255)
)
__END_SQL__

$dbh->do( <<"__END_SQL__" );
INSERT INTO 007_tree
    ( id, parent_id, value, class )
VALUES
    ( 1, NULL, "root", "Tree" )
__END_SQL__

sub get_values {
    my $dbh = shift;

    my $sth = $dbh->prepare_cached( "SELECT * FROM 007_tree ORDER BY id" );
    $sth->execute;
    return $sth->fetchall_arrayref( {} );
}

{
    my $persist = $CLASS->connect({
        type  => 'DB',
        dbh   => $dbh,
        table => '007_tree',
        id    => 1,
    });

    my $tree = $persist->tree;

    $runs{stats}{func}->( $tree,
        height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
    );
    is( $tree->value, 'root', "The tree's value was loaded correctly" );

    my $child = Tree->new( 'child' );
    $tree->add_child( $child );

    my $values = get_values( $dbh );
    is_deeply(
        $values,
        [
            { id => 1, parent_id => undef, class => 'Tree', value => 'root' },
            { id => 2, parent_id =>     1, class => 'Tree', value => 'child' },
        ],
        "After first add_child, everything ok",
    );

    my $child2 = Tree->new( 'child2' );
    $tree->add_child( $child2 );

    $values = get_values( $dbh );
    is_deeply(
        $values,
        [
            { id => 1, parent_id => undef, class => 'Tree', value => 'root' },
            { id => 2, parent_id =>     1, class => 'Tree', value => 'child' },
            { id => 3, parent_id =>     1, class => 'Tree', value => 'child2' },
        ],
        "After second add_child, everything ok",
    );

    $tree->remove_child( $child );

    $values = get_values( $dbh );
    is_deeply(
        $values,
        [
            { id => 1, parent_id => undef, class => 'Tree', value => 'root' },
            { id => 2, parent_id => undef, class => 'Tree', value => 'child' },
            { id => 3, parent_id =>     1, class => 'Tree', value => 'child2' },
        ],
        "After first remove_child, everything ok",
    );
}
__END__

    $child2->value( 'New value' );

__END_FILE__
}

