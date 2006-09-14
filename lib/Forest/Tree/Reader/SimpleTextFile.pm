
package Forest::Tree::Reader::SimpleTextFile;
use Moose;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

with 'Forest::Tree::Reader';

has 'tab_width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 4
);

## methods

method parse_line => sub {
    my ($line) = @_;
    my ($indent, $node) = ($line =~ /^(\s*)(.*)$/);
    my $depth = ((length $indent) / self->tab_width); 
    return ($depth, $node);
};

method load => sub {
        
    my $fh = *{self->source};
    my @lines = map { chomp; $_ } <$fh>;
    
    my $current_tree = self->tree;
    
    while (@lines) {
        my $line = shift @lines;
        
        next if $line =~ /^#/;
        next unless $line;
        
        my ($depth, $node) = self->parse_line($line);
        
        #warn "Depth: $depth - Node: $node - for $line";
        
        my $new_tree = self->create_new_subtree(node => $node);
        
		if ($current_tree->is_root) {
			$current_tree->add_child($new_tree);
			$current_tree = $new_tree;
			next;
		}
		
		my $tree_depth = $current_tree->depth;		
		if ($depth == $tree_depth) {	
			$current_tree->add_sibling($new_tree);
			$current_tree = $new_tree;
		} 
		elsif ($depth > $tree_depth) {
			(($depth - $tree_depth) <= 1) 
                || die "Parse Error : the difference between the depth ($depth) and " . 
                       "the tree depth ($tree_depth) is too much (" . 
                       ($depth - $tree_depth) . ") at line:\n'$line'";
			$current_tree->add_child($new_tree);
			$current_tree = $new_tree;
		} 
		elsif ($depth < $tree_depth) {
			$current_tree = $current_tree->parent while ($depth < $current_tree->depth);
			$current_tree->add_sibling($new_tree);
			$current_tree = $new_tree;	
		} 
		       
    }
};

no Moose;

1;

__END__

=pod

=cut