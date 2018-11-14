	AREA	StatEval, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start
;variance formula = ((old variance*old count) + (new input - old mean)*(new input - new mean))/new count
        LDR     R5, = 10
        LDR     R7, = 0
        LDR     R8, = 0
        LDR     R12, = 0        ;initialises registers
        LDR     R11, = 0
newInstruction
        LDR     R4, = 0         ;resets R4 to zero
        LDR     R6, = 0         ;prevents empty spaces adding to sum
read
	
        BL	getkey		; read key from console
        CMP	R0, #0x0D  	; while (key != CR)
	BEQ	lastInput       ;{
        CMP     R0, #0x20       ;seperate inputs by spaces
        BEQ     nextInput
        CMP     R0, #'0'        ;ensures input is between 0 and 9{
        BLO     read
        CMP     R0, #'9'        ;}
        BHI     read                
        BL	sendchar	;   echo key back to console
        LDR     R6, = 1         ;acts as a check that a legit value has been entered
        MUL     R4,     R5,     R4      ;
        ADD     R4,     R4,     R0    ;adds user input to total
        SUB     R4,     R4,     #'0'   ;converts ascii value to decimal unsigned
        
	B	read		; }
lastInput
        LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
        LDR     R0, = 1
        CMP     R6,     #1
        BNE     redirection     
        b       calculation
nextInput
        CMP     R6,     #1
        BNE     newInstruction     
        BL      sendchar
        LDR     R0, = 0
calculation
        MUL     R12,    R7,     R12     ;old variance*old count
        ADD     R7,     R7,     #1      ;Count
        SUB     R1,     R4,     R11     ;temp register 1(new input - old mean)
        
        LDR     R11, = 0        ;resets R11 to store new mean
        ADD     R8,     R8,     R4      ;sum
        MOV     R6,     R8      ;re-intialise R6 as current sum
        
        CMP     R7,     #1      ;if first iteration of loop
        BNE     maxCheck
        MOV     R9,     R4      ;max value = R4
        MOV     R10,    R4      ;min value = R4
        b       meanCalculation
        
maxCheck
        CMP     R4,     R9      ;if(R4>R9){
        BLS     minCheck        ;R9 = R4
        MOV     R9,     R4      ;}
        
minCheck
        CMP     R4,    R10      ;if(R4<R10){ 
        BHS     meanCalculation        ;R10 = R4
        MOV     R10,    R4      ;}
        
        b       meanCalculation
        
redirection     ;if they enter in no new value and press enter
        MOV     R6,     R8      ;re-intialise R6 as current sum
        LDR     R11, = 0        ;resets R11 to store new mean
finalmean
        SUBS    R6,     R6,     R7      ;Divides current sum by count
        BLO     endVariance
        ADD     R11,    R11,    #1      ;R11 = mean
        b       finalmean 
        
meanCalculation
        SUBS    R6,     R6,     R7      ;Divides current sum by count
        BLO     mean
        ADD     R11,    R11,    #1      ;R11 = mean
        b       meanCalculation        
mean

        SUB     R2,     R4,     R11     ;temp register 2(new input - new mean)
        MUL     R1,     R2,     R1      ;(new input - old mean)*(new input - new mean)=R1
        ADD     R1,    R12,     R1      ;variance*new count
        LDR     R12, = 0
varianceDivision
        SUBS    R1,     R1,     R7      ;
        BLO     endVariance
        ADD     R12,     R12,     #1      ;R1 divided by new count
        b       varianceDivision
endVariance
        CMP     R0,     #1
        BNE     newInstruction
stop	B	stop

	END	
