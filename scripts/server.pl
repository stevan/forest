#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Template;
use FindBin;

use lib $FindBin::Bin . '/../lib';

use Forest::Tree;
use Forest::Tree::Reader::SimpleTextFile;
use Forest::Tree::Indexer::SimpleUIDIndexer;
use Forest::Tree::Service::AJAX;

open(TREE, "<", $FindBin::Bin . "/test.tree") || die "Could not open the tree file";

my $reader = Forest::Tree::Reader::SimpleTextFile->new(
    tree   => Forest::Tree->new(node => 'root', uid => 'root'),
    source => \*TREE
);

warn "... loading tree";
$reader->load;
warn "+ tree loaded";

my $index = Forest::Tree::Indexer::SimpleUIDIndexer->new(tree => $reader->tree);

warn "... building tree index";
$index->build_index;
warn "+ tree indexed";

my $service = Forest::Tree::Service::AJAX->new(tree_index => $index);

{
    package # hide me from PAUSE
        Forest::Tree::Service::AJAX::Server;
    use base 'HTTP::Server::Simple::CGI', 'HTTP::Server::Simple::Static';
    
    sub handle_request {
        my ($self, $cgi) = @_;
        if (my $tree_id = $cgi->param('tree_id')) {
            print $service->get_children_of_tree_as_json($tree_id)
        }
        else {
            return $self->serve_static($cgi, $FindBin::Bin);
        }        
    }
}
    
Forest::Tree::Service::AJAX::Server->new()->run();    

1;
