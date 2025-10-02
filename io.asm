;------------------------------------------------------------------------------------------------------------------------------
; void strprint(String* message)
; This function expects 1 argument: String in EAX
; The string is printed to STDOUT (terminal interface)

strprint:
    push    edx
    push    ecx
    push    ebx
    push    eax

.print:
    call    strlen              ; EAX now contains strlen
    mov     edx, eax            ; String length expected in EDX
    pop     eax                 
    mov     ecx, eax            ; String* expected in ECX
    mov     ebx, 1              ; FD for STDOUT is 1
    mov     eax, 4
    int     80h

.return:
    pop     ebx
    pop     ecx
    pop     edx
    ret

;------------------------------------------------------------------------------------------------------------------------------
; void strprintln(String message)
; This function expects 1 argument: String in EAX
; The string is printed to STDOUT (terminal interface) with a trailing LF char

strprintln:
	call	strprint

	push	eax			       
	mov	    eax, 0Ah		    ; 0Ah is the Line Feed char ASCII code
					            ; EAX contains 0000000Ah

	push	eax			        ; Put the LF char on the stack
					            ; Stack top-down now is 0Ah, 00h, 00h, 00h

    mov 	eax, esp		    ; ESP points to the top of the stack (0Ah)
	call 	strprint

.return:
	pop	    eax			        ; Balance the stack
	pop	    eax			        
	ret				             

;------------------------------------------------------------------------------------------------------------------------------
; void intprint(int number)
; Expects 1 argument: Integer representation of a number in EAX
; Prints to STDOUT()

intprint:
	push 	eax			       
	push	ecx
	push	edx
	push 	esi			        

	mov	    ecx, 0			    ; Byte (char) counter

.divide_loop:
	inc 	ecx
	xor     edx, edx            ; Init remainder storage	    
	mov 	esi, 10
	idiv	esi			        ; Quotient will be in EAX, rmd in EDX

	add	    edx, 48             ; Get ASCII value (char representation)
	push	edx                 ; Push onto stack for printing later
	cmp	    eax, 0			    ; If EAX cannot be further divided, it will contain 0
	jnz	    .divide_loop

.print_loop:
	dec	    ecx
	mov 	eax, esp
	call	strprint
	pop	    eax

	cmp	    ecx, 0
	jnz	    .print_loop

.return:
	pop 	esi		        	; Balance stack and restore registers
	pop	    edx
	pop	    ecx
	pop	    eax
	ret

;------------------------------------------------------------------------------------------------------------------------------
; void intprintln(int number)
; Expects 1 argument: Integer representation of a number in EAX
; Prints to STDOUT() with a trailing LF

intprintln:
	call	intprint

	push	eax			       
     
	mov	    eax, 0Ah
	push	eax                 ; strprint takes a String*, not a String
	mov	    eax, esp
	call	strprint

.return:
	pop	    eax			        ; Balance stack and restore registers
	pop	    eax
	ret
		        