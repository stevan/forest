#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

use_ok('Forest');
use_ok('Forest::Tree');
use_ok('Forest::Tree::Reader');
use_ok('Forest::Tree::Reader::SimpleTextFile');
use_ok('Forest::Tree::Writer');
use_ok('Forest::Tree::Writer::SimpleASCII');
use_ok('Forest::Tree::Writer::SimpleHTML');
use_ok('Forest::Tree::Indexer');
use_ok('Forest::Tree::Indexer::SimpleUIDIndexer');
use_ok('Forest::Tree::Service');