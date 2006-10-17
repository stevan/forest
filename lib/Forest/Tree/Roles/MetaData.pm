
package Forest::Tree::Roles::MetaData;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'meta_data' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub fetch_meta_data_for {
    my ($self, $key) = @_;
    
    my $current = $self;
    
    do {    
        if ($current->does(__PACKAGE__)) {
            my $meta = $current->meta_data;
            return $meta->{$key} 
                if exists $meta->{$key};            
        }
        $current = $self->parent;
        
    } until $current->is_root;
    
    if ($current->does(__PACKAGE__)) {
        my $meta = $current->meta_data;
        return $meta->{$key} 
            if exists $meta->{$key};            
    }   
    
    return;
}

no Moose; 1;

__END__

=pod

=cut