
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16

call HW_INIT
jmp MAIN

HW_INIT:
	ldi r16, 0x0F
	out DDRA, r16
	ret

MAIN:
	
	sbic PIND,0
	call DISPLAY_VALUE
	sbic PIND,1
	call INC_VALUE
rjmp MAIN


INC_VALUE:
	inc r18
	cpi r18,0x10
	brne WAIT_FOR_BUTTON_RELASSE
	dec r18
WAIT_FOR_BUTTON_RELASSE:
	
	sbic PIND,1
	jmp WAIT_FOR_BUTTON_RELASSE
	ret

DISPLAY_VALUE:
	out PORTA, r18
	clr r18
WAIT:
	sbic PIND,0
	jmp WAIT
	ret