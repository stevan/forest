use strict;
use warnings;

use Test::More tests => 16;

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

my $err;
my $handler = sub {
    no warnings;
    $err = join "", @_;
    return;
};

$tree->error_handler( $handler );
is( $tree->error_handler, $handler, "We have set a custom error handler" );

is( $tree->error, undef, "Calling the custom error handler returns undef" );
is( $err, "". $tree, "... and with no arguments only passes the node in" );

is( $tree->error( 'Some error, huh?' ), undef, "Calling the custom error handler returns undef" );
is( $err, "". join("",$tree, 'Some error, huh?'), "... and with one argument passes the node and the argument in" );

is( $tree->error( 1, 2 ), undef, "Calling the custom error handler returns undef" );
is( $err, "". join("",$tree, 1, 2), "... and with two arguments passes the node and all arguments in" );
