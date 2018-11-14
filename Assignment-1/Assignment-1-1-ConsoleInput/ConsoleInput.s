	AREA	ConsoleInput, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start
        LDR     R5, = 10
        LDR     R7, = 0
        LDR     R8, = 0
        LDR     R12, = 0        ;initialises registers
        LDR     R11, = 0
newInstruction
        LDR     R4, = 0         ;resets R4 to zero
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
        MUL     R4,     R5,     R4      ;
        ADD     R4,     R4,     R0    ;adds user input to total
        SUB     R4,     R4,     #'0'   ;converts ascii value to decimal unsigned
        
	B	read		; }
lastInput
        LDR     R0, = 0x0A      ;outputs linefeed
        BL      sendchar
        LDR     R0, = 1    
        b       stop
nextInput  
        BL      sendchar
        LDR     R0, = 0
        b newInstruction
        
stop	B	stop

	END	