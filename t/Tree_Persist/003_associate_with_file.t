use strict;
use warnings;

use File::Copy qw( cp );
use Test::More;
use Test::File;
use Test::File::Cleaner;
use Test::File::Contents;

use File::Spec::Functions qw( catfile );

use t::tests qw( %runs );

plan tests => 9 + 1 * $runs{stats}{plan};

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

my $dirname = catfile( qw( t Tree_Persist datafiles ) );

my $cleaner = Test::File::Cleaner->new( $dirname );

{
    my $filename = catfile( $dirname, 'save1.xml' );

    cp( catfile( $dirname, 'tree1.xml' ), $filename );

    file_exists_ok( $filename, 'Tree1 file exists' ); 

    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
</node>
__END_FILE__

    my $persist = $CLASS->connect({
        filename => $filename,
    });

    my $tree = $persist->tree;

    $runs{stats}{func}->( $tree,
        height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
    );
    is( $tree->value, 'root', "The tree's value was loaded correctly" );

    my $child = Tree->new( 'child' );
    $tree->add_child( $child );

    file_exists_ok( $filename, 'Tree1 file still exists' ); 

    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
    <node class="Tree" value="child">
    </node>
</node>
__END_FILE__

    my $child2 = Tree->new( 'child2' );
    $tree->add_child( $child2 );

    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
    <node class="Tree" value="child">
    </node>
    <node class="Tree" value="child2">
    </node>
</node>
__END_FILE__

    $tree->remove_child( $child );

    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
    <node class="Tree" value="child2">
    </node>
</node>
__END_FILE__

    $child2->set_value( 'New value' );

    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
    <node class="Tree" value="New value">
    </node>
</node>
__END_FILE__
}
