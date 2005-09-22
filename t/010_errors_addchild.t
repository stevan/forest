use strict;
use warnings;

use Test::More tests => 37;

my $CLASS = 'Tree';
use_ok( $CLASS );

my $root = $CLASS->new;
my $child1 = $CLASS->new;
my $child2 = $CLASS->new;

is( $root->add_child(), undef, "add_child(): No children is an error" );
is( $root->last_error, "add_child(): No children passed in", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( 'not_a_child' ), undef, "add_child(): Illegal child is an error" );
is( $root->last_error, "add_child(): 'not_a_child' is not a Tree", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

my $bad_node = bless({},'Not::A::Tree' );
is( $root->add_child( $bad_node ), undef, "add_child(): Illegal child is an error" );
is( $root->last_error, "add_child(): '$bad_node' is not a Tree", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

my $bad_node2 = bless({},'Not::A::Tree' );
is( $root->add_child( $bad_node, $bad_node2 ), undef, "add_child(): Illegal children is an error" );
is( $root->last_error, "add_child(): '$bad_node' is not a Tree", "... but only first is return as an error" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( $child1, $bad_node ), undef, "add_child(): Any illegal child is an error, even with good children in the mix" );
is( $root->last_error, "add_child(): '$bad_node' is not a Tree", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( at => $child1, $bad_node ), undef, "add_child(): An illegal 'at' value is an error" );
is( $root->last_error, "add_child(): '$child1' is not a legal index", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( $child1, at => $bad_node ), undef, "add_child(): An illegal 'at' value is an error" );
is( $root->last_error, "add_child(): '$bad_node' is not a legal index", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( $child1, at => 1 ), undef, "add_child(): An 'at' value outside the current number of children is illegal" );
is( $root->last_error, "add_child(): '1' is outside the current range", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( at => 1, $child1 ), undef, "add_child(): An 'at' value outside the current number of children is illegal" );
is( $root->last_error, "add_child(): '1' is outside the current range", "... and the error is good" );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $root->add_child( $root ), undef, "add_child(): Cannot add the root to itself" );
is( $root->last_error, "add_child(): Cannot add a node in the tree back into the tree", '... and the error is good' );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

$child1->add_child( $child2 );
is( $root->add_child( $child2 ), undef, "add_child(): Cannot add a child to another parent" );
is( $root->last_error, "add_child(): Cannot add a child to another parent", '... and the error is good' );
cmp_ok( $root->children, '==', 0, "... and we still have no children" );

is( $child1->add_child( $child2 ), undef, "add_child(): Cannot add a child a second time" );
is( $child1->last_error, "add_child(): Cannot add a node in the tree back into the tree", '... and the error is good' );
cmp_ok( $child1->children, '==', 1, "... and we still have only one child" );
