
package Tree;

use 5.6.0;

use strict;
use warnings;

our $VERSION = '0.99_00';

use Scalar::Util qw( blessed refaddr weaken );
use Contextual::Return;

my %CONFIG = (
    use_weak_refs => 1,
);

sub import {
    shift;
    for (@_) {
        if ( lc($_) eq 'no_weak_refs' ) {
            $CONFIG{ use_weak_refs } = 0;
        }
        elsif ( lc($_) eq 'use_weak_refs' ) {
            $CONFIG{ use_weak_refs } = 1;
        }
    }
}

# These are the class methods

my %error_handlers = (
    'quiet' => sub {
        my $node = shift;
        $node->last_error( join "\n", @_);
        return;
    },
    'warn' => sub {
        my $node = shift;
        $node->last_error( join "\n", @_);
        warn @_;
        return;
    },
    'die' => sub {
        my $node = shift;
        $node->last_error( join "\n", @_);
        die @_;
    },
);

sub QUIET { return $error_handlers{ 'quiet' } } 
sub WARN  { return $error_handlers{ 'warn' } } 
sub DIE   { return $error_handlers{ 'die' } } 

# The default error handler is quiet
my $ERROR_HANDLER = $error_handlers{ 'quiet' };

sub new {
    my $class = shift;
    my $self = bless {
        _children => [],
        _parent => $class->_null,
        _height => 1,
        _width => 1,
        _depth => 0,
        _error_handler => $ERROR_HANDLER,
        _root => undef,
    }, $class;
    $self->_set_root( $self );
    return $self;
}

# These are the behaviors

