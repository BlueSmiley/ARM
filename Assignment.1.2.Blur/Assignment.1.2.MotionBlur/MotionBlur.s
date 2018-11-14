	AREA	MotionBlur, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start
        PRESERVE8

start

	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight	; load the height of the image (rows) in R5
	MOV	R5, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6, R0
        
        MUL     R11,    R5,     R6      ;area
        ADD     R11,    R4,    R11,      LSL     #2
        
        LDR     R7, = 5 ;radius
        
        LDR     R9,=0   ;column index
        LDR     R10,=0   ;row index
iterate
        CMP     R9,     R6      
        BLO     currentrow
;increment row index and reset column when equal to width
        ADD     R10,     R10,     #1
        LDR     R9, =0
currentrow
        CMP     R10,     R5      
        BHS     final
;end if row index = height as indexes are 0 indexed
        MUL     R8,     R10,     R6      ;row length by row index
        ADD     R8,     R8,     R9      ;column index + offset
        
        STR     R7,     [SP,    #-4]!   ;pushes radius
        STR     R10,     [SP,    #-4]!   ;pushes row index
        STR     R9,     [SP,    #-4]!   ;pushes column index
        STR     R4,     [SP,    #-4]!   ;pushes mem addrress
        STR     R6,     [SP,    #-4]!   ;pushes row length/width
        STR     R5,     [SP,    #-4]!   ;pushes column length/height
       
        BL      blur
        ADD     SP,     SP,     #24             ;pops stack
        STR     R0,     [R11,   R8,      LSL     #2]     ;stores new pixel 
        ADD     R9,     R9,     #1      ;increment column index
        b iterate
;slight change to initial specification,im going to treat a radius of 1 as
;average of current pixel and one pixel diagonally below and above
;this deals with the ambiguity of what to do with odd numbers and
;makes more sense as radii of 0 = do nothing 
;and every other radii applies blur
final
        MOV     R0,     R4
        MOV     R1,     R11
        MOV     R2,     R5
        MOV     R3,     R6
        BL      transfer
	BL	putPic		; re-display the updated image

stop	B	stop

transfer
;given two memory address and the width and height it overwrites contents
;from the second to first
;R0 = target address  R1= new address R2 = pic height R3 = pic width
;returns void
        STMFD   SP!,     {LR,R4-R7}
        LDR     R4,=0   ;column index
        LDR     R5,=0   ;row index
for
        CMP     R4,     R3      
        BLO     innerfor
;increment row index and reset column when equal to width
        ADD     R5,     R5,     #1
        LDR     R4, =0
innerfor
        CMP     R5,     R2      
        BHS     finishCopy
;end if row index = height as indexes are 0 indexed
        MUL     R6,     R5,     R3      ;row length by row index
        ADD     R6,     R6,     R4      ;column index + offset
        LDR     R7,     [R1,    R6,     LSL #2]     ;gets pixel at new address
        STR     R7,     [R0,    R6,     LSL #2]     ;replaces old pixel
        ADD     R4,     R4,     #1
        b       for
finishCopy
        LDMFD   SP!,     {PC,R4-R7}
        

blur
;given the indexes of the pic and radius of blur,blurs the pixel
;parameters row index column index memory adress row length column length radius
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        MOV     R12,    SP      ;scratch register
        ADD     R12,    R12,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R9}
;R4=column length R5= row length r6=mem address 
;R7=column index R8=row index R9=radius  R10=count
        LDR     R10,=0  ;count is 0
        LDR     R1,=0   ;temp count =0
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7      ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]     ;gets pixel at address
        STR     R0,     [SP,    #-4]!
upleft
        CMP     R1,    R9      ;check count vs radius
        BHS     oppdir
        
        SUBS    R8,     R8,     #1      ;is row index less than 0
        BLO     oppdir
        SUBS    R7,     R7,     #1      ;is column index<0
        BLO     oppdir
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7      ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]     ;gets pixel at address
        STR     R0,     [SP,    #-4]!
        
        ADD     R1,    R1,    #1      ;increment temp count
        b upleft
oppdir        
        ADD     R10,    R10,    R1      ;add tmep count to count
        LDR     R1,=0           ;reset count
        LDMFD   R12,     {R4-R9}        ;used to reset the indices
downright
        CMP     R1,    R9      ;check count vs radius
        BHS     endsub
        
        ADD     R8,     R8,     #1      
        CMP     R8,     R4              ;is row index>=column length/height 
        BHS     endsub
        ADD     R7,     R7,     #1
        CMP     R7,     R5              ;is column index>=row length/width  
        BHS     endsub
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7      ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]     ;gets pixel at address
        STR     R0,     [SP,    #-4]!
        
        ADD     R1,    R1,    #1      ;increment temp count
        b downright
endsub   
        ADD     R10,    R10,    R1      ;add temp count to count
        MOV     R1,     R10;make copy of count
        
        LDR     R2,=0   ;r2 is now used to represent the average red
        LDR     R3,=0   ;r3=green
        LDR     R4,=0    ;r4=blue
poppixels        
        LDR     R0,     [SP],     #4
        MOV     R11,    R0
        BL      getPicRed
        ADD     R2,     R2,     R0      ;add pixel red to sum
        
        MOV     R0,     R11
        BL      getPicGreen
        ADD     R3,     R3,     R0      ;add pixel green
        
        MOV     R0,     R11
        BL      getPicBlue
        ADD     R4,     R4,     R0      ;add pixel blue
        
        SUBS     R1,    R1,    #1        ;decrement count
        BLO     rtrnres
        b       poppixels
rtrnres
        ADD     R10,     R10,     #1      ;current pixel
        MOV     R1,     R10
        
        MOV     R0,     R2
        BL      division
        AND     R0,     R0,     #0x000000FF
        MOV     R2,     R0      ;no more use for R2
        MOV     R1,     R10
        
        MOV     R0,     R3
        BL      division
        MOV     R3,     R0
        MOV     R1,     R10
        
        MOV     R0,     R4
        BL      division
        MOV     R4,     R0
        
        MOV     R0,     R2
        MOV     R1,     R3
        MOV     R2,     R4
        BL      compositeColors
         
        AND     R0,     R0,     #0x00FFFFFF
        LDMFD   SP!,     {PC,R4-R12}


               
getPicRed
;gets the red component of a pixel as a number between 0-255
;parameter R0 = pixel
;returns R0 as red component
        MOV     R0,     R0,      LSR     #16
        BX      LR

getPicGreen
;gets the green component of a pixel as a number between 0-255
;parameter R0 = pixel
;returns R0 as green component
        MOV     R0,     R0,      LSR     #8
        AND     R0,     R0,     #0x000000FF
        BX      LR
        
getPicBlue
;gets the blue component of a pixel as a number between 0-255
;parameter R0 = pixel
;returns R0 as blue component
        AND     R0,     R0,     #0x000000FF
        BX      LR
        
compositeColors
;combines the red green and blue components into a single colour
;parameters R0=red R1=green R2=blue
;returns R0 as colour
        MOV     R0,     R0,     LSL     #16     ;red in last pos
        MOV     R1,     R1,     LSL     #8      ;green in second
        ADD     R0,     R0,     R1      ;combine red and green
        ADD     R0,     R0,     R2      ;combine with blue
        AND     R0,     R0,     #0x00FFFFFF
        BX      LR
        
swapRed
;swaps the red component of a pixel with a specified value
;parameters     R0=color        R1=red component
;returns R0 as new pixel
        AND     R1,     R1,     #0x000000FF      ;prevents component over 255
        MOV     R1,     R1,     LSL     #16     ;red in last pos
        LDR     R2,=0x0000FFFF
        AND     R0,     R0,     R2     ;scrambles red of color
        ORR     R0,     R1,     R0      ;final color
        BX      LR
        
swapGreen
;swaps the green component of a pixel with a specified value
;parameters     R0=color        R1=green component
;returns R0 as new pixel
        AND     R1,     R1,     #0x000000FF      ;prevents component over 255
        MOV     R1,     R1,     LSL     #8     ;green in second pos
        LDR     R2,=0x00FF00FF
        AND     R0,     R0,     R2     ;scrambles green of color
        ORR     R0,     R1,     R0      ;final color
        BX      LR
        
swapBlue
;swaps the blue component of a pixel with a specified value
;parameters     R0=color        R1=blue component
;returns R0 as new pixel
        AND     R1,     R1,     #0x000000FF      ;prevents component over 255
        LDR     R2,=0x00FFFF00
        AND     R0,     R0,     R2     ;scrambles blue of color
        ORR     R0,     R1,     R0      ;final color
        BX      LR
        
division
;divides two unsigned integers and returns the quotient
;R0 = Number to be divided
;R1 = divisor
;returns R0 = quotient
        STMFD   SP!,     {LR,R4-R6}
        LDR     R4,=0
        LDR     R5,=0;quotient
        LDR     R6,=1   ;for power
topowr        
        CMP     R0,     R1,      LSL     R4
        BLS     wh
        ADD     R4,     R4,     #1      ;increment power
        b       topowr
             
wh
        SUBS    R0,     R0,     R1,     LSL     R4 ;Repeatedly subtracts divisor
        BLO     stopwh              ;decreases power if too large
        ADD     R5,     R5,     R6,     LSL     R4      ;quotient
        B       wh
stopwh
        ADD     R0,     R0,     R1,     LSL     R4
        SUBS    R4,     R4,     #1      ;ends if power is <0
        BLO     enddiv
        b wh
enddiv
        MOV     R0,     R5
        LDMFD   SP!,     {PC,R4-R6}     ;end subroutine

	END	