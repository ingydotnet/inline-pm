BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};
use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => '_Inline_test';

plan(tests => 3,
     todo => [],
     onfail => sub {},
    );


my $obj = Soldier->new('Benjamin', 'Private', 11111);

ok($obj->get_serial == 11111);
ok($obj->get_name eq 'Benjamin');
ok($obj->get_rank eq 'Private');

package Soldier;

use Inline C => Config =>
    USING => 'ParseRegExp',
    TYPEMAPS => ['t/typemap', 't/soldier_typemap'];

use Inline C => <<'END';

typedef struct {
  char* name;
  char* rank;
  long  serial;
  } Soldier;



Soldier * new(char* class, char* name, char* rank, long serial) {
    Soldier* soldier;
    New(42, soldier, 1, Soldier);

    soldier->name = savepv(name);
    soldier->rank = savepv(rank);
    soldier->serial = serial;

    return soldier;
}


char* get_name(Soldier * obj) {
      return obj->name;
}

char* get_rank(Soldier * obj) {
      return obj->rank;
}

long get_serial(Soldier * obj) {
     return obj->serial;
}

void DESTROY(Soldier* obj) {
     Safefree(obj->name);
     Safefree(obj->rank);
     Safefree(obj);
}

END

