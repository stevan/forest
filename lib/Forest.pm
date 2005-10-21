package Forest;

our $VERSION = '0.99_01';

1;
__END__

=head1 NAME

Forest - the distribution for L<Tree> and friends

=head1 DESCRIPTION

Forest is the name for a group of related modules that all deal with trees. 

B<NOTE:> This is currently a developer release. The API is nearly-completely
frozen, but we reserve the right to make incompatible changes. When 1.0 is
released, its API I<will> be backwards-compatible.

=head1 CIRCULAR REFERENCES

All the modules in this distribution use L<Scalar::Util>'s C<weaken()> to
avoid circular references. This avoids the problem of circular references in
all cases.

=head1 BUGS

None that we are aware of.

The test suite for Forest is based very heavily on the test suite for
L<Test::Simple>, which has been tested extensively and is used in a number of
major applications/distributions, such as L<Catalyst> and rt.cpan.org.

=head1 TODO

=over 4

=item * traverse()

Need to add contextual awareness by providing an iterating closure (object?)
in scalar context.

=item * Traversals and memory

Need tests for what happens with a traversal list and deleted nodes,
particularly w.r.t. how memory is handled - should traversals weaken?

=back

=head1 CODE COVERAGE

We use L<Devel::Cover> to test the code coverage of our tests. Below is the
L<Devel::Cover> report on this module's test suite. We use TDD, which is why
our coverage is so high.
 
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  File                           stmt branch   cond    sub    pod   time  total
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  blib/lib/Tree.pm              100.0  100.0  100.0  100.0  100.0   79.7  100.0
  blib/lib/Tree/Binary.pm       100.0  100.0   66.7  100.0  100.0    4.3   97.8
  blib/lib/Tree/Fast.pm         100.0   96.4   66.7  100.0  100.0   12.4   99.0
  blib/lib/Tree/Persist.pm      100.0   75.0  100.0  100.0  100.0    0.6   97.6
  .../lib/Tree/Persist/Base.pm  100.0   87.5  100.0  100.0  100.0    0.8   98.1
  blib/lib/Tree/Persist/DB.pm   100.0    n/a    n/a  100.0    n/a    0.1  100.0
  ...ist/DB/SelfReferential.pm  100.0   87.5   44.4  100.0    n/a    1.4   94.9
  .../lib/Tree/Persist/File.pm  100.0   50.0    n/a  100.0    n/a    0.3   96.7
  .../Tree/Persist/File/XML.pm  100.0  100.0  100.0  100.0    n/a    0.5  100.0
  Total                         100.0   95.0   81.0  100.0  100.0  100.0   98.6
  ---------------------------- ------ ------ ------ ------ ------ ------ ------

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
