
package Tree::Binary;

use Tree;
our @ISA = qw( Tree );

1;
__END__

=head1 NAME

Tree::Binary - An implementation of a binary tree

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

None that we are aware of.

The test suite for Tree 1.0 is based very heavily on the test suite for L<Test::Simple>, which has been heavily tested and used in a number of other major distributions, such as L<Catalyst> and rt.cpan.org.

=head1 NOTES

=over 4

=item * Strongly binary

Where every node has 0 or 2 children

=item * Weakly binary

Where the root has one child

=item * Partial balancing

Creating an AVL search tree

=item * BTree

A special m-ary balanced tree.

=over 4

=item 1 The root either is a leaf or has 2+ children

=item 2 Every node (except root/leaf) has between ceil(m/2) and m children

=item 3 Every path from root to leaf is the same size

=back

=item * 2-3 Tree

A BTree of order 3.

=over 4

=item 1 All nodes have 2 or 3 children

=item 2 The leaves, traversed from left to right, are ordered.

=item 3 Insertion

Locate where it should be and add it. If the parent's children > 3, split it into two nodes with 2 children and add the 2nd to the parent. Continue up to the root, adding a new root, if needed.

=item 4 Deletion

Locate the leaf and remove it. If the parent's children < 2, merge it with an adjacent sibling, removing it from its parent. Continue up to the root, removing the root, if needed.

=back

=item * Red-Black

=over 4

=item 1 Every node has 2 children colored either red or black

=item 2 Every leaf is black

=item 3 Every red node has 2 black children

=item 4 Every path from the root to a leaf contains the same number of black children (called the I<black-height>)

=back

Special case is an AA tree. This requires that right children must always be red. q.v. L<http://en.wikipedia.org/wiki/AA_tree> for more info.

=item * Andersson

q.v. L<http://www.eternallyconfuzzled.com/tuts/andersson.html>

=item * Splay

q.v. L<http://en.wikipedia.org/wiki/Splay_tree>

=item * Scapegoat

q.v. L<http://en.wikipedia.org/wiki/Scapegoat_tree>

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
