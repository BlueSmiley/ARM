	AREA	SymmDiff, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR     R0, =ASize
        LDR     R1, =AElems
        LDR     R0,     [R0]
        LDR     R2, =BSize
        LDR     R3, =BElems
        LDR     R2,     [R2]    ;loads the size and set of elements
        LDR     R4, =CSize
        LDR     R5, =CElems
        LDR     R7, = 0         ;to store size of C
for                             ;transfers A to C
        CMP     R0,     #0
        BEQ     compare
        LDR     R6,     [R1]
        STR     R6,     [R5]
        SUB     R0,     R0,     #1      ;decrease count by one
        ADD     R7,     R7,     #1      ;increase C size by one
        ADD     R1,     R1,     #4      ;next address
        ADD     R5,     R5,     #4      ;next C address
        b       for
transfer
        ADD     R7,     R7,     #1      ;increase C size
        STR     R0,     [R5]            ;transfers element from b to C
        ADD     R5,     R5,     #4      ;next C address
nextelement
        SUB     R2,     R2,     #1      ;decrement remaining elements in B
        ADD     R3,     R3,     #4      ;next address of B       
compare                                 ;compares each element of b against C
        CMP     R2,     #0
        BEQ     ending                    ;when finished checking B end
        LDR     R0,     [R3]            ;loads element from set B
        LDR     R1, = CElems
        MOV     R9,     R7              ;transfers size of C temporarily
loop
        LDR     R8,     [R1]            ;loads element from C
        CMP     R0,     R8              ;compares elements
        BEQ     nextelement
        ADD     R1,     R1,     #4      ;next address
        SUB     R9,     R9,     #1      ;decrements size
        CMP     R9,     #0
        BEQ     transfer
        b       loop
ending
        STR     R7,     [R4]
        
        
stop	B	stop


	AREA	TestData, DATA, READWRITE

ASize	DCD	8			; Number of elements in A
AElems	DCD	4,6,2,13,19,7,1,3	; Elements of A

BSize	DCD	6			; Number of elements in B
BElems	DCD	13,9,1,20,5,8		; Elements of B

CSize	DCD	0			; Number of elements in C
CElems	SPACE	56			; Elements of C

	END
