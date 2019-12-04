/*

Multiplex 4x7-segment display with internal timers for time keeping

16-bit timer overflow for counting time ~1Hz
8-bit timer overflow for multiplexing segment display ~15kHz

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
	.dseg
	.org 0x60
	TIME_VAR:
	.byte 0x04

	.cseg

	ldi YL, LOW(TIME_VAR)
	ldi YH, HIGH(TIME_VAR)


TIMER1_INIT: ;16-bit timer 1 set as an overflow timer 
	
	; Setting counter mode
	ldi r16, (1<<WGM13)|(1<<WGM12)
	out TCCR1B, r16

	ldi r16, (1<<WGM11)|(0<<WGM10) 
	out TCCR1A, r16

	; Setting max counter value before overflow
	ldi r16, 0x3D
	out ICR1H, r16
	ldi r16, 0x08
	out ICR1L, r16

	; Setting prescaling and interrupt
	in r16, TCCR1B  
	ori r16,(0<<CS12)|(1<<CS11)|(1<<CS10) ;Prescaler set to F_CPU/64 (S:108)

	out TCCR1B, r16
	ldi r16, 1<<TOIE1
	out TIMSK, r16
	

TIMER0_INIT:

	ldi r16, (1<<CS02)|(0<<CS01)|(0<<CS00) // Prescaler 256
	out TCCR0, r16
	
	in r16, TIMSK
	ori r16, (1<<TOIE0)

	out TIMSK, r16
	sei

MAIN:
	nop
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

DISPLAY_TIME:
	


	ret

TIMER_COUNTER:
	
	// Sekunder
	ldd r17, Y+3
	inc r17 
	std Y+3, r17
	cpi r17, 10
	brne NOT_10

	// Tiotal sek
	clr r17
	std Y+3, r17
	ldd r17, Y+2
	inc r17
	std Y+2, r17
	cpi r17, 6
	brne NOT_60

	// Minuter
	clr r17
	std Y+2, r17
	ldd r17, Y+1
	inc r17
	std Y+1, r17
	cpi r17, 10
	brne NOT_10

	// Tiotal Minuter
	clr r17
	std Y+1, r17
	ldd r17, Y+0
	inc r17
	std Y+0, r17
	cpi r17, 6
	brne NOT_60
	clr r17
	std Y+0, r17

NOT_10:

NOT_60:

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
*/

.org 0x0200 
Number: .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7C, 0x07, 0x7F, 0x67