sub add_child {
    my $self = shift;
    my @nodes = @_;

    $self->last_error( undef );

    my $index;
    if ( @nodes >= 2 ) {
        if ( !blessed($nodes[0]) ) {
            my ($at) = shift @nodes;
            $index = shift @nodes;

            if ( defined $index ) {
                unless ( $index =~ /^-?\d+$/ ) {
                    return $self->error( "add_child(): '$index' is not a legal index" );
                }

                if ( $index > $self->children || $self->children + $index < 0 ) {
                    return $self->error( "add_child(): '$index' is out-of-bounds" );
                }
            }
        }
        elsif ( !blessed( $nodes[$#nodes - 1] ) ) {
            $index = pop @nodes;
            my ($at) = pop @nodes;

            if ( defined $index ) {
                unless ( $index =~ /^-?\d+$/ ) {
                    return $self->error( "add_child(): '$index' is not a legal index" );
                }

                if ( $index > $self->children || $self->children + $index < 0 ) {
                    return $self->error( "add_child(): '$index' is out-of-bounds" );
                }
            }
        }
    }

    unless ( @nodes ) {
        return $self->error( "add_child(): No children passed in" );
    }

    for my $node ( @nodes ) {
        unless ( blessed($node) && $node->isa( 'Tree' ) ) {
            return $self->error( "add_child(): '$node' is not a Tree" );
        }

        if ( $node->root eq $self->root ) {
            return $self->error( "add_child(): Cannot add a node in the tree back into the tree" );
        }

        if ( $node->parent ) {
            return $self->error( "add_child(): Cannot add a child to another parent" );
        }
    }

    for my $node ( @nodes ) {
        $node->_set_parent( $self );
        $node->_set_root( $self->root );
        $node->_fix_depth;
    }

    if ( defined $index ) {
        if ( $index ) {
            splice @{$self->children}, $index, 0, @nodes;
        }
        else {
            unshift @{$self->children}, @nodes;
        }
    }
    else {
        push @{$self->children}, @nodes;
    }

    $self->_fix_height;
    $self->_fix_width;

    return $self;
}

sub remove_child {
    my $self = shift;
    my @nodes = @_;

    $self->last_error( undef );

    unless ( @nodes ) {
        return $self->error( "remove_child(): Nothing to remove" );
    }

    my @indices;
    foreach my $proto (@nodes) {
        if ( !defined( $proto ) ) {
            return $self->error( "remove_child(): 'undef' is out-of-bounds" );
        }

        if ( !blessed( $proto ) ) {
            unless ( $proto =~ /^-?\d+$/ ) {
                return $self->error( "remove_child(): '$proto' is not a legal index" );
            }

            if ( $proto >= $self->children || $self->children + $proto <= 0 ) {
                return $self->error( "remove_child(): '$proto' is out-of-bounds" );
            }

            push @indices, $proto;
        }
        else {
            my ($index) = $self->has_child( $proto );

            unless ( defined $index ) {
                return $self->error( "remove_child(): '$proto' not found" );
            }

            push @indices, $index;
        }
    }

    my @return;
    for my $idx (sort { $b <=> $a } @indices) {
        my $node = splice @{$self->children}, $idx, 1;
        $node->_set_parent( $node->_null );
        $node->_set_root( $node );
        $node->_fix_depth;

        push @return, $node;
    }

    $self->_fix_height;
    $self->_fix_width;

    return (
        DEFAULT { @return }
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
    my @nodes = @_;

    my @children = $self->children;
    my %temp = map { refaddr($children[$_]) => $_ } 0 .. $#children;

    return
        BOOL { 
            my $rv = 1;
            $rv &&= exists $temp{refaddr($_)}
                for @nodes;
            return $rv;
        }
        SCALAR {
            return $temp{refaddr($nodes[0])};
        }
        LIST {
            return map { $temp{refaddr($_)} } @nodes;
        }
    ;
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
    if ( @_ ) {
        my @idx = @_;
        return @{$self->{_children}}[@idx];
    }
    else {
        return (
            DEFAULT { @{$self->{_children}} }
            SCALAR { scalar @{$self->{_children}} }
            ARRAYREF { $self->{_children} }
        );
    }
}

sub root {
    my $self = shift;
    return (
        SCALARREF { \($self->{_root}) }
        DEFAULT { $self->{_root} }
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

sub depth {
    my $self = shift;
    return (
        SCALARREF { \($self->{_depth}) }
        DEFAULT { $self->{_depth} }
    );
}

sub error_handler {
    my $self = shift;

    if ( !blessed( $self ) ) {
        my $old = $ERROR_HANDLER;
        $ERROR_HANDLER = shift if @_;
        return $old;
    }

    my $root = $self->root;
    my $old = $root->{_error_handler};
    $root->{_error_handler} = shift if @_;
    return $old;
}

sub error {
    my $self = shift;
    my @args = @_;

    return $self->error_handler->( $self, @_ );
}

sub last_error {
    my $self = shift;
    $self->root->{_last_error} = shift if @_;
    return $self->root->{_last_error};
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

    $self->parent->_fix_width;

    return $self;
}

sub _fix_depth {
    my $self = shift;

    if ( $self->is_root ) {
        ${$self->depth} = 0;
    }
    else {
        ${$self->depth} = $self->parent->depth + 1;
    }

    for my $child (@{$self->children}) {
        $child->_fix_depth;
    }

    return $self;
}

sub _set_parent {
    my $self = shift;
    my ($value) = @_;

    ${$self->parent} = $value;
    weaken( $self->{_parent} ) if $CONFIG{ use_weak_refs };

    return;
}

sub _set_root {
    my $self = shift;
    my ($value) = @_;

    ${$self->root} = $value;

    # Propagate the root-change down to all children
    # Because this is called from DESTROY, we need to verify
    # that the child still exists because destruction in Perl5
    # is neither ordered nor timely.
    for my $child ( grep { $_ } @{$self->children} ) {
        $child->_set_root( $value );
    }

    weaken( $self->{_root} ) if $CONFIG{ use_weak_refs };

    return;
}

# These are the book-keeping methods

sub DESTROY {
    my $self = shift;

    return if $CONFIG{ use_weak_refs };

    $self->_set_root( $self->_null );
    foreach my $child (grep { $_ } @{$self->children}) {
        $child->_set_parent( $child->_null );
    }
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

This is meant to be a full-featured replacement for L<Tree::Simple>.

=head1 METHODS

=head2 Constructor

=over 4

=item B<new()>

This will return a Tree object. It currently accepts no parameters.

=back

=head2 Behaviors

=over 4

=item B<add_child(@nodes)>

This will add all the @nodes as children of $self. If the first two or last two parameters are of the form C<at =E<gt> $idx>, @nodes will be added starting at that index. If C<$idx> is negative, it will start that many in from the end. So, C<$idx == -1> will add @nodes before the last element of the children. If $idx is undefined, then it act as a push(). If $idx is 0, then it will act as an unshift.

=item B<remove_child(@nodes)>

This will remove all the @nodes from the children of $self. You can either pass in the actual child object you wish to remove, the index of the child you wish to remove, or a combination of both.

=back

All behaviors will reset last_error().

=head2 State Queries

=over 4

=item B<is_root()>

This will return true is $self has no parent and false otherwise.

=item B<is_leaf()>

This will return true is $self has no children and false otherwise.

=item B<has_child(@nodes)>

If called in a boolean context, this will return true is $self has each of the @nodes as a child. If called in a list context, it will map back the list of indices for each of the @nodes. If called in a scalar, non-boolean context, it will return back the index for C<$nodes[0]>.

=back

=head2 Accessors

=over 4

=item B<parent()>

This will return the parent of $self.

=item B<children( [ $idx, [$idx, ..] ] )>

This will return the children of $self. If called in list context, it will return all the children. If called in scalar context, it will return the number of children.

You may optionally pass in a list of indices to retrieve. This will return the children in the order you asked for them. This is very much like an arrayslice.

=item B<root()>

This will return the root node of the tree that $self is in. The root of the root node is itself.

=item B<height()>

This will return the height of $self. A leaf has a height of 1. A parent has a height of its tallest child, plus 1.

=item B<width()>

This will return the width of $self. A leaf has a width of 1. A parent has a width equal to the sum of all the widths of its children.

=item B<depth()>

This will return the depth of $self. A root has a depth of 0. A child has the depth of its parent, plus 1.

This is the distance from the root. It's useful for things like pretty-printing the tree.

=back

=head1 ERROR HANDLING

Describe what the default error handlers do and what a custom error handler is expected to do.

=head2 Error-related methods

=over 4

=item B<error_handler( [ $handler ] )>

This will return the current error handler for the tree. If a value is passed in, then it will be used to set the error handler for the tree.

If called as a class method, this will instead work with the default error handler.

=item B<error( $error, [ arg1 [, arg2 ...] ] )>

Call this when you wish to report an error using the currently defined error_handler for the tree. The only guaranteed parameter is an error string describing the issue. There may be other arguments, and you may certainly provide other arguments in your subclass to be passed to your custom handler.

=item B<last_error()>

If an error occurred during the last behavior, this will return the error string. It is reset only when a behavior is called.

=back

=head2 Default error handlers

=over 4

=item QUIET

Use this error handler if you want to have quiet error-handling. The last_error method will retrieve the error from the last operation, if there was one. If an error occurs, the operation will return undefined.

=item WARN

=item DIE

=back

=head1 CIRCULAR REFERENCES

Copy the text from L<Tree::Simple>, rewording appropriately.

=head1 BUGS

None that we are aware of.

The test suite for Tree 1.0 is based very heavily on the test suite for L<Test::Simple>, which has been heavily tested and used in a number of other major distributions, such as L<Catalyst> and rt.cpan.org.

=head1 CODE COVERAGE

We use L<Devel::Cover> to test the code coverage of our tests. Below is the L<Devel::Cover> report on this module's test suite. We use TDD, which is why our coverage is so high.
 
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  File                           stmt branch   cond    sub    pod   time  total
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  blib/lib/Tree.pm              100.0   98.5  100.0  100.0  100.0  100.0   99.8
  Total                         100.0   98.5  100.0  100.0  100.0  100.0   99.8
  ---------------------------- ------ ------ ------ ------ ------ ------ ------

=head2 Missing Tests

=over 4

=item * A test on import where something is passed in that isn't an expected value.

=back

=head1 ACKNOWLEDGEMENTS

=over 4

=item Stevan Little for writing L<Tree::Simple>, upon which Tree is based.

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

