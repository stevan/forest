use strict;
use warnings;

use Test::More tests => 5;

my $CLASS = 'Tree::Simple';
use_ok( $CLASS );

# Test plan:
# 1) Create with an empty new().
# TODO: 2) Create with an explicit parent => undef

my $tree = $CLASS->new();
isa_ok( $tree, $CLASS );

ok( $tree->is_root, "Node without a parent knows it's a root" );
ok( $tree->is_leaf, "Node without a child knows it's a leaf" );

my $parent = $tree->parent;
isa_ok( $parent, 'Tree::Simple::Null' );
