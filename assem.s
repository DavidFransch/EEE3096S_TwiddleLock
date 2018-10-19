/*--------------------------------------------------------------*/
/*EEE3096S_Lab6_assembly.s					*/
/*Authors: Richard Powrie (PWRRIC001)				*/
/*         David Fransch (FRNDAV011)				*/
/* to run:(in command line)					*/
/* make								*/
/* ./assem ; echo $?						*/
/*--------------------------------------------------------------*/
@.func main		/*'main' is a function*/

/*--------------------------------------------------------------*/
/* --data section*/
/*--------------------------------------------------------------*/
.data

/* --arrays*/
my_array: .word 82, 70, 93, 77, 6, 23, 99, 70, 25, 30
.balign 4
len_my_array: .word 10		/*length of array = 10*/

/* --output strings*/
unsorted_message: 	.asciz "The unsorted array is:\n"
sorted_message: 	.asciz "The sorted array is:\n"
debug:			.asciz "debug: %d  "

/* --format strings for array print function*/
integer_printf: 	.asciz "%d "	/*print integer with space*/
newline_print: 		.asciz "\n"	/*print newline*/

/*--------------------------------------------------------------*/
/* --code section*/
/*--------------------------------------------------------------*/
.text



/*--------------------print_array function----------------------*/
print_array: /*paramters: r0 = address of integer array, r1 = num of elements */
	push {r4, r5, r6, lr} /*keep lr in the stack*/
/*--------------------------------------------------------------*/
	mov r4, r0			/*store address of array*/
	mov r5, r1			/*store number of elements*/
	mov r6, #0			/*counter: current print element*/
	
	/*---------while loop----------*/
	Lprint_array_condition:
	cmp r6, r5 /*check condition, loop while r6 != r5*/
	beq Lprint_array_end	/*if condition met, exit loop*/
		/*prepare call to printf*/
		ldr r0, =integer_printf
		ldr r1, [r4, r6, LSL #2]	/*r1 is address: r4+r6*4*/
		bl printf
		
		add r6, r6, #1			/*increment r6*/
		b Lprint_array_condition	/*loop back*/

	Lprint_array_end:
	/*-----------------------------*/

	/*prepare call to puts*/
	ldr r0, =newline_print
	bl puts					/*print new line*/
	
/*--------------------------------------------------------------*/
	pop {r4, r5, r6, lr}	/*restore lr from stack*/
	bx lr		/*exit program*/
/*-----------------exit print_array function--------------------*/





/*--------------------sort_array function-----------------------*/
sort_array: /*paramters: r0 = address of integer array, r1 = num of elements */
	push {r4, r5, r6, lr} /*keep lr in the stack*/
/*--------------------------------------------------------------*/
	mov r4, r0			/*store address of array*/
	mov r5, r1			/*store number of elements*/
	sub r5, r5, #1			/*subtract 1 from length to keep loops in bounds*/

	mov r6, #0			/*counter1: outer loop counter*/
	/*---------while loop 1--------*/
	Lsort_array_condition1:
	cmp r6, r5 /*check condition, loop while r6 != r5*/
	beq Lsort_array_end1	/*if condition met, exit loop*/


		mov r7, #0			/*counter2: inner loop counter*/
		/*---------while loop 2--------*/
		Lsort_array_condition2:
		cmp r7, r5 /*check condition, loop while r7 != r5*/
		beq Lsort_array_end2	/*if condition met, exit loop*/

			ldr r8, [r4, r7, LSL #2]/*load element at address r4 + r7x4*/
			add r9, r7, #1		/*increment r7 value for next element*/
			ldr r10,[r4, r9, LSL #2]/*load element at address r4 + r9x4*/

			/*----------if-then------------*/
			sort_if_eval: cmp r8, r10		/*if r8 > r10*/
			blt sort_else				/*branch to else if less than*/

				str r8, [r4, r9, LSL #2]	/*r8 stored in r10 address*/
				str r10, [r4, r7, LSL #2]	/*r10 stored in r8 address*/

				b end_of_sort_if
			/*-------------else------------*/
			sort_else: 				/*if r10 > r8*/

				str r8, [r4, r7, LSL #2]	/*r8 stored in r8 address*/
				str r10, [r4, r9, LSL #2]	/*r10 stored in r10 address*/

			end_of_sort_if:
			/*-----------------------------*/
		
			add r7, r7, #1			/*increment r7*/
			b Lsort_array_condition2	/*loop back*/

		Lsort_array_end2:
		/*-----------------------------*/

		add r6, r6, #1			/*increment r6*/
		b Lsort_array_condition1	/*loop back*/

	Lsort_array_end1:
	/*-----------------------------*/

	/*prepare call to puts*/
	ldr r0, =newline_print
	bl puts					/*print new line*/
	
/*--------------------------------------------------------------*/
	pop {r4, r5, r6, lr}	/*restore lr from stack*/
	bx lr		/*exit program*/
/*-----------------exit sort_array function---------------------*/






/*-------------------------main function------------------------*/
.global main
main:			
	push {lr} /*keep lr in the stack*/
/*--------------------------------------------------------------*/
	/*prepare to print "unsorted array"*/
	ldr r0, =unsorted_message
	bl puts
	/*prepare call to print_array*/
	ldr r0, =my_array
	ldr r1, =len_my_array
	ldr r1, [r1]
	bl print_array
	
	/*prepare call to sort_array*/
	ldr r0, =my_array
	ldr r1, =len_my_array
	ldr r1, [r1]
	bl sort_array

	/*prepare to print "sorted array"*/
	ldr r0, =sorted_message
	bl puts
	/*prepare call to print_array*/
	ldr r0, =my_array
	ldr r1, =len_my_array
	ldr r1, [r1]
	bl print_array

/*--------------------------------------------------------------*/
	mov r0, #0
	pop {lr}	/*restore lr from stack*/
	bx lr		/*exit program*/
/*-----------------------exit main function---------------------*/



/*---------external------------*/
.global puts
.global printf
/*--------------------------------------------------------------*/