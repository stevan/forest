
package Forest::Tree::Writer::SimpleASCII;
use Moose;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

with 'Forest::Tree::Writer';

method output => sub {
    my $out;
    
    sub {
        my $f = shift;
        sub {
            my $t = shift;
            $out .= (('    ' x $t->depth) . ($t->node || '\undef') . "\n")
                unless $t->depth == -1;
            $t->children->map($f);
        }
    }->y->(self->tree);
    
    return $out;
};

no Moose;

1;

__END__

=pod

=cut