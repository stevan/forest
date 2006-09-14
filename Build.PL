use Module::Build;

use strict;

my $build = Module::Build->new(
    module_name => 'Forest',
    license => 'perl',
    requires => {
        'Moose'          => '0.11',
        'Moose::Autobox' => '0.03',
        'version'        => '0',
    },
    optional => {
        'JSON::Syck' => '0',
    },
    build_requires => {
        'Test::More'      => '0.47',
        'Test::Exception' => '0.21',
        'Test::use::ok'   => '0.01', 
    },
    create_makefile_pl => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL',
    ],
);

$build->create_build_script;

