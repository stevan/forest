
package Forest::Tree::Service::AJAX;
use Moose;

use JSON::Syck ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Service';

sub get_tree_as_json {
    my ($self, $tree_id, %options) = @_;
    
    my $tree = $self->tree_index->get_tree_at($tree_id);
    
    return $self->return_JSON_error($tree_id)
        unless blessed($tree) && $tree->isa('Forest::Tree');
    
    return $self->prepare_tree_for_JSON($tree, %options);   
}

## util methods

sub prepare_tree_for_JSON {
    my ($self, $tree, %options) = @_;

    return $tree->as_json(%options)
        if $tree->does('Forest::Tree::Roles::JSONable');

    return JSON::Syck::Dump({
        uid        => $tree->uid,
        node       => $tree->node,
        is_leaf    => $tree->is_leaf ? 1 : 0,
        (($options{include_children}) ? (
            children => [ map { 
                {
                    uid        => $_->uid,
                    node       => $_->node,
                    is_leaf    => $_->is_leaf ? 1 : 0,
                }            
            } @{$tree->children} ]
        ) : ())
    });
}

sub return_JSON_error {
    my ($self, $tree_id) = @_;
    JSON::Syck::Dump({ error => 'Could not find tree at index (' . $tree_id . ')' });
}

no Moose; 1;

__END__

=pod

=cut