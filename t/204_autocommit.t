use strict;
use warnings;

use Test::More;

plan tests => 8;

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

use File::Copy qw( cp );
use File::Spec::Functions qw( catfile );
use Test::File;
use Test::File::Cleaner;
use Test::File::Contents;

my $dirname = catfile( qw( t datafiles ) );

my $cleaner = Test::File::Cleaner->new( $dirname );

{
    my $filename = catfile( $dirname, 'save1.xml' );

    cp( catfile( $dirname, 'tree1.xml' ), $filename );

    file_exists_ok( $filename, 'Tree1 file exists' ); 

    file_contents_is( $filename, <<__END_FILE__, '... and the contents are good' );
<node class="Tree" value="root">
</node>
__END_FILE__

    my $persist = $CLASS->connect(
        filename => $filename,
    );

    ok( $persist->autocommit, "Autocommit defaults to true" );

    ok( $persist->autocommit( 0 ), "Setting autocommit returns the old value" );
    ok( !$persist->autocommit, "After setting it to false, it's now false" );

    my $tree = $persist->tree;

    $tree->value( 'foo' );

    file_contents_is( $filename, <<__END_FILE__, "Shoudn't change anything with autocommit off" );
<node class="Tree" value="root">
</node>
__END_FILE__

    $persist->commit;

    file_contents_is( $filename, <<__END_FILE__, "... but committing should." );
<node class="Tree" value="foo">
</node>
__END_FILE__

}
