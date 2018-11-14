	AREA	ArrayMove, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =array
	LDR	R1, =N
	LDR	R2, =3					; move from index1
	LDR	R3, =6					; move to index2
	
	LDR R5, [R0, R2, LSL #2]	; tmp = array[R3]
	SUBS R4,	R2, R3			; count
	BMI negfor
posfor
	CMP R4, #0					; while (count > 0)
	BLE replace					; {
	SUB	R8,	R2,	#1				;   tmp2 = index1 -1
	LDR	R6,	[R0, R8,LSL #2]		;   tmp3 = array[tmp2]
	STR	R6,	[R0, R2,LSL	#2]		;	array[index] = tmp3
	SUB	R2,	R2,	#1				;	index1--
	SUB R4, R4, #1				;   count--
	B   posfor					; }

negfor
	CMP R4, #0					; while (count < 0)
	BGE replace					; {
	ADD	R8,	R2,	#1				;	tmp2 = index1 +1
	LDR	R6,	[R0, R8,LSL #2]		;   tmp3 = array[tmp2]
	STR	R6,	[R0, R2,LSL	#2]		;   array[index1] = tmp2
	ADD	R2,	R2,	#1				;   index1++
	ADD R4, R4, #1				;   count++
	B   negfor					; }
	
replace
	STR R5, [R0, R3, LSL #2]	; array[index2] = tmp

stop	B	stop


	AREA	TestArray, DATA, READWRITE

N	equ	9
array	DCD	7,2,5,9,1,3,2,3,4

	END	