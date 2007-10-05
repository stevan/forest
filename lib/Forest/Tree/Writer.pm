
package Forest::Tree::Writer;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'tree' => (
    is          => 'rw',
    isa         => 'Forest::Tree',
    is_weak_ref => 1,
);

requires 'as_string';

sub write {
    my ($self, $fh) = @_;
    # NOTE:
    # this is way over simplified
    # but it will do for now.
    # - SL
    print $fh $self->as_string;
}

1;

__END__

=pod

=cut