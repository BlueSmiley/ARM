	AREA	AsciiAdd, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, ='2'	; R1 = 0x32 (ASCII symbol '2')
	LDR	R2, ='4'	; R2 = 0x34 (ASCII symbol '4')	
	LDR     R3, ='0'        ;Loading ascii symbol 0 into R3
        
        SUB     R1,     R1,     R3      ;This process converts the ascii code
        SUB     R2,     R2,     R3      ;to its decimal equivalent
        ADD     R0,     R1,     R2      ;adds both decimals together
        ADD     R0,     R0,     R3      ;Converts back to ascii
	
stop	B	stop

	END	