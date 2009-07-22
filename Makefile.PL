use 5.010000;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Class::Context',
    VERSION_FROM      => 'lib/Class/Context.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     
      (ABSTRACT_FROM  => 'lib/Class/Context.pm', # retrieve abstract from module
       AUTHOR         => 'cmapuk[0nline] <cmapuk.0nline@gmail.com>') : ()),
);
