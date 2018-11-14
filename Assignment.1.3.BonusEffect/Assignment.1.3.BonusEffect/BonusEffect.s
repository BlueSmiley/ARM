	AREA	BonusEffect, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start
        PRESERVE8
;doing edge detection with three major parts
;pre-processing:
;optional filter
;converting to greyscale + adding gaussian filter to remove noise
;processing:
;sobel edge detection approximation using kernel
;post-processing
;normalising image to range of 0-255
;thresholding and linking result
start

	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight	; load the height of the image (rows) in R5
	MOV	R5, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6, R0
        
        MOV     R0,     R4
        MOV     R1,     R5
        MOV     R2,     R6
        
        LDR     R3,=0x0000FFFF
        BL      primaryFilter
        
        MOV     R0,     R4
        MOV     R1,     R5
        MOV     R2,     R6
        BL      picToGrey
                
        MUL     R11,    R5,     R6      ;area
        ADD     R11,    R4,    R11,      LSL     #2
        
        LDR     R7, = 0 ;boolean
        LDR     R2, =   256    ;default max and min
        STR     R2,     [SP,    #-4]!
        STR     R2,     [SP,    #-4]!
        
        
iteraterepeat        
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
        
        CMP     R7,     #1
        BEQ     sobeldet
        BHI     finisher
        
        STR     R10,     [SP,    #-4]!   ;pushes row index
        STR     R9,     [SP,    #-4]!   ;pushes column index
        STR     R4,     [SP,    #-4]!   ;pushes mem addrress
        STR     R6,     [SP,    #-4]!   ;pushes row length/width
        STR     R5,     [SP,    #-4]!   ;pushes column length/height      
        BL      gaussianBlur
        ADD     SP,     SP,     #20             ;pops stack
        b       movetonextindex
sobeldet
        STR     R10,     [SP,    #-4]!   ;pushes row index
        STR     R9,     [SP,    #-4]!   ;pushes column index
        STR     R4,     [SP,    #-4]!   ;pushes mem addrress
        STR     R6,     [SP,    #-4]!   ;pushes row length/width
        STR     R5,     [SP,    #-4]!   ;pushes column length/height
        BL      edgeDetection
        ADD     SP,     SP,     #20             ;pops stack
        
        LDR     R2,     [SP],   #4      ;max
        LDR     R3,     [SP],   #4      ;min
        
        STR     R0,     [SP,    #-4]!    ;back up pixel
        BL      getPicBlue      ;gets blue component/luminance
        
        CMP     R2,    #255      ;check if row 0
        BLS     maxcheck        ;if at default values overwrite
        MOV     R2,     R0
        MOV     R3,     R0
        b       pushminmax
maxcheck
        CMP     R2,     R0      ;compare max to pixel intensity
        BHS     mincheck
        MOV     R2,     R0      ;replace max
mincheck
        CMP     R3,     R0
        BLS     pushminmax
        MOV     R3,     R0
pushminmax
        LDR     R0,     [SP],   #4      ;restore pixel
        STR     R3,     [SP,    #-4]!   ;push in reverse order of pop
        STR     R2,     [SP,    #-4]!
        b       movetonextindex
finisher
        LDR     R0, = 160       ;minimum threshold
        STR     R0,     [SP,    #-4]!   ;pushes min thr
        LDR     R0, = 180
        STR     R0,     [SP,    #-4]!   ;pushes max thr
        
        STR     R10,     [SP,    #-4]!   ;pushes row index
        STR     R9,     [SP,    #-4]!   ;pushes column index
        STR     R4,     [SP,    #-4]!   ;pushes mem addrress
        STR     R6,     [SP,    #-4]!   ;pushes row length/width
        STR     R5,     [SP,    #-4]!   ;pushes column length/height      
        BL      thresholding
        ADD     SP,     SP,     #28             ;pops stack
           
movetonextindex        
        STR     R0,     [R11,   R8,      LSL     #2]     ;stores new pixel 
        ADD     R9,     R9,     #1      ;increment column index
        b iterate

final
        MOV     R0,     R4
        MOV     R1,     R11
        MOV     R2,     R5
        MOV     R3,     R6
        BL      transfer
        ADD     R7,     R7,     #1      ;change boolean
        CMP     R7,     #2      ;boolean check
        BLO     iteraterepeat
        
        LDR     R2,     [SP],   #4      ;max
        LDR     R3,     [SP],   #4      ;min 
        STR     R4,     [SP,    #-4]!   ;pushes mem addrress
        STR     R6,     [SP,    #-4]!   ;pushes row length/width
        STR     R5,     [SP,    #-4]!   ;pushes column length/height
        STR     R3,     [SP,    #-4]!   ;push max
        STR     R2,     [SP,    #-4]!   ;push min
        BL      normalise
        ADD     SP,     SP,     #28     ;pop stack
        
        CMP     R7,     #2      ;boolean check
        BEQ     iteraterepeat
                 
	BL	putPic		; re-display the updated image

stop	B	stop

thresholding
;doesnt matter if this actually gets implemented by end.just for fun
;very simple
;attempts to use thresholds to link and highlight edges
;parameters: 
;low thr high thr row index  column index 
;Memory adress row length column length high thr low thr
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R10}
;R4=column length R5= row length r6=mem address R7=column index R8=row index
;R9=high thr    R10=low thr
        AND     R10,    R10,    #0x000000FF
        AND     R9,     R9,    #0x000000FF      ;just in case u chose th>255
        
        MOV     R0,     R10
        MOV     R1,     R10
        MOV     R2,     R10
        BL      compositeColors
        MOV     R10,    R0      ;this operation saves operations later
        
        MOV     R0,     R9
        MOV     R1,     R9
        MOV     R2,     R9
        BL      compositeColors
        MOV     R9,    R0      ;this operation saves operations later
        
        STMFD   SP!,     {R4-R8}        ;push parameters
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        CMP     R0,     R10     ;sees if pixel is below lower thr
        BLS     turnBlack
        CMP     R0,     R9      ;if pixel>=higher threshold
        BHI     turnWhite
        
        BL      getPixelUL
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelU
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelUR
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelL
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelR
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelBL
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelB
        CMP     R0,     R10
        BLS     turnBlack
        BL      getPixelBR
        CMP     R0,     R10
        BLS     turnBlack
turnWhite
        LDR     R0,=0x00FFFFFF
        LDMFD   SP!,     {R4-R8}        ;pop parameters
        LDMFD   SP!,     {R4-R12,PC}
turnBlack
        LDR     R0,=0
        LDMFD   SP!,     {R4-R8}        ;pop parameters
        LDMFD   SP!,     {R4-R12,PC}
        


primaryFilter
;filters entire pic to only include the colour channels in mask
;R0=addrss      R1=pic height   R2=pic width    R3=mask
        STMFD   SP!,     {LR,R4-R10}
        LDR     R4,=0   ;column index
        LDR     R5,=0   ;row index
        MOV     R6,     R0
        MOV     R7,     R1
        MOV     R8,     R2      ;local copies of parameters
        MOV     R10,    R3
rowCheck
        CMP     R4,     R8      
        BLO     columnCheck
;increment row index and reset column when equal to width
        ADD     R5,     R5,     #1
        LDR     R4, =0
columnCheck
        CMP     R5,     R7      
        BHS     finishFilter
;end if row index = height as indexes are 0 indexed
        MUL     R9,     R5,     R8      ;width by row index
        ADD     R9,     R9,     R4      ;column index + offset
        LDR     R0,     [R6,    R9,     LSL #2]     ;gets pixel at address
        
        AND     R0,     R0,     R10
        STR     R0,     [R6,    R9,     LSL #2]     ;replaces old pixel
        ADD     R4,     R4,     #1
        b       rowCheck
finishFilter
        LDMFD   SP!,     {PC,R4-R10}


picToGrey
;converts entire pic to greyscale
;R0=adress,     R1=pic height R2=pic width
        STMFD   SP!,     {LR,R4-R9}
        LDR     R4,=0   ;column index
        LDR     R5,=0   ;row index
        MOV     R6,     R0
        MOV     R7,     R1
        MOV     R8,     R2      ;local copies of parameters
loop
        CMP     R4,     R8      
        BLO     innerloop
;increment row index and reset column when equal to width
        ADD     R5,     R5,     #1
        LDR     R4, =0
innerloop
        CMP     R5,     R7      
        BHS     finishGreying
;end if row index = height as indexes are 0 indexed
        MUL     R9,     R5,     R8      ;width by row index
        ADD     R9,     R9,     R4      ;column index + offset
        LDR     R0,     [R6,    R9,     LSL #2]     ;gets pixel at address
       
        BL      convertPixelGray
        STR     R0,     [R6,    R9,     LSL #2]     ;replaces old pixel
        ADD     R4,     R4,     #1
        b       loop
finishGreying
        LDMFD   SP!,     {PC,R4-R9}
        

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

edgeDetection
;uses sobel edge detection on grayscale image
;parameters row index  column index Memory adress row length column length
;return pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
             
        STMFD   SP!,     {R4-R8}        ;push parameters
;make x kernel        
        LDR     R10,=0;sum x
        BL      getPixelUL
        BL      getPicBlue
        ADD     R10,     R0,     R10
        BL      getPixelL
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #1     
        ADD     R10,     R0,     R10
        BL      getPixelBL
        BL      getPicBlue
        ADD     R10,     R0,     R10
        
        BL      getPixelUR
        BL      getPicBlue
        LDR     R1,=0
        SUB     R0,     R1,     R0
        ADD     R10,     R0,     R10
        BL      getPixelR
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #1
        LDR     R1,=0
        SUB     R0,     R1,     R0
        ADD     R10,     R0,     R10        
        BL      getPixelBR
        BL      getPicBlue
        LDR     R1,=0
        SUB     R0,     R1,     R0
        ADDS    R10,     R0,     R10
        BPL     positive
        SUB     R10,    R1,     R10     ;get abs if negative
positive         
;make y kernel  
        LDR     R11,=0;sum y
        BL      getPixelUL
        BL      getPicBlue
        ADD     R11,     R0,     R11
        BL      getPixelU
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #1     ;left pixel*2
        ADD     R11,     R0,     R11
        BL      getPixelUR
        BL      getPicBlue
        ADD     R11,     R0,     R11
        
        BL      getPixelBL
        BL      getPicBlue
        LDR     R1,=0
        SUB     R0,     R1,     R0
        ADD     R11,     R0,     R11
        BL      getPixelB
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #1
        LDR     R1,=0
        SUB     R0,     R1,     R0
        ADD     R11,     R1,     R11        
        BL      getPixelBR
        BL      getPicBlue
        LDR     R1,=0
        SUB     R0,     R1,     R0
        ADDS    R11,     R0,     R11
        BPL     absolute
        SUB     R11,    R1,     R11     ;get abs if negative
absolute
        ADD     R0,     R10,    R11
;to detect edge we need to combine the y and x components
;the approximation of sobel is to add the absolute value of both rather
;than combine the x and y using sqrt and squaring them
;this saves a lot of computing time because sqrt is not trivial in assembly
;and there are a lot of pixels
        
        CMP     R0,     #0x000000FF
        BLO     maxintensity  ;to set to max if greater than 255
        LDR     R0,=0x000000FF
maxintensity
;technically unecessary but better safe then sorry
        AND     R0,    R0,    #0x000000FF      ;clears any overflow
        MOV     R1,     R0
        MOV     R2,     R0
        BL      compositeColors
                           
        LDMFD   SP!,     {R4-R8}        ;pop parameters
        LDMFD   SP!,     {R4-R12,PC}
 
;used for noise reduction,we will only change intensity/luminosity
;smooths high frequency(drastic change in intensity) components
;technically not a great filter as it loses weak edges due to being linear
;however better than nothing I presume(unless we assume image has no noise)
gaussianBlur
;applies a gaussian blur on the pixel
;parameters row index  column index Memory adress row length column length
;return pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
        
;R4=column length R5= row length r6=mem address R7=column index R8=row index             
        STMFD   SP!,     {R4-R8}        ;push parameters
        LDR     R10,=0
        
        BL      getPixelUL
        BL      getPicBlue
        ADD     R10,    R10,    R0      ;ul*1
        BL      getPixelU
        BL      getPicBlue
        MOV     R0,     R0,      LSL     #1     ;u*2
        ADD     R10,    R10,    R0
        BL      getPixelUR
        BL      getPicBlue
        ADD     R10,    R10,    R0      ;ur*1
        
        BL      getPixelBL
        BL      getPicBlue
        ADD     R10,    R10,    R0      ;bl*1
        BL      getPixelBR
        BL      getPicBlue
        ADD     R10,    R10,    R0      ;br*1
        BL      getPixelB
        BL      getPicBlue
        MOV     R0,     R0,      LSL     #1     ;b*2
        ADD     R10,    R10,    R0
        
        BL      getPixelL
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #1      ;l*2
        ADD     R10,    R10,    R0
        BL      getPixelR
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #1      ;r*2
        ADD     R10,    R10,    R0
        
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        BL      getPicBlue
        MOV     R0,     R0,     LSL     #2      ;4*current pixel
        
        ADD     R10,    R10,    R0
        MOV     R10,    R10,    LSR     #4      ;divide by 16
        
        CMP     R10,     #0x000000FF
        BLO     notmaxgrey  ;to set to max if greater than 255
        LDR     R10,=0x000000FF
notmaxgrey
;technically unecessary but better safe then sorry
        AND     R10,    R10,    #0x000000FF      ;clears any overflow
        
        MOV     R0,     R10
        MOV     R1,     R10
        MOV     R2,     R10
        BL      compositeColors
        
        LDMFD   SP!,     {R4-R8}        ;pop parameters
        LDMFD   SP!,     {R4-R12,PC}
        
;used to emphasize edges and de-emphasise noise
normalise
;normalises the pixels of the image given a max and a min
;parameters memory adress row length column length max min
;returns void
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R8=mem R7=row length R6=column length R5=min R4=max
;R0 = column index      R1 = row index
        SUB     R1,     R4,     R5      ;max-min
        CMP     R1,     #0      ;range of 0 cannot be mapped to new range
        BLS     finishnorm
        LDR     R0,=255 ;new normalised range
        BL      division
        MOV     R10,     R0      ;ratio
        
        LDR     R0,=0
        LDR     R1,=0
        
pass
        CMP     R0,     R7      
        BLO     samerow
;increment row index and reset column when equal to width
        ADD     R1,     R1,     #1
        LDR     R0, =0
samerow
        CMP     R1,     R6     
        BHS     finishnorm
;end if row index = height as indexes are 0 indexed
        MUL     R2,     R1,     R7      ;row length by row index
        ADD     R2,     R2,     R0      ;column index + offset
        LDR     R9,     [R8,    R2,     LSL #2]         ;gets pixel at address
        
        STMFD   SP!,     {R0-R2} ;push
        MOV     R0,     R9      ;move value
        BL      getPicBlue
        SUB     R0,     R0,     R5      ;pixel-min
        MUL     R0,     R10,     R0      ;*ratio
        CMP     R0,     #0x000000FF
        BLO     notoverrange  ;to set to max if greater than 255
        LDR     R0,=0x000000FF
notoverrange
        MOV     R1,     R0
        MOV     R2,     R0
        BL      compositeColors
        MOV     R9,     R0
        LDMFD   SP!,     {R0-R2} ;pop
        
        STR     R9,     [R8,    R2,     LSL #2]         ;stores pixel at address
        
        ADD     R0,     R0,     #1      ;increment column index
        b       pass
finishnorm        
        LDMFD   SP!,     {R4-R12,PC}
        
;due to boolean checking on assembly requiring many instructions
;and labels and due to the already large size of my code
;I decided to take easy way for ease and not clone symmetrically opp pixel
        
       
getPixelUL
;gets upper left pixel or clones bottom otherwise
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index

        CMP     R8,     #1      ;is row index less than 0
        BLO     godown
        
        CMP     R7,     #1      ;is column index<0
        BLO     godown
        
        SUB     R7,     R7,     #1
        SUB     R8,     R8,     #1
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
godown
        
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelB
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}

getPixelBR
;gets bottom right pixel or clones up otherwise
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index

        ADD     R0,     R8,     #1      
        CMP     R0,     R4              ;is row index>=column length/height 
        BHS     goup
        ADD     R0,     R7,     #1
        CMP     R0,     R5              ;is column index>=row length/width  
        BHS     goup
        
        ADD     R8,     R8,     #1
        ADD     R7,     R7,     #1
        
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
goup
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelU
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}

getPixelUR
;gets upper right pixel or clones bottom
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index

        CMP     R8,     #1      ;is row index less than 0
        BLO     copydown
        ADD     R0,     R7,     #1
        CMP     R0,     R5             ;is column index>=row length/width 
        BHS     copydown
        
        SUB     R8,     R8,     #1
        ADD     R7,     R7,     #1
        
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
copydown
        STMFD   SP!,    {R4-R8} ;push parameters
        BL      getPixelB
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}
        
getPixelBL
;gets bottom left pixel or clones up
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index
        CMP     R7,     #1      ;to move back a column
        BLO     copyup      ;if column index<0
        
        ADD     R0,     R8,     #1      ;to move down a row
        CMP     R0,     R4      ;;is row index>=column length/height
        BHS     copyup
        
        SUB     R7,     R7,     #1
        ADD     R8,     R8,     #1
     
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
copyup
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelU
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}
        
getPixelU
;gets pixel above current pixel or clones bottom one
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index  
        CMP     R8,     #1      ;move back a row
        BLO     bottom  ;if <0 clone
        
        SUB     R8,     R8,     #1
     
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
bottom
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelB
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}
        
getPixelB
;gets pixel below current pixel or clones upper one
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index  
        ADD     R0,     R8,     #1      ;move down a row
        CMP     R0,   R4        ;if row>=column length/height  
        BHS     upper  ;if <0 clone
        
        ADD     R8,     R8,     #1
     
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
upper
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelU
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}
        
getPixelL
;gets pixel left of current pixel or clones one on right
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index  
        CMP     R7,     #1      ;move back a column 
        BLO     right  ;if <0 clone
        
        SUB     R7,     R7,     #1
     
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
right
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelR
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
        LDMFD   SP!,     {PC,R4-R12}
        
getPixelR
;gets pixel right of current pixel or clones one on left
;parameters     row index  column index  memory adress row length column length
;returns pixel R0
        STMFD   SP!,     {LR,R12}
        ADD     R12,    SP,    #8
        STMFD   SP!,     {R4-R11}
        LDMFD   R12,     {R4-R8}
;R4=column length R5= row length r6=mem address R7=column index R8=row index  
        ADD     R0,     R7,     #1      ;move forward a column 
        CMP     R0,     R5              ;compare it vs width
        BHS     left  ;if <0 clone
        
        ADD     R7,     R7,     #1
     
        MUL     R0,     R5,     R8      ;row length by row index
        ADD     R0,     R0,     R7     ;column index + offset
        LDR     R0,     [R6,    R0,     LSL #2]         ;gets pixel at address
        LDMFD   SP!,     {PC,R4-R12}
left
        STMFD   SP!,     {R4-R8} ;push parameters
        BL      getPixelL
        LDMFD   SP!,     {R4-R8} ;pop parameters
        
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
        ORR     R0,     R0,     #0x00FF0000     ;scrambles red of color
        AND     R0,     R1,     R0      ;final color
        BX      LR
        
swapGreen
;swaps the green component of a pixel with a specified value
;parameters     R0=color        R1=green component
;returns R0 as new pixel
        AND     R1,     R1,     #0x000000FF      ;prevents component over 255
        MOV     R1,     R1,     LSL     #8     ;green in second pos
        ORR     R0,     R0,     #0x0000FF00     ;scrambles green of color
        AND     R0,     R1,     R0      ;final color
        BX      LR
        
swapBlue
;swaps the blue component of a pixel with a specified value
;parameters     R0=color        R1=blue component
;returns R0 as new pixel
        AND     R1,     R1,     #0x000000FF      ;prevents component over 255
        ORR     R0,     R0,     #0x000000FF     ;scrambles blue of color
        AND     R0,     R1,     R0      ;final color
        BX      LR

convertPixelGray
;converts a pixel into its grayscale version 
;based on apporiximation of colorimetry formula
;.2*R + .7*G + .1B
;parameters R0=pixel
;returns R0=gray pixel
        STMFD   SP!,     {LR,R4}
        MOV     R4,     R0      ;to make copy of pixel
        
        BL      getPicRed
        LDR     R1,=5   ;to get 1/5 of red value
        BL      division
        STR     R0,     [SP,    #-4]!   ;pushes value to stack
        MOV     R0,     R4      ;to get original pixel
        
        BL      getPicGreen
        LDR     R1,=7
        MUL     R0,     R1,     R0     
        LDR     R1,=10   ;to get 7/10 of red value
        BL      division
        STR     R0,     [SP,    #-4]!   ;pushes value to stack
        MOV     R0,     R4      ;to get original pixel
        
        BL      getPicBlue
        LDR     R1,=10   ;to get 1/10 of red value
        BL      division
        
        LDR     R1,     [SP],    #4  ;pops green luminance value
        ADD     R0,     R0,     R1
        LDR     R1,     [SP],    #4
        ADD     R0,     R1,     R0      ;combines all three luminances
        AND     R0,     R0,     #0x000000FF      ;to give max = 255
        MOV     R1,     R0
        MOV     R2,     R0
        BL      compositeColors
        LDMFD   SP!,     {PC,R4}
        
        
        
        

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
        b       wh
enddiv
        MOV     R0,     R5
        LDMFD   SP!,     {PC,R4-R6}     ;end subroutine



	END	
                
             