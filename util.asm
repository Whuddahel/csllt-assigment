;------------------------------------------------------------------------------------------------------------------------------
; int strlen(String* message)
; This function takes 1 argument: String in EAX
; The return value - length of the string, excluding the null indicator is left in EAX

strlen:
    push    ebx                 ; Preserve original EBX value
    mov     ebx, eax            ; EBX will contain the address of the starting character

.nextchar:
    cmp     byte[eax], 0        ; Check whether the pointed byte (char) is a null terminator
    jz      .finished           
    inc     eax                 ; EAX now points to the next byte (char)
    jmp     .nextchar

.return:
    sub     eax, ebx            ; Get difference in size in bytes a.k.a string length
    
    pop     ebx                 ; Restore original EBX value
    ret

;------------------------------------------------------------------------------------------------------------------------------
; int atoi(String* number)
; This function takes 1 argument: String in EAX
; The return value is the integer representation of the string in EAX

atoi:
	push 	ebx			
	push	ecx                 
	push	edx
	push	esi                 

	mov	esi, eax                ; Contains string pointer
	mov	eax, 0                  ; Init result storage
	mov	ecx, 0                  ; Init loop counter

.multiply_loop:
	xor	ebx, ebx		        ; Clear EBX register
	mov	bl, [esi + ecx]		    ; Current character is loaded into BL
					            ; Using BL allows precisely one byte (char) to be loaded
					            ; Alternative: movzx byte [esi + ecx]

	cmp	bl, 48
	jl	.finished		        ; ASCII values <48 are not digits
	cmp	bl, 57
	jg	.finished		        ; ASCII values >57 are also not digits
					            ; Any non-numeric value (e.g. null terminator) will exit the loop


	sub	bl, 48                  ; Get integer representation of current char
	add	eax, ebx		        ; EAX now contains the digit as the LSB
	mov	ebx, 10
	mul 	ebx			        ; Increase level of significance of previous digit by one
                                ; Makes space for the next digit

	inc 	ecx                 ; Increment loop counter, BL will contain the next char the following iteration
	jmp	.multiply_loop

.finished:
	cmp	ecx, 0			        ; In case of no valid arguments
	je 	.return

	mov	ebx, 10
	div	ebx			            ; Balance out the initial *10 operation performed

.return:
	pop	esi     
	pop	edx
	pop	ecx
	pop	ebx
	ret

;------------------------------------------------------------------------------------------------------------------------------
; void exit()
; Takes no arguments, is responsible for proper program exit

exit:
    xor     ebx, ebx            ; Clears EBX (program status code) register
    mov     eax, 1              ; Kernel OPCODE for SYS_EXIT
    int     80h                 ; Invocation
    ret                         ; Actually redudant, but just there because OCD