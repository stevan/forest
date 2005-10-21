use strict;
use warnings;

use Test::More;

use t::tests qw( %runs );

plan tests => 6 + 3 * $runs{stats}{plan};

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
CREATE TEMPORARY TABLE 005_tree (
    id INT NOT NULL PRIMARY KEY
   ,parent_id INT REFERENCES 005_tree (id)
   ,class VARCHAR(255) NOT NULL
   ,value VARCHAR(255)
)
__END_SQL__

$dbh->do( <<"__END_SQL__" );
INSERT INTO 005_tree
    ( id, parent_id, value, class )
VALUES 
    ( 1, NULL, 'root', 'Tree' )
   ,( 2, NULL, 'root2', 'Tree' )
   ,( 3, 2, 'child', 'Tree' )
__END_SQL__

{
    my $persist = $CLASS->connect({
        type  => 'DB',
        dbh   => $dbh,
        table => '005_tree',
        id    => 1,
    });

    my $tree = $persist->tree();
    isa_ok( $tree, 'Tree' );

    $runs{stats}{func}->( $tree,
        height => 1, width => 1, depth => 0,
        size => 1, is_root => 1, is_leaf => 1,
    );
    is( $tree->value, 'root', "The tree's value was loaded correctly" );
}

{
    my $persist = $CLASS->connect({
        type  => 'DB',
        dbh   => $dbh,
        table => '005_tree',
        id    => 2,
    });

    my $tree = $persist->tree();

    isa_ok( $tree, 'Tree' );

    $runs{stats}{func}->( $tree,
        height => 2, width => 1, depth => 0, size => 2, is_root => 1, is_leaf => 0,
    );
    is( $tree->value, 'root2', "The tree's value was loaded correctly" );

    my ($child) = $tree->children;

    $runs{stats}{func}->( $child,
        height => 1, width => 1, depth => 1, size => 1, is_root => 0, is_leaf => 1,
    );
    is( $child->value, 'child', "The tree's value was loaded correctly" );
}
