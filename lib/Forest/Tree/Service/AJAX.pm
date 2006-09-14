
package Forest::Tree::Service::AJAX;
use Moose;
use Moose::Autobox;

use JSON::Syck ();

use version; our $VERSION = qv('0.0.1');

with 'Forest::Tree::Service';

method _prepare_tree_for_JSON => sub {
    my ($tree) = @_;
    +{
        uid        => $tree->uid,
        node       => $tree->node,
        is_leaf    => $tree->is_leaf ? 1 : 0,
    }
};

method _return_JSON_error => sub {
    my ($tree_id) = @_;
    JSON::Syck::Dump({ error => 'Could not find tree at index (' . $tree_id . ')' });
};

method get_tree_as_json => sub {
    my ($tree_id) = @_;
    
    my $tree = self->tree_index->get_tree_at($tree_id);
    
    return self->_return_JSON_error($tree_id)
        unless (blessed $tree && $tree->isa('Forest::Tree'));
    
    return JSON::Syck::Dump(self->_prepare_tree_for_JSON($tree));   
};

method get_children_of_tree_as_json => sub {
    my ($tree_id) = @_;
    
    my $tree = self->tree_index->get_tree_at($tree_id);
    
    return self->_return_JSON_error($tree_id)
        unless (blessed $tree && $tree->isa('Forest::Tree'));
    
    return JSON::Syck::Dump(
        {
            parent_uid => $tree_id,
            children   => $tree->children->map(sub { self->_prepare_tree_for_JSON($_[0]) })
        }
    );
};

1;

__END__

=pod

=cut