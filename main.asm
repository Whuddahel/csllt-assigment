%include "util.asm"
%include "io.asm"
%include "validation.asm"
%include "menu.asm"
%include "login.asm"
%include "files.asm"

SECTION .data
; VARIABLES

; MESSSAGES

msg1    db  "Poop", 0h
msg2    db  "Poop", 0h



SECTION .bss
username        resb    255                 ; null if guest
input_buffer    resb    255                 ; used to store the value of the input function
temp_buffer    resb    255                  ; general purpose whatever
line_buffer     resb    1024               ; pretty much exclusive to reading files
token_buffer    resb    255                 ; if tokenize is called value is stored here
fd_storage   resd 1



SECTION .text
global _start
_start:
    call    print_welcome_banner


call    register


; main_menu:
;     mov     eax, [username]     ; null username means guest
;     cmp     eax, 0
;     je      guest_menu
;     ; jne     user_menu
; guest_menu:
;     call    print_guest_menu
;     call    input
;     call    check_choice

;     cmp     eax, 1

;     cmp     eax, 2

;     cmp     eax, 3
;     je      exit_program


;     jne     guest_menu

exit_program:
    call    exit 