	AREA	StackReverse, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR	R5, =string
        LDR     R6, = 0      ;counter
stackstore        
        LDRB     R4,      [R5]
        CMP     R4,     #0
        BEQ     reverse
        STRB     R4,     [R13,   #-1]!
        ADD     R5,     R5,     #1
        ADD     R6,     R6,     #1      
        b      stackstore 
reverse
        LDR     R5, =string
transfer        
        CMP     R6,     #0
        BEQ     stop
        LDRB    R4,     [R13], #1
        STRB    R4,     [R5],    #1
        SUB     R6,     R6,     #1
        b       transfer
	
stop	B	stop


	AREA	TestString, DATA, READWRITE

string	DCB	"abcdef"

	END	