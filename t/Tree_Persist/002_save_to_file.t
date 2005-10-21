use strict;
use warnings;

use Test::More;

eval "use XML::Parser";
plan skip_all => "XML::Parser required for testing File plugin" if $@;

plan tests => 11;

use Test::File;
use Test::File::Cleaner;
use Test::File::Contents;

use File::Spec::Functions qw( catfile );

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

use_ok( 'Tree' );

my $dirname = catfile( qw( t Tree_Persist datafiles ) );

my $cleaner = Test::File::Cleaner->new( $dirname );

{
    my $filename = catfile( $dirname, 'save1.xml' );
    file_not_exists_ok( $filename, "Tree1 file doesn't exist yet" ); 

    my $tree = Tree->new( 'root' );

    my $persist = $CLASS->create_datastore({
        tree => $tree,
        filename => $filename,
    });

    file_exists_ok( $filename, 'Tree1 file exists' ); 
    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
</node>
__END_FILE__

}

{
    my $filename = catfile( $dirname, 'save2.xml' );
    file_not_exists_ok( $filename, "Tree2 file doesn't exist yet" ); 

    my $tree = Tree->new( 'A' )->add_child(
        Tree->new( 'B' ),
        Tree->new( 'C' )->add_child(
            Tree->new( 'D' ),
        ),
        Tree->new( 'E' ),
    );

    my $persist = $CLASS->create_datastore({
        tree => $tree,
        filename => $filename,
    });

    file_exists_ok( $filename, 'Tree2 file exists' ); 
    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="A">
    <node class="Tree" value="B">
    </node>
    <node class="Tree" value="C">
        <node class="Tree" value="D">
        </node>
    </node>
    <node class="Tree" value="E">
    </node>
</node>
__END_FILE__

}

{
    my $filename = catfile( $dirname, 'save3.xml' );
    file_not_exists_ok( $filename, "Tree3 file doesn't exist yet" ); 

    my $tree = Tree->new( 'A' )->add_child(
        Tree->new( 'B' ),
        Tree->new( 'C' )->add_child(
            Tree->new( 'D' ),
            Tree->new( 'E' ),
        ),
    );

    my $persist = $CLASS->create_datastore({
        filename => $filename,
        tree => $tree,
    });

    file_exists_ok( $filename, 'Tree3 file exists' ); 
    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="A">
    <node class="Tree" value="B">
    </node>
    <node class="Tree" value="C">
        <node class="Tree" value="D">
        </node>
        <node class="Tree" value="E">
        </node>
    </node>
</node>
__END_FILE__

}

