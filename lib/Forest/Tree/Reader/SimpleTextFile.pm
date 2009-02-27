package Forest::Tree::Reader::SimpleTextFile;
use Moose;

our $VERSION   = '0.06';
our $AUTHORITY = 'cpan:STEVAN';

with 'Forest::Tree::Reader';

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

## methods

sub build_parser {
    return sub {
        my ($self, $line) = @_;
        my ($indent, $node) = ($line =~ /^(\s*)(.*)$/);
        my $depth = ((length $indent) / $self->tab_width); 
        return ($depth, $node);
    }
}

sub parse_line { $_[0]->parser->(@_) }

sub read {
    my ($self, $fh) = @_;
    
    my $current_tree = $self->tree;
    
    while (my $line = <$fh>) {
        
        chomp($line);
        
        next if !$line || $line =~ /^#/;
        
        my ($depth, $node, @rest) = $self->parse_line($line);
        
        #use Data::Dumper;
        #warn "Depth: $depth - Node: $node - for $line and " . Dumper \@rest;
        
        my $new_tree = $self->create_new_subtree(node => $node, @rest);
        
        if ($current_tree->is_root) {
            $current_tree->add_child($new_tree);
            $current_tree = $new_tree;
            next;
        }
        
        my $tree_depth = $current_tree->depth;        
        if ($depth == $tree_depth) {    
            $current_tree->add_sibling($new_tree);
            $current_tree = $new_tree;
        } 
        elsif ($depth > $tree_depth) {
            (($depth - $tree_depth) <= 1) 
                || die "Parse Error : the difference between the depth ($depth) and " . 
                       "the tree depth ($tree_depth) is too much (" . 
                       ($depth - $tree_depth) . ") at line:\n'$line'";
            $current_tree->add_child($new_tree);
            $current_tree = $new_tree;
        } 
        elsif ($depth < $tree_depth) {
            $current_tree = $current_tree->parent while ($depth < $current_tree->depth);
            $current_tree->add_sibling($new_tree);
            $current_tree = $new_tree;    
        } 
               
    }
};

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=head1 NAME

Forest::Tree::Reader::SimpleTextFile - A reader for Forest::Tree heirarchies

=head1 DESCRIPTION

This reads simple F<.tree> files, which are basically the tree represented
as a tabbed heirarchy. 

=head1 ATTRIBUTES 

=over 4

=item I<tab_width>

=back

=head1 METHODS 

=over 4

=item B<read ($fh)>

=item B<build_parser>

=item B<create_new_subtree (%options)>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2009 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
