; void print_registers()
; Prints all general-purpose registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP)
; Uses existing strprint and intprint

section .data
reg_labels:
    db "EAX: ",0
reg_labels_ebx:
    db "EBX: ",0
reg_labels_ecx:
    db "ECX: ",0
reg_labels_edx:
    db "EDX: ",0
reg_labels_esi:
    db "ESI: ",0
reg_labels_edi:
    db "EDI: ",0
reg_labels_ebp:
    db "EBP: ",0
reg_labels_esp:
    db "ESP: ",0
newline db 0Ah, 0

section .text
print_registers:
    pushf
    pushad                    ; save all registers

    ; EAX
    mov eax, reg_labels
    call strprint
    mov eax, [esp + 28]         ; original EAX
    call intprint
    mov eax, newline
    call strprint

    ; EBX
    mov eax, reg_labels_ebx
    call strprint
    mov eax, [esp + 16]
    call intprint
    mov eax, newline
    call strprint

    ; ECX
    mov eax, reg_labels_ecx
    call strprint
    mov eax, [esp + 24]
    call intprint
    mov eax, newline
    call strprint

    ; EDX
    mov eax, reg_labels_edx
    call strprint
    mov eax, [esp + 20]
    call intprint
    mov eax, newline
    call strprint

    ; ESI
    mov eax, reg_labels_esi
    call strprint
    mov eax, [esp + 12]
    call intprint
    mov eax, newline
    call strprint

    ; EDI
    mov eax, reg_labels_edi
    call strprint
    mov eax, [esp + 8]
    call intprint
    mov eax, newline
    call strprint

    ; EBP
    mov eax, reg_labels_ebp
    call strprint
    mov eax, [esp + 4]
    call intprint
    mov eax, newline
    call strprint

    ; ESP
    mov eax, reg_labels_esp
    call strprint
    lea eax, [esp + 32]         ; approximate original ESP before pushad
    call intprint
    mov eax, newline
    call strprint

    popad
    popf
    ret
