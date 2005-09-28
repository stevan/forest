use strict;
use warnings;

use Test::More tests => 4;

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

can_ok( $CLASS, 'new' );

my $persist = $CLASS->new;
isa_ok( $persist, $CLASS );

can_ok( $persist, qw( load store associate ) );
