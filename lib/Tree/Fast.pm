package Tree::Fast;

use strict;
use warnings;

our $VERSION = '1.00';

use Scalar::Util qw( blessed weaken );

sub new {
    my $class = shift;

    return $class->clone( @_ )
        if blessed $class;

    my $self = bless {}, $class;

    $self->_init( @_ );

    return $self;
}

sub _init {
    my $self = shift;
    my ($value) = @_;

    $self->{_parent} = $self->_null,
    $self->{_children} = [];
    $self->{_value} = $value,

    return $self;
}

sub clone {
    my $self = shift;

    return $self->new(@_) unless blessed $self;

    my $value = @_ ? shift : $self->value;
    my $clone = ref($self)->new( $value );

    if ( my @children = @{$self->{_children}} ) {
        $clone->add_child( map { $_->clone } @children );
    }

    return $clone;
}

sub add_child {
    my $self = shift;
    my @nodes = @_;

    my $index;
    if ( !blessed $nodes[0] ) {
        $index = shift @nodes;
    }

    for my $node ( @nodes ) {
        $node->set_parent( $self );
    }

    if ( defined $index ) {
        if ( $index ) {
            splice @{$self->{_children}}, $index, 0, @nodes;
        }
        else {
            unshift @{$self->{_children}}, @nodes;
        }
    }
    else {
        push @{$self->{_children}}, @nodes;
    }

    return $self;
}

sub remove_child {
    my $self = shift;
    my @indices = @_;

    my @return;
    for my $idx (sort { $b <=> $a } @indices) {
        my $node = splice @{$self->{_children}}, $idx, 1;
        $node->set_parent( $node->_null );

        push @return, $node;
    }

    return @return;
}

sub parent {
    my $self = shift;
    return $self->{_parent};
}

sub set_parent {
    my $self = shift;

    $self->{_parent} = shift;
    weaken( $self->{_parent} );

    return $self;
}

sub children {
    my $self = shift;
    if ( @_ ) {
        my @idx = @_;
        return @{$self->{_children}}[@idx];
    }
    else {
        if ( caller->isa( __PACKAGE__ ) ) {
            return wantarray ? @{$self->{_children}} : $self->{_children};
        }
        else {
            return @{$self->{_children}};
        }
    }
}

sub value {
    my $self = shift;
    return $self->{_value};
}

sub set_value {
    my $self = shift;

    $self->{_value} = $_[0];

    return $self;
}

sub mirror {
    my $self = shift;

    @{$self->{_children}} = reverse @{$self->{_children}};
    $_->mirror for @{$self->{_children}};

    return $self;
}

use constant PRE_ORDER   => 1;
use constant POST_ORDER  => 2;
use constant LEVEL_ORDER => 3;

sub traverse {
    my $self = shift;
    my $order = shift || $self->PRE_ORDER;

    my @list;

    if ( $order eq $self->PRE_ORDER ) {
        @list = ($self);
        push @list, map { $_->traverse( $order ) } @{$self->{_children}};
    }
    elsif ( $order eq $self->POST_ORDER ) {
        @list = map { $_->traverse( $order ) } @{$self->{_children}};
        push @list, $self;
    }
    elsif ( $order eq $self->LEVEL_ORDER ) {
        my @queue = ($self);
        while ( my $node = shift @queue ) {
            push @list, $node;
            push @queue, @{$node->{_children}};
        }
    }
    else {
        return $self->error( "traverse(): '$order' is an illegal traversal order" );
    }

    return @list;
}

sub _null {
    return Tree::Null->new;
}

package Tree::Null;

#XXX Add this in once it's been thought out
#our @ISA = qw( Tree );

# You want to be able to interrogate the null object as to
# its class, so we don't override isa() as we do can()

use overload
    '""' => sub { return "" },
    '0+' => sub { return 0 },
    'bool' => sub { return },
        fallback => 1,
;

{
    my $singleton = bless \my($x), __PACKAGE__;
    sub new { return $singleton }
    sub AUTOLOAD { return $singleton }
    sub can { return sub { return $singleton } }
}

# The null object can do anything
sub isa {
    my ($proto, $class) = @_;

    if ( $class =~ /^Tree(?:::.*)?$/ ) {
        return 1;
    }

    return $proto->SUPER::isa( $class );
}

1;
__END__
