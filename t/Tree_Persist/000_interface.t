use strict;
use warnings;

use File::Spec::Functions qw( catfile );
use Test::More tests => 7;

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

my %existing_methods = do {
    no strict 'refs';
    map {
        $_ => undef
    } grep {
        /^[a-zA-Z_]+$/
    } grep {
        exists &{${ $CLASS . '::'}{$_}}
    } keys %{ $CLASS . '::'}
};

my %methods = (
    class => [ qw(
        connect create_datastore
    )],
    public => [ qw(
        autocommit tree
        commit rollback reload
    )],
    private => [ qw(
        _build_string
    )],
    book_keeping => [qw(
    )],
    imported => [qw(
        blessed refaddr
    )],
);

# These are the class methods
can_ok( $CLASS, @{ $methods{class} } );
delete @existing_methods{@{$methods{class}}};

my $persist = $CLASS->connect({
    filename => catfile( qw( t datafiles tree1.xml ) ),
});
TODO: {
    local $TODO = "Hmm...";
    isa_ok( $persist, $CLASS );
}

for my $type ( qw( public private book_keeping imported ) ) {
    next unless @{$methods{$type}};
    can_ok( $persist, @{ $methods{ $type } } );
    delete @existing_methods{@{$methods{ $type }}};
}

if ( my @k = keys %existing_methods ) {
    ok( 0, "We need to account for '" . join ("','", @k) . "'" );
}
else {
    ok( 1, "We've accounted for everything." );
}
