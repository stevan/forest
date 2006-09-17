
package Forest::Tree::Service::AJAX;
use Moose;

use JSON::Syck ();

our $VERSION = '0.0.1';

with 'Forest::Tree::Service';

sub prepare_tree_for_JSON {
    my ($self, $tree) = @_;
    +{
        uid        => $tree->uid,
        node       => $tree->node,
        is_leaf    => $tree->is_leaf ? 1 : 0,
    }
}

sub return_JSON_error {
    my ($self, $tree_id) = @_;
    JSON::Syck::Dump({ error => 'Could not find tree at index (' . $tree_id . ')' });
}

sub get_tree_as_json {
    my ($self, $tree_id) = @_;
    
    my $tree = $self->tree_index->get_tree_at($tree_id);
    
    return $self->return_JSON_error($tree_id)
        unless blessed($tree) && $tree->isa('Forest::Tree');
    
    return JSON::Syck::Dump($self->prepare_tree_for_JSON($tree));   
}

sub get_children_of_tree_as_json {
    my ($self, $tree_id) = @_;
    
    my $tree = $self->tree_index->get_tree_at($tree_id);
    
    return $self->return_JSON_error($tree_id)
        unless blessed($tree) && $tree->isa('Forest::Tree');
    
    return JSON::Syck::Dump(
        {
            parent_uid => $tree_id,
            children   => [ map { $self->prepare_tree_for_JSON($_) } @{$tree->children} ]
        }
    );
}

no Moose; 1;

__END__

=pod

=cut