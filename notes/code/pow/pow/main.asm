; Implementation of pow() function from lecture examples

.include "m2560def.inc"

.def zero = r15 ; To store constant value 0

; Multiplication of two 2 byte unsigned numbers with a 2 byte result.
; All parameters are registers, @5:@4 should be in the form: rd+1:rd,
; where d is the even number, and they are not r1 and r0.
; operation: (@5:@4) = (@1:@0) * (@3:@2)

.macro mul2                     ; a * b
	mul @0, @2                  ; al * bl
	movw @5:@4, r1:r0
	mul @1, @2                  ; ah * bl
	add @5, r0
	mul @0, @3                  ; bh * al
	add @5, r0
.endmacro

main:
	ldi r28, low(RAMEND -4)     ; 4 bytes to store local
	ldi r29, high(RAMEND - 4)   ; Assume an integer is 2
	out SPH, r29                ; Adjust stack pointer to point
	out SPL, r28                ; to the new stack

; Function body of ‘main’
	ldi r24, low(2)             ; m = 2;
	ldi r25, high(2)
	std Y+1, r24
	std Y+2, r25
	ldi r24, low(3)             ; n = 3;
	ldi r25, high(3)
	std Y+3, r24
	std Y+4, r25

; Prepare parameters for function call.
	ldd r20, Y+3                ; r21:r20 hold the actual parameter n
	ldd r21, Y+4
	ldd r22, Y+1                ; r23:r22 hold the actual parameter m
	ldd r23, Y+2
	rcall pow                   ; Call subroutine ‘
	std Y+1, r24                ; Store the returned result
	std Y+2, r25

end:
	rjmp end                    ; end of main function()

pow:
; prologue:			        
	push r28                    ; r29:r28 will be used as the frame pointer              
	push r29                    ; Save r29:r28 in the stack 
	push r16

	push r17                    ; Save registers used in the function body
	push r18
	push r19
	push zero
	in r28, SPL                 ; Initialize the stack frame pointer value
	in r29, SPH
	sbiw r29:r28, 8             ; Reserve space for local variables
	                            ; and parameters.
	out SPH, r29                ; Update the stack pointer to
	out SPL, r28                ; point to the new stack
	                            ; Pass the actual parameters.

	std Y+1, r22                ; Pass m to b
	std Y+2, r23
	std Y+3, r20                ; Pass n to e
	std Y+4, r21
; end of prologue

; Function body
	                  ; Use r23:r22 for i and r21:r20 for p,
	                  ; r25:r24 temporarily for e, and r17:r16 for b
	clr zero
	clr r23           ; Initialize i to 0
	clr r22;
	clr r21           ; Initialize p to 1
	ldi r20, 1
	ldd r25, Y+4      ; Load e to registers
	ldd r24, Y+3
	ldd r17, Y+2      ; Load b to registers
	ldd r16, Y+1

loop:
	cp r22, r24       ; compare i with e
	cpc r23, r25
	brsh done         ; if i >= e
	mul2 r20,r21, r16,r17, r18,r19           ; p *= b
	movw r21:r20, r19:r18
	; AVR does not have add immediate instructions (addi, addci)
	; but it can be done by subtracting a negative immediate.
	; Could adiw be used instead?
	sbi r22, LOW(-1)
	sbci r23, HIGH(-1)
	rjmp loop

done:
	movw r25:r24, r21:r20
	; End of function body

; Epilogue
	;ldd r25, Y+8
	; the return value of p is stored in r25,r24
	;ldd r24, Y+7
	adiw r29:r28, 8       ; De allocate the reserved space
	out SPH, r29
	out SPL, r28
	pop zero
	pop r19
	pop r18               ; Restore registers
	pop r17
	pop r16
	pop r29
	pop r28
	ret                   ; Return to caller
	; End of epilogue