	AREA	Closure, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR     R1, =ASize 
        LDR     R1, [R1]
        LDR     R2, =AElems
        LDR     R7, = 0         ;temporary counter
        MOV     R0,     R1      ;To remember total number of elements in set
        MOVS    R1,     R1,     LSR   #1      ;Halves the size
        BCC     first           ;checks if uneven
        MOV     R4,     R2
uneven                             ;iterate over set to check for a 0
        ADD     R7,     R7,     #1 ;counter++
        LDR     R5,     [R4]
        CMP     R5,     #0     
        BEQ     first
        ADD     R4,     R4,     #4
        CMP     R0,     R7
        BLS     notclosed
        b       uneven
next
        ADD     R2, #4          ;Moves to next address
        SUB     R0,     R0,     #1      ;Since we moved to next element
first
        LDR     R3, [R2]        ; element at address
        MOV     R4,     R2        ;secondary adress counter
        LDR     R7, = 0         ;temporary counter
        CMP     R3,     #0      ;if (element != 0)
        BEQ     next
while
        ADD     R4,     R4,     #4 ;Moves to next element to compare
        ADD     R7,     R7,     #1 ;counter++
        CMP     R0,     R7
        BLO     notclosed
        
        LDR     R5,     [R4]
        ADD     R6,     R5,     R3      ;Adds elements in both addresses
        CMP     R6,     #0      ;Checks if negation
        BNE     while           ;if not compare to next element
        STR     R6,     [R4]
        STR     R6,     [R2]    ;replaces both locations with 0
        SUB     R1,     R1,     #1 ;elements/2 --
        CMP     R1,     #0
        BEQ     closed
        b       next
closed
        LDR     R0, = 1
        b stop
notclosed
        LDR     R0, = 0

stop	B	stop


	AREA	TestData, DATA, READWRITE

ASize	DCD	8			; Number of elements in A
AElems	DCD	+4,-6,-4,+3,-8,+6,+8,-3	; Elements of A

	END
