use Inline C;
goto_C();

__END__
__C__
void goto_C() {
    printf("I've been banished to C, but at least I have Perl %s\n",
           SvPVX(eval_pv("use Config; $Config{version}", 
                         0)));
}
