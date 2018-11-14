	AREA	Divide, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
        LDR     R1, = 5
        LDR     R0, = 3
        
        EOR     R0,     R1,     R0
        EOR     R1,     R1,     R0
        EOR     R0,     R1,     R0


stop    B       stop

        END