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

	ldi r16, 0x03
	out DDRD, r16

	call TIMER0_INIT
	call ADC_INIT

	sei
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN:
	nop
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
	//call ADC_M
	out SREG,r16
	pop r16
	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JOYSTICK:
	push r16
	push YH
	push YL

	ldi YH, HIGH(POSX)
	ldi YL, LOW(POSX)
	ld  r16, Y

	sbi ADCSRA, ADSC
wait1:
	sbic ADCSRA, ADSC
	rjmp wait1
	in r17, ADCH

	cpi r17, 0x03
	breq INC_POSX
	cpi r17, 0x00
	breq DEC_POSX
	rjmp DONE_WITH_INPUT
INC_POSX:
	inc r16
	rjmp DONE_WITH_INPUT

DEC_POSX:
	dec r16

DONE_WITH_INPUT:
	st Y,r16
	pop YL
	pop YH
	pop r16
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
ISR_ADC:

	reti
*/
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
