/*

Multiplex 4x7-segment display with internal timers for time keeping

16-bit timer overflow for counting time ~1Hz
8-bit timer overflow for multiplexing segment display ~15kHz

*/

.org 0x00
jmp SETUP

.org 0x10 
jmp ISR_TIMER1

.org 0x12
jmp ISR_TIMER0

.org 0x30

SETUP: 

	.equ NUMBER_OF_DISPLAYS = 4
	.def COUNTER = r18

	ldi	r16, HIGH(RAMEND)
	out	SPH, r16
	ldi	r16, LOW(RAMEND)
	out	SPL, r16

	ldi r16, 0xFF
	out DDRB, r16

	ldi r16, 0x03
	out DDRD, r16

	ldi ZH, HIGH(NUMBER*2); VF BEHÖVS?
	ldi ZL, LOW(NUMBER*2);VF BEHÖVS?

	//Allocated N bytes in memory
	.dseg
	.org 0x60

TIME_VAR:
	.byte NUMBER_OF_DISPLAYS

CURRENT_DISPLAY:
	.byte 1
	.cseg

	ldi YL, LOW(TIME_VAR)
	ldi YH, HIGH(TIME_VAR)
	
	ldi r17, NUMBER_OF_DISPLAYS
	ldi r16,0x00
	call CLEAR_N_BYTES
	call TIMER1_INIT
	call TIMER0_INIT
	sei
	jmp main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLEAR_N_BYTES:
	push YL
	push YH
	st Y+, r16 //STORE WITH ZERO
	dec r17
	brne CLEAR_N_BYTES
	pop YH
	pop YL
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIMER1_INIT: ;16-bit timer 1 set as an overflow timer 
	
	; Setting counter mode
	ldi r16, (1<<WGM13)|(1<<WGM12)
	out TCCR1B, r16

	ldi r16, (1<<WGM11)|(0<<WGM10) 
	out TCCR1A, r16

	; Setting max counter value before overflow
	ldi r16, 0x3D
	out ICR1H, r16
	ldi r16, 0x08
	out ICR1L, r16

	; Setting prescaling and interrupt
	in r16, TCCR1B  
	ori r16,(0<<CS12)|(1<<CS11)|(1<<CS10) ;Prescaler set to F_CPU/64 (S:108)

	out TCCR1B, r16
	ldi r16, 1<<TOIE1
	out TIMSK, r16
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIMER0_INIT:
	ldi r16, (0<<CS02)|(1<<CS01)|(0<<CS00) // Prescaler 256
	out TCCR0, r16	
	
	in r16, TIMSK
	ori r16, (1<<TOIE0)
	out TIMSK, r16
	
	//sbi TIMSK, TOIE0
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAIN:
	nop
	rjmp MAIN
;--------------------------------------------------------------	


ISR_TIMER1:
	push r16
	in r16,SREG //RÄDDAR FLAGGOR- SKA VARA KVAR! :D
	call TIMER_COUNTER
	out SREG,r16
	pop r16
	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
ISR_TIMER0:
	push r16
	in r16,SREG //RÄDDAR FLAGGOR- SKA VARA KVAR! :D
	call DISPLAY_TIME
	out SREG,r16
	pop r16
	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_TIME:
	 push YL
	 push YH
	 push ZH
	 push ZL
	 push COUNTER


	 ldi YH, HIGH(CURRENT_DISPLAY)
	 ldi YL, LOW(CURRENT_DISPLAY)

	 ld COUNTER, Y
	 out PORTD, COUNTER

	 ldi YH, HIGH(TIME_VAR)
	 ldi YL, LOW(TIME_VAR) 
	 add YL, COUNTER
	 ld  r16, Y

	 ldi ZH, HIGH(NUMBER*2);
	 ldi ZL, LOW(NUMBER*2);
	 add ZL, r16
	 lpm r16, Z
	 out PORTB, r16

	 inc COUNTER 
	 cpi COUNTER, NUMBER_OF_DISPLAYS
	 brne NOT_MAX_MODULO
	 clr COUNTER
 	 
NOT_MAX_MODULO:
    ldi YH, HIGH(CURRENT_DISPLAY)
	ldi YL, LOW(CURRENT_DISPLAY) 
	st  Y, COUNTER 

	pop COUNTER
	pop ZL	
	pop ZH
    pop YH
	pop YL
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TIMER_COUNTER:
	push r18
	push YH
	push YL					
	ldi	 YL,LOW(TIME_VAR)
	ldi  YH,HIGH(TIME_VAR)

NEXT_2SEGMENT:
	ldi r18,10

	call LOAD_STORE			
	brne DONE_WITH_INC

	subi r18, NUMBER_OF_DISPLAYS

	call LOAD_STORE
	brne DONE_WITH_INC
	rjmp NEXT_2SEGMENT		
				
	DONE_WITH_INC:
	pop YL
	pop YH
	pop r18
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LOAD_STORE:
	ld r17,Y 
	inc r17
	cp r17, r18
	brne NOT_MAX
	clr r17
NOT_MAX:
	st Y+, r17 
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.org 0x0200 
NUMBER: .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7C, 0x07, 0x7F, 0x67
