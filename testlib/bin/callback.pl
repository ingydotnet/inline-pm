use Inline C;
goto_C();
sub how_is_perl_doing {
    print "This is Perl. I'm doing fine!\n";
}

__END__
__C__
void goto_C() {
    printf("C is boring. I wonder how Perl is doing?\n");
    call_pv("how_is_perl_doing", G_VOID | G_EVAL);
}
