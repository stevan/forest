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
    
    sub _dump_for_json {
        my $self = shift;
        return {
           __meta__    => $self->meta_data,
           __uid__     => $self->uid,
           __node__    => $self->node,
           __is_leaf__ => $self->is_leaf ? 1 : 0,       
       };
    }
    
    sub as_json {
        my $self = shift;
        return JSON::Syck::Dump($self->_dump_for_json);
    }
    
    sub children_as_json {
        my $self = shift;
        return JSON::Syck::Dump(
            {
                __uid__  => $self->uid,
                children => [ map { 
                    $_->_dump_for_json           
                } @{$self->children} ]
            }
        );
    }    
    
    package My::Tree::Reader;
    use Moose;
    extends 'Forest::Tree::Reader::SimpleTextFile';
    
    sub create_new_subtree {
        my $t = My::Tree->new(@_);
        $t->uid($t->node);
        $t->meta_data->{inv} = reverse $t->node;
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
'{"__uid__":"1.2.1","__meta__":{"inv":"1.2.1"},"__is_leaf__":1,"__node__":"1.2.1"}', 
'... got the JSON for the tree');

is($service->get_tree_as_json('1.2.2'), 
'{"error":"Could not find tree at index (1.2.2)"}', 
'... got the error JSON');

is($service->get_children_of_tree_as_json('1.0'),
'{"__uid__":"1.0","children":[{"__uid__":"1.1","__meta__":{"inv":"1.1"},"__is_leaf__":1,"__node__":"1.1"},{"__uid__":"1.2","__meta__":{"inv":"2.1"},"__is_leaf__":0,"__node__":"1.2"}]}',
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