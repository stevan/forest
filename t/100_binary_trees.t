use strict;
use warnings;

use Test::More tests => 34;

my $CLASS = 'Tree::Binary';
use_ok( $CLASS );

my $tree = $CLASS->new( 'root' );
isa_ok( $tree, $CLASS );
isa_ok( $tree, 'Tree' );

ok( $tree->is_root, "Node without a parent knows it's a root" );
ok( $tree->is_leaf, "Node without a child knows it's a leaf" );
is( $tree->root, $tree, "The root's root is itself" );

is( $tree->value, 'root', "value() works" );
cmp_ok( $tree->size, '==', 1, "size() works" );
cmp_ok( $tree->depth, '==', 0, "depth() works" );
cmp_ok( $tree->height, '==', 1, "height() works" );
cmp_ok( $tree->width, '==', 1, "width() works" );

can_ok( $tree, qw( left right ) );

my $left = $CLASS->new( 'left' );

is( $tree->left(), undef, "Calling left with no params is a getter" );
is( $tree->left( $left ), $tree, "Calling left as a setter chains" );
is( $tree->left(), $left, "... and set the left" );

cmp_ok( $tree->size, '==', 2, "size() works" );
cmp_ok( $tree->height, '==', 2, "height() works" );
cmp_ok( $tree->width, '==', 1, "width() works" );

is( $tree->left( undef ), $tree, "Calling left with undef as a param" );
is( $tree->left(), undef, "... unsets left" );

cmp_ok( $tree->size, '==', 1, "size() works" );
cmp_ok( $tree->height, '==', 1, "height() works" );
cmp_ok( $tree->width, '==', 1, "width() works" );

my $right = $CLASS->new( 'right' );

is( $tree->right(), undef, "Calling right with no params is a getter" );
is( $tree->right( $right ), $tree, "Calling right as a setter chains" );
is( $tree->right(), $right, "... and set the right" );

cmp_ok( $tree->size, '==', 2, "size() works" );
cmp_ok( $tree->height, '==', 2, "height() works" );
cmp_ok( $tree->width, '==', 1, "width() works" );

is( $tree->right( undef ), $tree, "Calling right with undef as a param" );
is( $tree->right(), undef, "... unsets right" );

cmp_ok( $tree->size, '==', 1, "size() works" );
cmp_ok( $tree->height, '==', 1, "height() works" );
cmp_ok( $tree->width, '==', 1, "width() works" );
