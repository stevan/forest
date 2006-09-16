
package Forest::Tree::Service;
use Moose::Role;

our $VERSION = '0.0.1';

has 'tree_index' => (
    is   => 'rw',
    does => 'Forest::Tree::Indexer',
);

1;

__END__

=pod

=cut