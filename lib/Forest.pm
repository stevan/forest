package Forest;
use Moose ();

our $VERSION   = '0.02';
our $AUTHORITY = 'cpan:STEVAN';

1;

__END__

=pod

=head1 NAME

Forest - A collection of n-ary tree related modules 

=head1 DESCRIPTION

Forest is intended to be a replacement for the Tree::Simple family of modules, 
and fixes many of the issues that have always bothered me about them. It is by 
no means a complete replacement yet, but should eventually grow to become that.

For more information please refer to the individual module documentation.

=head1 DISCLAIMER

This module has been sitting on my laptop for a long time waiting to be released. 
I am pretty happy with it's current state, but it has not been used very much yet
so I am not 100% sure it is as stable as Tree::Simple (which it is meant to replace). 
So please, use with caution. Also being that this is a the 0.02 release I reserve the 
right to re-write the entire thing if I want too.

All that said, we use n-ary trees pretty heavily at C<$work> and this module will 
be replacing all our Tree::Simple usage so it will eventually improve in stability, 
performance and functionality.

=head1 TODO

=over 4

=item More documentation

This is 0.02 so it is lacking quite a bit of docs. Although I invite people to read the 
source, it is quite simple really.

=item More tests

The coverage is in the low 90s, but there is still a lot of behavioral stuff that could
use some testing too.

=back

=head1 SEE ALSO 

=over 4

=item L<Tree::Simple>

I wrote this module a few years ago and I had served me well, but recently I find 
myself getting frustrated with some of the uglier bits of this module. So Forest is 
a re-write of this module.

=item L<Tree>

This is an ambitious project to replace all the Tree related modules with a single
core implementation. There is some good code in here, but the project seems to be 
very much on the back-burner at this time. 

=item O'Caml port of Forest

Ask me about the O'Caml port of this module, it is also sitting on my hard drive
waiting for release. It actually helped quite a bit in terms of helping me settle
on the APIs for this module. Static typing can be very helpful sometimes. 

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

With contributions from:

Guillermo (groditi) Roditi

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
