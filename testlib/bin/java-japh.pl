use Inline Java;

$j = JAxH->new;
$j->jaxh('Perl');

__END__
__Java__
class JAxH {
    public JAxH(){ }

    public static void jaxh(String s) {
        System.out.println("Just Another " + s + 
                           " Hacker");
    }
}
