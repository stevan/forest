use strict;
use warnings;

use Test::More tests => 46;

my $CLASS = 'Tree';
use_ok( $CLASS );

# Test plan:
# Add a single child, then retrieve it, then remove it.
# 1) Verify that one can retrieve a child added
# 2) Verify that the appropriate status methods reflect the change
# 3) Verify that the child can be removed
# 4) Verify that the appropriate status methods reflect the change

my $root = $CLASS->new();
isa_ok( $root, $CLASS );

my $child = $CLASS->new();
isa_ok( $child, $CLASS );

ok( $child->is_root, "The child is a root ... for now" );
ok( $child->is_leaf, "The child is also a leaf" );

ok( !$root->has_child( $child ), "The root doesn't have the child ... yet" );

is( $root->add_child( $child ), $root, "add_child() chains" );

ok( $root->is_root, 'The root is still the root' );
ok( !$root->is_leaf, 'The root is no longer a leaf' );

ok( !$child->is_root, 'The child is no longer a root' );
ok( $child->is_leaf, 'The child is still a leaf' );

cmp_ok( $root->children, '==', 1, "The root has one child" );
{
    my @children = $root->children;
    cmp_ok( @children, '==', 1, "The list of children is still 1 long" );
    is( $children[0], $child, "... and the child is correct" );
}

is( $root->children(0), $child, "You can also access the children by index" );
{
    my @children = $root->children(0);
    cmp_ok( @children, '==', 1, "The list of children by index is still 1 long" );
    is( $children[0], $child, "... and the child is correct" );
}

is( $child->parent, $root, "The child's parent is also set correctly" );
is( $child->root, $root, "The child's root is also set correctly" );

ok( $root->has_child( $child ), "The tree has the child" );

my $idx = $root->has_child( $child );
cmp_ok( $idx, '==', 0, "... and the child is at index 0 (scalar)" );

my @idx = $root->has_child( $child );
is_deeply( \@idx, [ 0 ], "... and the child is at index 0 (list)" );

cmp_ok( $root->height, '==', 2, "The root's height is 2" );
cmp_ok( $child->height, '==', 1, "The child's height is 1" );

cmp_ok( $root->width, '==', 1, "The root's width is 1" );
cmp_ok( $child->width, '==', 1, "The child's width is 1" );

cmp_ok( $root->depth, '==', 0, "The root's depth is 0" );
cmp_ok( $child->depth, '==', 1, "The child's depth is 1" );

cmp_ok( $root->size, '==', 2, "The root's size is 2" );
cmp_ok( $child->size, '==', 1, "The child's size is 1" );

is( $root->remove_child( $child ), $child, "remove_child() returns the removed node" );

ok( $root->is_root, 'The root is still the root' );
ok( $root->is_leaf, 'The root is now a leaf' );

ok( $child->is_root, 'The child is now a root' );
ok( $child->is_leaf, 'The child is still a leaf' );

is( $child->parent, "", "The child's parent is now empty" );
is( $child->root, $child, "The child's root is now itself" );

cmp_ok( $root->children, '==', 0, "The root has no children" );

cmp_ok( $root->height, '==', 1, "The root's height is now 1 again" );
cmp_ok( $child->height, '==', 1, "The child's height is still 1" );

cmp_ok( $root->width, '==', 1, "The root's width is still 1" );
cmp_ok( $child->width, '==', 1, "The child's width is still 1" );

cmp_ok( $root->depth, '==', 0, "The root's depth is 0" );
cmp_ok( $child->depth, '==', 0, "The child's depth is 0" );

cmp_ok( $root->size, '==', 1, "The root's size is 1" );
cmp_ok( $child->size, '==', 1, "The child's size is 1" );
