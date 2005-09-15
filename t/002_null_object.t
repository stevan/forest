use strict;
use warnings;

use Test::More tests => 13;

my $CLASS = 'Tree::Simple';
use_ok( $CLASS );

# Test plan:
# 1) The null object should inherit from Tree::Simple
# 2) It should be false in all respects
# 3) It should report that it can perform any method
# 4) Any method call on it should return back the null object

my $NULL_CLASS = $CLASS . '::Null';

my $obj = $NULL_CLASS->new;
isa_ok( $obj, $NULL_CLASS );
TODO: {
    local $TODO = "It's not clear if this inheritance should be there.";
    isa_ok( $obj, $CLASS );
}

ok( !$obj, "The null object is false" );
TODO: {
    local $TODO = "Need to figure out a way to have an object evaluate as undef";
    ok( !defined $obj, " ... and undefined" );
}
ok( $obj eq "", " .. and stringifies to the empty string" );
ok( $obj == 0, " ... and numifies to zero" );

can_ok( $obj, 'some_random_method' );
my $val = $obj->some_random_method;
is( $val, $obj, "The return value of any method call on the null object is the null object" );

is( $obj->method1->method2, $obj, "Method chaining works" );

is( $CLASS->_null, $obj, "The _null method on $CLASS returns a null object" );
my $tree = $CLASS->new;
isa_ok( $tree, $CLASS );
is( $tree->_null, $obj, "The _null method on an object of $CLASS returns a null object" );
