
package Forest::Tree::Writer::SimpleASCII;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Writer';

sub as_string {
    my ($self) = @_;
    my $out;
    
    $self->tree->traverse(sub {
        my $t = shift;
        $out .= (('    ' x $t->depth) . ($t->node || '\undef') . "\n");
    });
    
    return $out;
}

__PACKAGE__->meta->make_immutable();
no Moose; 1;

__END__

=pod

=cut