use strict;
use warnings;

use Test::More;

use t::tests qw( %runs );

plan tests => 5 + 2 * $runs{stats}{plan};

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

{
    my $persist = $CLASS->connect({
        type  => 'DB',
        dbh   => $dbh,
        table => 'tree',
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
        table => 'tree',
        id    => 2,
    });

    my $tree = $persist->tree();

    isa_ok( $tree, 'Tree' );

    $runs{stats}{func}->( $tree,
        height => 2, width => 1, depth => 0, size => 2, is_root => 1, is_leaf => 0,
    );
    is( $tree->value, 'root2', "The tree's value was loaded correctly" );
}
