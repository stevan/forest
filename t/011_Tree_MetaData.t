#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Forest::Tree');
    use_ok('Forest::Tree::Reader::SimpleTextFile');
    use_ok('Forest::Tree::Indexer');
    use_ok('Forest::Tree::Indexer::SimpleUIDIndexer');
};


{
    {
        package My::Tree;
        use Moose;
        extends 'Forest::Tree';
           with 'Forest::Tree::Roles::MetaData';
        
        package My::Tree::Reader;
        use Moose;
        extends 'Forest::Tree::Reader::SimpleTextFile';
        
        has '+tree' => (
            default => sub { 
                My::Tree->new(
                    node      => '0.0|DEFAULT', 
                    meta_data => { number => '0.0', name => 'DEFAULT' }
                ) 
            }
        );        
        
        sub parse_line {
            my ($self, $line) = @_;
            my ($indent, $node) = ($line =~ /^(\s*)(.*)$/);
            my $depth = ((length $indent) / $self->tab_width); 
            
            my ($number, $name) = (split /\|/ => $node);
            
            my $tree = My::Tree->new(
                node      => $node,
                meta_data => { 
                    (($number) ? (number => $number) : ()), 
                    (($name)   ? (name   => $name  ) : ()),
                }
            );
            
            return ($depth, $tree);
        }
    }
    
    my $reader = My::Tree::Reader->new(source => \*DATA);
    isa_ok($reader, 'My::Tree::Reader');    
    isa_ok($reader, 'Forest::Tree::Reader::SimpleTextFile');    
    
    $reader->load;

    my $tree = $reader->tree;
    
    is($tree->node, '0.0|DEFAULT', '... got the right root node');
    is_deeply($tree->meta_data, { number => '0.0', name => 'DEFAULT' }, '... got the right metadata hash');
    is($tree->fetch_meta_data_for('number'), '0.0',     '... got the right root node metadata');    
    is($tree->fetch_meta_data_for('name'),   'DEFAULT', '... got the right root node metadata');     
    
    is($tree->get_child_at(0)->node, '1.0', '... got the right root node');
    is_deeply($tree->get_child_at(0)->meta_data, { number => '1.0' }, '... got the right metadata hash');
    is($tree->get_child_at(0)->fetch_meta_data_for('number'), '1.0',     '... got the right root node metadata');    
    is($tree->get_child_at(0)->fetch_meta_data_for('name'),   'DEFAULT', '... got the right root node metadata');       

    is($tree->get_child_at(0)->get_child_at(0)->node, '1.1|One-Point-One', '... got the right root node');
    is($tree->get_child_at(0)->get_child_at(0)->fetch_meta_data_for('number'), '1.1',     '... got the right root node metadata');    
    is($tree->get_child_at(0)->get_child_at(0)->fetch_meta_data_for('name'),   'One-Point-One', '... got the right root node metadata');    
    
    is($tree->get_child_at(0)->get_child_at(1)->node, '1.2|One-Point-Two', '... got the right root node');
    is($tree->get_child_at(0)->get_child_at(1)->fetch_meta_data_for('number'), '1.2',     '... got the right root node metadata');    
    is($tree->get_child_at(0)->get_child_at(1)->fetch_meta_data_for('name'),   'One-Point-Two', '... got the right root node metadata');    
    
    is($tree->get_child_at(0)->get_child_at(1)->get_child_at(0)->node, '1.2.1', '... got the right root node');
    is($tree->get_child_at(0)->get_child_at(1)->get_child_at(0)->fetch_meta_data_for('number'), '1.2.1',     '... got the right root node metadata');    
    is($tree->get_child_at(0)->get_child_at(1)->get_child_at(0)->fetch_meta_data_for('name'),   'One-Point-Two', '... got the right root node metadata');    
    
    is($tree->get_child_at(0)->get_child_at(1)->get_child_at(1)->node, '|One-Point-Two-Point-Two', '... got the right root node');
    is($tree->get_child_at(0)->get_child_at(1)->get_child_at(1)->fetch_meta_data_for('number'), '1.2',     '... got the right root node metadata');    
    is($tree->get_child_at(0)->get_child_at(1)->get_child_at(1)->fetch_meta_data_for('name'),   'One-Point-Two-Point-Two', '... got the right root node metadata');    
}

__DATA__
1.0
    1.1|One-Point-One
    1.2|One-Point-Two
        1.2.1
        |One-Point-Two-Point-Two