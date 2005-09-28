use strict;
use warnings;

use Test::More;

use t::tests qw( %runs );

plan tests => 21 + 14 * $runs{stats}{plan};

my $CLASS = 'Tree::Binary';
use_ok( $CLASS );

my $root = $CLASS->new( 'root' );
isa_ok( $root, $CLASS );
isa_ok( $root, 'Tree' );

is( $root->root, $root, "The root's root is itself" );
is( $root->value, 'root', "value() works" );

$runs{stats}{func}->( $root,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

can_ok( $root, qw( left right ) );

my $left = $CLASS->new( 'left' );

$runs{stats}{func}->( $left,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

is( $root->left(), undef, "Calling left with no params is a getter" );
is( $root->left( $left ), $root, "Calling left as a setter chains" );
is( $root->left(), $left, "... and set the left" );

cmp_ok( $root->children, '==', 1, "children() works" );

$runs{stats}{func}->( $root,
    height => 2, width => 1, depth => 0, size => 2, is_root => 1, is_leaf => 0,
);

$runs{stats}{func}->( $left,
    height => 1, width => 1, depth => 1, size => 1, is_root => 0, is_leaf => 1,
);

is( $root->left( undef ), $root, "Calling left with undef as a param" );
is( $root->left(), undef, "... unsets left" );

cmp_ok( $root->children, '==', 0, "children() works" );

$runs{stats}{func}->( $root,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

$runs{stats}{func}->( $left,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

my $right = $CLASS->new( 'right' );

$runs{stats}{func}->( $right,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

is( $root->right(), undef, "Calling right with no params is a getter" );
is( $root->right( $right ), $root, "Calling right as a setter chains" );
is( $root->right(), $right, "... and set the right" );

cmp_ok( $root->children, '==', 1, "children() works" );

$runs{stats}{func}->( $root,
    height => 2, width => 1, depth => 0, size => 2, is_root => 1, is_leaf => 0,
);

$runs{stats}{func}->( $right,
    height => 1, width => 1, depth => 1, size => 1, is_root => 0, is_leaf => 1,
);

is( $root->right( undef ), $root, "Calling right with undef as a param" );
is( $root->right(), undef, "... unsets right" );

cmp_ok( $root->children, '==', 0, "children() works" );

$runs{stats}{func}->( $root,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

$runs{stats}{func}->( $right,
    height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
);

$root->left( $left );
$root->right( $right );

cmp_ok( $root->children, '==', 2, "children() works" );

$runs{stats}{func}->( $root,
    height => 2, width => 2, depth => 0, size => 3, is_root => 1, is_leaf => 0,
);

$runs{stats}{func}->( $left,
    height => 1, width => 1, depth => 1, size => 1, is_root => 0, is_leaf => 1,
);

$runs{stats}{func}->( $right,
    height => 1, width => 1, depth => 1, size => 1, is_root => 0, is_leaf => 1,
);
