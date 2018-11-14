	AREA	Divide, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

        LDR     R2, = 29;R2 = a
        LDR     R3, = 7 ;R3 = b
        LDR     R0, = 0 ;To store quotient value
        CMP     R3,#0     
while
        BEQ     noremainder        ;ends code if R3 = 0 or 0 flag is set
        BLO     endwh              ;ends code if R2<R3 or N flag is set,I think thats how it works
        ADD     R0,     R0,     #1
        SUBS    R2,     R2,     R3 ;Repeatedly subtracts R3 from R2
        B       while
endwh
        ADD    R1,     R2,      R3 ;Makes R1 the remainder
        SUB    R0,     R0,      #1
noremainder

	
stop	B	stop

	END	