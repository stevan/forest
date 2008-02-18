package Forest::Tree::Writer::SimpleHTML;
use Moose;

use Sub::Current;

our $VERSION   = '0.02';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Writer',
     'Forest::Tree::Roles::HasNodeFormatter';

sub as_string {
    my ($self) = @_;
    my $out;    
    
    sub {
        my $t      = shift;
        my $indent = ('    ' x $t->depth);
        
        $out .= ($indent . '<li>' . $self->node_formatter->($t) . '</li>' . "\n")
            unless $t->depth == -1;
            
        unless ($t->is_leaf) {
            $out .= ($indent . '<ul>' . "\n");
            map { ROUTINE->($_) } @{ $t->children };
            $out .= ($indent . '</ul>' . "\n");      
        }      
    }->($self->tree);
    
    return $out;
}

make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Forest::Tree::Writer::SimpleHTML - A simple HTML writer for Forest::Tree heirarchies

=head1 DESCRIPTION

This is a simple writer which draws a tree as an HTML unordered list.

=head1 METHODS 

=over 4

=item B<as_string>

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
