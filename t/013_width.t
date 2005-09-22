#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 77;

BEGIN { 
	use_ok('Tree'); 
};


{ # test height (with pictures)

    my $tree = Tree->new();
    isa_ok($tree, 'Tree');

    my $D = Tree->new('D');
    isa_ok($D, 'Tree');

    $tree->add_child($D);

    #   |
    #  <D>

    cmp_ok($D->width(), '==', 1, '... D has a width of 1');

    my $E = Tree->new('E');
    isa_ok($E, 'Tree');

    $D->add_child($E);

    #   |
    #  <D>
    #    \
    #    <E>

    cmp_ok($D->width(), '==', 1, '... D has a width of 1');
    cmp_ok($E->width(), '==', 1, '... E has a width of 1');

    my $F = Tree->new('F');
    isa_ok($F, 'Tree');

    $E->add_child($F);

    #   |
    #  <D>
    #    \
    #    <E>
    #      \
    #      <F>

    cmp_ok($D->width(), '==', 1, '... D has a width of 1');
    cmp_ok($E->width(), '==', 1, '... E has a width of 1');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');

    my $C = Tree->new('C');
    isa_ok($C, 'Tree');

    $D->add_child($C);

    #    |
    #   <D>
    #   / \
    # <C> <E>
    #       \
    #       <F>

    cmp_ok($D->width(), '==', 2, '... D has a width of 2');
    cmp_ok($E->width(), '==', 1, '... E has a width of 1');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');

    my $B = Tree->new('B');
    isa_ok($B, 'Tree');

    $D->add_child($B);

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #             \
    #             <F>


    cmp_ok($D->width(), '==', 3, '... D has a width of 3');
    cmp_ok($E->width(), '==', 1, '... E has a width of 1');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');


    my $A = Tree->new('A');
    isa_ok($A, 'Tree');

    $E->add_child($A);

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #           / \
    #         <A> <F>       

    cmp_ok($D->width(), '==', 4, '... D has a width of 4');
    cmp_ok($E->width(), '==', 2, '... E has a width of 2');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');
    cmp_ok($A->width(), '==', 1, '... A has a width of 1');

    my $G = Tree->new('G');
    isa_ok($G, 'Tree');

    $E->add_child( at => 1, $G);

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #          / | \
    #       <A> <G> <F>         

    cmp_ok($D->width(), '==', 5, '... D has a width of 5');
    cmp_ok($E->width(), '==', 3, '... E has a width of 3');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($G->width(), '==', 1, '... G has a width of 1');
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');
    cmp_ok($A->width(), '==', 1, '... A has a width of 1');

    my $H = Tree->new('H');
    isa_ok($H, 'Tree');

    $G->add_child($H);

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #          / | \
    #       <A> <G> <F> 
    #            |
    #           <H>    

    cmp_ok($D->width(), '==', 5, '... D has a width of 5');
    cmp_ok($E->width(), '==', 3, '... E has a width of 3');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($G->width(), '==', 1, '... G has a width of 1');
    cmp_ok($H->width(), '==', 1, '... H has a width of 1');
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');
    cmp_ok($A->width(), '==', 1, '... A has a width of 1');

    my $I = Tree->new('I');
    isa_ok($I, 'Tree');

    $G->add_child($I);

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #          / | \
    #       <A> <G> <F> 
    #            | \
    #           <H> <I>   

    cmp_ok($D->width(), '==', 6, '... D has a width of 6');
    cmp_ok($E->width(), '==', 4, '... E has a width of 4');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($G->width(), '==', 2, '... G has a width of 2');
    cmp_ok($H->width(), '==', 1, '... H has a width of 1');
    cmp_ok($I->width(), '==', 1, '... I has a width of 1');    
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');
    cmp_ok($A->width(), '==', 1, '... A has a width of 1');      

    ok($E->remove_child($A), '... removed A subtree from B tree');

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #            | \
    #           <G> <F> 
    #            | \
    #           <H> <I>  

    cmp_ok($D->width(), '==', 5, '... D has a width of 5');
    cmp_ok($E->width(), '==', 3, '... E has a width of 3');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($G->width(), '==', 2, '... G has a width of 2');
    cmp_ok($H->width(), '==', 1, '... H has a width of 1');
    cmp_ok($C->width(), '==', 1, '... C has a width of 2');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');

    # and the removed tree is ok
    cmp_ok($A->width(), '==', 1, '... A has a width of 1');

    ok($D->remove_child($E), '... removed E subtree from D tree');

    #        |
    #       <D>
    #      / | 
    #   <B> <C>

    cmp_ok($D->width(), '==', 2, '... D has a width of 2');
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');

    # and the removed trees are ok
    cmp_ok($E->width(), '==', 3, '... E has a width of 3');
    cmp_ok($F->width(), '==', 1, '... F has a width of 1');
    cmp_ok($G->width(), '==', 2, '... G has a width of 2');
    cmp_ok($H->width(), '==', 1, '... H has a width of 1');    

    ok($D->remove_child($C), '... removed C subtree from D tree');

    #        |
    #       <D>
    #      /  
    #   <B> 

    cmp_ok($D->width(), '==', 1, '... D has a width of 1');
    cmp_ok($B->width(), '==', 1, '... B has a width of 1');

    # and the removed tree is ok
    cmp_ok($C->width(), '==', 1, '... C has a width of 1');

}
