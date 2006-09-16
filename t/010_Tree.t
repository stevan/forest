#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Exception;

BEGIN {
    use_ok('Forest::Tree');
};

my $t = Forest::Tree->new();
isa_ok($t, 'Forest::Tree');

ok($t->is_root, '... this is the tree root');
ok($t->is_leaf, '... this is the leaf');

ok(!defined $t->parent, '... no parent');
ok(!defined $t->node, '... no node value');
is_deeply($t->children, [], '... no children');
is($t->depth, -1, '... the root has a depth of -1');

my $child_1 = Forest::Tree->new(node => '1.0');
isa_ok($child_1, 'Forest::Tree');

ok($child_1->is_leaf, '... this is a leaf');
ok($child_1->is_root, '... this is a root');
is($child_1->node, '1.0', '... got the right node value');
is($child_1->depth, -1, '... the child has a depth of -1');
is_deeply($child_1->children, [], '... no children');

$t->add_child($child_1);

ok(!$t->is_leaf, '... this is no longer leaf');
is_deeply($t->children, [ $child_1 ], '... 1 child');
is($t->depth, -1, '... the root still has a depth of -1');
is($t->get_child_at(0), $child_1, '... got the right child');

ok(!$child_1->is_root, '... this is no longer a root');
ok($child_1->is_leaf, '... but this is still a leaf');
is($child_1->parent, $t, '... its parent is tree');
is($child_1->depth, 0, '... the child now has a depth of 0');

my $child_1_1 = Forest::Tree->new(node => '1.1');
isa_ok($child_1_1, 'Forest::Tree');

ok($child_1_1->is_leaf, '... this is a leaf');
ok($child_1_1->is_root, '... this is a root');
is($child_1_1->node, '1.1', '... got the right node value');
is($child_1_1->depth, -1, '... the child has a depth of -1');
is_deeply($child_1_1->children, [], '... no children');

$t->get_child_at(0)->add_child($child_1_1);

is_deeply($child_1->children, [ $child_1_1 ], '... one child');

ok(!$child_1->is_leaf, '... this is no longer a leaf');
is($child_1->depth, 0, '... the child still has a depth of 0');

ok(!$child_1_1->is_root, '... this is no longer a root');
ok($child_1_1->is_leaf, '... but this is still a leaf');
is($child_1_1->parent, $child_1, '... its parent is tree');
is($child_1_1->depth, 1, '... the child now has a depth of 1');

my $child_2 = Forest::Tree->new(node => '2.0');
isa_ok($child_2, 'Forest::Tree');

my $child_3 = Forest::Tree->new(node => '3.0');
isa_ok($child_3, 'Forest::Tree');

my $child_4 = Forest::Tree->new(node => '4.0');
isa_ok($child_4, 'Forest::Tree'); 

$child_1->add_sibling($child_4);

is_deeply($t->children, [ $child_1, $child_4 ], '... 2 children');

ok(!$child_4->is_root, '... this is no longer a root');
ok($child_4->is_leaf, '... but this is still a leaf');
is($child_4->parent, $t, '... its parent is tree');
is($child_4->depth, 0, '... the child now has a depth of 1');

$t->insert_child_at(1, $child_2);

is_deeply($t->children, [ $child_1, $child_2, $child_4 ], '... 3 children');

ok(!$child_2->is_root, '... this is no longer a root');
ok($child_2->is_leaf, '... but this is still a leaf');
is($child_2->parent, $t, '... its parent is tree');
is($child_2->depth, 0, '... the child now has a depth of 1');

$child_2->insert_sibling_at(2, $child_3);

is_deeply($t->children, [ $child_1, $child_2, $child_3, $child_4 ], '... 4 children');

ok(!$child_3->is_root, '... this is no longer a root');
ok($child_3->is_leaf, '... but this is still a leaf');
is($child_3->parent, $t, '... its parent is tree');
is($child_3->depth, 0, '... the child now has a depth of 1');

throws_ok {
    $t->add_child([]);    
} qr/Child parameter must be a Forest\:\:Tree not/, '... throws exception';

throws_ok {
    $t->add_child({});    
} qr/Child parameter must be a Forest\:\:Tree not/, '... throws exception';




