package Tree::Persist::File::XML;

use Tree::Persist::File;
our @ISA = qw( Tree::Persist::File );

use Scalar::Util qw( blessed refaddr );
use XML::Parser;
use Tree;

sub reload {
    my $self = shift;

    my $linenum = 0;
    my @stack;
    my $parser = XML::Parser->new(
        Handlers => {
            Start => sub {
                shift;
                my ($name, %args) = @_;

                my $node = $args{class}->new( $args{value} );

                if ( @stack ) {
                    $stack[-1]->add_child( $node );
                }
                else {
                    $self->set_tree( $node );
                }

                push @stack, $node;
            },
            End => sub {
                $linenum++;
                pop @stack;
            },
        },
    );

    $parser->parsefile( $self->{_filename} );

    return $self;
}

my $pad = ' ' x 4;

sub _build_string {
    my $self = shift;
    my ($tree) = @_;

    my $str = '';

    my $curr_depth = $tree->depth;
    my @closer;
    foreach my $node ( $tree->traverse ) {
        my $new_depth = $node->depth;
        $str .= pop(@closer) while @closer && $curr_depth-- >= $new_depth;

        $curr_depth = $new_depth;
        $str .= ($pad x $curr_depth)
                . '<node class="'
                . blessed($node)
                . '" value="'
                . $node->value
                . '">' . $/;
        push @closer, ($pad x $curr_depth) . "</node>\n";
    }
    $str .= pop(@closer) while @closer;

    return $str;
}

1;
__END__
