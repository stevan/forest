use strict;
use warnings;

use Test::More tests => 8;

my $CLASS = 'Tree';
use_ok( $CLASS );

# NOTE: These tests are all assuming pre-order traversal. Additional tests will
# need to be added for post-order and level-order traversals (as well as in-order
# traversals when doing the btree tests).

my @list;
my @nodes;

push @nodes, $CLASS->new('A');

@list = $nodes[0]->traverse;
is_deeply( \@list, [$nodes[0]], "A preorder traversal of a single-node tree is itself" );

push @nodes, $CLASS->new('B');
$nodes[0]->add_child( $nodes[-1] );

@list = $nodes[0]->traverse;
is_deeply( \@list, \@nodes, "A preorder traversal of this tree is A-B" );

push @nodes, $CLASS->new('C');
$nodes[0]->add_child( $nodes[-1] );

@list = $nodes[0]->traverse;
is_deeply( \@list, \@nodes, "A preorder traversal of this tree is A-B-C" );

push @nodes, $CLASS->new('D');
$nodes[1]->add_child( $nodes[-1] );

@list = $nodes[0]->traverse;
is_deeply( \@list, [ @nodes[0,1,3,2] ], "A preorder traversal of this tree is A-B-D-C" );

push @nodes, $CLASS->new('E');
$nodes[1]->add_child( $nodes[-1] );

@list = $nodes[0]->traverse;
is_deeply( \@list, [ @nodes[0,1,3,4,2] ], "A preorder traversal of this tree is A-B-D-E-C" );

push @nodes, $CLASS->new('F');
$nodes[1]->add_child( $nodes[-1] );

@list = $nodes[0]->traverse;
is_deeply( \@list, [ @nodes[0,1,3,4,5,2] ], "A preorder traversal of this tree is A-B-D-E-F-C" );

push @nodes, $CLASS->new('G');
$nodes[4]->add_child( $nodes[-1] );

@list = $nodes[0]->traverse;
is_deeply( \@list, [ @nodes[0,1,3,4,6,5,2] ], "A preorder traversal of this tree is A-B-D-E-G-F-C" );
