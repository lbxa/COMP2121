;
; reverse_string.asm
;
; Created: 15/03/2020 4:55:48 PM
; Author : lucas
;

.NOLIST
.include "m2560def.inc"
.LIST

.macro SET_STACK
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16
.endmacro

.dseg
msg_data: 
	.byte 0x200

.cseg
.org 0x200
rjmp start

start:
	SET_STACK
	ldi ZH, HIGH(msg << 1)
	ldi ZL, LOW(msg << 1)
	rcall get_length

	ldi XH, HIGH(msg_data)
	ldi XL, LOW(msg_data)
	add XL, r17               ; add counter to beginning of X
						      ; location where reverse string begins
loop:
	lpm r24, Z+
	st X, r24
	dec XL
	dec r17
	brge loop
	ret

; Subroutine
get_length:
	push ZH
	push XL
	ldi r17, 0

loop_1:
	lpm r24, Z+
	cpi r24, 0
	breq exit_loop
	inc r17
	rjmp loop_1

exit_loop: 
	pop ZH
	pop ZL
	ret

msg:
	.db "String to be reversed", 0