
package Forest::Tree::Reader::SimpleTextFile;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Reader';

has 'tab_width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 4
);

## methods

# NOTE:
# this could become a required method
# or perhaps some kind of attribute set
# - SL
sub create_new_subtree { 
    my ($self, %options) = @_;
    my $node = $options{node};
    if (blessed($node) && $node->isa('Forest::Tree')) {
        return $node;
    }
    else {
        return Forest::Tree->new(%options);
    }    
}

# FIXME:
# this shoul become an attribute 
# so that it can be overridden easily
# - SL
sub parse_line {
    my ($self, $line) = @_;
    my ($indent, $node) = ($line =~ /^(\s*)(.*)$/);
    my $depth = ((length $indent) / $self->tab_width); 
    return ($depth, $node);
}

# FIXME:
# this can be moved into the 
# role actually, and we just need
# to make sure we have enough hooks 
# to be able to override all the 
# bits we need.
# - SL
sub load {
    my $self = shift;
    
    my $fh           = *{$self->source};
    my $current_tree = $self->tree;
    
    while (my $line = <$fh>) {
        
        chomp($line);
        
        next if !$line || $line =~ /^#/;
        
        my ($depth, $node) = $self->parse_line($line);
        
        #warn "Depth: $depth - Node: $node - for $line";
        
        my $new_tree = $self->create_new_subtree(node => $node);
        
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

__PACKAGE__->meta->make_immutable();
no Moose; 1;

__END__

=pod

=cut