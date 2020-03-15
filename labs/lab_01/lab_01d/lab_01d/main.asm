; #########################################################
; lab_01d.asm
; #########################################################
; Program which loads arrays into different areas of memory 
; and sorts their order.
;
; Created: 15/03/2020 5:38:20 PM
; Author : Lucas
; #########################################################

.NOLIST
.include "m2560def.inc"
.LIST

; constants
.equ MAX_ARR_SIZE = 7
.def counter = r18
.def tmp = r19
.def num_input = r20

.dseg
int_arr_data: .byte MAX_ARR_SIZE
new_int_arr: .byte MAX_ARR_SIZE + 1

.cseg
.org 0x200
rjmp start

start:
	int_arr: .db 1, 2, 5, 7, 8, 12, 20
	ldi num_input, 8                        ; number to placed into the array 
											 ; maintaining sorted order
	ldi ZH, HIGH(int_arr << 1)
	ldi ZL, LOW(int_arr << 1)

	ldi YH, HIGH(int_arr_data)
	ldi YL, LOW(int_arr_data)

	clr counter
	rjmp load_array_loop

; This array will load all the values from int_arr
; into the corresponding values of Y in RAM
load_array_loop:
	lpm tmp, Z+							     ; tmp reg is used for lpm instruction
	st Y+, tmp								 ; store from Z+ into RAM memory				
	inc counter							     ; i++
	cpi counter, MAX_ARR_SIZE				 ; if (i == MAX_ARR_SIZE)
	breq load_array_end						 ; goto loop_end
	rjmp load_array_loop

load_array_end: 
	clr counter
	clr tmp
	ldi ZH, HIGH(int_arr << 1)
	ldi ZL, LOW(int_arr << 1)

	ldi YH, HIGH(new_int_arr)				 ; load new number into a newly sorted
	ldi YL, LOW(new_int_arr)                 ; array new_int_arr
	rjmp load_sorted_value

; Load new value into the array making
; sure it remain sorted. If the number already
; exists then don't add it in
load_sorted_value:
	lpm tmp, Z+
	cp num_input, tmp                        ; if (num_input < tmp) 
	breq continue_loop
	brlt insert_val                   
	rjmp continue_loop                       
						    
insert_val:	                             
	st Y+, num_input					     
	rjmp continue_loop

continue_loop:
	st Y+, tmp
	inc counter
	cpi counter, MAX_ARR_SIZE + 1
	breq load_sorted_end
	rjmp load_sorted_value

load_sorted_end:
	clr counter

halt:
	rjmp halt
	
	