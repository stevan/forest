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

my $DATA = join "" => <DATA>;   

{
    package # hide me from PAUSE
        Forest::Tree::Service::AJAX::Server;
    use base 'HTTP::Server::Simple::CGI';
    
    sub handle_request {
        my ($self, $cgi) = @_;
        if (my $tree_id = $cgi->param('tree_id')) {
            print $service->get_children_of_tree_as_json($tree_id)
        }
        else {
            Template->new->process(\$DATA) or warn Template->error;                 
        }
    }
}
    
Forest::Tree::Service::AJAX::Server->new()->run();    

1;

## This is the template file to be used

__DATA__

<html>
<head>
<title>Forest::Tree::Service::AJAX example</title>
<script language="javascript">

String.prototype.parseJSON = function () {
    try {
        return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(
                this.replace(/"(\\.|[^"\\])*"/g, ''))) &&
            eval('(' + this + ')');
    } catch (e) {
        return false;
    }
};

var req;

function load_tree (tree_id) {
    
    var node = document.getElementById(tree_id);
    
    if (node.hasChildNodes()) {
        if (node.style.display == 'none') {
            node.style.display = 'block';            
        }
        else {
            node.style.display = 'none';
        }
    }
    else {
        req = new XMLHttpRequest();
    
        req.onreadystatechange = check_state;
        req.open("GET", ('/?tree_id=' + tree_id), true);
        req.send("");    
    }
}

function check_state () {
    if (req.readyState == 4) {
        if (req.status == 200) {
            var json  = req.responseText;
            var trees = json.parseJSON();
            insert_trees(trees);
        } 
        else {
            alert("There was a problem retrieving the tree:\n" + req.statusText);
        }
    }
}

function insert_trees (trees) {
    
    var node = document.getElementById(trees.parent_uid);
    var HTML = node.innerHTML;    
    
    for (var i = 0; i < trees.children.length; i++) {
        var tree = trees.children[i];
        if (tree.is_leaf == 1) {
            HTML += "<li>" + tree.node + "</li>";            
        }
        else {
            HTML += "<li><a href=\"javascript:void(0);\" onclick=\"load_tree('" + 
                    tree.uid + 
                    "')\">" + 
                    tree.node + 
                    "</a></li><ul id='" +
                    tree.uid + 
                    "'></ul>";        
        }
    }
    
    node.innerHTML = HTML;
}

</script>
</head>
<body>
<h1>Forest::Tree::Service::AJAX example</h1>
<hr/>
<ul>
<li><a href="javascript:void(0);" onclick="load_tree('root')">root</a></li>
<ul id="root"></ul>
</ul>
</body>
</html>

