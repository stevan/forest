package Tree::Persist;

use strict;
use warnings;

our $VERSION = '0.99_01';

sub connect {
    my $class = shift;

    my $obj = $class->_instantiate( @_ );

    $obj->_reload;

    return $obj;
}

sub create_datastore {
    my $class = shift;

    my $obj = $class->_instantiate( @_ );

    $obj->_create;

    return $obj;
}

sub _instantiate {
    my $class = shift;
    my ($opts) = @_;

    my $type = delete $opts->{type};
    $type ||= 'File';

    use Tree::Persist::File::XML;
    use Tree::Persist::DB::SelfReferential;

    my $obj =
        $type eq 'File' ? Tree::Persist::File::XML->new( $opts ) :
        $type eq 'DB'   ? Tree::Persist::DB::SelfReferential->new( $opts ) :
        die "Unknown type '$type'"
    ;

    return $obj;
}

1;
__END__

=head1 NAME

Tree::Persist

=head1 SYNOPSIS

  my $persist = Tree::Persist->new({
      ...
  });

  my $tree = $persist->tree.

  $persist->autocommit( 0 );

  $tree->set_value( 'foo' );

=head1 DESCRIPTION

This is a transparent persistence layer for Tree and its children. It's fully
pluggable and will allow either loading, storing, and/or association with
between a datastore and a tree.

B<NOTE:> If you load a subtree, you will have access to the parent's id, but
the node will be considered the root for the tree you are working with.

=head1 PLUGINS

The plugins that have been written are:

=over 4

=item * L<Tree::Persist::DB::SelfReferential>

=item * L<Tree::Persist::File::XML>

=back

Please refer to their documentation for the appropriate options for
C<connect()> and C<create_datastore()>.

=head1 METHODS

=head2 Class Methods

=over 4

=item * B<connect({ %opts })>

This will return an object that will provide persistence. It will B<not> be an
object that inherits from Tree::Persist.

=item * B<create_datastore({ %opts })>

This will create a new datastore for a tree. It will then return the object
used to create that datastore, as if you had called L<connect()>.

=back

=head2 Behaviors

These behaviors apply to the object returned from C<connect()> or
C<create_datastore()>.

=over 4

=item * B<autocommit()>

This is a boolean option that determines whether or not changes to the tree
will committed to the datastore immediately or not. The default is true. This
will return the current setting.

=item * B<tree()>

This returns the tree.

=item * B<commit()>

This will save all changes made to the tree associated with this Tree::Persist
object.

This is a no-op if autocommit is true.

=item * B<rollback()>

This will undo all changes made to the tree since the last commit. If there
were any changes, it will reload the tree from the datastore.

This is a no-op if autocommit is true.

B<NOTE>: Any references to any of the nodes in the tree as it was before
rollback() is called will B<not> refer to the same node of C<$persistE<gt>tree>
after rollback().

=back

=head1 BUGS/TODO/CODE COVERAGE

Please see the relevant sections of L<Forest>.

=head1 AUTHORS

Rob Kinyon E<lt>rob.kinyon@iinteractive.comE<gt>

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

Thanks to Infinity Interactive for generously donating our time.

=head1 COPYRIGHT AND LICENSE

Copyright 2004, 2005 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut
