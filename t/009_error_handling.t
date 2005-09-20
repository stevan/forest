use strict;
use warnings;

use Test::More tests => 9;

my $CLASS = 'Tree';
use_ok( $CLASS );

is( $CLASS->error_handler, $CLASS->QUIET, "The initial default error_handler is quiet." );

my $tree = $CLASS->new;

is( $tree->error_handler, $CLASS->QUIET, "The default error-handler is quiet." );

is( $tree->error_handler( $tree->DIE ), $CLASS->QUIET, "Setting the error_handler returns the old one" );
is( $tree->error_handler, $CLASS->DIE, "The new error-handler is die." );

is( $CLASS->error_handler( $CLASS->WARN ), $CLASS->QUIET, "Setting the error_handler as a class method returns the old default error handler" );
my $tree2 = $CLASS->new;
is( $tree2->error_handler, $CLASS->WARN, "A new tree picks up the new default error handler" );
is( $tree->error_handler, $CLASS->DIE, "... but it doesn't change current trees" );

$tree->add_child( $tree2 );
is( $tree2->error_handler, $tree->error_handler, "A child picks up its parent's error handler" );
