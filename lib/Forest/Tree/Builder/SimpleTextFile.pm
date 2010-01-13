package Forest::Tree::Builder::SimpleTextFile;
use Moose;

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

use namespace::clean -except => 'meta';

no warnings 'recursion';

with qw(Forest::Tree::Builder::Callback); # for compatibility with overriding create_new_subtree, otherwise invisible

has fh => (
    isa => "FileHandle",
    is  => "ro",
    required => 1,
);

has 'tab_width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 4
);

has 'parser' => (
    is      => 'rw',
    isa     => 'CodeRef',
    lazy    => 1,
    builder => 'build_parser',
);

sub build_parser {
    return sub {
        my ($self, $line) = @_;
        my ($indent, $node) = ($line =~ /^(\s*)(.*)$/);
        my $depth = ((length $indent) / $self->tab_width);
        return ($depth, $node);
    }
}

sub parse_line { $_[0]->parser->(@_) }

sub _build_subtrees {
    my $self = shift;

    my $cur_children = [];
    my @stack;

    my $fh = $self->fh;

    while ( defined(my $line = <$fh>) ) {

        chomp($line);

        next if !$line || $line =~ /^#/;

        my ($depth, $node, @rest) = $self->parse_line($line);

        if ( $depth > @stack ) {
            if ( $depth = @stack + 1 ) {
                push @stack, $cur_children;
                $cur_children = $cur_children->[-1]{children} = [];
            } else {
                die "Parse Error : the difference between the depth ($depth) and " .
                    "the tree depth (" . scalar(@stack)  . ") is too much (" .
                    ($depth - @stack) . ") at line:\n'$line'";
            }
        } elsif ( $depth < @stack ) {
            while ( $depth < @stack ) {
                foreach my $node ( @$cur_children ) {
                    $node = $self->create_new_subtree(%$node);
                }

                $cur_children = pop @stack;
            }
        }

        push @$cur_children, { node => $node, @rest };
    }

    while ( @stack ) {
        $_ = $self->create_new_subtree(%$_) for @$cur_children;
        $cur_children = pop @stack;
    }

    return [ map { $self->create_new_subtree(%$_) } @$cur_children ];
}


__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
