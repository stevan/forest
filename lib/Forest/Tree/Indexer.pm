
package Forest::Tree::Indexer;
use Moose::Role;

our $VERSION = '0.0.1';

has 'tree' => (
    is  => 'rw',
    isa => 'Forest::Tree',
);

has 'index' => (
    is      => 'rw',
    isa     => 'HashRef',
);

# requires 'build_index';

sub get_index_keys { [ keys %{(shift)->index} ] }

sub get_root { (shift)->tree }

sub get_tree_at {
    my ($self, $tree_id) = @_;
    $self->index->{$tree_id}    
}

1;

__END__

=pod

=cut