	AREA	Shift64, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =0x13131313
	LDR	R1, =0x13131313
	LDR	R2, = 2
        LDR     R5, = 0 ;To change sign if negative
	CMP	R2,	#0
	BLT	leftshift
	BGT	rightshift
	b	stop
leftshift
        ADD     R3,     R2,     #32    ;to clear all other bits + move it
        LSR     R4,     R0,     R3     ;gets just the bit to be shifted
        SUB     R5,     R5,     R2
        LSL     R1,     R1,     R5
        LSL     R0,     R0,     R5
        ORR     R1,     R1,     R4      ;Adds the shifted bits
	b	stop
rightshift
	SUB     R3,     R2,     #32
	SUB     R3,     R5,     R3      ;Similar to shifting left
        LSL     R4,     R1,     R3      ;Gets just the bit that will be transfered
        LSR     R1,     R1,     R2
        LSR     R0,     R0,     R2
        ORR     R0,     R0,     R4      ;Adds the shifted bits
	
	; your program goes here
	
stop	B	stop


	END
		