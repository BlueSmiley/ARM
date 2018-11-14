	AREA	Expressions, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =5	; x = 5
	LDR	R2, =6	; y = 6
        ADD     R3,     R1,     R2
        LDR     R4, ='4'
        LDR     R5, ='6'
	
	; your program goes here
	
stop	B	stop

	END	