
;En kort signal (”prick”/”dit”) är 1 tidsenhet lång
;En lång signal (”streck”/”dah”) är 3 tidsenheter
;Mellan teckendelarna skall det vara 1 tidsenhets tystnad
;Mellan tecknen 3 tidsenheters tystnad
;Mellan ord 7 tidsenheters tystnad.




SETUP:	

	.db $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8 ; Hex av Tecken

	ldi		r22,$01					; Utport till displayen+scop
	out		DDRB,r22				; Utport till displayen+scop
	
	ldi		r18, HIGH(RAMEND)
	out		SPH, r18
	ldi		r18, LOW(RAMEND)
	out		SPL, r18


	clr		r21						; DATA
	clr		r19						; Sort
	ldi		r20, 4					; COUNTER 1
	ldi		r18, 4					; COUNTER 2

TEXT:
	.db "DATORTEKNIK", $00

READ:
	ldi ZH, HIGH(TEXT*2)
	ldi ZL, LOW(TEXT*2)
	lpm r21, Z+
	;Call Something
	;lpm r21, Z
	brne READ

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








