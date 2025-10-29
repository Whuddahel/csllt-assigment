; This file will contain the functions for login and registering accounts.
;------------------------------------------------------------------------------------------------------------------------------
SECTION .data
account_details_file        db  "account_details.txt", 0h
login_notice    db  "Logging into an account...", 0h
register_notice    db  "Registering a new account...", 0h
msg_enter_uname db  "Enter in your username: ", 0h
msg_enter_pass  db  "Enter in your password: ", 0h
login_success   db  "Login Successful. Logging in as ", 0h
register_success   db  "Registration Successful. Please log in to access the account.", 0h
login_failed   db  "Invalid credentials", 0h

error_comma db  "Username or password cannot contain a comma.", 0h
error_username_exists   db  "This username is already taken.", 0h
;------------------------------------------------------------------------------------------------------------------------------
; void register()
; This function takes a username and password from the user. Usernames and passwords must not contain commas. The username should also be unique
; If all checks are passed, the new entry is appended with 0 balance
register:
    push    ebx
    push    esi
    push    edi

.request_username:
    mov     eax, msg_enter_uname
    call    strprint
    call    input

    mov     esi, input_buffer               ; temporarily store username in username
    mov     edi, username
    call    strcpy

.validate_username:
    mov     esi, username

.comma_check_username:
    mov     al, [esi]
    cmp     al, 0
    je      .existing_check_username

    cmp     al, ","
    je      .contains_comma

    inc     esi
    jmp     .comma_check_username

.existing_check_username:
    mov     eax, username
    call    find_user_offset

    cmp     eax, -1
    jne     .username_exists

.request_password:
    mov     eax, msg_enter_pass
    call    strprint
    call    input

    mov     esi, input_buffer               ; storing password in temp_buffer   
    mov     edi, temp_buffer
    call    strcpy

.validate_password:
    mov     esi, temp_buffer

.comma_check_password:
    mov     al, [esi]
    cmp     al, 0
    je      .all_good

    cmp     al, ","
    je      .contains_comma

    inc     esi
    jmp     .comma_check_password

.all_good:
    mov     esi, username
    mov     edi, line_buffer
    call    strcpy

    mov     esi, line_buffer
    mov     eax, line_buffer                ; get current length of line_buffer
    call    strlen
    add     edi, eax                        ; EDI now points to the end of the string

    mov     byte [edi], ","
    inc     edi
    ; copy password
    mov     esi, temp_buffer
.copy_password_loop:
    mov     al, [esi]
    cmp     al, 0
    je      .append_rest

    mov     [edi], al
    inc     esi
    inc     edi
    jmp     .copy_password_loop

.append_rest:
    mov     byte [edi], ","
    inc     edi
    mov     byte [edi], "0"
    inc     edi
    mov     byte [edi], 0
    inc     edi

    mov     esi, line_buffer
    call    append_accounts
    mov     eax, register_success
    call    strprintln
    jmp     .return

.username_exists:
    mov     eax, error_username_exists
    call    strprintln

    jmp     .return

.contains_comma:
    mov     eax, error_comma
    call    strprintln

    jmp     .return

.return:
; THIS CLEARS UNAME
    mov     edi, username    ; destination address
    mov     ecx, 255          ; size of username buffer 
    xor     eax, eax         ; zero to store
    rep     stosb            ; fill [edi]..[edi+ecx-1] with zeros


    pop     edi
    pop     esi
    pop     ebx
    ret

;------------------------------------------------------------------------------------------------------------------------------
; void login()
; Will request arguments from the user.
; The username variable in .bss will be updated if successful
login:
    push    ebx
    push    esi
    push    edi

    mov     eax, login_notice
    call    strprintln

.request_username:
    mov     eax, msg_enter_uname
    call    strprint
    call    input

    mov     esi, input_buffer               ; temporarily store username in username
    mov     edi, username
    call    strcpy

.request_password:
    mov     eax, msg_enter_pass
    call    strprint
    call    input

    mov     esi, input_buffer               ; storing password in temp_buffer   
    mov     edi, temp_buffer
    call    strcpy

.find_user_line:
    mov     eax, username
    call    find_user_offset                ; respective file line is in line_buffer now, EAX is offset
    cmp     eax, 0
    jl      .login_failed                   ; offset is -1 if failed (no match)

.compare_password: 
    mov     eax, 1
    call    tokenize                        ; token_buffer is password

    mov     eax, token_buffer
    mov     ebx, temp_buffer
    call    strcmp

    cmp     eax, 0
    je      .login_success

.login_failed:
    mov     eax, login_failed
    call    strprintln

    mov     edi, username    ; destination address
    mov     ecx, 255          ; size of username buffer
    xor     eax, eax         ; zero to store
    rep     stosb            ; fill [edi]..[edi+ecx-1] with zeros

    jmp    .return

.login_success:
    mov     eax, login_success
    call    strprint
    mov     eax, username
    call    strprintln

.return:
    pop     edi
    pop     esi
    pop     ebx
    ret



