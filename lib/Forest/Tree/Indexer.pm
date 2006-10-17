
package Forest::Tree::Indexer;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'root' => (
    is  => 'rw',
    isa => 'Forest::Tree',
);

has 'index' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },    
);

requires 'build_index';

sub clear_index    { (shift)->index({})         }
sub get_index_keys { [ keys %{(shift)->index} ] }
sub get_root       { (shift)->root              }

sub get_tree_at {
    my ($self, $tree_id) = @_;
    $self->index->{$tree_id}    
}

1;

__END__

=pod

=cut