use Inline ASM => DATA => 
           PROTOTYPES => {JAxH => 'void(char*)'};
print JAxH('Perl');
__END__
__ASM__
        BITS 32
        GLOBAL JAxH
        EXTERN printf
        SECTION .text
JAxH    push ebp
        mov ebp,esp
        mov eax,[ebp+8]
        push dword eax
        push dword jaxhstr
        call printf
        mov esp,ebp
        pop ebp
        ret
        SECTION .data
jaxhstr db "Just Another %s Hacker", 10, 0
