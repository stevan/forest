package Tree::Persist;

use strict;
use warnings;

use Tree;
use XML::Parser;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub load {
    my $self = shift;
    my $filename = shift || $self->{_filename};

    my @stack;
    my $class;
    my $root;
    my $parser = XML::Parser->new(
        Handlers => {
            Start => sub {
                shift;
                my ($name, %args) = @_;

                $class ||= $args{class};
                my $node = $class->new( $args{value} );

                if ( @stack ) {
                    $stack[-1]->add_child( $node );
                }
                else {
                    $root = $node;
                }

                push @stack, $node;
            },
            End => sub {
                pop @stack;
            },
        },
    );

    $parser->parsefile( $filename );

    return $root;
}

sub store {}
sub associate {}

1;
__END__

=head1 NAME

Tree::Persist

=head1 SYNOPSIS

=head1 DESCRIPTION

This is meant to be a transparent persistence layer for Tree and its children. It's fully pluggable and will allow either loading, storing, and/or association with between a datastore and a tree.

=head1 METHODS

=head2 Constructor

=over 4

=item B<new()>

This will return a Tree::Persist object.

=back

=head2 Behaviors

=over 4

=item * B<load()>

This will load a tree from the given datastore.

=item * B<save( $tree )>

This will save C<$tree> to the given datastore.

=item * B<associate( $tree )>

This will install event handlers in C<$tree> so that any change to C<$tree> will be mirrored in the datastore.

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
