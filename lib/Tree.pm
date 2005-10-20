package Tree;

use 5.6.0;

use strict;
use warnings;

our $VERSION = '1.00';

use Scalar::Util qw( blessed refaddr weaken );
use Contextual::Return;

use base 'Tree::Fast';

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

sub _init {
    my $self = shift;

    $self->SUPER::_init( @_ );

    $self->{_height} = 1,
    $self->{_width} = 1,
    $self->{_depth} = 0,

    $self->{_error_handler} = $ERROR_HANDLER,
    $self->{_last_error} = undef;

    $self->{_handlers} = {
        add_child    => [],
        remove_child => [],
        value        => [],
    };

    $self->{_root} = undef,
    $self->_set_root( $self );

    $self->{_meta} = {};

    return $self;
}

# These are the behaviors

sub add_child {
    my $self = shift;
    my @nodes = @_;

    $self->last_error( undef );

    my $index;
    if ( @nodes >= 2 ) {
        my $num_children = () = $self->children;
        if ( !blessed($nodes[0]) ) {
            my ($at) = shift @nodes;
            $index = shift @nodes;

            if ( defined $index ) {
                unless ( $index =~ /^-?\d+$/ ) {
                    return $self->error( "add_child(): '$index' is not a legal index" );
                }

                if ( $index > $num_children || $num_children + $index < 0 ) {
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

                if ( $index > $num_children || $num_children + $index < 0 ) {
                    return $self->error( "add_child(): '$index' is out-of-bounds" );
                }
            }
        }
    }

    unless ( @nodes ) {
        return $self->error( "add_child(): No children passed in" );
    }

    for my $node ( @nodes ) {
        unless ( blessed($node) && $node->isa( __PACKAGE__ ) ) {
            return $self->error( "add_child(): '$node' is not a " . __PACKAGE__ );
        }

        if ( $node->root eq $self->root ) {
            return $self->error( "add_child(): Cannot add a node in the tree back into the tree" );
        }

        if ( $node->parent ) {
            return $self->error( "add_child(): Cannot add a child to another parent" );
        }
    }

    $self->SUPER::add_child( (defined $index ? $index : () ), @nodes );

    for my $node ( @nodes ) {
        $node->_set_root( $self->root );
        $node->_fix_depth;
    }

    $self->_fix_height;
    $self->_fix_width;

    $self->event( 'add_child', $self, @_ );

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
    my $num_children = () = $self->children;
    foreach my $proto (@nodes) {
        if ( !defined( $proto ) ) {
            return $self->error( "remove_child(): 'undef' is out-of-bounds" );
        }

        if ( !blessed( $proto ) ) {
            unless ( $proto =~ /^-?\d+$/ ) {
                return $self->error( "remove_child(): '$proto' is not a legal index" );
            }

            if ( $proto >= $num_children || $num_children + $proto <= 0 ) {
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

    my @return = $self->SUPER::remove_child( @indices );

    for my $node ( @return ) {
        $node->_set_root( $node );
        $node->_fix_depth;
    }

    $self->_fix_height;
    $self->_fix_width;

    $self->event( 'remove_child', $self, @_ );

    return (
        DEFAULT { @return }
        ARRAYREF { \@return }
        SCALAR { $return[0] }
    );
}

sub add_event_handler {
    my $self = shift;
    my ($opts) = @_;

    while ( my ($type,$handler) = each %$opts ) {
        push @{$self->{_handlers}{$type}}, $handler;
    }

    return $self;
}

sub event {
    my $self = shift;
    my ( $type, @args ) = @_;

    foreach my $handler ( @{$self->{_handlers}{$type}} ) {
        $handler->( @args );
    }

    $self->parent->event( @_ );

    return $self;
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

sub root {
    my $self = shift;
    return $self->{_root};
}

sub _set_root {
    my $self = shift;

    $self->{_root} = shift;
    weaken( $self->{_root} );

    # Propagate the root-change down to all children
    # Because this is called from DESTROY, we need to verify
    # that the child still exists because destruction in Perl5
    # is neither ordered nor timely.

    $_->_set_root( $self->{_root} )
        for grep { $_ } @{$self->{_children}};

    return $self;
}

for my $name ( qw( height width depth ) ) {
    no strict 'refs';

    *{ __PACKAGE__ . "::${name}" } = sub {
        use strict;
        my $self = shift;
        return $self->{"_${name}"};
    };
}

sub meta {
    my $self = shift;
    return $self->{_meta};
}

sub size {
    my $self = shift;
    my $size = 1;
    $size += $_->size for $self->children;
    return $size;
}

sub set_value {
    my $self = shift;

    my $old_value = $self->value();
    $self->SUPER::set_value( @_ );

    $self->event( 'value', $self, $old_value );

    return $self;
}

# These are the error-handling functions

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

sub _fix_height {
    my $self = shift;

    my $height = 1;
    for my $child ($self->children) {
        my $temp_height = $child->height + 1;
        $height = $temp_height if $height < $temp_height;
    }

    $self->{_height} = $height;

    $self->parent->_fix_height;

    return $self;
}

sub _fix_width {
    my $self = shift;

    my $width = 0;
    $width += $_->width for $self->children;

    $self->{_width} = $width || 1;

    $self->parent->_fix_width;

    return $self;
}

sub _fix_depth {
    my $self = shift;

    if ( $self->is_root ) {
        $self->{_depth} = 0;
    }
    else {
        $self->{_depth} = $self->parent->depth + 1;
    }

    $_->_fix_depth for $self->children;

    return $self;
}

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

=item B<new([$value])>

This will return a Tree object. It will accept one parameter which, if passed, will become the value (accessible by L<value()>). All other parameters will be ignored.

If you call C<$tree->new([$value])>, it will instead call C<clone()>, then set the value of the clone to $value.

=item B<clone()>

This will return a clone of C<$tree>. The clone will be a root tree, but all children will be cloned.

If you call <Tree->clone([$value])>, it will instead call C<new()>.

B<NOTE:> the value is merely a shallow copy. This means that all references will be kept.

=back

=head2 Behaviors

=over 4

=item B<add_child(@nodes)>

This will add all the @nodes as children of C<$tree>. If the first two or last two parameters are of the form C<at =E<gt> $idx>, @nodes will be added starting at that index. If C<$idx> is negative, it will start that many in from the end. So, C<$idx == -1> will add @nodes before the last element of the children. If $idx is undefined, then it act as a push(). If $idx is 0, then it will act as an unshift.

=item B<remove_child(@nodes)>

This will remove all the @nodes from the children of C<$tree>. You can either pass in the actual child object you wish to remove, the index of the child you wish to remove, or a combination of both.

=item B<mirror()>

This will modify the tree such that it is a mirror of what it was before. This means that the order of all children is reversed.

B<NOTE>: This is a destructive action. It I<will> modify the tree's internal structure. If you wish to get a mirror, yet keep the original tree intact, use C<my $mirror = $tree->clone->mirror;>

=item B<traverse( [$order] )>

This will return a list of the nodes in the given traversal order. The default traversal order is pre-order.

The various traversal orders do the following steps:

=over 4

=item * Pre-order (aka Prefix traversal)

This will return the node, then the first sub tree in pre-order traversal, then the next sub tree, etc.

Use C<$tree->PRE_ORDER> as the C<$order>.

=item * Post-order (aka Prefix traversal)

This will return the each sub-tree in post-order traversal, then the node.

Use C<$tree->POST_ORDER> as the C<$order>.

=item * Level-order (aka Prefix traversal)

This will return the node, then the all children of the node, then all grandchildren of the node, etc.

Use C<$tree->LEVEL_ORDER> as the C<$order>.

=back

=back

All behaviors will reset last_error().

=head2 State Queries

=over 4

=item * B<is_root()>

This will return true is C<$tree> has no parent and false otherwise.

=item * B<is_leaf()>

This will return true is C<$tree> has no children and false otherwise.

=item * B<has_child(@nodes)>

If called in a boolean context, this will return true is C<$tree> has each of the @nodes as a child. If called in a list context, it will map back the list of indices for each of the @nodes. If called in a scalar, non-boolean context, it will return back the index for C<$nodes[0]>.

=back

=head2 Accessors

=over 4

=item * B<parent()>

This will return the parent of C<$tree>.

=item * B<children( [ $idx, [$idx, ..] ] )>

This will return the children of C<$tree>. If called in list context, it will return all the children. If called in scalar context, it will return the number of children.

You may optionally pass in a list of indices to retrieve. This will return the children in the order you asked for them. This is very much like an arrayslice.

=item * B<root()>

This will return the root node of the tree that C<$tree> is in. The root of the root node is itself.

=item * B<height()>

This will return the height of C<$tree>. A leaf has a height of 1. A parent has a height of its tallest child, plus 1.

=item * B<width()>

This will return the width of C<$tree>. A leaf has a width of 1. A parent has a width equal to the sum of all the widths of its children.

=item * B<depth()>

This will return the depth of C<$tree>. A root has a depth of 0. A child has the depth of its parent, plus 1.

This is the distance from the root. It's useful for things like pretty-printing the tree.

=item * B<size()>

This will return the number of nodes within C<$tree>. A leaf has a size of 1. A parent has a size equal to the 1 plus the sum of all the sizes of its children.

=item * B<value()>

This will return the value stored in the node.

=item * B<set_value([$value])>

This will set the value stored in the node to $value, then return $self.

=item * B<meta()>

This will return a hashref that can be used to store whatever metadata the client
wishes to store. For example, L<Tree::Persist::DB> uses this to store database
row ids.

It is recommended that you store your metadata in a subhashref and not in the
top-level metadata hashref, keyed by your package name. L<Tree::Persist> does
this, using a unique key for each persistence layer associated with that tree.
This will help prevent clobbering of metadata.

=back

=head1 ERROR HANDLING

Describe what the default error handlers do and what a custom error handler is expected to do.

=head2 Error-related methods

=over 4

=item * B<error_handler( [ $handler ] )>

This will return the current error handler for the tree. If a value is passed in, then it will be used to set the error handler for the tree.

If called as a class method, this will instead work with the default error handler.

=item * B<error( $error, [ arg1 [, arg2 ...] ] )>

Call this when you wish to report an error using the currently defined error_handler for the tree. The only guaranteed parameter is an error string describing the issue. There may be other arguments, and you may certainly provide other arguments in your subclass to be passed to your custom handler.

=item * B<last_error()>

If an error occurred during the last behavior, this will return the error string. It is reset only when a behavior is called.

=back

=head2 Default error handlers

=over 4

=item QUIET

Use this error handler if you want to have quiet error-handling. The last_error method will retrieve the error from the last operation, if there was one. If an error occurs, the operation will return undefined.

=item WARN

=item DIE

=back

=head1 EVENT HANDLING

Forest provides for basic event handling. You may choose to register one or more callbacks to be called when the appropriate event occurs. The events are:

=over 4

=item * add_child

This event will trigger as the last step in an L<add_child()> call.

The parameters will be C<( $self, @args )> where C<@args> is the arguments passed into the add_child() call.

=item * remove_child

This event will trigger as the last step in an L<remove_child()> call.

The parameters will be C<( $self, @args )> where C<@args> is the arguments passed into the remove_child() call.

=item * value

This event will trigger as the last step in a L<set_value()> call.

The parameters will be C<( $self, $old_value, $new_value )> where C<$old_value> is what the value was before it was changed. The new value can be accessed through C<$self->value()>.

=back

=head2 Event handling methods

=over 4

=item * B<add_event_handler( $type => $callback [, $type => $callback, ... ])>

You may choose to add event handlers for any known type. Callbacks must be references to subroutines. They will be called in the order they are defined.

=item * B<event( $type, $actor, @args )>

This will trigger an event of type C<$type>. All event handlers registered on C<$tree> will be called with parameters of C<($actor, @args)>. Then, the parent will be notified of the event and its handlers will be called, on up to the root.

This allows you specify an event handler on the root and be guaranteed that it will fire every time the appropriate event occurs anywhere in the tree.

=back

=head1 NULL TREE

If you call C<$self->parent> on a root node, it will return a Tree::Null object. This is an implementation of the Null Object pattern optimized for usage with L<Tree>. It will evaluate as false in every case (using L<overload>) and all methods called on it will return a Tree::Null object.

=head2 Notes

=over 4

=item * Tree::Null does B<not> inherit from Tree. This is so that all the methods will go through AUTOLOAD vs. the actual method.

=item * However, calling isa() on a Tree::Null object will report that it is-a any object that is either Tree or in the Tree:: hierarchy.

=item * The Tree::Null object is a singleton.

=item * The Tree::Null object I<is> defined, though. I couldn't find a way to make it evaluate as undefined. That may be a good thing.

=back

=head1 CIRCULAR REFERENCES

Copy the text from L<Tree::Simple>, rewording appropriately.

=head1 BUGS

None that we are aware of.

The test suite for Tree 1.0 is based very heavily on the test suite for L<Test::Simple>, which has been heavily tested and used in a number of other major distributions, such as L<Catalyst> and rt.cpan.org.

=head1 TODO

=over 4

=item * traverse()

Need to add contextual awareness by providing an iterating closure (object?) in scalar context.

=item * N-ary Proofs

Need to generalize some of the btree proofs to N-ary trees, if possible.

=item * Traversals and memory

Need tests for what happens with a traversal list and deleted nodes, particularly w.r.t. how memory is handled - should traversals weaken if use_weak_refs is in force?

=item * Convert to use attr() and set_attr()

As recommended by Damian in PBP

=item * Remove all uses of Contextual::Return

Contrary to recommendation by Damian in PBP - this is a UI nightmare solely
for spiffiness value.

=back

=head1 ACKNOWLEDGEMENTS

=over 4

=item * Stevan Little for writing L<Tree::Simple>, upon which Tree is based.

=back

=head1 CODE COVERAGE

We use L<Devel::Cover> to test the code coverage of our tests. Please see L<Forest>
for the coverage report.

=head1 AUTHORS

Rob Kinyon E<lt>rob.kinyon@iinteractive.comE<gt>

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

Thanks to Infinity Interactive for generously donating our time.

=head1 COPYRIGHT AND LICENSE

Copyright 2004, 2005 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut
