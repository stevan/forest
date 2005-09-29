use strict;
use warnings;

use File::Copy qw( cp );
use Test::More;
use Test::File;
use Test::File::Cleaner;
use Test::File::Contents;

use File::Spec::Functions qw( catfile );

use t::tests qw( %runs );

plan tests => 4 + 1 * $runs{stats}{plan};

my $CLASS = 'Tree::Persist';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

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

    my $tree = $persist->tree;

    $runs{stats}{func}->( $tree,
        height => 1, width => 1, depth => 0, size => 1, is_root => 1, is_leaf => 1,
    );
    is( $tree->value, 'root', "The tree's value was loaded correctly" );
}
