use strict;
use warnings;

use Test::More tests => 7;

my $CLASS = 'Tree';
use_ok( $CLASS );

# Test plan:
# 1) Create with an empty new().
# TODO: 2) Create with an explicit parent => undef

my $tree = $CLASS->new();
isa_ok( $tree, $CLASS );

ok( $tree->is_root, "Node without a parent knows it's a root" );
ok( $tree->is_leaf, "Node without a child knows it's a leaf" );

my $parent = $tree->parent;
is( $parent, $tree->_null, "The root's parent is the null node" );

ok( $tree->height == 1, "A tree with just a root has a height of 1" );
ok( $tree->width == 1, "A tree with just a root has a width of 1" );
