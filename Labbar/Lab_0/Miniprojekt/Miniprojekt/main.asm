;
; Miniprojekt.asm
;
; Created: 2019-11-06 13:13:12

; r16-r19 free to use

	.def num = r20 ; number 0-9
	.def key = r21 ; key pressed yes/no
	clr r16
	out DDRA,r16
	ldi r16,$0F
	out DDRB,r16
	clr num
	
FOREVER:
	clr key ; get keypress in boolean ’key’
	sbic PINA,0 ; skip over if not pressed
	dec key ; key=FF

LOOP:
	cpi key,0
	breq FOREVER ; until key
	out PORTB,num ; print digit
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
	brne D_3
	inc num ; num++
	cpi num,10 ; num==10?
	brne NOT_10 ; no, so jump
	clr num ; was 10

NOT_10:
	clr key ; get keypress in boolean ’key’
	sbic PINA,0 ; skip over if not pressed
	dec key ; key=FF
	jmp LOOP