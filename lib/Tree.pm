
package Tree;

use 5.6.0;

use strict;
use warnings;

our $VERSION = '0.99_00';

use Scalar::Util qw( refaddr );
use Contextual::Return;

# These are the constructors

sub new {
    my $class = shift;
    my $self = bless {
        _children => [],
        _parent => $class->_null,
        _height => 1,
        _width => 1,
    }, $class;
    return $self;
}

# These are the behaviors

sub add_child {
    my $self = shift;

    for ( @_ ) {
        ${$_->parent} = $self;
        push @{$self->children}, $_;
    }

    $self->_fix_height;
    $self->_fix_width;

    return $self;
}

sub remove_child {
    my $self = shift;

    my @return;
    for my $old (@_) {
        ${$old->parent} = $old->_null;
        @{$self->children} = grep { $_ ne $old } @{$self->children};
        push @return, $old;
    }

    $self->_fix_height;
    $self->_fix_width;

    return (
        LIST { @return }
        ARRAYREF { \@return }
        SCALAR { $return[0] }
    );
}

# These are the state-queries

sub is_root {
    my $self = shift;
    return !$self->parent;
}

sub is_leaf {
    my $self = shift;
    return $self->height == 1;
}

sub has_child {
    my $self = shift;

    my %temp = map { refaddr($_) => undef } @{$self->children};

    my $rv = 1;
    $rv &&= exists $temp{refaddr($_)}
        for @_;

    return $rv;
}

# These are the smart accessors

sub parent { 
    my $self = shift;
    return (
        SCALARREF { \($self->{_parent}) }
        DEFAULT { $self->{_parent} }
    );
}

sub children {
    my $self = shift;
    return (
        LIST { @{$self->{_children}} }
        SCALAR { scalar @{$self->{_children}} }
        ARRAYREF { $self->{_children} }
    );
}

sub height {
    my $self = shift;
    return (
        SCALARREF { \($self->{_height}) }
        DEFAULT { $self->{_height} }
    );
}

sub width {
    my $self = shift;
    return (
        SCALARREF { \($self->{_width}) }
        DEFAULT { $self->{_width} }
    );
}

# These are private convenience methods

sub _null {
    return Tree::Null->new;
}

sub _fix_height {
    my $self = shift;

    my $height = 1;
    for my $child (@{$self->children}) {
        my $temp_height = $child->height + 1;
        $height = $temp_height if $height < $temp_height;
    }

    #XXX This sucks - Contextual::Return::Value needs to change
    # to walk though any nesting
    ${$self->height} = $height + 0;

    $self->parent->_fix_height;

    return $self;
}

sub _fix_width {
    my $self = shift;

    ${$self->width} = 0;
    for my $child (@{$self->children}) {
        ${$self->width} += $child->width;
    }
    ${$self->width} ||= 1;

    return $self;
}

package Tree::Null;

#XXX Add this in once it's been thought out
#our @ISA = qw( Tree );

# There's a lot of choices that have been made to allow for
# subclassing of this package. They are:
# 1) overload uses method names and not subrefs
# 2) new() accesses a hash of singletons, not just a scalar
# 3) AUTOLOAD uses ref() instead of __PACKAGE__

# You want to be able to interrogate the null object as to
# its class, so we don't override isa() as we do can()

use overload
    '""' => 'stringify',
    '0+' => 'numify',
    'bool' => 'boolify',
        fallback => 1,
;

{
    my %singletons;
    sub new {
        my $class = shift;
        $singletons{$class} = bless \my($x), $class
            unless exists $singletons{$class};
        return $singletons{$class};
    }
}

# The null object can do anything
sub can {
    return 1;
}

{
    our $AUTOLOAD;
    sub AUTOLOAD {
        no strict 'refs';
        *{$AUTOLOAD} = sub { ref($_[0])->new };
        goto &$AUTOLOAD;
    }
}

sub stringify { return ""; }
sub numify { return 0; }
sub boolify { return; }

1;

__END__

=head1 NAME

Tree - the basic implementation of a tree

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 Constructor

=over 4

=item B<new()>

This will return a Tree object. It currently accepts no parameters.

=back

=head2 Behaviors

=over 4

=item B<add_child(@nodes)>

This will add all the @nodes as children of $self.

=item B<remove_child(@nodes)>

This will remove all the @nodes from the children of $self.

=back

=head2 State Queries

=item B<is_root()>

This will return true is $self has no parent and false otherwise.

=item B<is_leaf()>

This will return true is $self has no children and false otherwise.

=item B<has_child(@nodes)>

This will return true is $self has each of the @nodes as a child.

=back

=head2 Accessors

=over 4

=item B<parent()>

This will return the parent of $self.

=item B<children()>

This will return the children of $self. If called in list context, it will return all the children. If called in scalar context, it will return the number of children.

=item B<height()>

This will return the height of $self. A leaf has a height of 1. A parent has a height of its tallest child, plus 1.

=item B<width()>

This will return the width of $self. A leaf has a width of 1. A parent has a width equal to the sum of all the widths of its children.

=over 4

=back

=head1 BUGS

None that we are aware of.

The test suite for Tree 1.0 is based very heavily on the test suite for L<Test::Simple>, which has been heavily tested and used in a number of other major distributions, such as L<Catalyst> and rt.cpan.org.

=head1 CODE COVERAGE

We use L<Devel::Cover> to test the code coverage of my tests, below is the L<Devel::Cover> report on this module's test suite. We use TDD, which is why our coverage is so high.
 
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  File                           stmt branch   cond    sub    pod   time  total
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  blib/lib/Tree.pm              100.0  100.0  100.0  100.0  100.0  100.0  100.0
  Total                         100.0  100.0  100.0  100.0  100.0  100.0  100.0
  ---------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 ACKNOWLEDGEMENTS

=over 4

=item Stevan Little for writing Tree::Simple, upon which Tree is based.

=back

=head1 AUTHORS

Rob Kinyon E<lt>rob.kinyon@iinteractive.comE<gt>
Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

Thanks to Infinity Interactive for generously donating our time

=head1 COPYRIGHT AND LICENSE

Copyright 2004, 2005 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

