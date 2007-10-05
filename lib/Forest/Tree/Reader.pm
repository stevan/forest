
package Forest::Tree::Reader;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# FIXME:
# this should probably be an 
# argument to `read` instead 
# of an attribute.
# - SL
has 'source' => (
    is       => 'ro', 
    isa      => 'FileHandle',
    required => 1,
);

has 'tree' => (
    is      => 'ro',
    isa     => 'Forest::Tree',
    lazy    => 1,
    default => sub { Forest::Tree->new },
);

# TODO:
# rename this to `read`
# - SL
requires 'load';

1;

__END__

=pod

=cut