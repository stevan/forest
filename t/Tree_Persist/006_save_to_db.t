use strict;
use warnings;

use Test::More;

#use t::tests qw( %runs );

plan tests => 4;

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

use DBI;
my $dbh = DBI->connect(
    'dbi:mysql:tree', 'tree', 'tree', {
        AutoCommit => 1,
        RaiseError => 1,
        PrintError => 0,
    },
);

{
    my $tree = Tree->new( 'root' );

    my $persist = $CLASS->create_datastore({
        type  => 'DB',
        tree  => $tree,
        dbh   => $dbh,
        table => 'tree',
    });

    my $sth = $dbh->prepare(
        "SELECT id,parent_id,class,value FROM tree WHERE id > 3 ORDER BY id"
    );
    $sth->execute;
    my $rows = $sth->fetchall_arrayref({});

    my $expected = [
        { id => 4, parent_id => undef, class => 'Tree', value => 'root' },
    ];

    is_deeply( $rows, $expected, "We put in what we expected to" );

    $dbh->do( "DELETE FROM tree WHERE id > 3" );
}

{
    my $tree = Tree->new( 'A' )->add_child(
        Tree->new( 'B' ),
        Tree->new( 'C' )->add_child(
            Tree->new( 'D' ),
        ),
        Tree->new( 'E' ),
    );

    my $persist = $CLASS->create_datastore({
        type  => 'DB',
        tree  => $tree,
        dbh   => $dbh,
        table => 'tree',
    });

    my $sth = $dbh->prepare(
        "SELECT id,parent_id,class,value FROM tree WHERE id > 3 ORDER BY id"
    );
    $sth->execute;
    my $rows = $sth->fetchall_arrayref({});

    my $expected = [
        { id => 4, parent_id => undef, class => 'Tree', value => 'A' },
        { id => 5, parent_id =>     4, class => 'Tree', value => 'B' },
        { id => 6, parent_id =>     4, class => 'Tree', value => 'C' },
        { id => 7, parent_id =>     4, class => 'Tree', value => 'E' },
        { id => 8, parent_id =>     6, class => 'Tree', value => 'D' },
    ];

    is_deeply( $rows, $expected, "We put in what we expected to" );

    $dbh->do( "DELETE FROM tree WHERE id > 3" );
}

{
    my $tree = Tree->new( 'A' )->add_child(
        Tree->new( 'B' ),
        Tree->new( 'C' )->add_child(
            Tree->new( 'D' ),
            Tree->new( 'E' ),
        ),
    );

    my $persist = $CLASS->create_datastore({
        type  => 'DB',
        tree  => $tree,
        dbh   => $dbh,
        table => 'tree',
    });

    my $sth = $dbh->prepare(
        "SELECT id,parent_id,class,value FROM tree WHERE id > 3 ORDER BY id"
    );
    $sth->execute;
    my $rows = $sth->fetchall_arrayref({});

    my $expected = [
        { id => 4, parent_id => undef, class => 'Tree', value => 'A' },
        { id => 5, parent_id =>     4, class => 'Tree', value => 'B' },
        { id => 6, parent_id =>     4, class => 'Tree', value => 'C' },
        { id => 7, parent_id =>     6, class => 'Tree', value => 'D' },
        { id => 8, parent_id =>     6, class => 'Tree', value => 'E' },
    ];

    is_deeply( $rows, $expected, "We put in what we expected to" );

    $dbh->do( "DELETE FROM tree WHERE id > 3" );
}
