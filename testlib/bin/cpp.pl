use Inline 'C++';
my $obj1 = Soldier->new('Benjamin', 'Private', 11111);
my $obj2 = Soldier->new('Sanders', 'Colonel', 22222);
my $obj3 = Soldier->new('Matt', 'Sergeant', 33333);
for my $obj ($obj1, $obj2, $obj3) {
    print ($obj->get_serial, ") ",
           $obj->get_name, " is a ",
           $obj->get_rank, "\n");
}


__END__
__C++__
class Soldier {
  public:
    Soldier(char *name, char *rank, int serial);
    char *get_name();
    char *get_rank();
    int get_serial();
  private:
    char *name;
    char *rank;
    int serial;
};

Soldier::Soldier(char *name, char *rank, int serial) {
    this->name = name;
    this->rank = rank;
    this->serial = serial;
}

char *Soldier::get_name() {
    return name;
}

char *Soldier::get_rank() {
    return rank;
}

int Soldier::get_serial() {
    return serial;
}
