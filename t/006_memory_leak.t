use strict;
use warnings;

use Test::More;

eval "use Test::Memory::Cycle 1.02";
plan skip_all => "Test::Memory::Cycle required for testing memory leaks" if $@;

plan tests => 51;

my $CLASS = 'Tree';
use_ok( $CLASS, 'no_weak_refs' );

#diag "parental connections must be destroyed manually";

{ #diag "verify the problem exists";

    my $child = $CLASS->new();
    ok($child->is_root, '... child is a ROOT');
    my $root_string;
    {
        my $root = $CLASS->new();
        $root_string = $root . "";
        $root->add_child($child);
        ok(!$child->is_root(), '... now child is not a ROOT');

        memory_cycle_exists($child, '... there is a cycle in child');
    }

    memory_cycle_exists($child, '... root is still connected with child');
    ok(!$child->is_root(), '... now child is not a ROOT');
    ok($child->parent(), '... now child parent is still defined');
    is($child->parent() . "", $root_string, "... and child's parent is root");
}

{ #diag "this fixes the problem";

    my $child = $CLASS->new("2");
    ok($child->is_root(), '... child is a ROOT');

    {
        my $root = $CLASS->new("1");
        $root->add_child($child);
        ok(!$child->is_root(), '... now child is not a ROOT');

        memory_cycle_exists($child, '... there is a cycle in child');
        $root->DESTROY();
    }

    memory_cycle_ok($child, '... calling DESTROY on root broke the connection with child');
    ok($child->is_root(), '... now child is a ROOT again');
    ok(!$child->parent(), "... now child's parent is no longer defined");
}

{ #diag "expand the original problem and see how it effects children";
    my $tree2 = $CLASS->new("2");
    ok($tree2->is_root(), '... tree2 is a ROOT');
    ok($tree2->is_leaf(), '... tree2 is a Leaf');
    my $tree3 = $CLASS->new("3");
    ok($tree3->is_root(), '... tree3 is a ROOT');
    ok($tree3->is_leaf(), '... tree3 is a Leaf');

    {
        my $tree1 = $CLASS->new("1");
        $tree1->add_child($tree2);
        ok(!$tree2->is_root(), '... now tree2 is not a ROOT');
        $tree2->add_child($tree3);
        ok(!$tree2->is_leaf(), '... now tree2 is not a Leaf');
        ok(!$tree3->is_root(), '... tree3 is no longer a ROOT');
        ok($tree3->is_leaf(), '... but tree3 is still a Leaf');

        memory_cycle_exists($tree1, '... there is a cycle in tree1');
        memory_cycle_exists($tree2, '... there is a cycle in tree2');
        memory_cycle_exists($tree3, '... there is a cycle in tree3');
        $tree1->DESTROY();

        memory_cycle_exists($tree1, '... there is still a cycle in tree1 because of the children');
    }

    memory_cycle_exists($tree2, '... calling DESTROY on tree1 broke the connection with tree2');
    ok($tree2->is_root(), '... now tree2 is a ROOT again');
    ok(!$tree2->is_leaf(), '... now tree2 is not a leaf again');
    ok(!$tree2->parent(), '... now tree2s parent is no longer defined');
    cmp_ok($tree2->children, '==', 1, '... now tree2 has one child');
    memory_cycle_exists($tree3, '... calling DESTROY on tree1 did not break the connection betwee tree2 and tree3');
    ok(!$tree3->is_root(), '... now tree3 is not a ROOT');
    ok($tree3->is_leaf(), '... now tree3 is still a leaf');
    ok($tree3->parent(), '... now tree3s parent is still defined');
    is($tree3->parent(), $tree2, '... now tree3s parent is still tree2');
}


{ #diag "child connections are strong";
    my $tree1 = $CLASS->new("1");
    my $tree2_string;

    {
        my $tree2 = $CLASS->new("2");
        $tree1->add_child($tree2);
        $tree2_string = $tree2 . "";

        memory_cycle_exists($tree1, '... tree1 is connected to tree2');
        memory_cycle_exists($tree2, '... tree2 is connected to tree1');

        $tree2->DESTROY(); # this does not make sense to do
    }

    memory_cycle_exists($tree1, '... tree2 is still connected to tree1 because child connections are strong');
    is($tree1->children(0) . "", $tree2_string, '... tree2 is still connected to tree1');
    is($tree1->children(0)->parent(), $tree1, '... tree2s parent is tree1');
    cmp_ok($tree1->children(), '==', 1, '... tree1 has a child count of 1');
}


{ #diag "expand upon this issue";
    my $tree1 = $CLASS->new("1");
    my $tree2_string;
    my $tree3 = $CLASS->new("3");

    {
        my $tree2 = $CLASS->new("2");
        $tree1->add_child($tree2);
        $tree2_string = $tree2 . "";
        $tree2->add_child($tree3);

        memory_cycle_exists($tree1, '... tree1 is connected to tree2');
        memory_cycle_exists($tree2, '... tree2 is connected to tree1');
        memory_cycle_exists($tree3, '... tree3 is connected to tree2');

        $tree2->DESTROY(); # this does not make sense to do
    }

    memory_cycle_exists($tree1, '... tree2 is still connected to tree1 because child connections are strong');
    is($tree1->children(0) . "", $tree2_string, '... tree2 is still connected to tree1');
    is($tree1->children(0)->parent(), $tree1, '... tree2s parent is tree1');
    cmp_ok($tree1->children(), '==', 1, '... tree1 has a child count of 1');
    cmp_ok($tree1->children(0)->children(), '==', 1, '... tree2 is still connected to tree3');
    is($tree1->children(0)->children(0), $tree3, '... tree2 is still connected to tree3');
}
