;
; AssemblerApplication1.asm
; LAB1 IR
; Created: 2019-11-05 18:00:30
; Author : Johan

SETUP:	
	ldi		r22,$FF					; Utport till displayen+scop
	out		DDRB,r22				; Utport till displayen+scop
	
	ldi		r18, HIGH(RAMEND)
	out		SPH, r18
	ldi		r18, LOW(RAMEND)
	out		SPL, r18

	clr		r21						; DATA
	clr		r19						; Sort
	ldi		r20, 4					; COUNTER 1
	ldi		r18, 4					; COUNTER 2

START_BIT:
	sbis	PINA,0 
	rjmp	START_BIT
	ldi		r16, 31
	call	DELAY


DOUBLECHECK:
	sbis	PINA,0
	rjmp	START_BIT
	call	DELAY
		

DATA:
	lsl		r21 
	sbic	PINA,0
	inc		r21					;ökar r21 enbart om Pin0 är hög
	dec		r20					;Counter++
	breq	PRINT
	;brne	PRINT
	call	DELAY
	;sbrc	r20, 0
	rjmp	DATA

PRINT:
	
	
	lsl		r19
	lsr		r21
	brcc	NOCARRY
	inc		r19
NOCARRY:	
	dec		r18;counter++
	brne	PRINT
	out		PORTB,r19			; fortfarande LSB/MSB bakvända
	rjmp	SETUP


DELAY:
	sbi		PORTB,7
delayYttreLoop:
	ldi		r17,$1F
delayInreLoop:
	dec		r17
	brne	delayInreLoop
	dec		r16
	brne	delayYttreLoop
	cbi		PORTB,7	
	ldi		r16,62
	ret	