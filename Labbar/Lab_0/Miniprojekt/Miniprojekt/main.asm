;
; Miniprojekt.asm
;
; Created: 2019-11-06 13:13:12
; Author : Joey Strandnes
;

; r16-r19 free to use

	.def num = r20 ; number 0-9
	.def key = r21 ; key pressed yes/no
	ldi r16,HIGH(RAMEND) ; set stack
	out SPH,r16 ; for calls
	ldi r16,LOW(RAMEND)
	out SPL,r16
	call INIT
	clr num

; --- Init. A0 in, B3-B0 out
INIT:
	clr r16
	out DDRA,r16
	ldi r16,$0F
	out

	ldi r16,$FF
	out PORTA,r16 ; Weak pullup 


; --- DELAY. Wait a lot!
DELAY:
	ldi r18,3
D_3:
	ldi r17,0
D_2:
	ldi r16,0
D_1:
	dec r16
	brne D_1
	dec r17
	brne D_2
	dec r18
	brne D_

FOREVER:
	call GET_KEY ; get keypress in boolean ’key’


; --- GET_KEY. Returns key != 0 if key pressed
GET_KEY:
	clr key
	sbic PINA,0 ; skip over if not pressed
	dec key

LOOP:
	cpi key,0
	breq FOREVER ; until key
	out PORTB,num ; print digit
	call DELAY
	inc num ; num++
	cpi num,10 ; num==10?
	brne NOT_10 ; no, so jump
	clr num ; was 10
	NOT_10:
	call GET_KEY	jmp LOOP