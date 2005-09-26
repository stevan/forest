use strict;
use warnings;

use Test::More tests => 72;

my $CLASS = 'Tree';
use_ok( $CLASS );

# Test Plan:
# 1) Add two children at once to a root node.
# 2) Verify
# 3) Remove one child
# 4) Verify that the other child is still a child of the root
# 5) Add the removed child back, then remove both to test removing multiple children

my $root = $CLASS->new( '1' );
isa_ok( $root, $CLASS );

my $child1 = $CLASS->new( '1.1' );
isa_ok( $child1, $CLASS );

my $child2 = $CLASS->new( '1.2' );
isa_ok( $child2, $CLASS );

ok( $root->is_root, "The root is a root node" );
ok( $root->is_leaf, "The root is a leaf node" );
ok( $child1->is_root, "The child1 is a root node" );
ok( $child1->is_leaf, "The child1 is a leaf node" );
ok( $child2->is_root, "The child2 is a root node" );
ok( $child2->is_leaf, "The child2 is a leaf node" );

is( $root->add_child( $child1, $child2 ), $root, "add_child(\@many) still chains" );

ok( $root->is_root, "The root is a root node" );
ok( !$root->is_leaf, "The root is not a leaf node" );
ok( !$child1->is_root, "The child1 is not a root node" );
ok( $child1->is_leaf, "The child1 is a leaf node" );
ok( !$child2->is_root, "The child2 is not a root node" );
ok( $child2->is_leaf, "The child2 is a leaf node" );

cmp_ok( $root->children, '==', 2, "The root has two children" );

ok( $root->has_child( $child1 ), "The root has child1" );
ok( $root->has_child( $child2 ), "The root has child2" );
ok( $root->has_child( $child1, $child2 ), "The root has both children" );

cmp_ok( $root->height, '==', 2, "The root's height is two." );
cmp_ok( $child1->height, '==', 1, "The child1's height is one." );
cmp_ok( $child2->height, '==', 1, "The child2's height is one." );

cmp_ok( $root->width, '==', 2, "The root's width is two." );
cmp_ok( $child1->width, '==', 1, "The child1's width is one." );
cmp_ok( $child2->width, '==', 1, "The child2's width is one." );

cmp_ok( $root->depth, '==', 0, "The root's depth is zero." );
cmp_ok( $child1->depth, '==', 1, "The child1's depth is one." );
cmp_ok( $child2->depth, '==', 1, "The child2's depth is one." );

cmp_ok( $root->size, '==', 3, "The root's size is three." );
cmp_ok( $child1->size, '==', 1, "The child1's size is one." );
cmp_ok( $child2->size, '==', 1, "The child2's size is one." );

my @v = $root->children(1, 0);
cmp_ok( @v, '==', 2, "Accessing children() by index out of order gives both back" );
is( $v[0], $child2, "... the first child is correct" );
is( $v[1], $child1, "... the second child is correct" );

$root->remove_child( $child1 );
cmp_ok( $root->children, '==', 1, "After removing child1, the root has one child" );
my @children = $root->children;
is( $children[0], $child2, "... and the right child is still there" );

ok( !$root->has_child( $child1 ), "The root doesn't have child1" );
ok( $root->has_child( $child2 ), "The root has child2" );
ok( !$root->has_child( $child1, $child2 ), "The root doesn't have both children" );
ok( !$root->has_child( $child2, $child1 ), "The root doesn't have both children (reversed)" );

cmp_ok( $root->height, '==', 2, "The root's height is still two." );
cmp_ok( $child1->height, '==', 1, "The child1's height is still one." );
cmp_ok( $child2->height, '==', 1, "The child2's height is still one." );

cmp_ok( $root->width, '==', 1, "The root's width is now one." );
cmp_ok( $child1->width, '==', 1, "The child1's width is one." );
cmp_ok( $child2->width, '==', 1, "The child2's width is one." );

$root->add_child( $child1 );
cmp_ok( $root->children, '==', 2, "Adding child1 back works as expected" );

cmp_ok( $root->height, '==', 2, "The root's height is still two. (" . $root->height . ")" );
cmp_ok( $child1->height, '==', 1, "The child1's height is still one." );
cmp_ok( $child2->height, '==', 1, "The child2's height is still one." );

cmp_ok( $root->width, '==', 2, "The root's width is back to two." );
cmp_ok( $child1->width, '==', 1, "The child1's width is one." );
cmp_ok( $child2->width, '==', 1, "The child2's width is one." );

{
    my $mirror = $root->clone->mirror;
    my @children = $root->children;
    my @reversed_children = $mirror->children;

    is( $children[0]->value, $reversed_children[1]->value );
    is( $children[1]->value, $reversed_children[0]->value );
}

my @removed = $root->remove_child( $child1, $child2 );
is( $removed[0], $child1 );
is( $removed[1], $child2 );
cmp_ok( $root->children, '==', 0, "remove_child(\@many) works" );

cmp_ok( $root->height, '==', 1, "The root's height is back to one." );
cmp_ok( $child1->height, '==', 1, "The child1's height is still one." );
cmp_ok( $child2->height, '==', 1, "The child2's height is still one." );

cmp_ok( $root->width, '==', 1, "The root's width is now one (as a single-node tree)." );
cmp_ok( $child1->width, '==', 1, "The child1's width is one." );
cmp_ok( $child2->width, '==', 1, "The child2's width is one." );

# Test various permutations of the return values from remove_child()
{
    $root->add_child( $child1, $child2 );
    my @removed = $root->remove_child( $child2, $child1 );
    is( $removed[0], $child2 );
    is( $removed[1], $child1 );
}

{
    $root->add_child( $child1, $child2 );
    my @removed = @{$root->remove_child( $child2, $child1 )};
    is( $removed[0], $child2 );
    is( $removed[1], $child1 );
}

{
    $root->add_child( $child1, $child2 );
    my $removed = $root->remove_child( $child2, $child1 );
    is( $removed->[0], $child2 );
    is( $removed->[1], $child1 );
}
