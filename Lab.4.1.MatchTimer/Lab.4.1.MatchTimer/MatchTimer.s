	AREA	MatchTimer, CODE, READONLY
	IMPORT	main
	EXPORT	start
VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010
VICVectAddr0	EQU	0xFFFFF100
VICVectPri0	EQU	0xFFFFF200
VICVectAddr	EQU	0xFFFFFF00

PINSEL4		EQU	0xE002C010
FIO2DIR1	EQU	0x3FFFC041
FIO2SET1	EQU	0x3FFFC059
FIO2CLR1	EQU	0x3FFFC05D
FIO2PIN1	EQU	0x3FFFC055

T0TCR		EQU	0xE0004004
T0CTCR		EQU	0xE0004070
T0MR0		EQU	0xE0004018
T0MCR		EQU	0xE0004014
T0PR		EQU	0xE000400C
T0IR		EQU	0xE0004000

EXTINT		EQU	0xE01FC140
EXTMODE		EQU	0xE01FC148
EXTPOLAR	EQU	0xE01FC14C    

PINSEL1		EQU	0xE002C004
DACR		EQU	0xE006C000
;
;notes - these are the (ARM periferal clock speed divided by 2 for high and low component) divided by frequencies of piano notes
;moving up an octave is a logical shift left (*2) of the note (still need to converti it to a time by 12MHz / (NOTE))
;https://en.wikipedia.org/wiki/Piano_key_frequencies
;NAME			TIME	MAX_WAVES_PER_SECOND/NOTE FREQ =
A			EQU 218182 ;(12MHz/2)/27.5		A0
AS			EQU 205938 ;6MHz/29.135	A#0
B			EQU 194382 ;6MHz/30.867	B0
C			EQU 183468 ;6MHz/32.7032	C1
CS			EQU 173171 ;6MHz/34.6478	C#1
D			EQU 163452 ;6MHz/36.7081	D1
DS			EQU 154278 ;6MHz/38.8909	D#1
E			EQU 145619 ;6MHz/41.2034	E1
F			EQU 137446 ;6MHz/43.6535	F1
FS			EQU 129732 ;6MHz/46.2493	F#1
G			EQU 122450 ;6MHz/48.9994	G
GS			EQU 115578 ;6MHz/51.9131	G#1
C4			EQU	22934	;6MHz / (261.626Hz * 2)

;
; A value between 0 and 1023 representing the volume
;
volume 		EQU 	1023
        
