use strict;
use warnings;

use Test::More tests => 8;

my $CLASS = 'Tree';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

# Test plan:
# 1) Verify that the API is correct. This will serve as documentation for which methods
#    should be part of which kind of API.
# 2) Verify that all methods in $CLASS have been classified appropriately

my %existing_methods = do {
    no strict 'refs';
    map {
        $_ => undef
    } grep {
        !/^_/ && /^[a-z_]+$/
    } grep {
        exists &{${ $CLASS . '::'}{$_}}
    } keys %{ $CLASS . '::'}
};

my %methods = (
    class => [ qw(
        new error_handler QUIET WARN DIE
    )],
    public => [ qw(
        is_root is_leaf
        add_child remove_child has_child
        root parent children
        height width depth
        error_handler error last_error
        value
        clone
    )],
    private => [ qw(
        _null _fix_width _fix_height _set_parent _set_root
    )],
    book_keeping => [qw(
        DESTROY import
    )],
    imported => [qw(
        weaken blessed refaddr
    )],
);

# These are the class methods
can_ok( $CLASS, @{ $methods{class} } );
delete @existing_methods{@{$methods{class}}};

my $tree = $CLASS->new();
isa_ok( $tree, $CLASS );

for my $type ( qw( public private book_keeping imported ) ) {
    can_ok( $tree, @{ $methods{ $type } } );
    delete @existing_methods{@{$methods{ $type }}};
}

if ( my @k = keys %existing_methods ) {
    ok( 0, "We need to account for '" . join ("','", @k) . "'" );
}
else {
    ok( 1, "We've accounted for everything." );
}
