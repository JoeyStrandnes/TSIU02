/*

16-Bit Timer test
Timer for real time counting/ keeping time


*/

.org 0x00
jmp SETUP

.org 0x10 
jmp ISR_TIMER1

.org 0x12
jmp ISR_TIMER0



.org 0x30

SETUP: 
	
	.def TIME = r22
	ldi TIME, 14

	ldi	r16, HIGH(RAMEND)
	out	SPH, r16
	ldi	r16, LOW(RAMEND)
	out	SPL, r16

	ldi r16, 0xFF
	out DDRB, r16

	ldi r16, 0x03
	out DDRD, r16

	ldi ZH, HIGH(NUMBER*2)
	ldi ZL, LOW(NUMBER*2)

	//Allocated 4 bytes in memory
	.cseg
	TIME_VAR:
	.org 0x60
	.byte 0x04
	.dseg

	ldi r16, LOW(TIME_VAR)
	out XL, r16

	ldi r16, HIGH(TIME_VAR)
	out XH, r16


TIMER1_INIT: ;16-bit timer 1 set as an overflow timer 
	
	; Setting counter mode
	ldi r16, (1<<WGM13)|(1<<WGM12)
	out TCCR1B, r16

	ldi r16, (1<<WGM11)|(0<<WGM10) 
	out TCCR1A, r16

	; Setting max counter value before overflow
	ldi r16, 0xFF 
	out ICR1H, r16
	ldi r16, 0xFF
	out ICR1L, r16

	; Setting prescaling and interrupt
	ldi r16,(1<<CS12)|(0<<CS11)|(1<<CS10) ;Prescaler set to F_CPU/1024 (S:108) MED 1024 OCH  ICR1 = FFFF 1046 ms
	out TCCR1B, r16
	ldi r16, 1<<TOIE1
	out TIMSK, r16
	

TIMER0_INIT:

	ldi r16, (1<<CS02) | (1<<CS00) // Prescaler 1024
	out TCCR0, r16
	sei

MAIN:
	;call loop


	lpm  r16, Z+
	out  PORTB, r16
	call MULTIPLEX
	call LOOP
	cpi  r16, 0x67
	brne NOT_9
	ldi  ZH, HIGH(NUMBER*2)
	ldi  ZL, LOW(NUMBER*2)
NOT_9:
	rjmp MAIN
	


ISR_TIMER1:
	push r16
	in r16,SREG //RÄDDAR FLAGGOR- SKA VARA KVAR! :D
	push r16
	call TIMER_COUNTER
	pop r16
	out SREG,r16
	pop r16
	reti
	
ISR_TIMER0:
	push r16
	in r16,SREG //RÄDDAR FLAGGOR- SKA VARA KVAR! :D
	push r16

	call DISPLAY_TIME

	pop r16
	out SREG,r16
	pop r16
	reti



TIMER_COUNTER:
	
	dec TIME
	breq MAIN
	ret


/*
MULTIPLEX:
	ldi r20, 0x4
LOOP420:
	call LOOP
	dec r20
	out PORTD, r20
	brne LOOP420	
	ret  


LOOP: ;TEST LOOP for timer
    ldi  r18, 5
    ldi  r19, 50
L1: dec  r19
    brne L1
    dec  r18
    brne L1
    nop
	ret
*/

.org 0x0200 
Number: .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7C, 0x07, 0x7F, 0x67

