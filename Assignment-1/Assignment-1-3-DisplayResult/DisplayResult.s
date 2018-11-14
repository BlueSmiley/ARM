	AREA	DisplayResult, CODE, READONLY
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
        LDR     R0, = 0x4D
        BL      sendchar
	LDR	R0, = 0x45
	BL	sendchar	
	LDR	R0, = 0x20
	BL	sendchar	;outputs ME for mean
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

;Begin displaying mean
        ADD     R6,     R6,     R7      ;remainder
        MUL     R6,     R5,     R6
        MOV     R4,     R11     ;R4 temporarily stores mean
        MUL     R4,    R5,     R4     ;allows display up to one decimal place

decimalCalculator
        SUBS    R6,     R6,     R7      ;Divides remainder by count
        BLO     meanDisplay
        ADD     R4,    R4,    #1      ;R4 =(actual mean*10)
        b       decimalCalculator
meanDisplay        
        
        LDR     R6, = 1         ;resets R6
exponential
        MUL     R0,     R6,     R5
        CMP     R4,    R0      ;checks if R6 has same number of decimal places as mean
        BLO     display
        MUL     R6,     R5,     R6 ;else increase R6 by one decimal place
        b       exponential
display
        LDR     R0, = 0         ;resets R0
        
division
        SUBS    R4,     R4,     R6
        BLO     endDivision
        ADD     R0,     R0,     #1      ;R0 is quotient
        b       division          ;Divides R4 by R6
        
endDivision
        ADD     R4,    R4,    R6      ;R4 is remainder     
        ADD     R0,     R0,     #'0'
        BL      sendchar
        CMP     R6,     #10
        BNE     wholeNumber
        LDR     R0, = 0x2E
        BL      sendchar        ;displays . after whole number
wholeNumber     
        CMP     R6,    #1       ;ends program when last decimal place has been displayed
        BEQ     endMeanDisplay
        
        MOV     R0,     R6
        LDR     R6, = 0
reducingPower
        ADD     R6,     R6,     #1
        SUB     R0,     R0,     R5
        CMP     R0,     #0
        BEQ     display
        b       reducingPower   ;Decreses R6 by one power
endMeanDisplay

;variance display
;(note:for large and very small values the variance is inaccurate as it loses precision due to lack of decimals)
;(also for a large number of values I think)
        LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
	LDR	R0, = 0x56
	BL	sendchar
	LDR	R0, = 0x41
	BL	sendchar
	LDR	R0, = 0x20
	BL	sendchar		;outputs VA for variance
                
        LDR     R6, = 1         ;resets R6
varianceDisplay
        MUL     R0,     R6,     R5
        CMP     R12,    R0      ;checks if R6 has same number of decimal places as variance
        BLO     VaDeclaration
        MUL     R6,     R5,     R6 ;else increase R6 by one decimal place
        b       varianceDisplay
        
VaDeclaration
        MOV     R4,     R12     ;R4 temporarily stores variance
Vadisplay
        LDR     R0, = 0         ;resets R0
        
Vadivision
        SUBS    R4,     R4,     R6
        BLO     endVaDivision
        ADD     R0,     R0,     #1      ;R0 is quotient
        b       Vadivision          ;Divides R4 by R6
        
endVaDivision
        ADD     R4,    R4,    R6      ;R4 is remainder     
        ADD     R0,     R0,     #'0'
        BL      sendchar
        CMP     R6,    #1       ;ends program when last decimal place has been displayed
        BEQ     endVarianceDisplay
        
        MOV     R0,     R6
        LDR     R6, = 0
VareducingPower
        ADD     R6,     R6,     #1
        SUB     R0,     R0,     R5
        CMP     R0,     #0
        BEQ     Vadisplay
        b       VareducingPower   ;Decreses R6 by one power
endVarianceDisplay

;count display                
   	LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
	LDR	R0, = 0x43
	BL	sendchar
	LDR	R0, = 0x4F
	BL	sendchar
	LDR	R0, = 0x20
	BL	sendchar		;outputs CO for count
        
        LDR     R6, = 1         ;resets R6
countDisplay
        MUL     R0,     R6,     R5
        CMP     R7,    R0      ;checks if R6 has same number of decimal places as count
        BLO     CoDeclaration
        MUL     R6,     R5,     R6 ;else increase R6 by one decimal place
        b       countDisplay
        
CoDeclaration
        MOV     R4,     R7     ;R4 temporarily stores count
Codisplay
        LDR     R0, = 0         ;resets R0
        
Codivision
        SUBS    R4,     R4,     R6
        BLO     endCoDivision
        ADD     R0,     R0,     #1      ;R0 is quotient
        b       Codivision          ;Divides R4 by R6
        
endCoDivision
        ADD     R4,    R4,    R6      ;R4 is remainder     
        ADD     R0,     R0,     #'0'
        BL      sendchar
        CMP     R6,    #1       ;ends program when last decimal place has been displayed
        BEQ     endCountDisplay
        
        MOV     R0,     R6
        LDR     R6, = 0
