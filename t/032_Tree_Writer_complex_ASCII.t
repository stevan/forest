#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Forest::Tree');
    use_ok('Forest::Tree::Reader::SimpleTextFile');
    use_ok('Forest::Tree::Writer');
    use_ok('Forest::Tree::Writer::ASCIIWithBranches');
};

my $reader = Forest::Tree::Reader::SimpleTextFile->new;
$reader->read(\*DATA);

{
    my $w = Forest::Tree::Writer::ASCIIWithBranches->new(tree => $reader->tree);
    isa_ok($w, 'Forest::Tree::Writer::ASCIIWithBranches');

    isa_ok($w->tree, 'Forest::Tree');

    # FOR DEBUGGIN
    #use Test::Differences;
    #eq_or_diff($w->as_string,
        
    is($w->as_string,        
q{root
   |---1.0
   |   |---1.1
   |   |---1.2
   |       |---1.2.1
   |---2.0
   |   |---2.1
   |---3.0
   |---4.0
       |---4.1
           |---4.1.1
}, '.... got the right output');

}

__DATA__
root
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