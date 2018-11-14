	AREA	Unique, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR     R2, = VALUES
	LDR     R1, = COUNT
	LDR     R1, [R1]        ;R1 = number of elements in set
	LDR     R0, = 0         ;Assume its not a unique set
        LDR     R6, = 1         ;Since we start on the second value
        MOV     R4,     R2      ;Now R4 has same adress as R2
	b       loopstart       ;skip loop part
loop
	SUB	R1,	R1,	#1
	CMP	R1,	#1      ;check if theres only one value left in set
	BLS	unique
	ADD	R2,	R2,	#4
        MOV     R4,     R2      ;Now R4 has same adress as R2
	LDR	R6, = 1
loopstart
	ADD	R4,	R4,	#4      ;go to next memory address 
        LDR	R3,	[R2]            ;Load address value to R3
	LDR	R5,	[R4]            ;load next address value to R5 for comparison
	CMP	R5,	R3              
	BEQ	stop                    ;If both are equal end program
        ADD	R6,	R6,	#1      ;increment total count by one
	CMP	R6,	R1              ;check count vs remaining elements in set
	BHS	loop                    ;if same check next element in set
	b	loopstart               ;else check against next element in set        
unique
	LDR	R0,	= 1

stop	B	stop


	AREA	TestData, DATA, READWRITE

COUNT	DCD	10
VALUES	DCD	5, 2, 7, 4, 13, 6, 18, 8, 9, 12


	END
