
package Forest::Tree::Writer;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'tree' => (
    is          => 'rw',
    isa         => 'Forest::Tree',
    is_weak_ref => 1,
);

requires 'output';


1;

__END__

=pod

=cut