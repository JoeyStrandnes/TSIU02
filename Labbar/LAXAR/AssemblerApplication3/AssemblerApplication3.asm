
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	call HW_SETUP
	call MAIN


HW_SETUP:
	ldi r16, 0xFF
	out DDRB, r16 // OUTPUT TILL DIODERNA
	ldi r16, 0x00
	out DDRA, r16 // INPUT FRÅN IR-TANGENTBORDET
	ldi r16, 0x00
	out DDRD, r16 // INPUT FRÅN STROBE
	ret

MAIN:
	clt 
	clr r17
	clr r18
WAIT_FOR_STROBE_ON:
	sbis PIND, 0
	jmp WAIT_FOR_STROBE_ON
	
	in r16, PINA
	andi r16, 0x0F
	cpi r16, 10
	brmi OK_VALUE
	cpi r16, 0x0F
	brne WAIT_FOR_STROBE_OFF
	call TOGGLE_T
	jmp WAIT_FOR_STROBE_OFF
OK_VALUE://r17 vänster display T=0 LSB, r18 höger display T=1 MSB
	brts RIGHT
	mov r17,r16
	jmp COMBINE
RIGHT:
	mov r18,r16
	swap r18
	andi r18,0xF0
COMBINE:
	clr r16
	or r16,r17
	or r16,r18 
	out PORTB, r16

WAIT_FOR_STROBE_OFF:
	sbic PIND,0
	jmp WAIT_FOR_STROBE_OFF
	jmp WAIT_FOR_STROBE_ON

TOGGLE_T:
	brts TOGGLE_OFF
	set
	jmp DONE_WITH_TOGGLE
TOGGLE_OFF:
	clt
DONE_WITH_TOGGLE:
	ret