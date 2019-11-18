;En kort signal (”prick”/”dit”) är 1 tidsenhet lång
;En lång signal (”streck”/”dah”) är 3 tidsenheter
;Mellan teckendelarna skall det vara 1 tidsenhets tystnad
;Mellan tecknen 3 tidsenheters tystnad
;Mellan ord 7 tidsenheters tystnad.
	
SETUP:
	ldi	r16, HIGH(RAMEND)
	out	SPH, r16
	ldi	r16, LOW(RAMEND)
	out	SPL, r16
	;ldi	r16, $0F
	;out	DDRB, r16

	ldi	ZL, LOW(MESSAGE*2)
	ldi	ZH, HIGH(MESSAGE*2)

MORSE:
	call	GET_CHAR
	
	jmp	MORSE
;---------------------------------------------------------------------
GET_CHAR:
	lpm	r21, Z+
	breq	END_OF_LINE
	;call	NOBEEP ; Nästa bokstav kräver 3N tystnad innan den sänds
	call	LOOKUP
	jmp	GET_CHAR ; loopar tills vi stöter på $00-då till END_OF_LINE

END_OF_LINE:		
	ret

;---------------------------------------------------------------------
LOOKUP:
	push	r21
	push	ZL
	push	ZH
	ldi	ZH, HIGH(BTAB*2)
	ldi	ZL, LOW(BTAB*2)
	subi	r21, $41 ;gör om till en offset i alfabetet
	add	ZL, r21
	brcc	NO_CARRY_TO_ZH
	inc	ZH
NO_CARRY_TO_ZH:
	lpm	r22, Z

	pop	ZH
	pop	ZL
	pop	r21
	ret
;----------------------------------------------------------------------	

GET_BIT:
	push	r22

	lsl	r22


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



.org $0100
MESSAGE:
	.db "DATORTEKNIK", $00

.org $0150
BTAB:
	.db $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8