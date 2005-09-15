use strict;
use warnings;

use Test::More tests => 6;

my $CLASS = 'Tree::Simple';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

# Test plan:
# 1) Verify that the API is correct. This will serve as documentation for which methods
#    should be part of which kind of API.
# 2) Verify that all methods in $CLASS have been classified appropriately

my %existing_methods = do {
  no strict 'refs';
  map { $_ => undef } grep exists &$_, keys %{ $CLASS . '::'};
};

my %methods = (
    class => [ qw(
        new
    )],
    public => [ qw(
        is_root is_leaf
        parent children
        add_child remove_child has_child
    )],
    private => [ qw(
        _null
    )],
#    book_keeping => [],
);

# These are the class methods
can_ok( $CLASS, @{ $methods{class} } );
delete @existing_methods{@{$methods{class}}};

my $tree = $CLASS->new();
isa_ok( $tree, $CLASS );

can_ok( $tree, @{ $methods{public} } );
delete @existing_methods{@{$methods{public}}};
can_ok( $tree, @{ $methods{private} } );
delete @existing_methods{@{$methods{private}}};
#can_ok( $tree, @{ $methods{book_keeping} } );
#delete @existing_methods{@{$methods{book_keeping}}};

ok( keys %existing_methods == 0, "We've accounted for everything." );
