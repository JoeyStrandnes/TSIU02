	.equ	VMEM_SZ     = 5		; #rows on display
	.equ	AD_CHAN_X   = 0		; ADC0=PA0, PORTA bit 0 X-led
	.equ	AD_CHAN_Y   = 1		; ADC1=PA1, PORTA bit 1 Y-led
	.equ	GAME_SPEED  = 70	; inter-run delay (millisecs)
	.equ	PRESCALE    = 7		; AD-prescaler value
	.equ	BEEP_PITCH  = 20	; Victory beep pitch
	.equ	BEEP_LENGTH = 100	; Victory beep length
	
	; ---------------------------------------
	; --- Memory layout in SRAM
	.dseg
	.org	SRAM_START
POSX:	.byte	1	; Own position
POSY:	.byte 	1
TPOSX:	.byte	1	; Target position
TPOSY:	.byte	1
LINE:	.byte	1	; Current line	
VMEM:	.byte	VMEM_SZ ; Video MEMory
SEED:	.byte	1	; Seed for Random
	.cseg

.org 0x00
jmp SETUP

.org 0x12
jmp ISR_TIMER0


.org 0x30



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SETUP: 

	ldi	r16, HIGH(RAMEND)
	out	SPH, r16
	ldi	r16, LOW(RAMEND)
	out	SPL, r16

	ldi r16, 0xFF
	out DDRB, r16

	ldi r16, 0x07
	out DDRD, r16

	call TIMER0_INIT
	call ADC_INIT
	call ERASE_VMEM
	call CLEAR_JOYSTICK

	sei
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLEAR_JOYSTICK:
	push ZL
	push ZH

	ldi ZL, LOW(SRAM_START)
	ldi ZH, HIGH(SRAM_START)

