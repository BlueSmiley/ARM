	AREA	StringReverse, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =strSrc
	LDR	R2, =strDst

stop	B	stop


	AREA	TestData, DATA, READWRITE

strSrc	DCB	"hello",0
strDst	SPACE	128

	END
