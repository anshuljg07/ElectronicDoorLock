;
; Lab3.asm
;
; Created: 2/27/2023 4:46:26 PM
; Author : rlrangeldelatejera, agowd
;

;.include "m328Pdef.inc"

rjmp _start1
; array for displaying digits 
digits:
	.db 0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x77,0x7C,0x39,0x5E,0x79,0x71

; array for containg the correct code
code:
	.db 0x6,0xD,0x7,0x7,0xD

_start1:
sbi DDRB,0 ; SRClk
sbi DDRB,1 ; RClk
sbi DDRB,2 ; SER
sbi DDRB, 5; L LED 

cbi PORTB,5

.equ NUMREPEATS9SECONDS = 900; 900 10ms incrments ~ 9 second
.equ NUMREPEATS5SECONDS = 500; 500 10ms incrments ~ 5 second

.equ dash=0b01000000
.equ underscore=0x04
.equ dot=0b10000000
; Replace with your application code

ldi R16,dash ; set second digit
ldi R19, -1 ; rotation counter displayed on the 7 segment display
ldi R24, 0 ; GLOBAL current index of password (DON'T TOUCH)
rcall display 
ldi R21, 0xFF //register to hold current pattern AB in the C code on the board
ldi r29, 0xFF

;Constantly checks for updates in the status of the user's modes of input: Pushbutton or RPG
;__________________________________________________________________________________
start:

	;check the status of both user-input modes
	rcall checkRotaryStatus
	rcall checkButtonStatus;

    rjmp start
;__________________________________________________________________________________

; Subroutine Display displays the set number to the seven segment display
;__________________________________________________________________________________
display: 
	push R16
	push R17
	in R17, SREG
	push R17
	ldi R17, 8 ; loop --> test all 8 bits
loop:
	rol R16 ; rotate left trough Carry
	BRCS set_ser_in_1 ; branch if Carry is set; put code here to set SER to 0
	cbi PORTB,2
	rjmp end
set_ser_in_1:
	; set SER to 1
	sbi PORTB,2
end:
	;generate SRCLK pulse
	sbi PORTB,0
	cbi PORTB,0
	dec R17
	brne loop
	; generate RCLK pulse...
	sbi PORTB,1
	cbi PORTB,1
	
	pop R17
	out SREG, R17
	pop R17
	pop R16
	
	ret
;__________________________________________________________________________________ 

; N second delay based on values loaded into r31 and r30, using the microDelay10ms
;__________________________________________________________________________________
delayNsec:
	rcall microDelay10ms; delay for 10ms

	sbiw r31:r30, 1; subtract from counter
	brne delayNsec; loop if counter is not finished

	ret
;__________________________________________________________________________________

; 10 ms timer, using normal internal 16 Mhz w/1024 prescaling
;__________________________________________________________________________________
microDelay10ms:
// registers below can be reused
// r18 --> TCNT0 
// r20 --> TCCR0 (also used in changeValue to ascertain current count)
// r23 --> TIFR0

	ldi r18, 100; 100 is the number of cycles ~ 10 ms which once reached will cause the timer to overflow

	out TCNT0, r18

	ldi r20, 0b00000101; normal mode, 1024 prescaler (starts the clock with the defined settings)
	out TCCR0B, r20

	rcall innermicroDelay10ms
	ret 
;------------------------------------------------------------------------------------

;Sample the button status every 2.5 ms ~ 4,000 cycles BUG: not recognizing the overflow flag
;------------------------------------------------------------------------------------
innerMicroDelay10ms:
	in r23, TIFR0; use r23 to temp store the contents of tifr0 (contains the flag status of the clocks)
	sbrs r23, TOV0; skip if the overflow flag for timer0 is set 

	rjmp innerMicroDelay10ms 

	;10ms elapsed
	ldi r20, 0; stop the clock
	out TCCR0B, r20

	ldi r23, (1<<TOV0); clear the TOV0 (timer 0 interrupt flag)
	out TIFR0, r23

	ret
;__________________________________________________________________________________
	

;sample the status of the button, if pressed call the buttonPressed subroutine
;__________________________________________________________________________________
checkButtonStatus:
	ldi r17, 0
	sbic PIND, 7
	rcall buttonPressed

	ret
;------------------------------------------------------------------------------------

;when the button pressed it is sampled to ascertain how long, then based on the press duration either a save entry, hard reset, or nothing is done
;------------------------------------------------------------------------------------
buttonPressed:
	rcall sampleIfPressed
	
	cpi r17, 20
	brlo checkPassword; checks the entered RPG entered selection


	cpi r17, 40
	brge hardReset; resets the entire program back to start

	ret
;------------------------------------------------------------------------------------

;samples the button in 50 ms increments while the button remains pressed
;------------------------------------------------------------------------------------
sampleIfpressed:
	rcall microDelay10ms
	rcall microDelay10ms
	rcall microDelay10ms
	rcall microDelay10ms
	rcall microDelay10ms

	inc r17; holds number of 10ms sample delays that has passed
	sbis PIND, 7
	ret
	rjmp sampleIfpressed
;----------------------------------------------------------------------------------

;does a hard reset of the program, reinitializes all global variables back to zero and displays a dash
;__________________________________________________________________________________
hardReset:
	;set password index counter to 0
	ldi r24, 0
	ldi r19,-1
	ldi r16, dash
	rcall display
	ret

;compares the current RPG value stored in r19 to the matching correct password index stored in the array
;__________________________________________________________________________________
checkPassword: //TODO
	ldi ZL, low(code<<1)
	ldi ZH, high(code<<1)
	add ZL, r24
	in r20, SREG
	sbrc r20, 0 
	inc ZH
	lpm r20, Z
	cp r20, r19
	breq setControlCorrect; if they match then setControlCorrect

	ldi R29, 0x0; global incorrect entry entered
	inc r24
	cpi r24, 5
	breq displayCodeIncorrect ; if user password wrong and its the 5th entry then display the incorrect code logic
	ret

;on the last entry check the global var (R29) keeping track of password correctness to see if the user answered correctly
;----------------------------------------------------------------------------------
setControlCorrect:
	
	inc r24
	cpi r24,5
	breq checkCodeCorrect; if the code is correct
	ret
;----------------------------------------------------------------------------------

;If the user entered all 5 digits correctly global r29 should be true (0xFF) otherwise it would be (0x00)
;----------------------------------------------------------------------------------
checkCodeCorrect:
	cpi r29, 0xFF; check if code correct
	breq displayCodeCorrect

	rjmp displayCodeIncorrect
;----------------------------------------------------------------------------------

;user password and correct don't match, then display dash and l led for 9 seconds and restart
;--------------------------------------------------------------------------------------------
displayCodeIncorrect:
	
	ldi R16, underscore
	ldi r29, 0xFF
	rcall display

	ldi r30, low(NUMREPEATS9SECONDS); r31:r30 ~ 100
	ldi r31, high(NUMREPEATS9SECONDS)
	rcall delayNsec

	ldi R16, dash
	
	rcall display
	ldi r24, 0
	ldi r19, -1//reset all registers TODO
	jmp start
;--------------------------------------------------------------------------------------------

;if the user password and the correct password match, display a dot and l led for 5 seconds, then restart
;--------------------------------------------------------------------------------------------
displayCodeCorrect:
	rcall turnLEDOn
	ldi R16, dot
	rcall display
	ldi r29, 0xFF
	ldi r30, low(NUMREPEATS5SECONDS); r31:r30 ~ 100
	ldi r31, high(NUMREPEATS5SECONDS)
	rcall delayNsec

	rcall turnLEDOff
	ldi r24, 0
	ldi r19, -1//reset all registers TODO
	ldi r16, dash
	rcall display
	jmp start
;__________________________________________________________________________________

;Sample the button and the FPG channel status every 10 ms ~ 16,000 cycles
;R19 -----> global counter var, DON'T TOUCH
;R20 -----> comparison var, RECYCLABLE
;R21 -----> global variable to hold previous input DONT TOUCH
;R22 -----> recyclable variable to read in input in each iteration of the subroutine RECYCLABLE
;R23 --> RECYCLABLE
;__________________________________________________________________________________
checkRotaryStatus:

	IN R22, PIND // load in status bits of PIN D

	//check the status of button call HERE

	andi R22, 0b00110000 // clear all status bits except for D5 and D4 (Channel A/B
	lsr R22
	lsr R22
	lsr R22
	lsr R22

	mov R23, R21 //R21 is the AB
	andi R23, 0b00000011 //make a copy of AB and bitmask it to just look at the last two bits and check those 

	//branch back to top if input did not change 
	cp R23,R22

	brne rotationDetected

	ret

;Load the bit pattern read by the RPG and see if it corresonds to a CCW, CW, or no turn
;--------------------------------------------------------------------------------------------
rotationDetected:
	lsl R21
	lsl R21
	or R21, R22 // fill the leftmost bit registers with the most recent value from the input

	cpi R21, 0b01001011; corresponding bit pattern for a CCW turn
	breq ccwTurn

	cpi R21, 0b10000111; corresponding bit pattern for a CW turn
	breq cwTurn

	ret
;--------------------------------------------------------------------------------------------

;Increment the 7-segment display value by 1 to reach a max of 15 or "F"
;--------------------------------------------------------------------------------------------
cwTurn:
	ldi R20, 15
	cp R19, R20
	breq rolloverFrontReset; dont allow the RPG value in r19 to go over 15
	inc R19
	rcall changeValue
	ret
;--------------------------------------------------------------------------------------------

;Decrement the 7-segment display value by 1 to reach a minimum of 0 or "0"
;--------------------------------------------------------------------------------------------
ccwTurn:
	
	ldi R20, 0
	cp R19, R20
	brlt rolloverBackReset; don't allow the RPG value to go below 0
	cpi R19, 0
	breq rolloverBackReset
	dec R19
	rcall changeValue
	ret
;--------------------------------------------------------------------------------------------

;Ignore user input if they wish to exceed the maximum RPG display value of "F" ~ 15.
;--------------------------------------------------------------------------------------------
rolloverFrontReset:
	jmp start
;--------------------------------------------------------------------------------------------

;Reset the display if it exceeds the minimum value of the display and allow rollover.
;--------------------------------------------------------------------------------------------
rolloverBackReset:
	jmp start
;__________________________________________________________________________________

;LED L on
;__________________________________________________________________________________
turnLEDOn:
	sbi PORTB, 5
	ret
;__________________________________________________________________________________

;LED L off
;__________________________________________________________________________________
turnLEDOff:
	cbi PORTB, 5
	ret
;__________________________________________________________________________________

;updates the 7-segment display based upon the value chosen by the user using the RPG
;__________________________________________________________________________________
changeValue: //TODO
	ldi ZL, low(digits<<1)
	ldi ZH, high(digits<<1)
	add ZL, r19
	in r20, SREG
	sbrc r20, 0 
	inc ZH
	lpm r16, Z
	rcall display
	ret
;__________________________________________________________________________________

