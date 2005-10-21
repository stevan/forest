package Tree::Persist::DB;

use strict;
use warnings;

use base qw( Tree::Persist::Base );

our $VERSION = '0.99_01';

sub _init {
    my $class = shift;
    my ($opts) = @_;

    my $self = $class->SUPER::_init( $opts );

    $self->{_dbh} = $opts->{dbh};
    $self->{_table} = $opts->{table};

    return $self;
}

1;
__END__

=head1 NAME

Tree::Persist::DB - the base class for DB plugins for Tree persistence

=head1 DESCRIPTION

This class is the base class for the Tree::Persist::DB::* hierarchy, which
provides DB plugins for Tree persistence through L<Tree::Persist>.

=head1 PARAMETERS

In addition to any parameters required by its parent L<Tree::Persist::Base>, the
following parameters are required by connect():

=over 4

=item * dbh (required)

This is the $dbh that is already connected to the right database and schema
with the appropriate user. This is required.

=item * table (required)

This is the table name that contains the tree. This is required.

=back

=head1 TODO

=over 4

=item *

Currently, the dbh and table options aren't checked for existence or validity.

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

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
