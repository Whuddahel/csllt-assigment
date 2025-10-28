;------------------------------------------------------------------------------------------------------------------------------
SECTION .data
msg_invalid_choice      db  "Enter in an appropriate choice", 0h          
;------------------------------------------------------------------------------------------------------------------------------
; boolean check_choice(int user_choice)
; This function is used to check whether the user's choice is within the range of options provided.
; User input is expected in EAX. EAX will contain an error message if invalid.
check_choice:
    mov     eax, input_buffer
    call    atoi

.within_guest_range:
; Input between 1 and 3
    cmp     eax, 1
    jl      .invalid
    cmp     eax, 3
    jg      .invalid

.within_user_range:
; Input between 1 and 9 (for now)
    cmp     eax, 1
    jl      .invalid
    cmp     eax, 9
    jg      .invalid

.finished:
; TODO: PLACEHOLDER
    call    intprintln
    ret

.invalid:
    mov     eax, msg_invalid_choice
    call    strprintln
    ret
    
