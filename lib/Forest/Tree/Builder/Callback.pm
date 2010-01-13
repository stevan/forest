package Forest::Tree::Builder::Callback;
use Moose::Role;

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Builder' => { excludes => [qw(create_new_subtree)] };

has new_subtree_callback => (
    isa => "CodeRef|Str",
    is  => "ro",
    required => 1,
    default => "Forest::Tree::Constructor::create_new_subtree",
);

sub create_new_subtree {
    my ( $self, @args ) = @_;

    my $method = $self->new_subtree_callback;

    $self->$method(@args);
}

# ex: set sw=4 et:

__PACKAGE__

__END__