CLEAR_JOYSTICK_LOOP:	
	ld r16, Z
	clr r16
	st Z+, r16	
	cpi ZL, LINE
	brne CLEAR_JOYSTICK_LOOP

	pop ZH
	pop ZL

	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN:
	call JOYSTICK
	call ERASE_VMEM
	call UPDATE
	//call DELAY_500
	//call BEEP
	rjmp MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TIMER0_INIT:
	ldi r16, (0<<CS02)|(1<<CS01)|(0<<CS00) // Prescaler 256
	out TCCR0, r16	
	in r16, TIMSK
	ori r16, (1<<TOIE0)
	out TIMSK, r16

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADC_INIT:
	
	ldi r16, (0<<REFS1)|(0<<REFS0)|(0<<ADLAR)
	out ADMUX, r16

	ldi r16, (1<< ADEN)|(0<<ADIE)|(0<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	out ADCSRA, r16

	sbi ADCSRA, ADSC
wait:
	sbic ADCSRA, ADSC
	rjmp wait

	in r16, ADCH

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ISR_TIMER0:
	push r16
	in r16,SREG //RÄDDAR FLAGGOR- SKA VARA KVAR! :D
	call MUX
	out SREG,r16
	pop r16
	reti
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JOYSTICK:
	;push r16
	push YH
	push YL

	ldi YH, HIGH(POSX)
	ldi YL, LOW(POSX)
	
	//ldi r16, (AD_CHAN_X<<) KANSKE
	cbi ADMUX, MUX0
	call GET_POS
	inc YL
	sbi ADMUX, MUX0
	call GET_POS

	call JOY_LIM
	pop YL
	pop YH
	;pop r16
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET_POS:
	push r16
	ld  r16, Y

	sbi ADCSRA, ADSC
WAIT_FOR_AD:
	sbic ADCSRA, ADSC
	rjmp WAIT_FOR_AD

	in r17, ADCH

	cpi r17, 0x03
	breq INC_POS
	cpi r17, 0x00
	breq DEC_POS
	rjmp DONE_WITH_INPUT
INC_POS:
	inc r16
	rjmp DONE_WITH_INPUT

DEC_POS:
	dec r16

DONE_WITH_INPUT:
	st Y,r16

	pop r16
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MUX:
	push ZL
	push ZH
	
	ldi ZL, LOW(LINE)
	ldi ZH, HIGH(LINE)
	ld r16, Z
	out PORTD, r16

	ldi ZL, LOW(VMEM)
	ldi ZH, HIGH(VMEM)

	add ZL, r16
	ld  r16, Z
	out PORTB, r16

	ldi ZL, LOW(LINE)
	ldi ZH, HIGH(LINE)
	ld r16, Z
	inc r16
	cpi r16, VMEM_SZ
	brne MUX_DONE
	clr r16

MUX_DONE:
	st Z, r16
	pop ZH
	pop ZL
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ERASE_VMEM:
	push ZL
	push ZH

	ldi ZL, LOW(VMEM)
	ldi ZH, HIGH(VMEM)

ERASE_VMEM_LOOP:	
	ld r16, Z
	ldi r16, 0b01010101
	//clr r16
	st Z+, r16	
	cpi ZL, VMEM+VMEM_SZ
	brne ERASE_VMEM_LOOP



	pop ZH
	pop ZL
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BEEP:
	ldi		r16,BEEP_LENGTH 
BEEP_LOOP:
	sbi		PORTB, 7
	call	DELAY
	cbi		PORTB, 7
	call	DELAY
	dec		r16
	brne	BEEP_LOOP
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY:
	push	r16
	ldi		r16,BEEP_PITCH 
DELAY_LOOP:
	dec		r16
	brne	DELAY_LOOP

	pop		r16
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY_500:
	ldi  r18, 3
    ldi  r19, 138
    ldi  r20, 86
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JOY_LIM:
	call	LIMITS		; don't fall off world!
	ret

	; ---------------------------------------
	; --- LIMITS Limit POSX,POSY coordinates	
	; --- Uses r16,r17
LIMITS:
	lds	r16,POSX	; variable
	ldi	r17,7		; upper limit+1
	call	POS_LIM		; actual work
	sts	POSX,r16
	lds	r16,POSY	; variable
	ldi	r17,5		; upper limit+1
	call	POS_LIM		; actual work
	sts	POSY,r16
	ret

POS_LIM:
	ori	r16,0		; negative?
	brmi	POS_LESS	; POSX neg => add 1
	cp	r16,r17		; past edge
	brne	POS_OK
	subi	r16,2
POS_LESS:
	inc	r16	
POS_OK:
	ret

	; ---------------------------------------
	; --- UPDATE VMEM
	; --- with POSX/Y, TPOSX/Y
	; --- Uses r16, r17
UPDATE:	
	clr	ZH 
	ldi	ZL,LOW(POSX)
	call 	SETPOS
	clr	ZH
	ldi	ZL,LOW(TPOSX)
	call	SETPOS
	ret

	; --- SETPOS Set bit pattern of r16 into *Z
	; --- Uses r16, r17
	; --- 1st call Z points to POSX at entry and POSY at exit
	; --- 2nd call Z points to TPOSX at entry and TPOSY at exit
SETPOS:
	ld	r17,Z+  	; r17=POSX
	call	SETBIT		; r16=bitpattern for VMEM+POSY
	ld	r17,Z		; r17=POSY Z to POSY
	ldi	ZL,LOW(VMEM)
	add	ZL,r17		; *(VMEM+T/POSY) ZL=VMEM+0..4
	ld	r17,Z		; current line in VMEM
	or	r17,r16		; OR on place
	st	Z,r17		; put back into VMEM
	ret
	
	; --- SETBIT Set bit r17 on r16
	; --- Uses r16, r17
SETBIT:
	ldi	r16,$01		; bit to shift
SETBIT_LOOP:
	dec 	r17			
	brmi 	SETBIT_END	; til done
	lsl 	r16		; shift
	jmp 	SETBIT_LOOP
SETBIT_END:
	ret
