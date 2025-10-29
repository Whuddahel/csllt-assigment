SECTION .data
temp_file   db      "accounts.tmp", 0h
balance_msg     db      "Your balance is: $", 0h

view_balance:
    call    find_user_offset

    mov     eax, 2
    call    tokenize

    mov     eax, balance_msg
    call    strprint

    mov     eax, token_buffer
    call    strprintln
    ret

; update_user_balance
; EAX is username, EBX is new balance
update_user_balance:
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    push    ebx                             ; new balance, string representation
    push    eax                             ; username
    call    find_user_offset                   ; The sole reason I created this function
    push    eax                             ; number of bytes to read until matching account start

.open_fds:
    mov     ecx, 0                          ; O_RDONLY
    mov     ebx, account_details_file
    mov     eax, 5                          ; SYS_OPEN
    int     80h                         
    mov     [fd_storage], eax

    mov     edx, 644                        ; rw-r--r-- file permissions
    mov     ecx, 241h                       ; O_WRONLY, O_CREAT, and O_TRUNC in case of prev bad runs
    mov     ebx, temp_file
    mov     eax, 5                          ; SYS_OPEN
    int     80h                         
    mov     [fd_temp], eax

    pop     edi                             ; number of bytes to read
    mov     esi, line_buffer
.first_copy:                                ; copies until the beginning of the matching line, one char at a time.
    mov     edx, 1                          ; read 1 byte at a time
    mov     ecx, esi                        ; put the char in line_buffer, each loop will replace the previous loop's character
    mov     ebx, [fd_storage]               ; EBX is used for FD in SYS_READ
    mov     eax, 3
    int     80h    

    cmp     eax, 0                         ; end of file, assuming the last valid entry is also newline-terminated
    je      .end_of_file

    mov     edx, 1                          ; write the read byte into accounts.tmp
    mov     ecx, esi
    mov     ebx, [fd_temp]
    mov     eax, 4
    int     80h

    dec     edi   
    cmp     edi, 0
    je      .create_new_entry
  
    jmp     .first_copy

.create_new_entry:
    pop     esi                             ; now contains username
    mov     edi, temp_buffer            
    call    strcpy                          ; temp_buffer only has username now, EAX points to last byte
    mov     edi, eax
    inc     edi
    mov     [edi], ","

    mov     eax, temp_buffer
    call    find_user_offset                ; line_buffer has the old entry

    mov     eax, 1
    call    tokenize                        ; get password in token_buffer
    mov     esi, token_buffer

    inc     edi
.append_password:    
    mov     al, [esi]
    cmp     al, 0
    je      .append_comma
    mov     [edi], al

    inc     edi
    inc     esi
    jmp     .append_password
.append_comma:
    inc     edi
    mov     byte [edi], ","

    pop     esi                             ;string representation of balance
    inc     edi
.append_balance:
    mov     al, [esi]
    cmp     al, 0
    je      .append_newline
    mov     [edi], al

    inc     edi
    inc     esi
    jmp     .append_balance
.append_newline:
    inc     edi
    mov     byte [edi], 0Ah
    mov     byte [edi + 1], 0

.write_new_entry:
    mov     eax, temp_buffer
    call    strlen

    mov     edx, eax
    mov     ecx, temp_buffer
    mov     ebx, [fd_temp]
    mov     eax, 4
    int     80h

    mov     esi, line_buffer
.copy_rest:                                ; copies until the end of the file now
    mov     edx, 1                          ; read 1 byte at a time
    mov     ecx, esi                        ; put the char in line_buffer, each loop will replace the previous loop's character
    mov     ebx, [fd_storage]               ; EBX is used for FD in SYS_READ
    mov     eax, 3
    int     80h    

    cmp     eax, 0                         ; end of file, assuming the last valid entry is also newline-terminated
    je      .end_of_file

    mov     edx, 1                          ; write the read byte into accounts.tmp
    mov     ecx, esi
    mov     ebx, [fd_temp]
    mov     eax, 4
    int     80h

    jmp     .copy_rest                      ; TODO MIGHT NEED TO APPEND NULL

.end_of_file:
    mov     ebx, [fd_storage]
    mov     eax, 6                 ; SYS_CLOSE
    int     80h

    mov     ebx, [fd_temp]
    mov     eax, 6
    int     80h
    
    mov     eax, 10
    mov     ebx, account_details_file
    int     80h
    mov     eax, 38
    mov     ebx, temp_file
    mov     ecx, account_details_file
    int     80h
    
    jmp     .return

.return:
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx

    ret 

; .open_fds:
;     mov     ecx, 0                          ; O_RDONLY
;     mov     ebx, account_details_file
;     mov     eax, 5                          ; SYS_OPEN
;     int     80h                         
;     mov     [fd_storage], eax

;     mov     edx, 644                        ; rw-r--r-- file permissions
;     mov     ecx, 241h                       ; O_WRONLY, O_CREAT, and O_TRUNC in case of prev bad runs
;     mov     ebx, temp_file
;     mov     eax, 5                          ; SYS_OPEN
;     int     80h                         
;     mov     [fd_temp], eax
;     ; not going to implement checks for bad file, too lengthy

;     mov     ecx, line_buffer
; .read_next_line:
;     mov     edx, 1
;     mov     ebx, [fd_storage]
;     mov     eax, 3                          ; SYS_READ
;     int     80h

;     ; likewise not going to check for failed reads
;     cmp     eax, 0
;     je      .end_of_file                    ; EOF

;     mov     al, [ecx]
;     cmp     al, 0Ah                         ; newline - end of entry
;     je      .process_line

;     inc     ecx
;     jmp     .read_next_line

; .process_line:
;     mov     byte [ecx], 0                   ; null terminate, replace newline
;     mov     eax, 0
;     call    tokenize

;     mov     eax, token_buffer
;     mov     ebx, esi
;     call    strcmp

;     cmp     eax, 0
;     jne     .write_original

; .write_modified:

; .write_original:
;     mov     byte [ecx], 0Ah                 ; back to new line
;     mov     byte [ecx + 1], 0                 ; null terminate
;     mov     eax, line_buffer
;     call    strlen                          ; should get length of line buffer + newline


;     mov     edx, eax
;     mov     ecx, line_buffer
;     mov     ebx, [fd_temp]
;     mov     eax, 4
;     int     80h
;     jmp     .read_next_line

; .continue_read:
;     mov     ecx, line_buffer
;     jmp     read_next_line

; .end_of_file:
;     ; close files
;     mov eax, 6
;     mov ebx, [fd_storage]
;     int 80h

;     mov eax, 6
;     mov ebx, [fd_temp]
;     int 80h

;     ; rename temp -> original
;     mov eax, 38         ; SYS_RENAME
;     mov ebx, temp_file
;     mov ecx, account_details_file
;     int 80h

;     jmp .return

; .return:
;     pop     edi
;     pop     esi
;     pop     edx
;     pop     ecx
;     pop     ebx

;     ret   
