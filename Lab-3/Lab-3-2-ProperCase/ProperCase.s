	AREA	ProperCase, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, = testStr
	b	capcheckbranch
nextaddress
	ADD	R1,	R1,	#1
loadnextchar
	LDRB R2, [R1]
	CMP	R2, #0
	BEQ	stop
	CMP R2,	#' '
	BNE	turnintolowercase
	ADD	R1,	R1,	#1
capcheckbranch	
	LDRB R2, [R1]
	CMP	R2, #0
	BEQ	stop
turnintocaps	
	CMP R2, #0x61	;check if <a ascii
	BLO nextaddress
	CMP	R2,	#0x7A	;check if >z ascii
	BHI nextaddress
	SUB	R2,	R2,	#0x20
	STRB R2, [R1]
	b	nextaddress
turnintolowercase
	CMP R2, #0x41	;check if <A
	BLO nextaddress
	CMP	R2,	#0x5A	;check if >Z
	BHI nextaddress
	ADD	R2,	R2,	#0x20
	STRB R2, [R1]
	b	nextaddress
	

stop	B	stop



	AREA	TestData, DATA, READWRITE

testStr	DCB	"hello WORLD jk ",0

	END
