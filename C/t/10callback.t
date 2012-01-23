# Check that basic callbacks are working, and that Inline::C keeps track correctly of whether functions
# are truly void or not. (In response to bug #55543.)
# This test script plagiarises the perlcall documentation.

BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};
use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use diagnostics;

print "1..4\n";

use Inline C => Config =>
    FORCE_BUILD => 1,
    _TESTING => 1,
    DIRECTORY => '_Inline_test',
    USING => 'ParseRegExp';


use Inline C => <<'END';

void list_context(int x) {
     Inline_Stack_Vars;
     int i = 0;

     Inline_Stack_Reset;

     for(i = 1; i < 11; i++) Inline_Stack_Push(sv_2mortal(newSVuv(i * x)));

     Inline_Stack_Done;

     Inline_Stack_Return(10);
}

void call_AddSubtract2(int a, int b) {
     dSP;
     I32 ax;
     int count;

     ENTER;
     SAVETMPS;

     PUSHMARK(SP);
     XPUSHs(sv_2mortal(newSViv(a)));
     XPUSHs(sv_2mortal(newSViv(b)));
     PUTBACK;

     count = call_pv("AddSubtract", G_ARRAY);

     SPAGAIN;
     SP -= count;
     ax = (SP - PL_stack_base) + 1;

     if (count != 2)
        croak("Big trouble\n");

     printf ("%d + %d = %d\n", a, b, SvIV(ST(0)));
     printf ("%d - %d = %d\n", a, b, SvIV(ST(1)));

     PUTBACK;
     FREETMPS;
     LEAVE;
}

void call_PrintList() {
     dSP;
     char * words[] = {"alpha", "beta", "gamma", "delta", NULL};

     call_argv("PrintList", G_DISCARD, words);
}

void call_Inc(int a, int b) {
     dSP;
     int count;
     SV * sva;
     SV * svb;

     ENTER;
     SAVETMPS;

     sva = sv_2mortal(newSViv(a));
     svb = sv_2mortal(newSViv(b));

     PUSHMARK(SP);
     XPUSHs(sva);
     XPUSHs(svb);
     PUTBACK;

     count = call_pv("Inc", G_DISCARD);

     if (count != 0)
        croak ("call_Inc: expected 0 values from 'Inc', got %d\n",
              count);

     printf ("%d + 1 = %d\n", a, SvIV(sva));
     printf ("%d + 1 = %d\n", b, SvIV(svb));

     FREETMPS;
     LEAVE;
}

void call_AddSubtract(int a, int b) {
     dSP;
     int count;

     ENTER;
     SAVETMPS;

     PUSHMARK(SP);
     XPUSHs(sv_2mortal(newSViv(a)));
     XPUSHs(sv_2mortal(newSViv(b)));
     PUTBACK;

     count = call_pv("AddSubtract", G_ARRAY);

     SPAGAIN;

     if (count != 2)
        croak("Big trouble\n");

     printf ("%d - %d = %d\n", a, b, POPi);
     printf ("%d + %d = %d\n", a, b, POPi);

     PUTBACK;
     FREETMPS;
     LEAVE;
}

void call_Adder(int a, int b) {
     dSP;
     int count;

     ENTER;
     SAVETMPS;

     PUSHMARK(SP);
     XPUSHs(sv_2mortal(newSViv(a)));
     XPUSHs(sv_2mortal(newSViv(b)));
     PUTBACK;

     count = call_pv("Adder", G_SCALAR);

     SPAGAIN;

     if (count != 1)
        croak("Big trouble\n");

     printf ("The sum of %d and %d is %d\n", a, b, POPi);

     PUTBACK;
     FREETMPS;
     LEAVE;
}

void call_PrintUID() {
     dSP;

     PUSHMARK(SP);
     call_pv("PrintUID", G_DISCARD|G_NOARGS);
}

void call_LeftString(char *a, int b) {
     dSP;

     ENTER;
     SAVETMPS;
     PUSHMARK(SP);
     POPMARK;
     PUSHMARK(SP);
     XPUSHs(sv_2mortal(newSVpv(a, 0)));
     XPUSHs(sv_2mortal(newSViv(b)));
     PUTBACK;
     call_pv("LeftString", G_DISCARD);
     FREETMPS;
     LEAVE;
}

