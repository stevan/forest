
package Forest::Tree::Roles::JSONable;
use Moose::Role;

use JSON::Syck ();

our $VERSION = '0.0.1';

requires 'as_json';
requires 'children_as_json';

no Moose; 1;

__END__

=pod

=cut