CoreducingPower
        ADD     R6,     R6,     #1
        SUB     R0,     R0,     R5
        CMP     R0,     #0
        BEQ     Codisplay
        b       CoreducingPower   ;Decreses R6 by one power
endCountDisplay

;Sum display
		
	LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
	LDR	R0, = 0x53
	BL	sendchar
	LDR	R0, = 0x55
	BL	sendchar
	LDR	R0, = 0x20
	BL	sendchar		;outputs SU for sum
        
        LDR     R6, = 1         ;resets R6
sumDisplay
        MUL     R0,     R6,     R5
        CMP     R8,    R0      ;checks if R6 has same number of decimal places as sum
        BLO     SuDeclaration
        MUL     R6,     R5,     R6 ;else increase R6 by one decimal place
        b       sumDisplay
        
SuDeclaration
        MOV     R4,     R8     ;R4 temporarily stores sum
Sudisplay
        LDR     R0, = 0         ;resets R0
        
Sudivision
        SUBS    R4,     R4,     R6
        BLO     endSuDivision
        ADD     R0,     R0,     #1      ;R0 is quotient
        b       Sudivision          ;Divides R4 by R6
        
endSuDivision
        ADD     R4,    R4,    R6      ;R4 is remainder     
        ADD     R0,     R0,     #'0'
        BL      sendchar
        CMP     R6,    #1       ;ends program when last decimal place has been displayed
        BEQ     endSumDisplay
        
        MOV     R0,     R6
        LDR     R6, = 0
SureducingPower
        ADD     R6,     R6,     #1
        SUB     R0,     R0,     R5
        CMP     R0,     #0
        BEQ     Sudisplay
        b       SureducingPower   ;Decreses R6 by one power
endSumDisplay
		
;Max value	
        LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
	LDR	R0, = 0x4D
	BL	sendchar
	LDR	R0, = 0x41
	BL	sendchar
	LDR	R0, = 0x20
	BL	sendchar		;outputs MA for maximum value
        
        LDR     R6, = 1         ;resets R6
maxDisplay
        MUL     R0,     R6,     R5
        CMP     R9,    R0      ;checks if R6 has same number of decimal places as max value
        BLO     MaDeclaration
        MUL     R6,     R5,     R6 ;else increase R6 by one decimal place
        b       maxDisplay
        
MaDeclaration
        MOV     R4,     R9     ;R4 temporarily stores max value
Madisplay
        LDR     R0, = 0         ;resets R0
        
Madivision
        SUBS    R4,     R4,     R6
        BLO     endMaDivision
        ADD     R0,     R0,     #1      ;R0 is quotient
        b       Madivision          ;Divides R4 by R6
        
endMaDivision
        ADD     R4,    R4,    R6      ;R4 is remainder     
        ADD     R0,     R0,     #'0'
        BL      sendchar
        CMP     R6,    #1       ;ends program when last decimal place has been displayed
        BEQ     endMaxDisplay
        
        MOV     R0,     R6
        LDR     R6, = 0
MareducingPower
        ADD     R6,     R6,     #1
        SUB     R0,     R0,     R5
        CMP     R0,     #0
        BEQ     Madisplay
        b       MareducingPower   ;Decreses R6 by one power
endMaxDisplay
        
;Minimum value        
		
	LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
	LDR	R0, = 0x4D
	BL	sendchar
	LDR	R0, = 0x49
	BL	sendchar
	LDR	R0, = 0x20
	BL	sendchar		;outputs MI for minimum value
        
        LDR     R6, = 1         ;resets R6
minDisplay
        MUL     R0,     R6,     R5
        CMP     R10,    R0      ;checks if R6 has same number of decimal places as min value
        BLO     MiDeclaration
        MUL     R6,     R5,     R6 ;else increase R6 by one decimal place
        b       minDisplay
        
MiDeclaration
        MOV     R4,     R10     ;R4 temporarily stores min value
Midisplay
        LDR     R0, = 0         ;resets R0
        
Midivision
        SUBS    R4,     R4,     R6
        BLO     endMiDivision
        ADD     R0,     R0,     #1      ;R0 is quotient
        b       Midivision          ;Divides R4 by R6
        
endMiDivision
        ADD     R4,    R4,    R6      ;R4 is remainder     
        ADD     R0,     R0,     #'0'
        BL      sendchar
        CMP     R6,    #1       ;ends program when last decimal place has been displayed
        BEQ     endMinDisplay
        
        MOV     R0,     R6
        LDR     R6, = 0
MireducingPower
        ADD     R6,     R6,     #1
        SUB     R0,     R0,     R5
        CMP     R0,     #0
        BEQ     Midisplay
        b       MireducingPower   ;Decreses R6 by one power
endMinDisplay		
	SUB     R6,     R9,     R10     ;R6 is the range
stop	B	stop

	END	