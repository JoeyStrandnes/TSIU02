;
; IR-lank.asm
;
; Created: 2019-11-08 12:25:30
; Author : Joey Strandnes
;


	ldi r22, $0F
	ldi r23, $01
	out DDRB, r22
	out DDRA, r23

	IN R21, PINA
	ANDI R21, (1<<3) ; Shift in PINA to Register1

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