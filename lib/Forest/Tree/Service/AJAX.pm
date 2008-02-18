package Forest::Tree::Service::AJAX;
use Moose;

use JSON::Any;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Service',
     'Forest::Tree::Roles::HasNodeFormatter';

sub get_tree_as_json {
    my ($self, $tree_id, %options) = @_;
    
    my $tree = $self->tree_index->get_tree_at($tree_id);
    
    return $self->return_json_error($tree_id)
        unless blessed($tree) && $tree->isa('Forest::Tree');
    
    return $self->prepare_tree_for_json($tree, %options);   
}

## util methods

sub prepare_tree_for_json {
    my ($self, $tree, %options) = @_;

    return $tree->as_json(%options)
        if $tree->does('Forest::Tree::Roles::JSONable');

    return JSON::Any->new->encode({
        uid        => $tree->uid,
        node       => $self->node_formatter->($tree->node),
        is_leaf    => $tree->is_leaf ? 1 : 0,
        (($options{include_children}) ? (
            children => [ map { 
                {
                    uid        => $_->uid,
                    node       => $self->node_formatter->($_->node),
                    is_leaf    => $_->is_leaf ? 1 : 0,
                }            
            } @{ $tree->children } ]
        ) : ())
    });
}

sub return_json_error {
    my ($self, $tree_id) = @_;
    return JSON::Any->new->encode({ error => 'Could not find tree at index (' . $tree_id . ')' });
}

make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Forest::Tree::Service::AJAX - A service for using a Forest::Tree over an AJAX UI 

=head1 DESCRIPTION

This is not really AJAX so much since it returns JSON, so this name will likely change.
But I am leaving it for right now.

=head1 METHODS 

=over 4

=item B<get_tree_as_json ($tree, %options)>

=item B<prepare_tree_for_json ($tree, %options)>

=item B<return_json_error ($tree_id)>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
