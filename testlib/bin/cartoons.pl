use Inline C;
use Data::Dumper;
$hash_ref = load_data(shift);
print Dumper $hash_ref;


__END__
__C__
static int next_word(char**, char*);
SV* load_data(char* file_name) {
    char buffer[100], word[100], * pos;
    AV* array;
    HV* hash = newHV();
    FILE* fh = fopen(file_name, "r");
    while (fgets(pos = buffer, sizeof(buffer), fh)) {
        if (next_word(&pos, word)) {
            hv_store(hash, word, strlen(word),
                     newRV_noinc((SV*)array = newAV()), 0);
            while (next_word(&pos, word))
                av_push(array, newSVpvf("%s", word));
        }
    }
    fclose(fh);
    return newRV_noinc((SV*) hash);
}


static int next_word(char** text_ptr, char* word) {
    char* text = *text_ptr;
    while(*text != '\0' &&
          *text <= ' ')
        text++;
    if (*text <= ' ')
        return 0;
    while(*text != '\0' &&
          *text > ' ') {
        *word++ = *text++;
    }
    *word = '\0';
    *text_ptr = text;
    return 1;
}
