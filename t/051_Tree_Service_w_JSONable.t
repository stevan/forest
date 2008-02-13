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
    use_ok('Forest::Tree::Roles::JSONable');    
};

{
    package My::Tree;
    use Moose;

    extends 'Forest::Tree';
       with 'Forest::Tree::Roles::JSONable',
            'Forest::Tree::Roles::MetaData';
    
    sub as_json {
        my ($tree, %options) = @_;

        return JSON::Any->new->encode({
            __meta__    => $tree->meta_data,
            __uid__     => $tree->uid,
            __node__    => $tree->node,
            __is_leaf__ => $tree->is_leaf ? 1 : 0,
            (($options{include_children}) ? (
                children => [ map { 
                    {
                        __meta__    => $_->meta_data,
                        __uid__     => $_->uid,
                        __node__    => $_->node,
                        __is_leaf__ => $_->is_leaf ? 1 : 0,
                    }            
                } @{$tree->children} ]
            ) : ())
        });
    } 
    
    __PACKAGE__->meta->make_immutable();
    
    package My::Tree::Reader;
    use Moose;
    extends 'Forest::Tree::Reader::SimpleTextFile';
    
    sub create_new_subtree {
        shift;
        my $t = My::Tree->new(@_);
        $t->uid($t->node);
        $t->meta_data->{inv} = reverse $t->node;
        $t;
    }
    
    __PACKAGE__->meta->make_immutable();
    
}

my $reader = My::Tree::Reader->new;
isa_ok($reader, 'My::Tree::Reader');    
isa_ok($reader, 'Forest::Tree::Reader::SimpleTextFile');

$reader->read(\*DATA);

my $index = Forest::Tree::Indexer::SimpleUIDIndexer->new(tree => $reader->tree);
isa_ok($index, 'Forest::Tree::Indexer::SimpleUIDIndexer');

$index->build_index;

my $service = Forest::Tree::Service::AJAX->new(tree_index => $index);
isa_ok($service, 'Forest::Tree::Service::AJAX');

is($service->get_tree_as_json('1.2.1'), 
'{"__uid__":"1.2.1","__meta__":{"inv":"1.2.1"},"__is_leaf__":1,"__node__":"1.2.1"}', 
'... got the JSON for the tree');

is($service->get_tree_as_json('1.2.2'), 
'{"error":"Could not find tree at index (1.2.2)"}', 
'... got the error JSON');

is($service->get_tree_as_json('1.0' => (include_children => 1)),
'{"__uid__":"1.0","__meta__":{"inv":"0.1"},"children":[{"__uid__":"1.1","__meta__":{"inv":"1.1"},"__is_leaf__":1,"__node__":"1.1"},{"__uid__":"1.2","__meta__":{"inv":"2.1"},"__is_leaf__":0,"__node__":"1.2"}],"__is_leaf__":0,"__node__":"1.0"}',
'... got the children as JSON');

is($service->get_tree_as_json('1.33' => (include_children => 1)),
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