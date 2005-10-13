use strict;
use warnings;

use Test::More;

use t::tests qw( %runs );

plan tests => 3 + 1 * $runs{stats}{plan};

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
        type => 'DB',
        dbh => $dbh,
    });

    my $tree = $persist->tree();

    TODO: {
        local $TODO = "Unimplemented yet";
        isa_ok( $tree, 'Tree' );

        SKIP: {
            skip "Not done yet", 1 + 1 * $runs{stats}{plan};
            $runs{stats}{func}->( $tree,
                height => 1, width => 1, depth => 0,
                size => 1, is_root => 1, is_leaf => 1,
            );
            is( $tree->value, 'root', "The tree's value was loaded correctly" );
        }
    }
}
