	AREA	Adjust, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start

start

	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight	; load the height of the image (rows) in R5
	MOV	R5, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6, R0
;not all functions are used but are made for later use

	; your code goes here
        LDR     R7,=0
        LDR     R8,=0
        
;8 byte to preserve alignment        
        LDR     R0, = 20        ;brightness
        STR     R0,     [SP,    #-8]!
        LDR     R0, = 16        ;contrast
        STR     R0,     [SP,    #-8]!    

;R7 = column index      R8 = row index
iterate
        CMP     R7,     R6      
        BLO     currentrow
;increment row index and reset column when equal to width
        ADD     R8,     R8,     #1
        LDR     R7, =0
currentrow
        CMP     R8,     R5      
        BHS     final
;end if row index = height as indexes are 0 indexed
        MUL     R9,     R8,     R6      ;row length by row index
        ADD     R9,     R9,     R7      ;column index + offset
        LDR     R10,     [R4,    R9,     LSL #2]         ;gets pixel at address
        
        MOV     R0,     R10      ;copy of pixel
        LDR     R1,     [SP]    ;contrast
        BL      changePixelContrast
        MOV     R10,     R0      ;replace old pixel
        
        LDR     R1,     [SP,    #8]     ;brightness
        BL      changePixelBrightness
        MOV     R10,     R0      ;replace old pixel
        
        STR     R10,     [R4,    R9,     LSL #2] ;puts in new address
        ADD     R7,     R7,     #1      ;increment column index
        b       iterate
final        
        ADD     SP,     SP,     #16
	BL	putPic		; re-display the updated image

stop	B	stop

changePixelBrightness
;changes the brightness of entire pixel by value
;R0 = pixel     R1=brightness
        STR     LR,     [SP,    #-8]!
        STR     R5,     [SP,    #-8]!
        STR     R4,     [SP,    #-8]!
        
        MOV     R4,     R0      ;copy of pixel
        MOV     R5,     R1      ;brightness
        
        BL      getPicRed
        MOV     R1,     R5      ;R1 could be corrupted
        BL      changeBrightness
        MOV     R1,     R0      ;R1 = new red
        MOV     R0,     R4      ;old pixel
        BL      swapRed
        MOV     R4,     R0      ;replace pixel with new one
        
        BL      getPicGreen
        MOV     R1,     R5      ;R1 could be corrupted
        BL      changeBrightness
        MOV     R1,     R0      ;R1 = new green
        MOV     R0,     R4      ;old pixel
        BL      swapGreen
        MOV     R4,     R0      ;replace pixel with new one
        
        BL      getPicBlue
        MOV     R1,     R5      ;R1 could be corrupted
        BL      changeBrightness
        MOV     R1,     R0      ;R1 = new blue
        MOV     R0,     R4      ;old pixel
        BL      swapBlue
        
        LDR     R4,     [SP],    #8
        LDR     R5,     [SP],    #8
        LDR     PC,     [SP],    #8


changePixelContrast
;changes the contrast of entire pixel by value
;R0 = pixel     R1=contrast
;returns R0=new pixel
;note this can be done much faster but this splits up the changes to each channel
        STR     LR,     [SP,    #-8]!
        STR     R5,     [SP,    #-8]!
        STR     R4,     [SP,    #-8]!
        
        MOV     R4,     R0      ;copy of pixel
        MOV     R5,     R1      ;contrast value
        
        BL      getPicRed
        MOV     R1,     R5      ;R1 could be corrupted
        BL      changeContrast
        MOV     R1,     R0      ;R1 = new red
        MOV     R0,     R4      ;old pixel
        BL      swapRed
        MOV     R4,     R0      ;replace pixel with new one
        
        BL      getPicGreen
        MOV     R1,     R5      ;R1 could be corrupted
        BL      changeContrast
        MOV     R1,     R0      ;R1 = new green
        MOV     R0,     R4      ;old pixel
        BL      swapGreen
        MOV     R4,     R0      ;replace pixel with new one
        
        BL      getPicBlue
        MOV     R1,     R5      ;R1 could be corrupted
        BL      changeContrast
        MOV     R1,     R0      ;R1 = new blue
        MOV     R0,     R4      ;old pixel
        BL      swapBlue
        
        LDR     R4,     [SP],    #8
        LDR     R5,     [SP],    #8
        LDR     PC,     [SP],    #8
        
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
        
changeBrightness
;changes the brightness of a specific color component of a pixel
;parameters R0=color component R1=brightness
;returns R0 as brightened component
        
        ADDS    R0,     R0,     R1      ;add brightness to component
        BPL     notzero
        LDR     R0,=0
        b normal
notzero        
        CMP     R0,     #0x000000FF
        BLO     normal  ;to set to max if greater than 255
        LDR     R0,=0x000000FF
normal
        CMP     R0,     #0
        BHS     finishedBrightness
        LDR     R0, = 0         ;to set to min if less than 0
finishedBrightness
        AND     R0,     R0,     #0x000000FF     ;clears any overflow
        BX      LR
        
changeContrast
;changes the contrast of a specific color component of a pixel
;parameters R0=color component R1=contrast
;returns R0 as saturated component
        CMP     R0,     #0
        BLS     notmax          ;if 0 skip all this
        MULS     R0,     R1,     R0      ;multiply by contrast
        BVS     ismax           ;if overflow than set to max
        MOV     R0,     R0,     LSR     #4      ;divides by 16
        CMP     R0,     #0x000000FF
        BLO     notmax  ;to set to max if greater than 255
ismax
        LDR     R0,=0x000000FF
notmax
        AND     R0,     R0,     #0x000000FF     ;clears any overflow
        BX      LR
        
swapRed
;swaps the red component of a pixel with a specified value
;parameters     R0=color        R1=red component
;returns R0 as new pixel
        CMP     R1,     #0x000000FF
        BLO     notmaxred  ;to set to max if greater than 255
        LDR     R1,=0x000000FF  ;else color is max
notmaxred
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
        CMP     R1,     #0x000000FF
        BLO     notmaxgreen  ;to set to max if greater than 255
        LDR     R1,=0x000000FF  ;else color is max
notmaxgreen
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
        CMP     R1,     #0x000000FF
        BLO     notmaxblue  ;to set to max if greater than 255
        LDR     R1,=0x000000FF  ;else color is max
notmaxblue
        AND     R1,     R1,     #0x000000FF      ;prevents component over 255
        LDR     R2,=0x00FFFF00
        AND     R0,     R0,     R2     ;scrambles blue of color
        ORR     R0,     R1,     R0      ;final color
        BX      LR


	END	