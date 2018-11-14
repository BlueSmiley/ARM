	AREA	ShiftAndAdd, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =9
	LDR	R2, =10
	LDR	R3, = 0
	LDR	R0, = 0
	CMP	R2,	#0
	BNE	whle
	MOV	R1,	R2      ;number*0 = 0
whle
	CMP	R2,	#0      ;end when number is shifted out fully
	BEQ	stop
	MOVS	R2,	R2, LSR #1      ;shift out one bit
	BCS	mult            ;if 1 multiply otherwise dont
	ADD	R3,		R3,		#1      ;add one to count
	b	whle
mult
	ADD	R0,	R0,	R1,	LSL	R3      ;multiply by 2^count
	ADD	R3,		R3,		#1      ;count++  
	b	whle
		
stop	B	stop


	END	
	