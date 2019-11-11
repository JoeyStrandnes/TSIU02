;
; IR-lank.asm
;
; Created: 2019-11-08 12:25:30
; Author : josst471
;

	
	ldi r22, $0F
	;ldi r23, $00
	ldi r21, $01
	out DDRB, r22
	;out DDRA, r23

	in r21, PINA

START_BIT:
	;clr r21

	;ldi r21, PINA
	sbis PINA, 0
	;cpi r21, 1
	brne START_BIT
	;ANDI R21, (1<<7) ; Shift in PINA to Register1


DATA:

DELAY:
	sbi PORTB, 7
	ldi r16, 10
delayYttreLoop:
	ldi r17, $1F
delayInreLoop:
	dec r17
	brne delayInreLoop
	dec r16
	brne delayYttreLoop
	cbi PORTB, 7
	ret