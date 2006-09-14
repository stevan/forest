
package Forest::Tree::Reader;
use Moose::Role;

use version; our $VERSION = qv('0.0.1');

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

#requires 'load';

sub create_new_subtree { shift; Forest::Tree->new(@_) }

1;

__END__

=pod

=cut