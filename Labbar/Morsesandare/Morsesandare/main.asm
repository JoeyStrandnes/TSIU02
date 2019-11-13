
;En kort signal (”prick”/”dit”) är 1 tidsenhet lång
;En lång signal (”streck”/”dah”) är 3 tidsenheter
;Mellan teckendelarna skall det vara 1 tidsenhets tystnad
;Mellan tecknen 3 tidsenheters tystnad
;Mellan ord 7 tidsenheters tystnad.




SETUP:	

	ldi		r22,$0F					; Utport till Högtalaren
	out		DDRB,r22				; Utport till Högtalaren
	
	ldi		r18, HIGH(RAMEND)
	out		SPH, r18
	ldi		r18, LOW(RAMEND)
	out		SPL, r18


	clr		r21						; DATA
	clr		r19						; Sort
	ldi		r20, 4					; COUNTER 1
	ldi		r18, 4					; COUNTER 2

	ldi		ZL, LOW(TEXT*2)
	ldi		ZH, HIGH(TEXT*2)

	;ldi		XL, LOW(MORSE*2)
	;ldi		XH, HIGH(MORSE*2)


LOOP:
	call GET_CHAR
	

	;call GET_MORSE

	lpm r22, Z+
	out PORTB, r21



	rjmp LOOP




GET_CHAR:
	
	lpm		r21, Z+
	;call	LOOP
	;adiw	ZH:ZL,1
	ret
	

DELAY:
	ldi		r16,200
delayYttreLoop:
	ldi		r17,$1F
delayInreLoop:
	dec		r17
	brne	delayInreLoop
	dec		r16
	brne	delayYttreLoop
	ret	


TEXT:
	.db "DATORTEKNIK", $00



MORSE:
	.org 141
	.db $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8 ; Hex av Tecken







