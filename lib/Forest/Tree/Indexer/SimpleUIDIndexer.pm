
package Forest::Tree::Indexer::SimpleUIDIndexer;
use Moose;

our $VERSION = '0.0.1';

with 'Forest::Tree::Indexer';

sub build_index {
    my $self  = shift;
    my $index = $self->index;
    
    $self->tree->traverse(sub {
        my $t = shift;
        $index->{$t->uid} = $t;        
    });
    
};

no Moose; 1;

__END__

=pod

=cut