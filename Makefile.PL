use strict;
use warnings;
use inc::Module::Install;

name 'Forest';
all_from 'lib/Forest.pm';
license 'perl';

# prereqs
requires 'Moose'                    => '0.90';
requires 'MooseX::Clone'            => '0.05';
requires 'MooseX::AttributeHelpers' => '0.17';
requires 'Scalar::Util'             => '1.17';
requires 'List::Util'               => '1.17';

# things the tests need
build_requires 'Test::More';
build_requires 'Test::Exception';
build_requires 'Path::Class';

tests('t/*.t');

WriteAll();
