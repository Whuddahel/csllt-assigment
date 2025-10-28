; This file contains file operations that may be commonly used
;------------------------------------------------------------------------------------------------------------------------------
SECTION .data
; filename        db  "account_details.txt", 0h   
; Already declared in login.asm
;------------------------------------------------------------------------------------------------------------------------------
; int find_user_line(String username)
; Arguments: Username in EAX
; Return value in EAX: -1 if no matches, byte offset to beginning of matching instance if so
find_user_offset:
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

.open_file:
    mov     ecx, 0                          ; O_RDONLY
    mov     ebx, account_details_file
    mov     eax, 5                          ; SYS_OPEN
    int     80h

    cmp     eax, 0
    jl      .open_failed  

    mov     [fd_storage], eax
    xor     edi, edi                        ; Will contain file offset
    mov     esi, line_buffer

.read_loop:
    mov     edx, 1                          ; read 1 byte at a time
    mov     ecx, esi                        ; put the char in line_buffer
    mov     ebx, [fd_storage]                       ; EBX is used for FD in SYS_READ
    mov     eax, 3
    int     80h

    cmp     eax, 0                         ; end of file, assuming the last valid entry is also newline-terminated
    je      .no_matches

    mov     al, [esi]                       ; the read byte is in ESI
    cmp     al, 0Ah                         ; newline - end of entry
    je      .check_line

    inc     esi
    inc     edi                            
    jmp     .read_loop

.check_line:                                ; see if the read line has the desired username
    mov     byte [esi], 0                   ; null-terminate line
    mov     esi, line_buffer

    mov     eax, 0
    call    tokenize                        ; EAX now contains the username

    mov     ebx, username
    call    strcmp

    cmp     eax, 0
    je      .found

    mov     esi, line_buffer
    mov     byte [esi], 0                   ; reset buffer
    inc     edi
    jmp     .read_loop

.found:
    mov     ebx, [fd_storage]
    mov     eax, 19                         ; SYS_LSEEK, note that EBX already contains the file descriptor
    mov     ecx, 0                          ; offset
    mov     edx, 1
    int     80h

    mov     eax, line_buffer
    call    strlen
    sub     edi, eax
    mov     eax, edi
    jmp     .return

.no_matches:
    mov     eax, -1
    jmp     .return

.open_failed:
    mov     eax, -1
    jmp     .return

.return:
    mov     ebx, [fd_storage] 
    push    eax                             ; want to return -1 if no matches
    mov     eax, 6                          ; SYS_CLOSE
    int     80h 

    mov     dword [fd_storage], 0           ; the FD is useless after SYS_CLOSE but just to be sure

    pop     eax

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret


;------------------------------------------------------------------------------------------------------------------------------
; String tokenize(int *index)
; Arguments: Field index in EAX (fields are separated by commas)
; Reads from line_buffer automatically, the tokenized value is in token_buffer
tokenize: 
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    mov     esi, line_buffer       ; source
    mov     edi, token_buffer       ; destination
    mov     ecx, eax               ; target field index
    xor     eax, eax               ; byte register counter (AL will hold char)
    xor     ebx, ebx               ; current field index

.skip_until_field:
    mov     al, [esi]

    cmp     al, 0                  ; end of entry
    je      .end_of_line

    cmp     ebx, ecx               ; at target field
    je      .copy_field

    cmp     al, ','
    jne     .next_skip
    inc     ebx

.next_skip:
    inc     esi
    jmp     .skip_until_field

.copy_field:
    mov     al, [esi]
    cmp     al, 0
    je      .terminate
    cmp     al, ','
    je      .terminate
    mov     [edi], al
    inc     esi
    inc     edi
    jmp     .copy_field

.terminate:
    mov     byte [edi], 0
    mov     eax, token_buffer
    jmp     .return

.end_of_line:
    mov     byte [token_buffer], 0
    mov     eax, token_buffer
    call    strprintln
    mov     eax, token_buffer

.return:
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

;--------------------------------------
; void append_accounts(String str)
; Appends the account_details.txt file
; Expects ESI to have the string pointer, ideally a whole entry, as this also puts a newline each time
append_accounts:
    push    eax
    push    ebx
    push    ecx
    push    edx

.open_file:
    mov     ebx, account_details_file
    mov     ecx, 442h        ; O_WRONLY | O_APPEND | O_CREAT
    mov     edx, 1B6h        ; mode 0666 rw- for all groups
    mov     eax, 5             ; SYS_OPEN
    int     80h
    cmp     eax, 0
    jl      .error_open
    mov     edi, eax           ; FD in EDI

.append_string:
    mov     eax, esi
    call    strlen
    mov     edx, eax           ; number of bytes to write

    mov     eax, 4             ; SYS_WRITE
    mov     ebx, edi           ; FD
    mov     ecx, esi           ; string pointer
    int     80h

    mov     eax, 4
    mov     ebx, edi
    mov     ecx, newline
    mov     edx, 1             ; just the newline byte
    int     80h

    mov     eax, 6             ; SYS_CLOSE
    mov     ebx, edi
    int     80h

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

.error_open:
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret