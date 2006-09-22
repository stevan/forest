
package Forest::Tree::Indexer::SimpleUIDIndexer;
use Moose;

our $VERSION = '0.0.1';

with 'Forest::Tree::Indexer';

sub build_index {
    my $self  = shift;
    my $root  = $self->get_root;    
    my $index = $self->index;

    (!exists $index->{$root->uid})
        || confess "Tree root has already been indexed, you must clear it before re-indexing";

    $index->{$root->uid} = $root;
    
    $root->traverse(sub {
        my $t = shift;
        (!exists $index->{$t->uid})
            || confess "Duplicate tree id (" . $t->uid . ") found";        
        $index->{$t->uid} = $t;        
    });
    
};

no Moose; 1;

__END__

=pod

=cut