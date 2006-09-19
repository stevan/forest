#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Forest::Tree');
    use_ok('Forest::Tree::Reader::SimpleTextFile');
    use_ok('Forest::Tree::Indexer::SimpleUIDIndexer');
    use_ok('Forest::Tree::Service');
    use_ok('Forest::Tree::Service::AJAX');
};

{
    package My::Tree::Reader;
    use Moose;
    extends 'Forest::Tree::Reader::SimpleTextFile';
    
    sub create_new_subtree {
        shift;
        my $t = Forest::Tree->new(@_);
        $t->uid($t->node);
        $t;
    }
    
}

my $reader = My::Tree::Reader->new(source => \*DATA);
isa_ok($reader, 'My::Tree::Reader');    
isa_ok($reader, 'Forest::Tree::Reader::SimpleTextFile');

$reader->load;

my $index = Forest::Tree::Indexer::SimpleUIDIndexer->new(tree => $reader->tree);
isa_ok($index, 'Forest::Tree::Indexer::SimpleUIDIndexer');

$index->build_index;

my $service = Forest::Tree::Service::AJAX->new(tree_index => $index);
isa_ok($service, 'Forest::Tree::Service::AJAX');

is($service->get_tree_as_json('1.2.1'), 
'{"uid":"1.2.1","node":"1.2.1","is_leaf":1}', 
'... got the JSON for the tree');

is($service->get_tree_as_json('1.2.2'), 
'{"error":"Could not find tree at index (1.2.2)"}', 
'... got the error JSON');

is($service->get_children_of_tree_as_json('1.0'),
'{"uid":"1.0","children":[{"uid":"1.1","node":"1.1","is_leaf":1},{"uid":"1.2","node":"1.2","is_leaf":0}],"node":"1.0","is_leaf":0}',
'... got the children as JSON');

is($service->get_children_of_tree_as_json('1.33'),
'{"error":"Could not find tree at index (1.33)"}', 
'... got the error JSON');

__DATA__
1.0
    1.1
    1.2
        1.2.1
2.0
    2.1
3.0
4.0
    4.1
        4.1.1