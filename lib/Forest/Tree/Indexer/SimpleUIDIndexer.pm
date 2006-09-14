
package Forest::Tree::Indexer::SimpleUIDIndexer;
use Moose;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

with 'Forest::Tree::Indexer';

method build_index => sub {
    my $index = self->index;
    
    sub {
        my $f = shift;
        sub {
            my $t = shift;
            $index->put($t->uid, $t);    
            $t->children->map($f);      
        }
    }->y->(self->tree);
    
};

no Moose;

1;

__END__

=pod

=cut