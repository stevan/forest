use strict;
use warnings;

use Test::More tests => 4;

my $CLASS = 'Tree';
use_ok( $CLASS );

my $root = $CLASS->new;
my $child1 = $CLASS->new;
my $child2 = $CLASS->new;

$root->add_child( $child1 );

is( $root->remove_child(), undef, "remove_child(): No children is an error" );
is( $root->last_error, "remove_child(): Nothing to remove", "... and the error is good" );
cmp_ok( $root->children, '==', 1, "... and we still have one child" );

