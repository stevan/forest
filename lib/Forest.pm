package Forest;

our $VERSION = '1.00';

1;
__END__

=head1 NAME

Forest - the distribution for L<Tree> and friends

=head1 DESCRIPTION

Forest is the name for a group of related modules that all deal with trees. 

=head1 CODE COVERAGE

We use L<Devel::Cover> to test the code coverage of our tests. Below is the L<Devel::Cover> report on this module's test suite. We use TDD, which is why our coverage is so high.
 
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

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut
