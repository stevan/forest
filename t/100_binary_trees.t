use strict;
use warnings;

use Test::More tests => 3;

my $CLASS = 'Tree::Binary';
use_ok( $CLASS );

my $tree = $CLASS->new;
isa_ok( $tree, $CLASS );
isa_ok( $tree, 'Tree' );
