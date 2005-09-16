use strict;
use warnings;

use Test::More tests => 31;

my $CLASS = 'Tree';
use_ok( $CLASS );

# Test Plan:
# 1) Add two children to a root node to make a 3-level tree.
# 2) Verify that all state is correctly reported
# 3) Remove the mid-level node
# 4) Verify that all state is correctly reported
# 5) Re-add the mid-level node
# 6) Verify that all state is correctly reported

my $root = $CLASS->new;
isa_ok( $root, $CLASS );

my $child1 = $CLASS->new;
isa_ok( $child1, $CLASS );

my $child2 = $CLASS->new;
isa_ok( $child2, $CLASS );

$root->add_child( $child1 );
$child1->add_child( $child2 );

ok( $root->children == 1, "The root has one child" );
ok( $child1->children == 1, "The child1 has one child" );
ok( $child2->children == 0, "The child2 has zero children" );

ok( $root->height == 3, "The root's height is three." );
ok( $child1->height == 2, "The child1's height is two." );
ok( $child2->height == 1, "The child2's height is one." );

ok( $root->width == 1, "The root's width is one." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

$root->remove_child( $child1 );

ok( $root->height == 1, "The root's height is one after removal." );
ok( $child1->height == 2, "The child1's height is two." );
ok( $child2->height == 1, "The child2's height is one." );

ok( $root->width == 1, "The root's width is one." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

$root->add_child( $child1 );

ok( $root->height == 3, "The root's height is three." );
ok( $child1->height == 2, "The child1's height is two." );
ok( $child2->height == 1, "The child2's height is one." );

ok( $root->width == 1, "The root's width is one." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

$child1->remove_child( $child2 );

ok( $root->height == 2, "The root's height is two." );
ok( $child1->height == 1, "The child1's height is one." );
ok( $child2->height == 1, "The child2's height is one." );

ok( $root->width == 1, "The root's width is one." );
ok( $child1->width == 1, "The child1's width is one." );
ok( $child2->width == 1, "The child2's width is one." );

