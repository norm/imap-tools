use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'IMAP::Tools',
    AUTHOR              => 'Mark Norman Francis <norm@cackhanded.net>',
    VERSION             => '0.7',
    EXE_FILES           => [ 
        'bin/imap-depostpone',
        'bin/imap-folder',
        'bin/imap-list',
        'bin/imap-list-folders',
        'bin/imap-mark',
        'bin/imap-move',
    ],
    PREREQ_PM => {
        'Modern::Perl'              => 0,
        'Config::Std'               => 0,
        'Date::Manip'               => 0,
        'MooseX::Declare'           => 0,
        'Net::IMAP::Client'         => 0,
    },
);
