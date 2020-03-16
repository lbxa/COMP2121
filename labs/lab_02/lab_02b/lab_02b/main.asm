; #########################################################
; lab_01d.asm
; #########################################################
; Program which implements lab_01d into a function, which
; is then called on specific values within a queue
;
; Created: 15/03/2020 5:38:20 PM
; Authors : Lucas Barbosa, Liam Garde
; #########################################################

.NOLIST
 .include "m2560def.inc"
.LIST 

.macro SET_STACK
	ldi YH, high(RAMEND)
    ldi YL, low(RAMEND)
    out SPH, YH
    out SPL, YL
.endmacro

; parameters
.def array_loc_h = r8       ; (r8:r9 for array address)
.def array_loc_l = r9       ; uint8_t* sorted_array
.def array_size  = r10      ; uint8 array_size
.def queue_param = r11      ; uint8_t value
.def rval        = r24      ; insert_request() return value

; local vars
.def tmp_reg1 = r17
.def tmp_reg2 = r18
.def counter = r19
.def counter2 = r20

    .dseg
.org 0x200
.equ MAX_ARR_SIZE = 256
array_result: .byte MAX_ARR_SIZE

    .cseg
rjmp main
array: .db 1, 2, 5, 7, 8, 12, 20
queue: .db  0, 1, 10, 25, 6

.equ queue_size = 5
.equ start_size = 7

main:
    SET_STACK

    ldi ZH, high(array << 1)
    ldi ZL, low(array << 1)
    
    ldi XH, high(array_result)    ; link RAM to X
    ldi XL, low(array_result)

array_loop:
    lpm tmp_reg1, Z+              ; load from prog memory to a register
    st X+, tmp_reg1               ; store to data memory from a register

    inc counter
    cpi counter, start_size
    brne array_loop

    clr counter
    clr counter2
    clr tmp_reg1
    clr tmp_reg2

    ; initialization for inserting a value
    ; init Z with address for Queue
    ldi ZH, high(queue << 1)
    ldi ZL, low(queue << 1)

    ; uint8_t insert_request(uint8_t *sorted_array, uint8_t array_size, uint8_t value)
    ldi tmp_reg1, start_size
    mov array_size, tmp_reg1           ; uint8_t array_size
    ldi tmp_reg1, high(array_result)
    mov array_loc_h, tmp_reg1          ; uint8_t *sorted_array
    ldi tmp_reg1, low(array_result)
    mov array_loc_l, tmp_reg1
    
queue_loop:
    lpm tmp_reg1, Z+            ; load a value from the queue, move Z pointer up
    mov queue_param, tmp_reg1   ; move to 4th parameter register
    rcall insert_request        ; call function
    mov array_size, rval        ; move the return of the function to array size
    inc counter
    cpi counter, queue_size
    breq queue_loop_exit
	rjmp queue_loop

queue_loop_exit:

halt:
	rjmp halt

; #########################################################
;  Function
; #########################################################

insert_request:
	; prologue
    push r17
    push r18
    push r19
    push r20

    mov XH, array_loc_h
    mov XL, array_loc_l
    clr counter
    clr counter2
    mov rval, array_size   ; function will eventually return new array size

insert_sorted:
    ld tmp_reg1, X
    cp queue_param, tmp_reg1
    breq dont_insert      ; don't include repeated numbers
    brlo insert           ; if the number is lower than the value in the array
	                      ; else: greater than or equal
    inc counter
    cp array_size, counter
    brlo end_insert
    adiw X, 1             ; i++
    rjmp insert_sorted

insert:
    ; the X register should store the data address to move up
    ; at this point the counter stores what position we are at starting from 1
    mov counter2, array_size    ; counter2 - counter represents how many items  
    sub counter2, counter       ; need to be inserted into the array (the offset)
    inc counter2                ; cheeky increment (i++)
    clr counter
    mov tmp_reg2, queue_param

 mov_up:
    ld tmp_reg1, X         ; load a value at X to a register
    st X+, tmp_reg2        ; store the new value at next location of X -> (post decrement)
    mov tmp_reg2, tmp_reg1 ; copy the value we took out, move it to the value we want to put back in
    inc counter
    cp counter, counter2
    breq mov_finished      ; ensures we stop at the end
    rjmp mov_up

end_insert:
	st X, queue_param

mov_finished:
	inc rval              ; array size gets bigger

dont_insert:
	pop r20
	pop r19
	pop r18
	pop r17

	ret