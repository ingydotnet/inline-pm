use Inline C => DATA => 
           LIBS => `gtk-config --libs`, 
           INC => `gtk-config --cflags`;
japh("Just another Perl Hacker!");
__END__
__C__
#include <gtk/gtk.h>
int japh(char *m) {
        GtkWidget *w, *b; 
        gtk_init(NULL,NULL); 
        w = gtk_window_new(GTK_WINDOW_TOPLEVEL); 
        gtk_window_set_title(GTK_OBJECT(w),"JAPH!");
        b = gtk_button_new_with_label(m);
        gtk_container_add(GTK_CONTAINER(w),b);
        gtk_widget_show_all(w);
        gtk_main();
}
