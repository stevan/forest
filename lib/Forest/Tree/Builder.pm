package Forest::Tree::Builder;
use Moose::Role;

with qw(Forest::Tree::Constructor);

has 'tree' => (
    is         => 'ro',
    writer     => "_tree",
    isa        => 'Forest::Tree::Pure',
    lazy_build => 1,
);

has tree_class => (
    isa => "ClassName",
    is  => "ro",
    reader => "_tree_class",
    default => "Forest::Tree",
);

# horrible horrible kludge to satisfy 'requires' without forcing 'sub
# tree_class {}' in every single class. God i hate roles and attributes
sub tree_class { shift->_tree_class(@_) }

sub _build_tree {
    my $self = shift;

    $self->create_new_subtree(
        children => $self->subtrees,
    );
}

has subtrees => (
    isa => "ArrayRef[Forest::Tree::Pure]",
    is  => "ro",
    lazy_build => 1,
);

requires "_build_subtrees";

# ex: set sw=4 et:

no Moose::Role; 1;

__END__
