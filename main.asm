%include "util.asm"
%include "io.asm"
%include "validation.asm"
%include "menu.asm"
%include "login.asm"
%include "files.asm"
%include "debug.asm"
%include "user-functions.asm"

SECTION .data
; VARIABLES

; MESSSAGES

msg1    db  "Poop", 0h
msg2    db  "Poop", 0h
logout_msg  db  "You are being logged out to a Guest account...", 0h
exit_msg    db  "Exiting the program. Goodbye...", 0h


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


main_menu:
    mov     eax, username
    call    strprintln
    mov     eax, [username]     ; null username means guest
    cmp     eax, 0
    je      guest_menu
    jne     user_menu
guest_menu:
    call    print_guest_menu
    call    input
    mov     eax, input_buffer
    call    atoi

    cmp     eax, 1
    je      do_register
    cmp     eax, 2
    je      do_login
    cmp     eax, 3
    je      exit_program
    jmp     invalid_choice

do_register:
    call    register
    jmp     main_menu

do_login:
    call    login
    jmp     main_menu


user_menu:
    call    print_user_menu
    call    input
    mov     eax, input_buffer
    call    atoi

    cmp     eax, 1
    je      do_view_balance
    cmp     eax, 2
    je      do_deposit
    cmp     eax, 3
    je      do_withdraw
    cmp     eax, 4
    je      do_transfer
    cmp     eax, 5
    je      do_logout
    cmp     eax, 6
    je      exit_program
    jmp     invalid_choice

do_view_balance:
    call    view_balance
    jmp     main_menu
do_deposit:
    call    login
    jmp     main_menu
do_withdraw:
    call    login
    jmp     main_menu
do_transfer:
    call    login
    jmp     main_menu
do_logout:
    mov     byte [username], 0
    mov     eax, logout_msg
    call    strprintln
    jmp     main_menu

    

invalid_choice:
    mov     eax, msg_invalid_choice
    call    strprintln
    jmp     main_menu

exit_program:
    mov     eax, exit_msg
    call    strprintln
    call    exit 