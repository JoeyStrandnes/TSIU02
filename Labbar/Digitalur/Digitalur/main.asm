/*

8-Bit Timer test
Timer for real time counting/ keeping time


*/

.org 0x00
jmp SETUP

.org 0x10 
jmp ISR_TIMER0

.org 0x30

SETUP: 
	
	.def TIME = r22
	ldi TIME, 14

	ldi	r16, HIGH(RAMEND)
	out	SPH, r16
	ldi	r16, LOW(RAMEND)
	out	SPL, r16

TIMER0_INIT: ;16-bit timer 0 set as an overflow timer 

	ldi r16,(1<<CS11)|(1<<CS10) ;Prescaler set to F_CPU/64 (S:108) ~4.1S
	out TCCR1B, r16
	ldi r16, 1<<TOIE1
	out TIMSK, r16
	sei
	;ret

MAIN:
	call loop
	rjmp MAIN
	


ISR_TIMER0:
	push r16
	in r16,SREG
	push r16
	call TIMER_COUNTER
	pop r16
	out SREG,r16
	pop r16
	jmp MAIN
	
TIMER_COUNTER:
	dec TIME
	breq MAIN
	ret



LOOP: ;TEST LOOP for timer
    ldi  r18, 13
    ldi  r19, 252
L1: dec  r19
    brne L1
    dec  r18
    brne L1
    nop
	ret; MAIN

