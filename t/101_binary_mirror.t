use strict;
use warnings;

use Test::More;

#use t::tests qw( %runs );

plan tests => 6;

my $CLASS = 'Tree::Binary';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

{
    my $tree = $CLASS->new( 'A' )
                     ->left(
                             $CLASS->new( 'B' )
                                   ->left(
                                       $CLASS->new( 'C' )
                                   )
                                   ->right(
                                       $CLASS->new( 'D' )
                                   )
                     )
                     ->right(
                             $CLASS->new( 'E' )
                                   ->left(
                                       $CLASS->new( 'F' )
                                   )
                                   ->right(
                                       $CLASS->new( 'G' )
                                   )
                     )
                ;

    my @order = $tree->traverse( $tree->IN_ORDER );
    is_deeply(
        [ map { $_->value } @order ],
        [ qw( C B D A F E G ) ],
        "The tree's ordering for in-order traversal is correct",
    );

    is_deeply(
        [ map { $_->value } $tree->traverse() ],
        [ qw( A B C D E F G ) ],
        "pre-order traversal works correctly",
    );

    my $mirror = $tree->clone->mirror;
    my @clone_order = $mirror->traverse( $mirror->IN_ORDER );
    is_deeply(
        [ map { $_->value } @clone_order ],
        [ qw( G E F A D B C ) ],
        "The mirror's ordering for in-order traversal is correct",
    );

}

{
    my $tree = $CLASS->new(4)
        ->left(
            $CLASS->new(20)
                ->left(
                    $CLASS->new(1)
                        ->right(
                            $CLASS->new(10)
                                ->left($CLASS->new(5))
                        )
                )
                ->right(
                    $CLASS->new(3)
                )
        )
        ->right(
            $CLASS->new(6)
                ->left(
                    $CLASS->new(5)
                        ->right(
                            $CLASS->new(7)
                                ->left( $CLASS->new(90) )
                                ->right( $CLASS->new(91) )
                        )
                )
        )
    ;

    my @results = map { $_->value } $tree->traverse( $tree->IN_ORDER );

    is_deeply(
        [ @results ],
        [ 1, 5, 10, 20, 3, 4, 5, 90, 7, 91, 6 ],
        "The tree's ordering for in-order traversal is correct",
    );

    my $mirror = $tree->clone->mirror;
    my @m_results = map { $_->value } $mirror->traverse( $mirror->IN_ORDER );

    is_deeply(
        [ @m_results ],
        [ reverse @results ],
        "... the in-order traversal of the mirror is the reverse of the in-order traversal of the original tree",
    );
}
