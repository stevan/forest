package Tree::Persist::File;

use strict;
use warnings;

use base qw( Tree::Persist::Base );

use Scalar::Util qw( blessed );

our $VERSION = '0.99_01';

sub _init {
    my $class = shift;
    my ($opts) = @_;

    my $self = $class->SUPER::_init( $opts );

    $self->{_filename} = $opts->{filename};

    return $self;
}

sub _create {
    my $self = shift;

    open my $fh, '>', $self->{_filename}
        or die "Cannot open '$self->{_filename}' for writing: $!\n";

    print $fh $self->_build_string( $self->{_tree} );

    close $fh;

    return $self;
}

*_commit = \&_create;

1;
__END__

=head1 NAME

Tree::Persist::File - the base class for File plugins for Tree persistence

=head1 DESCRIPTION

This class is a base class for the Tree::Persist::File::* hierarchy, which
provides File plugins for Tree persistence.

=head1 PARAMETERS

In addition to any parameters required by its parent L<Tree::Persist::Base>, the following
parameters are required by connect():

=over 4

=item * filename (required)

This is the filename that will be used as the datastore.

=back

=head1 TODO

=over 4

=item *

Currently, the filename parameter isn't checked for validity or existence.

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
