; Div8 divides a 16-bit-number by a 8-bit-number 
; (Test: 16-bit-number: 0xAAAA, 8-bit-number: 0x55) 
.nolist
.include "m2586include.def"
.list

; presets
.def dividend_l = R0   ; LSB 16-bit-number to be divided 
.def dividend_h = R1   ; MSB 16-bit-number to be divided 
.def tmp = R2          ; interim register
.def divisor = R3      ; 8-bit-number to divide with
.def result_low = R4   ; LSB result
.def result_high = R5  ; MSB result
.def load = R16        ; multipurpose register for loading 

.cseg
.org 0

rjmp start

start:
    ldi load, 0xAA    ; 0xAAAA to be divided 
    mov dividend_h, load
    mov dividend_l, load
    ldi load, 0x55    ; 0x55 to be divided with 
    mov divisor,load

; Divide dividend_h:dividend_l by divisor 
div8: 
    clr tmp            ; clear interim register
    clr result_high    ; clear result (the result registers
    clr result_low     ; are also used to count to 16 for the 
    inc result_low     ; division steps, is set to 1 at start)

; Here the division loop starts 
div8a:
    clc               ; clear carry-bit
    rol dividend_l    ; rotate the next-upper bit of the number 
    rol dividend_h    ; to the interim register (multiply by 2) 
    rol tmp

    brcs div8b        ; a one has rolled left, so subtract
    cp tmp, divisor   ; Division result 1 or 0?
    brcs div8c        ; jump over subtraction, if smaller

div8b:
    sub tmp,divisor   ; subtract number to divide with 
    sec               ; set carry-bit, result is a 1
    rjmp div8d        ; jump to shift of the result bit

div8c:
    clc               ; clear carry-bit, resulting bit is a 0

div8d:
    rol result_low    ; rotate carry-bit into result registers
    rol result_high
    brcc div8a        ; as long as zero rotate out of the result 
                      ; registers: go on with the division loop

; End of the division reached 
stop:
    rjmp stop         ; endless loop