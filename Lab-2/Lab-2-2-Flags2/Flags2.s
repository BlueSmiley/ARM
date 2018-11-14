	AREA	Flags2, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
        LDR     R0, = 0x00000001
        ADDS    R2,     R0,     R0 ;N=0 Z=0 C=0 V=0
        
        
        LDR     R0, = 0xFFFFFFFF
        LDR     R1, = 0x00000000
        ADDS    R2,     R0,     R1 ;N=1 Z=0 C=0 V=0
        
        LDR     R1, = 0x00000002
        ADDS    R2,     R1,     R0 ;C=1 rest=0
        
        LDR     R0, = 0xFFFFFFFF
        ADDS    R2,     R0,     R0 ;N=1 C=1 rest=0
        
        LDR     R0, = 0xFFFFFFFF
        LDR     R1, = 0x00000001
        ADDS    R2,     R1,     R0 ;Z=1 C=1 rest=0
        
        LDR     R0, = 0x00000000
        ADDS    R2,     R0,     R0 ;Z=1 rest=0
        
        LDR     R0, = 0x5FFFFFFF
        ADDS    R2,     R0,     R0 ;N=1 V=1 rest=0
        
        LDR     R0, =0x80000001
        ADDS    R2,     R0,     R0  ;C=1 V=1 rest=0
        
        LDR     R0, = 0x80000000
        ADDS    R2,     R0,     R0 ;Z=1 C=1 V=1 rest=0



stop	B	stop

	END	