start

        LDR	R5, =count		; addr = address of count;
	MOV	R6, #0			; tmp = 0;
	STR	R6, [R5]		; Memory.Word(addr) = tmp;
        
        LDR    R5,=boolean
        LDR     R6,=0
        STRB    R6, [R5]
        
        ; Configure pin P0.26 for AOUT (DAC analog out)
	LDR	R5, =PINSEL1
	LDR	R6, [R5]
	BIC	R6, R6, #(0x03 << 20)
	ORR	R6, R6, #(0x02 << 20)
	STR	R6, [R5]
	
        ; Enable P2.10 for EINT0
	LDR	R5, =PINSEL4
	LDR	R6, [R5]	
	BIC	R6, #(0x03 << 20)
	ORR	R6, #(0x01 << 20)
	STR	R6, [R5]
	
	; Set edge-sensitive mode for EINT0
	LDR	R5, =EXTMODE
	LDR	R6, [R5]
	ORR	R6, #1
	STRB	R6, [R5]
	
	; Set rising-edge mode for EINT0
	LDR	R5, =EXTPOLAR
	LDR	R6, [R5]
	BIC	R6, #1
	STRB	R6, [R5]
	
	; Reset EINT0
	LDR	R5, =EXTINT
	MOV	R6, #1
	STRB	R6, [R5]
	

	
	;
	; Configure push button (Vector 0x14) interrupt handler
	;

	MOV	R3, #14			; vector = 14;
	MOV	R4, #1			; vmask = 1;
	MOV	R4, R4, LSL R3		; vmask = vmask << vector;

	
	; VICIntSelect - Set Vector 0x14 for IRQ (clear bit 14)
	LDR	R5, =VICIntSelect	; addr = VICIntSelect;
	LDR	R6, [R5]		; tmp = Memory.Word(addr);		
	BIC	R6, R6, R4		; Clear bit for Vector 0x14
	STR	R6, [R5]		; Memory.Word(addr) = tmp;
	
	; Set Priority to lowest (15)
	LDR	R5, =VICVectPri0	; addr = VICVectPri0;
	MOV	R6, #0xF		; pri = 15;
	STR	R6, [R5, R3, LSL #2]	; Memory.Word(addr + vector * 4); = pri;
	
	; Set handler address
	LDR	R5, =VICVectAddr0	; addr = VICVectAddr0;
	LDR	R6, =ButtonHandler	; handler = address of ButtonHandler;
	STR	R6, [R5, R3, LSL #2]	; Memory.Word(addr + vector * 4) = handler;

	
	; VICIntEnable
	LDR	R5, =VICIntEnable	; addr = VICVectEnable;
	STR	R4, [R5]		; enable interrupts for vector 0x14
        
;timer
	;
	; Configure TIMER0 for 1 second interrupts
	;
	
	; Stop and reset TIMER0 using Timer Control Register
	; Set bit 0 of TCR to 0 to diasble TIMER
	; Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]

	; Clear any previous TIMER0 interrupt by writing 0xFF to the TIMER0
	; Interrupt Register (T0IR)
	LDR	R5, =T0IR
	LDR	R6, =0xFF
	STRB	R6, [R5]

	; Set timer mode using Count Timer Control Register
	; Set bits 0 and 1 of CTCR to 00
	; for timer mode
	LDR	R5, =T0CTCR
	LDR	R6, =0x00
	STRB	R6, [R5]

	; Set match register for 1 sec using Match Register
	; Assuming a 12Mhz clock, set MR to 12,000,000
	LDR	R5, =T0MR0
	LDR	R6, =12000000
	STR	R6, [R5]

	; Interrupt and restart on match using Match Control Register
	; Set bit 0 of MCR to 1 to turn on interrupts
	; Set bit 1 of MCR to 1 to reset counter to 0 after every match
	; Set bit 2 of MCR to 0 to leave the counter enabled after match
	LDR	R5, =T0MCR
	LDR	R6, =0x03
	STRH	R6, [R5]

	; Turn off prescaling using Prescale Register
	; (prescaling is only needed to measure long intervals)
	LDR	R5, =T0PR
	LDR	R6, =0
	STR	R6, [R5]

	;
	; Configure VIC for TIMER0 interrupts
	;

	; Useful VIC vector numbers and masks for following code
	LDR	R3, =4			; vector 4
	LDR	R4, =(1 << 4) 	; bit mask for vector 4
	
	; VICIntSelect - Clear bit 4 of VICIntSelect register to cause
	; channel 4 (TIMER0) to raise IRQs (not FIQs)
	LDR	R5, =VICIntSelect	; addr = VICVectSelect;
	LDR	R6, [R5]		; tmp = Memory.Word(addr);		
	BIC	R6, R6, R4		; Clear bit for Vector 0x04
	STR	R6, [R5]		; Memory.Word(addr) = tmp;
	
	; Set Priority for VIC channel 4 (TIMER0) to lowest (15) by setting
	; VICVectPri4 to 15. Note: VICVectPri4 is the element at index 4 of an
	; array of 4-byte values that starts at VICVectPri0.
	; i.e. VICVectPri4=VICVectPri0+(4*4)
	LDR	R5, =VICVectPri0	; addr = VICVectPri0;
	MOV	R6, #15			; pri = 15;
	STR	R6, [R5, R3, LSL #2]	; Memory.Word(addr + vector * 4); = pri;
	
	; Set Handler routine address for VIC channel 4 (TIMER0) to address of
	; our handler routine (TimerHandler). Note: VICVectAddr4 is the element
	; at index 4 of an array of 4-byte values that starts at VICVectAddr0.
	; i.e. VICVectAddr4=VICVectAddr0+(4*4)
	LDR	R5, =VICVectAddr0	; addr = VICVectAddr0;
	LDR	R6, =TimerHandler	; handler = address of TimerHandler;
	STR	R6, [R5, R3, LSL #2]	; Memory.Word(addr + vector * 4) = handler

	
	; Enable VIC channel 4 (TIMER0) by writing a 1 to bit 4 of VICIntEnable
	LDR	R5, =VICIntEnable	; addr = VICIntEnable;
	STR	R4, [R5]		; enable Timers for vector 0x4

	;
	; Start TIMER0
	;

	; Start TIMER0 using the Timer Control Register
	; Set bit 0 of TCR to enable the timer
	LDR	R5, =T0TCR
	LDR	R6, =0x01
	STRB	R6, [R5]
repeat
        LDR     R5,=boolean
        LDRB     R6,     [R5]
        CMP     R6,     #0      ;check if buzzer off
        BEQ     repeat  ;if off
        BL      buzzer
        b repeat        ;infinite loop
stop	B	stop

;
; EINT0 Button Handler
;
ButtonHandler
	SUB	LR, LR, #4		; Adjust return address
	STMFD	sp!, {r0-r12, LR}	; save registers

	;
	; Reset EINT0
	;
	LDR	R5, =EXTINT
	MOV	R6, #1
	STRB	R6, [R5]
        
        LDR	R5, =T0TCR
        LDRB    R6,     [R5]            ;gets first byte
        EOR     R6,     R6,     #1      ;toggles timer  as bit 0 is set to enable
	STRB	R6, [R5]
	;
	; Clear source of interrupt
	;
	LDR	R3, =VICVectAddr	; addr = VICVectAddr
	MOV	R4, #0			; tmp = 0;
	STR	R4, [R3]		; Memory.Word(addr) = tmp;

	;
	; Return
	;
	LDMFD	sp!, {r0-r12, PC}^	; restore register and CPSR
        
TimerHandler
	SUB	LR, LR, #4		; Adjust return address (because the processor
					; sets it 4 bytes after the real return address!!)

	STMFD	sp!, {r0-r12, LR}	; save registers to avoid unintended side effects
	
	; Reset TIMER0 interrupt by writing 0xFF to T0IR
	LDR	R5, =T0IR
	MOV	R6, #0xFF
	STRB	R6, [R5]
        
        LDR     R5,=count
        LDR     R6,     [r5]
        LDR     R5,=MATCH_TIME
        CMP     R6,     R5
        BLO     matchNotOver
        
        LDR     R5,=count
        LDR     R6,     [R5]
        LDR     R5,=BUZZING_TIME
        CMP     R6,     R5
        BHS     turnOff
        
        LDR     R5,=boolean
        LDR     R6,=1
        STRB    R6, [R5]
matchNotOver  
        LDR     R5,=count
        LDR     R6,     [R5]
        ADD     R6,     R6,     #1
        LDR     R5,=count
        STR     R6,     [R5]
        b finishTick
turnOff
        LDR    R5,=boolean
        LDR     R6,=0
        STRB    R6, [R5]
finishTick        
	; Clear source of interrupt by writing 0 to VICVectAddr
	LDR	R5, =VICVectAddr
	MOV	R6, #0		
	STR	R6, [R5]	
	
	; Return
	LDMFD	sp!, {r0-r12, PC}^	; restore register and CPSR
	; your interrupt handlers go here

;buzzer subrouting
;parameter none
;returns void
buzzer			
        STMFD   SP!,    {R4-R12,LR}				; while (forever) { 
	;
	; Change analog output to cause square wave signal
	; If signal is currently high, send it low. If its low, send it high
	;
	; Load the current DAC output value
	LDR	R5, =DACR
	LDR	R6, [R5]
	
	; Mask out all but bits 15...6
	LDR	R7, =0x0000FFC0
	AND	R6, R6, R7
	
	CMP	R6, #0			; if (DACR == 0)
	BNE	high			; {
	LDR	R6, =(volume << 6)	;  DACR = volume << 6
	B	endif			; }
high					; else {
	LDR	R6, =0			;  DACR = 0
endif					; }
	STR	R6, [R5]		; store new DACR
	
	; Short delay
	LDR	R4, =C4		;  square wave delay
	;LSR	R4, R4, #3		;MOVE UP N OCTAVES (APPROX)
whDelay					;   while (count > 0)
	CMP	R4, #0			;   {
	BEQ	eWhDelay		;
	SUB	R4, R4, #1		;     count = count - 1
	B	whDelay			;   }
eWhDelay				;
        LDMFD   SP!,    {R4-R12,PC}
        
count	        SPACE	4
MATCH_TIME      EQU     5
BUZZING_TIME    EQU     10
boolean         SPACE   4
        
	END	
	