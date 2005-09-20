use strict;
use warnings;

use Test::More tests => 36;

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

ok( $root->children == 1, "The root has one child" );
{
    my @children = $root->children;
    ok( @children == 1, "The list of children is still 1 long" );
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

ok( $root->height == 2, "The root's height is 2" );
ok( $child->height == 1, "The child's height is 1" );

ok( $root->width == 1, "The root's width is 1" );
ok( $child->width == 1, "The child's width is 1" );

is( $root->remove_child( $child ), $child, "remove_child() returns the removed node" );

ok( $root->is_root, 'The root is still the root' );
ok( $root->is_leaf, 'The root is now a leaf' );

ok( $child->is_root, 'The child is now a root' );
ok( $child->is_leaf, 'The child is still a leaf' );

is( $child->parent, "", "The child's parent is now empty" );
is( $child->root, $child, "The child's root is now itself" );

ok( $root->children == 0, "The root has no children" );

ok( $root->height == 1, "The root's height is now 1 again" );
ok( $child->height == 1, "The child's height is still 1" );

ok( $root->width == 1, "The root's width is still 1" );
ok( $child->width == 1, "The child's width is still 1" );
