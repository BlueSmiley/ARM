	AREA	Button, CODE, READONLY
	IMPORT	main
	EXPORT	start

VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010
VICVectAddr0	EQU	0xFFFFF100
VICVectPri0	EQU	0xFFFFF200
VICVectAddr	EQU	0xFFFFFF00

PINSEL4		EQU	0xE002C010
EXTINT		EQU	0xE01FC140
EXTMODE		EQU	0xE01FC148
EXTPOLAR	EQU	0xE01FC14C



start
	;
	; Reset count
	;
	LDR	R5, =count		; addr = address of count;
	MOV	R6, #0			; tmp = 0;
	STR	R6, [R5]		; Memory.Word(addr) = tmp;



	;
	; Configure EINT0 on P2.10
	;

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

	;
	; Infinite loop
	;
		
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
	
	;
	; Increment Count
	;
	LDR	R3, =count		; addr = count
	
	LDR	R4, [R3]		; tmp_count = Memory.Word(addr);
	ADD	R4, R4, #1		; increment count;
	STR	R4, [R3]		; Memory.Word(addr) = tmp_count;

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

	
	
	AREA	TestData, DATA, READWRITE
	
count	SPACE	4

	END