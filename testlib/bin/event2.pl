use Inline with => Event;
use Inline C;
Event->timer(desc     => 'Perl timer',
             interval => 0.5,
             cb       => \&c_callback,
            );
Event::loop;
__END__
__C__
void c_callback(pe_event * event) {
  pe_timer * watcher = event->up;
  printf("In C callback (\"%s\", %d, %d)\n\n",
         SvPVX(watcher->base.desc),
         event->prio, watcher->base.prio);
}
