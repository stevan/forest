package Tree::Persist;

use strict;
use warnings;

sub connect {
    my $class = shift;
    my ($opts) = @_;

    use Tree::Persist::File::XML;

    my $self = Tree::Persist::File::XML->new( $opts );

    $self->reload;

    my $sub = sub {
        $self->{_changes}++;
        $self->commit if $self->autocommit;
    };

    $self->{_tree}->add_event_handler({
        add_child    => $sub,
        remove_child => $sub,
        value        => $sub,
    });

    return $self;
}

sub create_datastore {
    my $class = shift;
    my ($opts) = @_;

    my $self = Tree::Persist::File::XML->new( $opts );
    $self->{_changes} = 1;
    $self->commit;

    return $class;
}

1;
__END__

=head1 NAME

Tree::Persist

=head1 SYNOPSIS

=head1 DESCRIPTION

This is meant to be a transparent persistence layer for Tree and its children. It's fully pluggable and will allow either loading, storing, and/or association with between a datastore and a tree.

=head1 METHODS

=head2 Class Methods

=over 4

=item * B<connect({ %opts })>

This will return a Tree::Persist object. C<%opts> includes:

=over 4

=item * Required: filename

This is the filename that is used as the XML datastore. The filename must exist and be in the appropriate format.

=item * Optional: autocommit

This is a boolean option that determines whether or not changes to the tree will committed to the datastore immediately or not. The default is true.

=back

=item * B<create_datastore({ %opts })>

This will create a new datastore for a tree. C<%opts> includes;

=over 4

=item * Required: tree

This is the tree that will be used to create the datastore.

=item * Required: filename

This is the filename that is used as the XML datastore. It I<will> be B<overwritten> if it exists.

=back

=back

=head2 Behaviors

=over 4

=item * B<autocommit()>

This is a boolean option that determines whether or not changes to the tree will committed to the datastore immediately or not. The default is true. This will return the current setting.

=item * B<tree()>

This returns the tree.

=item * B<commit()>

This will save all changes made to the tree associated with this Tree::Persist object.

This is a no-op if autocommit is true.

=item * B<rollback()>

This will undo all changes made to the tree since the last commit. Essentially, it performs a reload() only if autocommit is false.

This is a no-op if autocommit is true.

B<NOTE>: Any references to any of the nodes in the tree as it was before rollback() is called will B<not> refer to the same node of C<$persist->tree> after rollback().

=item * B<reload()>

This will throw out the current tree and reload it from the datastore.

B<NOTE>: Any references to any of the nodes in the tree as it was before reload() is called will B<not> refer to the same node of C<$persist->tree> after reload().

=back

=head1 ACKNOWLEDGEMENTS

=over 4

=item * 

=back

=head1 AUTHORS

Rob Kinyon E<lt>rob.kinyon@iinteractive.comE<gt>

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

Thanks to Infinity Interactive for generously donating our time.

=head1 COPYRIGHT AND LICENSE

Copyright 2004, 2005 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut
