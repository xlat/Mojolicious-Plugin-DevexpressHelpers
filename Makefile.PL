use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Mojolicious::Plugin::DevexpressHelpers',
    AUTHOR           => q{Nicolas Georges <xlat@cpan.org>},
    VERSION_FROM     => 'lib/Mojolicious/Plugin/DevexpressHelpers.pm',
    ABSTRACT_FROM    => 'lib/Mojolicious/Plugin/DevexpressHelpers.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Modern::Perl' => 0,
        'Mojo::JSON' => 0,
        'Mojo::Base' => 0,
        'Mojolicious::Plugin' => 0,
        #~ 'Mojolicious::Plugin::AssetPack' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Mojolicious-Plugin-DevexpressHelpers-*' },
);
