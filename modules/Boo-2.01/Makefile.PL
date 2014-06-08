use Inline::MakeMaker;

WriteMakefile(
    NAME             => 'Boo',
    VERSION_FROM     => 'lib/Boo.pm',

    clean => { FILES => '_Inline *.inl' },
);
