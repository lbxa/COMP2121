;
; basics.asm
;
; Created: 8/03/2020 11:30:49 PM
; Author : lucas
;

.include "m2560def.inc"

; Replace with your application code
start:
	ldi r16, 8
	ldi r17, 9

halt:
	rjmp halt
