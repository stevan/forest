
package Forest::Tree;
use Moose;
use Moose::Autobox;

use version; our $VERSION = qv('0.0.1');

has 'node' => (is  => 'rw', isa => 'Any');

has 'uid'  => (
    is      => 'rw', 
    isa     => 'Value',
    lazy    => 1,
    default => sub { ($_[0] =~ /\((.*?)\)$/)[0] }
);

has 'depth' => (
    reader  => 'depth',
    writer  => '_set_depth',
    isa     => 'Int',
    default => -1,
);

has 'parent' => (
    reader      => 'parent',
    writer      => '_set_parent',   
    predicate   => 'has_parent', 
    isa         => 'Forest::Tree',  
    is_weak_ref => 1,  
    handles     => { 
        'add_sibling'       => 'add_child',
        'get_sibling_at'    => 'get_child_at',
        'insert_sibling_at' => 'insert_child_at',
    },    
    trigger     => sub {
        my ($self) = @_;
        $self->_set_depth($self->parent->depth + 1)
    },    
);

has 'children' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

## informational 

method is_root => sub { !self->has_parent       };
method is_leaf => sub { !self->children->length };

## child management

method add_child => sub {
    my ($child) = @_;
    (blessed($child) && $child->isa('Forest::Tree'))
        || confess "Child parameter must be a Forest::Tree not ($child)";
    $child->_set_parent(self);
    self->children->push($child);
    self;
};

method insert_child_at => sub {
    my ($index, $child) = @_;
    (blessed($child) && $child->isa('Forest::Tree'))
        || confess "Child parameter must be a Forest::Tree not ($child)";    
    $child->_set_parent(self);
    splice @{self->children}, $index, 0, $child;    
};

method get_child_at => sub {
    my ($index) = @_;
    self->children->at($index);
};

method child_count => sub { self->children->length };

no Moose;

1;

__END__

=pod

=cut