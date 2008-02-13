package Forest::Tree::Reader;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'tree' => (
    is      => 'ro',
    isa     => 'Forest::Tree',
    lazy    => 1,
    default => sub { Forest::Tree->new },
);

has 'parser' => (
    is      => 'rw',
    isa     => 'CodeRef',   
    lazy    => 1,
    builder => 'build_parser',
);

requires 'build_parser';
requires 'read';

sub parse_line { $_[0]->parser->(@_) }

1;

__END__

=pod

=head1 NAME

Forest::Tree::Reader - An abstract role for tree reader

=head1 DESCRIPTION

This is an abstract role for tree readers.

=head1 ATTRIBUTES

=over 4

=item I<tree>

=item I<parser>

=back

=head1 REQUIRED METHODS 

=over 4

=item B<read>

=item B<build_parser>

=back

=head1 METHODS 

=over 4

=item B<parse_line>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
