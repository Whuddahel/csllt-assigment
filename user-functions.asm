SECTION .data
temp_filename   db      "accounts.tmp", 0h
; update_user_balance
; EAX is username, EBX is new balance
view_balance:
    call    find_user_offset
    ; cmp     eax, -1
    ; je      .user_not_found

    mov     eax, 2
    call    tokenize

    mov     eax, token_buffer
    call    strprintln
    ret

; update_user_balance:
;     push    ebx
;     push    ecx
;     push    edx
;     push    esi
;     push    edi

;     ret   