void foo(int x) {
     call_AddSubtract(123, 456);
     call_LeftString("Hello World !!", x);
     call_AddSubtract(789,101112);
     call_AddSubtract2(23,50);
     call_Inc(22,223);
     call_PrintList();
     call_PrintUID();
     call_Adder(7123, 8369);
     call_LeftString("Hello World !!", x + 1);
     call_Inc(34,35);
     call_PrintList();
     call_Adder(71231, 83692);
     call_PrintUID();
     call_LeftString("Hello World !!", x + 2);
     call_AddSubtract2(23,50);
}

void bar(int x) {
     dXSARGS;
     int i = 0;

     call_LeftString("Hello World !!", x);

     sp = mark;

     call_LeftString("Hello World !!", x + 1);

     for(i = 1; i < 11; i++) XPUSHs(sv_2mortal(newSVuv(i * x)));

     /* call_LeftString("Hello World !!", x + 2); * /* CRASHES ON RETURN */

     PUTBACK;

     call_LeftString("Hello World !!", x + 3);

     XSRETURN(10);
}

END

my @list = list_context(17);
if(scalar(@list) == 10 && $list[0] == 17) {print "ok 1\n"}
else {
  warn "\nscalar \@list: ", scalar(@list), "\n\$list[0]: $list[0]\n";
  print "not ok 1\n";
}

call_LeftString("Just testing", 8);

foo(7);

@list = bar(6);
if(scalar(@list) == 10 && $list[0] == 6) {print "ok 2\n"}
else {
  warn "\nscalar \@list: ", scalar(@list), "\n\$list[0]: $list[0]\n";
  print "not ok 2\n";
}

call_PrintUID();
call_Adder(18, 12345);
call_AddSubtract(131415, 161718);
call_Inc(102,304);
call_PrintList();
call_AddSubtract2(23,50);

open RD, '<', '_Inline_test/void_test' or warn "Unable to open _Inline_test/void_test: $!";
my @checks = <RD>;
close RD or warn "Unable to close _Inline_test/void_test: $!";

my $expected = 10;

if(scalar(@checks == $expected)) {print "ok 3\n"}
else {
  warn "scalar \@checks is ", scalar(@checks), ". Expected $expected\n";
  print "not ok 3\n";
}

my $ok;

if($checks[0] eq "LIST_CONTEXT\n") {$ok .= 'a'}
else {warn "4a: Got '$checks[0]', expected 'LIST_CONTEXT'\n"}

if($checks[1] eq "TRULY_VOID\n") {$ok .= 'b'}
else {warn "4b: Got '$checks[0]', expected 'TRULY_VOID'\n"}

if($checks[2] eq "TRULY_VOID\n") {$ok .= 'c'}
else {warn "4c: Got '$checks[0]', expected 'TRULY_VOID'\n"}

if($checks[3] eq "LIST_CONTEXT\n") {$ok .= 'd'}
else {warn "4d: Got '$checks[0]', expected 'LIST_CONTEXT'\n"}

if($checks[4] eq "TRULY_VOID\n") {$ok .= 'e'}
else {warn "4e: Got '$checks[4]', expected 'TRULY_VOID'\n"}

if($checks[5] eq "TRULY_VOID\n") {$ok .= 'f'}
else {warn "4f: Got '$checks[5]', expected 'TRULY_VOID'\n"}

if($checks[6] eq "TRULY_VOID\n") {$ok .= 'g'}
else {warn "4g: Got '$checks[6]', expected 'TRULY_VOID'\n"}

if($checks[7] eq "TRULY_VOID\n") {$ok .= 'h'}
else {warn "4h: Got '$checks[7]', expected 'TRULY_VOID'\n"}

if($checks[8] eq "TRULY_VOID\n") {$ok .= 'i'}
else {warn "4i: Got '$checks[8]', expected 'TRULY_VOID'\n"}

if($checks[9] eq "TRULY_VOID\n") {$ok .= 'j'}
else {warn "4j: Got '$checks[9]', expected 'TRULY_VOID'\n"}

if($ok eq 'abcdefghij') {print "ok 4\n"}
else {
  warn "\$ok: $ok\n";
  print "not ok 4\n";
}

Inline::C::_testing_cleanup();

sub PrintUID {
    print "UID is $<\n";
}

sub LeftString {
    my($s, $n) = @_;
    print substr($s, 0, $n), "\n";
}

sub Adder {
    my($a, $b) = @_;
    $a + $b;
}

sub AddSubtract {
    my($a, $b) = @_;
    ($a+$b, $a-$b);
}

sub Inc {
    ++ $_[0];
    ++ $_[1];
}

sub PrintList {
    my(@list) = @_;
    foreach (@list) { print "$_\n" }
}


