use Inline C => 'bool is_odd(int n){return n % 2;}';

printf "%d is%s odd\n", 
       ($x = shift), 
       is_odd($x) ? "" : " not";
