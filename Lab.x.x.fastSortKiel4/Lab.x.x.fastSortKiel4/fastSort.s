	AREA	ArrayMove, CODE, READONLY
	IMPORT	main
	EXPORT	start

;plan : need three times initial memory 
;one stores indexes in order of size
;other stores the numbers greater than number that replaced them in a seperate array
;at same as index as initial
;put the initial index in center of second memory
;this is min and max at start size = 1
;get next number and check if bigger or smaller and place index before or after in memory
;increment size of thing every time
;always move next number half of the size of array after checking if bigger 
;or smaller than min and max
;if uneven do one more check after in opposite direction of last check

start
	LDR	R0, =array
	LDR	R1, =N	

	BL fastSORT
	
stop	B	stop

	;fastSORT - sorts the numbers in the array (passed in) in assending order (low to high) 
	;Params - R0 the start address of an integer array
	;		- R1 the number of elements in it
	;Return - nothing (memory affected)
fastSORT
        
	;
	;your subroutine here
	;
        
	
	
	AREA	TestArray, DATA, READWRITE
;not a great way to put 1000 numbers in memory, but I want everyone's to be identical
;from the good people at random.org
N	equ	1000
array	DCD	34, 77, 81, 96, 81, 81, 63, 69, 76, 40, 21, 56, 18, 85, 64, 33, 30, 56, 76, 67, 9, 47, 100, 1, 95, 19, 47, 91, 52, 25, 22, 97, 100, 33, 46, 26, 82, 59, 3, 68, 67, 36, 17, 31, 60, 12, 20, 16, 7, 31, 95, 50, 73, 33, 80, 53, 34, 5, 57, 39, 62, 96, 9, 2, 64, 50, 66, 25, 6, 77, 31, 86, 64, 31, 27, 71, 89, 81, 73, 21, 45, 54, 90, 97, 80, 43, 89, 56, 18, 79, 21, 48, 86, 30, 31, 78, 64, 25, 33, 22, 91, 53, 13, 31, 90, 1, 3, 78, 11, 68, 60, 22, 77, 15, 98, 80, 53, 12, 73, 64, 32, 22, 19, 72, 38, 82, 39, 88, 1, 48, 9, 67, 38, 73, 85, 10, 97, 99, 22, 90, 47, 63, 34, 90, 24, 65, 48, 20, 26, 46, 85, 57, 91, 99, 39, 83, 58, 92, 35, 28, 56, 25, 81, 11, 7, 80, 78, 91, 9, 34, 16, 69, 57, 51, 40, 97, 82, 84, 36, 11, 28, 96, 47, 3, 14, 15, 22, 21, 56, 51, 49, 14, 83, 16, 54, 33, 45, 14, 75, 90, 5, 24, 5, 43, 51, 5, 57, 90, 50, 39, 50, 10, 47, 90, 47, 92, 100, 93, 60, 81, 41, 49, 48, 73, 36, 89, 97, 88, 58, 73, 54, 36, 99, 24, 11, 72, 64, 93, 54, 98, 85, 37, 67, 38, 38, 47, 12, 90, 12, 43, 9, 94, 41, 56, 6, 49, 86, 5, 11, 17, 97, 97, 38, 51, 64, 38, 96, 49, 98, 53, 74, 3, 68, 23, 48, 56, 84, 26, 57, 56, 83, 46, 10, 56, 10, 28, 13, 23, 83, 32, 79, 67, 81, 79, 67, 96, 13, 2, 9, 71, 94, 4, 87, 22, 84, 79, 22, 55, 8, 7, 12, 69, 60, 95, 60, 97, 83, 22, 91, 4, 68, 45, 82, 32, 24, 28, 20, 64, 11, 41, 56, 50, 91, 84, 56, 92, 94, 34, 4, 57, 26, 70, 36, 54, 94, 33, 70, 46, 86, 11, 65, 11, 87, 20, 19, 79, 18, 87, 56, 39, 84, 1, 60, 21, 51, 72, 13, 6, 46, 44, 55, 16, 11, 74, 82, 81, 96, 40, 78, 65, 65, 39, 87, 37, 63, 78, 79, 84, 9, 94, 93, 56, 16, 98, 79, 92, 37, 92, 99, 51, 76, 28, 17, 44, 92, 15, 10, 9, 49, 30, 12, 38, 97, 35, 9, 76, 13, 79, 49, 26, 12, 64, 19, 98, 4, 47, 17, 54, 14, 48, 87, 36, 90, 50, 61, 89, 68, 23, 46, 31, 61, 54, 34, 65, 87, 3, 71, 23, 90, 86, 88, 100, 59, 70, 79, 66, 73, 95, 71, 19, 58, 67, 16, 86, 80, 49, 30, 66, 26, 58, 100, 38, 79, 4, 55, 64, 37, 65, 90, 69, 54, 37, 63, 55, 41, 46, 3, 61, 12, 57, 55, 13, 99, 40, 9, 31, 62, 70, 34, 79, 49, 84, 61, 34, 47, 74, 100, 76, 30, 66, 17, 100, 78, 21, 40, 46, 38, 72, 51, 41, 77, 86, 87, 51, 48, 14, 64, 37, 27, 28, 16, 84, 64, 95, 21, 75, 81, 84, 94, 80, 44, 54, 45, 54, 12, 89, 87, 93, 68, 23, 19, 16, 7, 44, 81, 85, 2, 6, 80, 33, 15, 42, 26, 89, 97, 2, 30, 83, 68, 81, 71, 100, 51, 30, 48, 81, 37, 27, 50, 28, 44, 9, 81, 60, 81, 36, 7, 76, 90, 17, 92, 78, 1, 1, 84, 20, 5, 92, 83, 65, 22, 34, 48, 67, 82, 12, 60, 92, 26, 17, 52, 64, 63, 99, 44, 61, 81, 16, 17, 7, 45, 46, 97, 66, 42, 37, 100, 51, 50, 85, 43, 66, 23, 97, 14, 2, 46, 87, 82, 47, 31, 73, 88, 10, 81, 30, 24, 56, 72, 89, 77, 26, 69, 42, 35, 53, 12, 88, 80, 26, 12, 88, 32, 38, 50, 86, 21, 71, 10, 52, 67, 35, 78, 21, 82, 92, 26, 12, 15, 43, 71, 61, 62, 31, 44, 10, 66, 98, 12, 58, 27, 42, 84, 69, 8, 89, 97, 97, 97, 10, 79, 84, 65, 86, 8, 2, 95, 75, 12, 89, 55, 3, 23, 15, 45, 35, 39, 13, 46, 35, 32, 22, 45, 67, 47, 30, 61, 35, 10, 92, 62, 7, 15, 73, 35, 46, 79, 86, 96, 39, 36, 56, 24, 38, 61, 77, 68, 30, 59, 13, 56, 26, 22, 86, 67, 59, 59, 62, 11, 48, 5, 24, 95, 47, 83, 41, 39, 68, 52, 80, 67, 27, 44, 35, 70, 37, 76, 59, 25, 49, 29, 85, 75, 15, 70, 39, 51, 39, 8, 88, 84, 16, 10, 3, 73, 84, 98, 49, 20, 98, 83, 23, 95, 30, 79, 57, 52, 33, 70, 23, 47, 1, 5, 22, 51, 67, 46, 11, 47, 84, 11, 40, 79, 29, 39, 26, 87, 29, 100, 79, 88, 49, 16, 27, 94, 58, 78, 34, 38, 3, 9, 46, 71, 81, 27, 71, 75, 58, 12, 27, 20, 86, 39, 43, 1, 34, 40, 74, 9, 73, 8, 38, 39, 4, 80, 93, 36, 38, 97, 61, 81, 91, 5, 76, 15, 55, 76, 96, 79, 83, 74, 54, 5, 68, 7, 33, 81, 56, 77, 29, 7, 58, 87, 38, 14, 64, 3, 88, 67, 73, 50, 16, 69, 48, 42, 25, 3, 12, 72, 50, 93, 6, 96, 80, 5, 70, 66, 26, 35, 73, 90, 40, 70, 68, 98, 90, 95, 48, 40, 44, 38, 36, 64, 9, 53, 22, 15, 84, 81, 34, 35, 34, 56, 73, 57, 92, 15, 60, 90, 88, 63, 12, 25, 3, 7, 59, 99, 52, 13, 12, 9, 80, 50, 42, 94, 78, 63, 86, 25, 17, 1, 9, 49, 97, 20, 93, 97, 24, 70, 50, 43, 28, 68, 20, 56, 9, 18, 64, 86, 87, 48, 13, 76, 34, 84, 71, 24, 42, 78, 59 		
	END	