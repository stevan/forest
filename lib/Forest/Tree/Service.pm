
package Forest::Tree::Service;
use Moose::Role;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

has 'tree_index' => (
    is   => 'rw',
    does => 'Forest::Tree::Indexer',
);

1;

__END__

=pod

=cut