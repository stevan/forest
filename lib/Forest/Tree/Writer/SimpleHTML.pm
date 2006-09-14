
package Forest::Tree::Writer::SimpleHTML;
use Moose;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

with 'Forest::Tree::Writer';

method output => sub {
    my $out;
    
    sub {
        my $f = shift;
        sub {
            my $t      = shift;
            my $indent = ('    ' x $t->depth);
            
            $out .= ($indent . '<li>' . ($t->node || '\undef') . '</li>' . "\n")
                unless $t->depth == -1;
                
            unless ($t->is_leaf) {
                $out .= ($indent . '<ul>' . "\n");
                $t->children->map($f);
                $out .= ($indent . '</ul>' . "\n");      
            }      
        }
    }->y->(self->tree);
    
    return $out;
};

no Moose;

1;

__END__

=pod

=cut