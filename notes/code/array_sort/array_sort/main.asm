;
; array_sort.asm
;
; Created: 15/03/2020 3:41:34 PM
; Author : lucas
;

.NOLIST
.include "m2560def.inc"
.LIST

; PRESETS
.macro SET_STACK
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16
.endmacro	

.dseg 
.equ ARR_MAX_SIZE = 7
array_d: 
	.byte ARR_MAX_SIZE

.cseg
.org 0x200

start:
	SET_STACK
    ldi XL, LOW(array << 1)
	ldi XH, HIGH(array << 1)
    lpm r24, X+

halt:
	rjmp halt

array:
	.db 1, 2, 5, 7, 8, 12, 20
