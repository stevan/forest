package Forest::Tree::Pure;
use Moose;
use MooseX::AttributeHelpers;

use Scalar::Util 'reftype';
use List::Util   'sum', 'max';

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
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

sub _build_size {
    my $self = shift;

    if ( $self->child_count ) {
        return 1 + sum map { $_->size } @{ $self->children };
    } else {
        return 1;
    }
}

has 'height' => (
     is         => 'ro',
     isa        => 'Int',
     lazy_build => 1,
);

sub _build_height {
    my $self = shift;

    if ( $self->child_count ) {
        return 1 + max map { $_->height } @{ $self->children };
    } else {
        return 0;
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
