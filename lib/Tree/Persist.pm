package Tree::Persist;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub load {}
sub store {}
sub associate {}

1;
__END__
