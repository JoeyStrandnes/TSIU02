;
; IR-lank.asm
;
; Created: 2019-11-08 12:25:30
; Author : josst471
;


	ldi r21, $00
	ldi r23, $00 ; Startbit counter
	ldi r20, $00

	ldi r22, $0F
	out DDRB, r22

	;in r21, PINA

START_BIT:

	sbis PINA, 0
	brne START_BIT
	ldi r16, 31
	clr r23

DELAY:
	sbi PORTB, 7
delayYttreLoop:
	ldi r17, $1F
delayInreLoop:
	dec r17
	brne delayInreLoop
	dec r16
	brne delayYttreLoop
	cbi PORTB, 7

	inc r23


DATA:
	
	ldi r16, 62
	
	cpi r23, 2
	brne DELAY

	in r20, PINA
	lsl r20

	cpi r23, 3
	brne DELAY

	in r20, PINA
	lsl r20

	;sbic PINA, 0
	;ldi r22, 1
	;ldi r22, 0
	


	inc r21
	jmp DELAY