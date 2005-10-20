use Module::Build;

use 5.6.0;

use strict;
use warnings;

my $build = Module::Build->new(
    module_name => 'Forest',
    license => 'perl',
    requires => {
        'perl'         => '5.6.0',
        'Scalar::Util' => '1.10',
        'Contextual::Return' => '0.0.2',
    },
    optional => {
        'DBI' => '1.41',
        'XML::Parser' => '0.01',
    },
    build_requires => {
        'Test::More'      => '0.47',
        'Test::Deep'      => '0.088',
        'Test::File'      => '1.10',
        'Test::File::Cleaner' => '0.02',
        'Test::File::Contents' => '0.02',
        'Test::Exception' => '0.15',
        'Test::Warn'      => '0.08',
        'File::Copy'      => '0.01',
        'File::Spec'      => '0.01',
        'Scalar::Util'    => '1.10',
    },
    create_makefile_pl => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL',
    ],
);

$build->create_build_script;
