my $obj1 = Soldier->new('Benjamin', 'Private', 11111);
my $obj2 = Soldier->new('Sanders', 'Colonel', 22222);
my $obj3 = Soldier->new('Matt', 'Sergeant', 33333);


for my $obj ($obj1, $obj2, $obj3) {
    print ($obj->get_serial, ") ", 
           $obj->get_name, " is a ", 
           $obj->get_rank, "\n");
}
#---------------------------------------------------------
package Soldier;
use Inline C => <<'END';
typedef struct {
    char* name;
    char* rank;
    long  serial;
} Soldier;


SV* new(char* class, char* name, char* rank, long serial) {
    Soldier* soldier = malloc(sizeof(Soldier));
    SV*      obj_ref = newSViv(0);
    SV*      obj = newSVrv(obj_ref, class);
    soldier->name = strdup(name);
    soldier->rank = strdup(rank);
    soldier->serial = serial;


    sv_setiv(obj, (IV)soldier);
    SvREADONLY_on(obj);
    return obj_ref;
}

char* get_name(SV* obj) {
    return ((Soldier*)SvIV(SvRV(obj)))->name;
}

char* get_rank(SV* obj) {
    return ((Soldier*)SvIV(SvRV(obj)))->rank;
}

long get_serial(SV* obj) {
    return ((Soldier*)SvIV(SvRV(obj)))->serial;
}
void DESTROY(SV* obj) {
    Soldier* soldier = (Soldier*)SvIV(SvRV(obj));
    free(soldier->name);
    free(soldier->rank);
    free(soldier);
}
END
