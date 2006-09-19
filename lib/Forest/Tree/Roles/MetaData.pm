
package Forest::Tree::Roles::MetaData;
use Moose::Role;

our $VERSION = '0.0.1';

has 'meta_data' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

no Moose; 1;

__END__

=pod

=cut