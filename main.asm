%include "util.asm"
%include "io.asm"
%include "validation.asm"


SECTION .data
; VARIABLES

; MESSSAGES
welcome_banner          db  "***********************************************************************************",0Ah
                        db  "*                                                                                 *",0Ah
                        db  "*                                                                                 *",0Ah
                        db  "*   /$$      /$$ /$$$$$$$$ /$$        /$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$   *",0Ah
                        db  "*  | $$  /$ | $$| $$_____/| $$       /$$__  $$ /$$__  $$| $$$    /$$$| $$_____/   *",0Ah
                        db  "*  | $$ /$$$| $$| $$      | $$      | $$  \__/| $$  \ $$| $$$$  /$$$$| $$         *",0Ah
                        db  "*  | $$/$$ $$ $$| $$$$$   | $$      | $$      | $$  | $$| $$ $$/$$ $$| $$$$$      *",0Ah
                        db  "*  | $$$$_  $$$$| $$__/   | $$      | $$      | $$  | $$| $$  $$$| $$| $$__/      *",0Ah
                        db  "*  | $$$/ \  $$$| $$      | $$      | $$    $$| $$  | $$| $$\  $ | $$| $$         *",0Ah
                        db  "*  | $$/   \  $$| $$$$$$$$| $$$$$$$$|  $$$$$$/|  $$$$$$/| $$ \/  | $$| $$$$$$$$   *",0Ah
                        db  "*  |__/     \__/|________/|________/ \______/  \______/ |__/     |__/|________/   *",0Ah
                        db  "*                                                                                 *",0Ah
                        db  "*                  to Bob's Banking (Scamming) Application                        *",0Ah
                        db  "*                                                                                 *",0Ah
                        db  "***********************************************************************************",0Ah
               

actions_guest           db  "Chose from one of the options below: ", 0Ah
                        db  "1. Register", 0Ah
                        db  "2. Login", 0Ah
                        db  "3. Exit", 0h








SECTION .bss
username        resb    255
input_buffer    resb    255


SECTION .text
global _start
_start:
    mov     eax, welcome_banner      
    call    strprintln
    call    input
    call    check_choice

    call    exit 