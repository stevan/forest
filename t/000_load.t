#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

use ok 'Forest';

use ok 'Forest::Tree';

use ok 'Forest::Tree::Reader';
use ok 'Forest::Tree::Reader::SimpleTextFile';

use ok 'Forest::Tree::Writer';
use ok 'Forest::Tree::Writer::SimpleASCII';
use ok 'Forest::Tree::Writer::SimpleHTML';

use ok 'Forest::Tree::Indexer';
use ok 'Forest::Tree::Indexer::SimpleUIDIndexer';

use ok 'Forest::Tree::Service';