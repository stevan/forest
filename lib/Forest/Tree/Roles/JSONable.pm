
package Forest::Tree::Roles::JSONable;
use Moose::Role;

use JSON::Syck ();

our $VERSION = '0.0.1';

requires 'as_json';

no Moose; 1;

__END__

=pod

=head1 METHODS

=over 4

=item B<as_json (?$include_children)>

Return a JSON string of the invocant. Takes C<$include_children> 
parameter to specify the depth of the tree to be dumped. 

=back

=cut