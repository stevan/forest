package Tree::Persist;

use strict;
use warnings;

use Tree;
use XML::Parser;

use Scalar::Util qw( blessed refaddr );

my $pad = ' ' x 4;

sub connect {
    my $class = shift;
    my %opts = @_;

    my $self = bless {
        _filename => $opts{filename},
        _tree => '',
        _datastore => [],
        _mapping => {},
    }, $class;

    $self->reload;

    $self->{_tree}->add_event_handler(
        add_child => sub { $self->commit },
        remove_child => sub { $self->commit },
        value => sub { $self->commit },
    );

    return $self;
}

sub create_datastore {
    my $class = shift;
    my %opts = @_;

    $class->commit( %opts );

    return $class;
}

sub reload {
    my $self = shift;

    my $linenum = 0;
    my @stack;
    my $parser = XML::Parser->new(
        Handlers => {
            Start => sub {
                shift;
                my ($name, %args) = @_;

                my $node = $args{class}->new( $args{value} );

                if ( @stack ) {
                    $stack[-1]->add_child( $node );
                }
                else {
                    $self->{_tree} = $node;
                }

                $self->{_mapping}{refaddr($node)} = $linenum++;

                push @stack, $node;
            },
            End => sub {
                $linenum++;
                pop @stack;
            },
        },
    );

    $parser->parsefile( $self->{_filename} );

    return $self;
}

sub commit {
    my $self = shift;
    my %opts = @_;

    my $fh;
    if ( blessed $self ) {
        open $fh, '>', $self->{_filename}
            or die "Cannot open '$self->{_filename}' for writing: $!\n";
    }
    else {
        open $fh, '>', $opts{filename}
            or die "Cannot open '$opts{filename}' for writing: $!\n";
    }

    print $fh $self->_build_string( $opts{tree} || $self->{_tree} );

    close $fh;

    return $self;
}

sub _build_string {
    my $self = shift;
    my ($tree) = @_;

    my $str = '';

    my $curr_depth = $tree->depth;
    my @closer;
    foreach my $node ( $tree->traverse ) {
        my $new_depth = $node->depth;
        $str .= pop(@closer) while @closer && $curr_depth-- >= $new_depth;

        $curr_depth = $new_depth;
        $str .= ($pad x $curr_depth) . '<node class="' . blessed($node) . '" value="' . $node->value . '">' . $/;
        push @closer, ($pad x $curr_depth) . "</node>\n";
    }
    $str .= pop(@closer) while @closer;

    return $str;
}

sub autocommit {}

sub rollback {}

sub tree {
    my $self = shift;
    return $self->{_tree};
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

=item * B<connect( %opts )>

This will return a Tree::Persist object. C<%opts> includes:

=over 4

=item * Required: (datastore)

=item * Optional: autocommit

This is a boolean option that determines whether or not changes to the tree will committed to the datastore immediately or not. The default is true.

=back

=item * B<create_datastore( %opts )>

This will create a new datastore for a tree. C<%opts> includes;

=over 4

=item * Required: tree

This is the tree that will be used to create the datastore.

=item * Required: (datastore)

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

B<NOTE>: Any references to any of the nodes in the tree as it was before rollback() is called are to considered suspect.

=item * B<reload()>

This will throw out the current tree and reload it from the datastore.

B<NOTE>: Any references to any of the nodes in the tree as it was before reload() is called are to considered suspect.

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
