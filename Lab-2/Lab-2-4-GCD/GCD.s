	AREA	GCD, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
        LDR     R2, =9  ;R2=a
        LDR     R3, =3  ;R3=b
        
        CMP     R2,     R3      ;checks if both values are equal
whileA        
        BEQ     endwhile        ;If equal branches to endwhile
        BLS     whileB          ;If a is less than b branches to whileB
        SUBS    R2,     R2,     R3      ;If a is greater,b is subtracted from a and stored in A
        B       whileA
whileB
        SUBS    R3,     R3,     R2      ;If b is greater,a is subtracted from b and stored in b
        B       whileA
endwhile
        ADD     R0,     R2,     R3

	
stop	B	stop

	END	