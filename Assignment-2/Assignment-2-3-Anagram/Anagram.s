	AREA	Anagram, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
        LDR     R1, = stringA
        MOV     R2,     R1
        LDRB     R4,     [R1]
        b       Asorting
nextchar
        ADD     R1,     R1,     #1
        LDRB     R4,    [R1]
        CMP     R4,     #0
        BEQ     Acomplete
        MOV     R2,     R1
Asorting
        ADD     R2,     R2,     #1      ;moves to next element
        LDRB     R3,     [R2]
        CMP     R3,     #0
        BEQ     nextchar
        CMP     R4,     R3
        BGT     swap
        b       Asorting
swap
        STRB     R4,    [R2]
        STRB     R3,    [R1]
        LDRB     R4,    [R1]
        b       Asorting
Acomplete
        LDR     R1, = stringB
        MOV     R2,     R1
        LDRB    R4,     [R1]
        b       Bsorting
nextvalue
        ADD     R1,     R1,     #1
        LDRB     R4,    [R1]
        CMP     R4,     #0
        BEQ     Bcomplete
        MOV     R2,     R1
Bsorting
        ADD     R2,     R2,     #1      ;moves to next element
        LDRB     R3,     [R2]
        CMP     R3,     #0
        BEQ     nextvalue
        CMP     R4,     R3
        BGT     resort
        b       Bsorting
resort
        STRB     R4,    [R2]
        STRB     R3,    [R1]
        LDRB     R4,    [R1]
        b       Bsorting
Bcomplete
        LDR     R0, = 0         ;assume isnt anagram
        LDR     R1, = stringA
        LDR     R2, = stringB
        b       firstletter
nextletter
        ADD     R1,     R1,     #1
        ADD     R2,     R2,     #1
firstletter
        LDRB    R3,     [R1]
        LDRB    R4,     [R2]
        CMP     R3,     R4
        BNE     stop
        CMP     R3, #0
        BNE     nextletter
        LDR     R0, = 1         ;is anagram     
        
stop	B	stop



	AREA	TestData, DATA, READWRITE

stringA	DCB	"bests",0
stringB	DCB	"beets",0

	END
