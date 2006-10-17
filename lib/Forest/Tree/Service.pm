
package Forest::Tree::Service;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'tree_index' => (
    is   => 'rw',
    does => 'Forest::Tree::Indexer',
);

1;

__END__

=pod

=cut