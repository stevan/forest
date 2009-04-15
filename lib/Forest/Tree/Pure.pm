package Forest::Tree::Pure;
use Moose;
use MooseX::AttributeHelpers;

use Scalar::Util 'reftype', 'refaddr';
use List::Util   'sum', 'max';

with qw(MooseX::Clone);

our $AUTHORITY = 'cpan:STEVAN';

has 'node' => (is => 'ro', isa => 'Item');

has 'children' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[Forest::Tree::Pure]',
    lazy      => 1,
    default   => sub { [] },
    provides  => {
        'get'   => 'get_child_at',
        'count' => 'child_count',
    },
);

has 'size' => (
    traits => [qw(NoClone)],
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

sub _build_size {
    my $self = shift;

    if ( $self->is_leaf ) {
        return 1;
    } else {
        return 1 + sum map { $_->size } @{ $self->children };
    }
}

has 'height' => (
    traits => [qw(NoClone)],
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

sub _build_height {
    my $self = shift;

    if ( $self->is_leaf ) {
        return 0;
    } else {
        return 1 + max map { $_->height } @{ $self->children };
    }
}

## informational
sub is_leaf { (shift)->child_count == 0 }

## traversal
sub traverse {
    my ($self, $func) = @_;
    (defined($func))
        || confess "Cannot traverse without traversal function";
    (reftype($func) eq "CODE")
        || die "Traversal function must be a CODE reference, not : $func";
    foreach my $child (@{ $self->children }) {
        $func->($child);
        $child->traverse($func);
    }
}

sub locate {
    my ( $self, @path ) = @_;

    if ( @path ) {
        my ( $head, @tail ) = @path;

        return $self->get_child_at($head)->locate(@tail);
    } else {
        return $self;
    }
}

sub transform {
    my ( $self, $path, $method, @args ) = @_;

    if ( @$path ) {
        my ( $i, @path ) = @$path;

        my $targ = $self->get_child_at($i);

        my $transformed = $targ->transform(\@path, $method, @args);

        if ( refaddr($transformed) == refaddr($targ) ) {
            return $self;
        } else {
            return $self->set_child_at( $i => $transformed );
        }
    } else {
        return $self->$method(@args);
    }
}

sub set_node {
    my ( $self, $node ) = @_;

    $self->clone( node => $node );
}

sub replace {
    my ( $self, $replacement ) = @_;

    return $replacement;
}

sub add_children {
    my ( $self, @additional_children ) = @_;

    foreach my $child ( @additional_children ) {
        (blessed($child) && $child->isa(ref $self))
            || confess "Child parameter must be a " . ref($self) . " not (" . (defined $child ? $child : 'undef') . ")";
    }

    my @children = @{ $self->children };

    push @children, @additional_children;

    return $self->clone( children => \@children );
}

sub add_child {
    my ( $self, $child ) = @_;

    $self->add_children($child);
}

sub set_child_at {
    my ( $self, $index, $child ) = @_;

    (blessed($child) && $child->isa(ref $self))
        || confess "Child parameter must be a " . ref($self) . " not (" . (defined $child ? $child : 'undef') . ")";

    my @children = @{ $self->children };

    $children[$index] = $child;

    $self->clone( children => \@children );
}

sub remove_child_at {
    my ( $self, $index ) = @_;

    my @children = @{ $self->children };

    splice @children, $index, 1;

    $self->clone( children => \@children );

}

sub insert_child_at {
    my ( $self, $index, $child ) = @_;

    (blessed($child) && $child->isa('Forest::Tree::Pure'))
        || confess "Child parameter must be a Forest::Tree::Pure not (" . (defined $child ? $child : 'undef') . ")";

    my @children = @{ $self->children };

    splice @children, $index, 0, $child;

    $self->clone( children => \@children );
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Forest::Tree - An n-ary tree

=head1 SYNOPSIS

  use Forest::Tree;

  my $t = Forest::Tree::Pure->new(
      node     => 1,
      children => [
          Forest::Tree->new(
              node     => 1.1,
              children => [
                  Forest::Tree->new(node => 1.1.1),
                  Forest::Tree->new(node => 1.1.2),                
                  Forest::Tree->new(node => 1.1.3),                
              ]
          ),
          Forest::Tree->new(node => 1.2),
          Forest::Tree->new(
              node     => 1.3,
              children => [
                  Forest::Tree->new(node => 1.3.1),
                  Forest::Tree->new(node => 1.3.2),                
              ]
          ),                                                
      ]
  );
  
  $t->traverse(sub {
      my $t = shift;
      print(('    ' x $t->depth) . ($t->node || '\undef') . "\n");
  });

=head1 DESCRIPTION

This module is a base class for L<Forest::Tree> providing functionality for immutable trees.

There is no parent, and changing of data is not supported.

This class is appropriate when many tree roots share the same children (e.g. in
a versioned tree).

=head1 ATTRIBUTES

=over 4

=item I<node>

=item I<children>

=over 4 

=item B<get_child_at ($index)>

Return the child at this position. (zero-base index)

=item B<child_count>

Returns the number of children this tree has

=back

=item I<size>

=over 4

=item B<size>

=item B<has_size>

=item B<clear_size>

=back

=item I<height>

=over 4

=item B<height>

=item B<has_height>

=item B<clear_height>

=back

=back

=head1 METHODS

=over 4

=item B<is_leaf>

True if the current tree has no children

=item B<traverse (\&func)>

Takes a reference to a subroutine and traverses the tree applying this subroutine to
every descendant.

=item B<add_children (@children)>

=item B<add_child ($child)>

Create a new tree node with the children appended.

The children must inherit C<Forest::Tree::Pure>

Note that this method does B<not> mutate the tree, instead it clones and
returns a tree with overridden children.

=item B<insert_child_at ($index, $child)>

Insert a child at this position. (zero-base index)

Returns a derived tree with overridden children.

=item B<remove_child_at ($index)>

Remove the child at this position. (zero-base index)

Returns a derived tree with overridden children.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2009 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
