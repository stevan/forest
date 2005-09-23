use strict;
use warnings;

use Test::More tests => 19;

my $CLASS = 'Tree';
use_ok( $CLASS );

my $root = $CLASS->new;
my $child1 = $CLASS->new;
my $child2 = $CLASS->new;

$root->add_child( $child1 );

is( $root->remove_child(), undef, "remove_child(): No children is an error" );
is( $root->last_error, "remove_child(): Nothing to remove", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );

is( $root->remove_child(undef), undef, "remove_child(): Undefined value error" );
is( $root->last_error, "remove_child(): 'undef' is out-of-bounds", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );

is( $root->remove_child('foo'), undef, "remove_child(): Non-numeric index error" );
is( $root->last_error, "remove_child(): 'foo' is not a legal index", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );

is( $root->remove_child(1), undef, "remove_child(): index too large error" );
is( $root->last_error, "remove_child(): '1' is out-of-bounds", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );

is( $root->remove_child(-1), undef, "remove_child(): index too small error" );
is( $root->last_error, "remove_child(): '-1' is out-of-bounds", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );

is( $root->remove_child( $child2 ), undef, "remove_child(): child not found" );
is( $root->last_error, "remove_child(): '$child2' not found", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );
