use Module::Build;

use strict;

my $build = Module::Build->new(
    dist_abstract => 'nothing',
    module_name => 'Forest',
    license => 'perl',
    requires => {
        'Moose'        => '0.35',
        'JSON::Any'    => '1.15',
        'Sub::Current' => '0.02',
    },
    optional => {
    },
    build_requires => {
        'Test::More'      => '0.47',
        'Test::Exception' => '0.21',
    },
    create_makefile_pl => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL',
    ],
);

$build->create_build_script;

