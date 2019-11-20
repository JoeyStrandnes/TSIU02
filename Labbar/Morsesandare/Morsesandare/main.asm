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
	ldi	r16, $FF
	out	DDRB, r16
	ldi	ZL, LOW(MESSAGE*2)
	ldi	ZH, HIGH(MESSAGE*2)

	.def N=r18
	.equ SPEED = 50	
	.equ PITCH = 255

MORSE:
	call	GET_CHAR
	cpi		r21,$00
	breq	END_OF_LINE ; loopar tills vi stöter på $00-då till END_OF_LINE
	
	call	LOOKUP
	call	SEND
	ldi		N,$02
	call	NO_BEEP ; Nästa bokstav kräver 3N tystnad innan den sänds. Har gjort en innan i SEND 
	jmp		MORSE 

END_OF_LINE:
	ldi		N,$07
	call	NO_BEEP
	jmp		SETUP
;---------------------------------------------------------------------
GET_CHAR:
	lpm	r21, Z+
	ret
;---------------------------------------------------------------------
SPACE:
	ldi N, $02
	call NO_BEEP
	ret
;---------------------------------------------------------------------
LOOKUP:
	push	r21
	push	ZL
	push	ZH
	ldi		ZH, HIGH(BTAB*2)
	ldi		ZL, LOW(BTAB*2)
	subi	r21, $41 ;gör om till en offset i alfabetet
	add		ZL, r21
	brcc	NO_CARRY_TO_ZH
	inc		ZH
NO_CARRY_TO_ZH:
	lpm	r22, Z
	pop	ZH
	pop	ZL
	pop	r21
	ret
;----------------------------------------------------------------------	
SEND:
	cpi		r22, $FF
	brne	VALID_CHAR
	call	SPACE
	rjmp	DONE_WITH_SPACE
VALID_CHAR:
	lsl		r22
	brcc	DIT
DAT:
	;ldi		N,$02
	call	BEEP
	call	BEEP
DIT:
	;ldi		N,$01
	call	BEEP
	;ldi N, $01
	call NO_BEEP ; EN N Tystnad efter varje dit/dat

	cpi		r22,$80
	brne	SEND
DONE_WITH_SPACE:
	ret
;----------------------------------------------------------------------

BEEP:
	ldi		r17, SPEED
BEEP_LOOP:
	sbi		PORTB, 0
	call	DELAY
	cbi		PORTB, 0
	call	DELAY
	dec		r17
	brne	BEEP_LOOP
	ret
;--------------------------------------------------------------------

NO_BEEP:
	ldi		r17,SPEED
NO_BEEP_LOOP:
	cbi	PORTB, 0
	call	DELAY
	call	DELAY
	dec		r17
	brne	NO_BEEP_LOOP
	ret
;---------------------------------------------------------------------
DELAY:
	ldi		r16,PITCH 
DELAY_LOOP:
	dec		r16
	brne	DELAY_LOOP
	ret
;---------------------------------------------------------------------


.org $0100
MESSAGE:	;Meddelande
	.db " DATOR TEKNIK", $00

.org $0150
BTAB:		;Morse tabell
	.db $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8


