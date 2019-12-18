

.org 0x00
jmp SETUP

.org 0x02
jmp ISR_INT0


SETUP:

ldi r16, HIGH(RAMEND)
out	SPH, r16

ldi r16, LOW(RAMEND)
out	SPL, r16

rjmp MAIN

HW_INIT:
ldi r16,0xFF
out DDRA, r16

ldi r16, (1<<ISC01)|(1<<ISC00)
out MCUCR, r16

ldi r16, 1<<INT0
out GICR, r16
sei

ret


MAIN:
	rjmp MAIN



ISR_INT0:
	in r16, PINB
	cpi r16, 10
	brmi LESS_THAN_10
	subi r16,10 // r16 har Entalssifrran i sig
	ori r16, 0x10 // OR:AR IN EN ETTA I TIOTALSSIFFRAN! 

LESS_THAN_10:
	
	swap r16
	out PORTA, r16

	reti