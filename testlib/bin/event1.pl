use Event;
use Config;
use Inline C => DATA =>
           INC => "-I$Config{installsitearch}/Event";
Event->timer(desc     => 'Perl timer',
             interval => 0.5,
             cb       => \&c_callback,
            );
BOOT();
Event::loop;
__END__
__C__
#include "EventAPI.h"
void c_callback(SV * sv) {
  pe_event * event = GEventAPI->sv_2event(sv);
  pe_timer * watcher = event->up;
  printf("In C callback (\"%s\", %d, %d)\n\n",
         SvPVX(watcher->base.desc),
         event->prio, watcher->base.prio);
}
void BOOT() {I_EVENT_API("Inline Script");}
