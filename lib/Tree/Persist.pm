package Tree::Persist;

use strict;
use warnings;

use Tree;
use XML::Parser;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub load {
    my $self = shift;
    my $filename = shift || $self->{_filename};

    my @stack;
    my $class;
    my $root;
    my $parser = XML::Parser->new(
        Handlers => {
            Start => sub {
                shift;
                my ($name, %args) = @_;

                $class ||= $args{class};
                my $node = $class->new( $args{value} );

                if ( @stack ) {
                    $stack[-1]->add_child( $node );
                }
                else {
                    $root = $node;
                }

                push @stack, $node;
            },
            End => sub {
                pop @stack;
            },
        },
    );

    $parser->parsefile( $filename );

    return $root;
}

sub store {}
sub associate {}

1;
__END__
