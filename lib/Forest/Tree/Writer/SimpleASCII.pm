
package Forest::Tree::Writer::SimpleASCII;
use Moose;

our $VERSION = '0.0.1';

with 'Forest::Tree::Writer';

sub output {
    my ($self) = @_;
    my $out;
    
    $self->tree->traverse(sub {
        my $t = shift;
        $out .= (('    ' x $t->depth) . ($t->node || '\undef') . "\n");
    });
    
    return $out;
}

no Moose; 1;

__END__

=pod

=cut