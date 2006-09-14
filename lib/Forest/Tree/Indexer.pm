
package Forest::Tree::Indexer;
use Moose::Role;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

has 'tree' => (
    is          => 'rw',
    isa         => 'Forest::Tree',
    is_weak_ref => 1,
);

has 'index' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

# requires 'build_index';

sub get_index_keys { (shift)->index->keys }

sub get_root { (shift)->tree }

sub get_tree_at {
    my ($self, $tree_id) = @_;
    return unless $self->index->exists($tree_id);
    $self->index->at($tree_id);
}

1;

__END__

=pod

=cut