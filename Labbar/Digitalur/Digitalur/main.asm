/*

8-Bit Timer test
Timer for real time counting/ keeping time


*/

SETUP: 
	
	.def TIME = r22
	ldi TIME, 60



TIMER0_INIT: ;8-bit timer 0 set as an overflow timer 

	ldi r16,(1<<CS12)|(1<<CS10) ;Prescaler set to F_CPU/1024 (S:108)
	out TCCR1A, r16
	ldi r16,1<<TOV0
	out TCCR1B,r16 ; Clear interrupts
	ldi r16,1<<TOIE0
	sts TOIE1,r16 ; Interrup enable
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
	reti
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
	rjmp MAIN

