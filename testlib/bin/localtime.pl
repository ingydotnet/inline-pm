print map {"$_\n"} get_localtime(time);

use Inline C => <<'END_OF_C_CODE';
#include <time.h>
void get_localtime(int utc) {
  struct tm *ltime = localtime(&utc);
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  Inline_Stack_Push(newSViv(ltime->tm_year));
  Inline_Stack_Push(newSViv(ltime->tm_mon));
  Inline_Stack_Push(newSViv(ltime->tm_mday));
  Inline_Stack_Push(newSViv(ltime->tm_hour));
  Inline_Stack_Push(newSViv(ltime->tm_min));
  Inline_Stack_Push(newSViv(ltime->tm_sec));
  Inline_Stack_Push(newSViv(ltime->tm_isdst));
  Inline_Stack_Done;
}
END_OF_C_CODE
