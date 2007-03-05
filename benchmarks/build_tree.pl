#!/usr/bin/perl

use strict;
use warnings;

use FindBin;

use lib $FindBin::Bin . '/../lib';

use Forest::Tree;
use Forest::Tree::Reader::SimpleTextFile;

my $tree = $FindBin::Bin . "/../scripts/test.tree.big";

open(TREE, "<", $tree) || die "Could not open the tree file :  $tree : because : $!";

my $reader = Forest::Tree::Reader::SimpleTextFile->new(
    tree   => Forest::Tree->new(node => 'root', uid => 'root'),
    source => \*TREE
);

warn "... loading tree";
$reader->load;
warn "+ tree loaded";

close TREE || die "Could not close the tree file : $tree";

warn "closing";