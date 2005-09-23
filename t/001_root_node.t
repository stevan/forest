use strict;
use warnings;

use Test::More tests => 34;

my $CLASS = 'Tree';
use_ok( $CLASS );

# Test plan:
# 1) Create with an empty new().
# 2) Create with a payload passed into new().
# 3) Create with 2 parameters passed into new().

{
    my $tree = $CLASS->new();
    isa_ok( $tree, $CLASS );

    ok( $tree->is_root, "Node without a parent knows it's a root" );
    ok( $tree->is_leaf, "Node without a child knows it's a leaf" );

    my $parent = $tree->parent;
    is( $parent, $tree->_null, "The root's parent is the null node" );

    cmp_ok( $tree->height, '==', 1, "A tree with just a root has a height of 1" );
    cmp_ok( $tree->width, '==', 1, "A tree with just a root has a width of 1" );
    cmp_ok( $tree->depth, '==', 0, "A tree with just a root has a depth of 0" );

    is( $tree->root, $tree, "The root's root is itself" );

    is( $tree->value, undef, "The root's value is undef" );
    is( $tree->value( 'foobar' ), 'foobar', "Setting value() returns the value passed in" );
    is( $tree->value(), 'foobar', "Setting value() returns the value passed in" );
}

{
    my $tree = $CLASS->new( 'payload' );
    isa_ok( $tree, $CLASS );

    ok( $tree->is_root, "Node without a parent knows it's a root" );
    ok( $tree->is_leaf, "Node without a child knows it's a leaf" );

    my $parent = $tree->parent;
    is( $parent, $tree->_null, "The root's parent is the null node" );

    cmp_ok( $tree->height, '==', 1, "A tree with just a root has a height of 1" );
    cmp_ok( $tree->width, '==', 1, "A tree with just a root has a width of 1" );
    cmp_ok( $tree->depth, '==', 0, "A tree with just a root has a depth of 0" );

    is( $tree->root, $tree, "The root's root is itself" );
    is( $tree->value, 'payload', "The root's value is undef" );
    is( $tree->value( 'foobar' ), 'foobar', "Setting value() returns the value passed in" );
    is( $tree->value(), 'foobar', "Setting value() returns the value passed in" );
}

{
    my $tree = $CLASS->new( 'payload', 'unused value' );
    isa_ok( $tree, $CLASS );

    ok( $tree->is_root, "Node without a parent knows it's a root" );
    ok( $tree->is_leaf, "Node without a child knows it's a leaf" );

    my $parent = $tree->parent;
    is( $parent, $tree->_null, "The root's parent is the null node" );

    cmp_ok( $tree->height, '==', 1, "A tree with just a root has a height of 1" );
    cmp_ok( $tree->width, '==', 1, "A tree with just a root has a width of 1" );
    cmp_ok( $tree->depth, '==', 0, "A tree with just a root has a depth of 0" );

    is( $tree->root, $tree, "The root's root is itself" );
    is( $tree->value, 'payload', "The root's value is undef" );
    is( $tree->value( 'foobar' ), 'foobar', "Setting value() returns the value passed in" );
    is( $tree->value(), 'foobar', "Setting value() returns the value passed in" );
}
