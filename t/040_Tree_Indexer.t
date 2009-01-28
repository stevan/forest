#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw/no_plan/;

BEGIN {
    use_ok('Forest::Tree');
    use_ok('Forest::Tree::Reader::SimpleTextFile');
    use_ok('Forest::Tree::Indexer');
    use_ok('Forest::Tree::Indexer::SimpleUIDIndexer');
};

{
    my $reader = Forest::Tree::Reader::SimpleTextFile->new;
    isa_ok($reader, 'Forest::Tree::Reader::SimpleTextFile');
    
    $reader->read(\*DATA);

    my $index = Forest::Tree::Indexer::SimpleUIDIndexer->new(tree => $reader->tree);
    isa_ok($index, 'Forest::Tree::Indexer::SimpleUIDIndexer');

    $index->build_index;

    my @keys = $index->get_index_keys;
    is(scalar @keys, 11, '... got the right amount of keys');

    foreach my $key (@keys) {
        my $tree = $index->get_tree_at($key);
        isa_ok($tree, 'Forest::Tree');
        is($tree->uid, $key, '... indexed by uid');
    }
}

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
