	AREA	MatMul, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =matR
	LDR	R1, =matA
	LDR	R2, =matB
	LDR	R3, =N

	LDR R4, =0		; i = 0
	LDR R5, =0		; j = 0
	LDR R6, =0		; k = 0
	
for1
	CMP R4, R3
	BGE stop
	LDR R5, = 0             ;j = 0
for2
	CMP R5, R3
	BGE endfor2
	LDR R7, =0		; r = 0
        LDR R6, = 0             ;k = 0
for3
	CMP R6, R3              ;for( k = 0 ;k<N ;k++)
	BGE endfor3
        ADD     R6,     R6,     #1;k++
        
        MUL     R9,     R3,     R4      ;i*N
        ADD     R9,     R9,     R6      ;i*N + k
        LDR     R9,     [R1,    R9,      LSL  #2]     ;A[i,k]
        
        MUL     R8,     R3,     R6      ;k*N
        ADD     R8,     R8,     R5      ;k*N + j
        LDR     R8,     [R2,    R8,      LSL  #2]     ;B[k,j]
        
        MUL     R10,     R8,     R9
        ADD     R7,     R7,     R10      ; r = r + A[i,k]*B[k,j]
        b       for3	
endfor3
        MUL     R9,     R3,     R4      ;i*N
        ADD     R9,     R9,     R5      ;i*N + j
        STR     R7,     [R0,    R9,      LSL  #2]     ;R[i,j] = r
        ADD     R5,     R5,     #1;     ;j++
        b       for2
endfor2
        ADD     R4,     R4,     #1;     ;i++
        b       for1
	
stop	B	stop


	AREA	TestArray, DATA, READWRITE

N	EQU	4

matA	DCD	5,4,3,2
	DCD	3,4,3,4
	DCD	2,3,4,5
	DCD	4,3,4,3

matB	DCD	5,4,3,2
	DCD	3,4,3,4
	DCD	2,3,4,5
	DCD	4,3,4,3

matR	SPACE	64

	END	