use strict;
use warnings;

use Test::More;

use t::tests qw( %runs );

plan tests => 5 + 2 * $runs{stats}{plan};

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

my $persist = $CLASS->new(
);

my $tree = $persist->load(
    't/datafiles/tree1.xml',
);

isa_ok( $tree, 'Tree' );

$runs{stats}{func}->( $tree,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);
is( $tree->value, 'root', "The tree's value was loaded correctly" );

my $tree2 = $persist->load(
    't/datafiles/tree2.xml',
);

isa_ok( $tree2, 'Tree' );

$runs{stats}{func}->( $tree2,
    height => 2, width => 1, depth => 0, size => 2, is_root => 1, is_leaf => 0,
);
is( $tree2->value, 'root2', "The tree's value was loaded correctly" );
