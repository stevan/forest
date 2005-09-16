use strict;
use warnings;

use Test::More tests => 61;

my $CLASS = 'Tree';
use_ok( $CLASS );

# Test Plan:
# 1) Add two children at once to a root node.
# 2) Verify
# 3) Remove one child
# 4) Verify that the other child is still a child of the root
# 5) Add the removed child back, then remove both to test removing multiple children

my $root = $CLASS->new;
isa_ok( $root, $CLASS );

my $child1 = $CLASS->new;
isa_ok( $child1, $CLASS );

my $child2 = $CLASS->new;
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

ok( $root->children == 2, "The root has two children" );

ok( $root->has_child( $child1 ), "The root has child1" );
ok( $root->has_child( $child2 ), "The root has child2" );
ok( $root->has_child( $child1, $child2 ), "The root has both children" );

ok( $root->height == 2, "The root's height is two." );
ok( $child1->height == 1, "The child1's height is one." );
ok( $child2->height == 1, "The child2's height is one." );

ok( $root->width == 2, "The root's width is two." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

$root->remove_child( $child1 );
ok( $root->children == 1, "After removing child1, the root has one child" );
my @children = $root->children;
is( $children[0], $child2, "... and the right child is still there" );

ok( !$root->has_child( $child1 ), "The root doesn't have child1" );
ok( $root->has_child( $child2 ), "The root has child2" );
ok( !$root->has_child( $child1, $child2 ), "The root doesn't have both children" );
ok( !$root->has_child( $child2, $child1 ), "The root doesn't have both children (reversed)" );

ok( $root->height == 2, "The root's height is still two." );
ok( $child1->height == 1, "The child1's height is still one." );
ok( $child2->height == 1, "The child2's height is still one." );

ok( $root->width == 1, "The root's width is now one." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

$root->add_child( $child1 );
ok( $root->children == 2, "Adding child1 back works as expected" );

ok( $root->height == 2, "The root's height is still two. (" . $root->height . ")" );
ok( $child1->height == 1, "The child1's height is still one." );
ok( $child2->height == 1, "The child2's height is still one." );

ok( $root->width == 2, "The root's width is back to two." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

my @removed = $root->remove_child( $child1, $child2 );
is( $removed[0], $child1 );
is( $removed[1], $child2 );
ok( $root->children == 0, "remove_child(\@many) works" );

ok( $root->height == 1, "The root's height is back to one." );
ok( $child1->height == 1, "The child1's height is still one." );
ok( $child2->height == 1, "The child2's height is still one." );

ok( $root->width == 1, "The root's width is now one (as a single-node tree)." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

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
