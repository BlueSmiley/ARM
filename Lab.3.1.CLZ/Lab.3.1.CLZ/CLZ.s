	AREA	CLZ, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR	r4, =0x40000024; install the start address of your exception handler
	LDR	r5, =UndefHandler; in the exception vector lookup table
        STR	r5, [r4]
        

	; write a program to test your exception handler
        LDR	r4, =0xF0000000	; test 3^4
	; This is our undefinied unstruction opcode
	DCD	0x77F150F4
        
	
stop	B	stop

UndefHandler
	STMFD	sp!, {r0-r12, LR}	; save registers

	LDR	r4, [lr, #-4]		; load undefinied instruction
	BIC	r5, r4, #0xFFF0FFFF	; clear all but opcode bits
	TEQ	r5, #0x00010000		; check for undefined opcode 0x1
	BNE	endif1			; if (power instruction) {

        BIC     R5,     R4,     #0x0FFFFFFF     ;get conditional code
        CMP     R5,     #0x70000000     ;check for V(0111) set, 
;change 7 to check for other flags
        BNE     noVcheck
        BVC     endif1                  ;if V flag isnt set end
noVcheck
	BIC	r5, r4, #0xFFFFFFF0	;  isolate Rm register number	;
	BIC	r7, r4, #0xFFFFF0FF	;  isolate Rd register number
	MOV	r7, r7, LSR #8		;

	LDR	r1, [sp, r5, LSL #2]	;  grab saved Rm off stack

	BL	CountLeadingZeros

	STR	r0, [sp, r7, LSL #2]	;  save result over saved Rd		
endif1					; }
	LDMFD	sp!, {r0-r12, PC}^	; restore register and CPSR


;CLZ subroutine
; Counts the number of leading zeros
; paramaters: r0: result (variable)
;             r1: x (value)
CountLeadingZeros
	STMFD	sp!, {lr}	; save registers
        LDR     R0,=0   ;count
while
        MOVS    R1,     R1,     LSL     #1
        BCS     finishCount
        ADD     R0,     R0,     #1
        CMP     R0,     #32
        BHS     finishCount
        b while
finishCount	
	LDMFD	sp!, {pc} ; restore registers and return



	END	
	