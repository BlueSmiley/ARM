	AREA	Flags, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
        LDR     R0 , =0xC0001000
        LDR     R1 , =0x51004000
        ADDS    R2,     R0,     R1 ;C=1 rest=0 R2 = 0x11005000
        
        LDR     R3 , =0x92004000
        SUBS    R4 ,  R3 ,  R3 ;Z=1 C=1 rest=0 R4=0x00000000
        
        LDR     R5 , =0x74000100
        LDR     R6 , =0x40004000
        ADDS    R7 ,  R5 ,  R6  ;N=1 V=1 rest=0 R7= 0xB4004100
        
        LDR     R1 , =0x6E0074F2
        LDR     R2 , =0x211D6000
        ADDS    R0 ,  R1 ,  R2 ;N=1 V=1 rest=0 R0=0x8F1DD4F2
        
        LDR     R1 , =0xBF2FDD1E
        LDR     R2 , =0x40D022E2
        ADDS    R0 ,  R1 ,  R2  ;Z=1 C=1 rest=0 R0=0x00000000

	
stop	B	stop

	END	