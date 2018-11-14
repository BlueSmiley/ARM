	AREA	Val2Dec, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R4, =7890
	LDR	R5, =decstr        
        
        LDR     R6, =0  ;stack counter
        MOV     R0,     R4      ;sets numerator as 7890
strString
        LDR     R1, =BASE_10_DIVISOR    ;sets divisor as 10
        BL      division
        ADD     R0,      R0,     #'0'   ;convert to ascii
        STR    R0,     [R13,   #-4]!   ;store in full descending
        ADD     R6,     R6,     #1      ;increment stack counter
        
        CMP     R1,     #0              ;check if quotient is 0
        BEQ     memstore
        MOV     R0,     R1              ;sets numerator as prev quotient
        b       strString
memstore
        CMP     R6,     #0              ;check if stack counter is 0 already
        BEQ     stop
transfer
        LDR    R7,     [R13],   #4      ;push from stack    
        STRB    R7,     [R5],    #1     ;transfer contents from stack to mem
        SUBS     R6,     R6,     #1      ;decrement stack counter
        BEQ     stop
        b transfer
	
stop	B	stop

;Division
;divides two unsigned integers and returns the quotient and remainder
;R0 = Number to be divided
;R1 = divisor
;returns R0 = remainder and R1 = quotient

division
        STMFD   SP!,     {LR,R4}
        LDR     R4, = 0 ;To store quotient value     
while
        SUBS    R0,     R0,     R1 ;Repeatedly subtracts divisor from total
        BLO     endwh              ;ends code if R2<R3
        ADD     R4,     R4,     #1      ;quotient
        B       while
endwh
        ADD     R0,     R0,      R1 ;Makes R0 the remainder
        MOV     R1,     R4          ;Makes R1 the quotient
        LDMFD   SP!,     {PC,R4}     ;end subroutine

BASE_10_DIVISOR EQU     10      ;constant declaration
        
	AREA	TestString, DATA, READWRITE

decstr	SPACE	16
	END	