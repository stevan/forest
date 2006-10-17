
package Forest::Tree::Reader;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'source' => (
    is       => 'ro', 
    isa      => 'Any',
    required => 1,
);

has 'tree' => (
    is      => 'ro',
    isa     => 'Forest::Tree',
    lazy    => 1,
    default => sub { Forest::Tree->new },
);

requires 'load';

1;

__END__

=pod

=cut