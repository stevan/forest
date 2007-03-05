
package Forest::Tree::Writer::SimpleHTML;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Writer';

sub output {
    my ($self) = @_;
    my $out;    
    
    my $traversal;
    $traversal = sub {
        my $t      = shift;
        my $indent = ('    ' x $t->depth);
        
        $out .= ($indent . '<li>' . ($t->node || '\undef') . '</li>' . "\n")
            unless $t->depth == -1;
            
        unless ($t->is_leaf) {
            $out .= ($indent . '<ul>' . "\n");
            map { $traversal->($_) } @{$t->children};
            $out .= ($indent . '</ul>' . "\n");      
        }      
    };
    
    $traversal->($self->tree);
    
    return $out;
}

__PACKAGE__->meta->make_immutable();
no Moose; 1;

__END__

=pod

=cut