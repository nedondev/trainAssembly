/* Constantes    */
.equ STDOUT, 1                         @ Linux output console
.equ EXIT,   1                         @ Linux syscall
.equ WRITE,  4                         @ Linux syscall
/* Initialized data */
.data
szCarriageReturn:  .asciz "\n"
arg_section:
.space 201 @defult_buffer
.space 201 @path_file_buffer
.space 201 @option buffer
.space 201 @option2 buffer
.space 201 @word buffer
.balign 4
filename: .space 201
.balign 4
option: .space 1
.balign 4
word: .space 71
.align 4

zero_argument: .asciz "No argument \n"
za_end:
.align 4
byte_option: .asciz "Byte Option \n"
bo_end:
.align 4
word_option: .asciz "Word Option \n"
wo_end:
.align 4
no_word_option: .asciz "No Word Option \n"
no_wo_end:
.align 4
input: .asciz "STDIN Input filename (optional: option): \n"
ip_end:
.align 4
errmsg: .asciz "open file failed"
errmsgend:
.align 4
/*UnInitialized data */
.bss 
.align 4
 
/*  code section */
.text
.global _start
_start:
	push {fp,lr}                        @ saves registers
	@mark option is empty at initial
	mov r1,#0
	ldr r2,=option
	strb r1,[r2]
	@mark word is empty when no word option at initial
	mov r1,#0
	ldr r2,=word
	strb r1,[r2]
	@mark mark filename empty at initial
	mov r1,#0
	ldr r2,=filename
	strb r1,[r2]

	@initial for get all arguments
	add r11,sp,#8                        @  fp <- start address
	ldr r4,[fp]                         @ number of Command line arguments
	sub r4,#1
	cmp r4,#0
	ble _zero_argument
	add r5,fp,#8                        @ first parameter address 
	mov r2, #0                          @ init loop counter
	ldr r6,=arg_section			@ get store argument address

get_all_argument:
	ldr r0,[r5,r2,lsl #2]               @ string address parameter
	bl _getArgMess                   @ display string
	add r2,#1                           @ increment counter
	cmp r2,r4                           @ number parameters 
	ldrge r1,=arg_section
	blt get_all_argument                @ loop

/*-w option 2 -b option 1*/
process:
	bl _openfile
	ldr  r6,=option
	ldrb r6, [r6]
	and r7,r6,#1
	cmp r7,#1
	bleq _byte_option
	and  r7,r6,#2
	cmp r7,#2
	bleq _word_option
	blne _no_word_option
exit:                                    @ standard end of the program
	mov r0, #0                          @ return code
	pop {fp,lr}                         @restaur  registers
	mov r7, #EXIT                       @ request to exit program
	swi 0                               @ perform the system call 

err: 	mov r4, r0
	mov r0, #1
	ldr r1, =errmsg
	mov r2, #(errmsgend-errmsg)
	mov r7, #4
	svc 0
	mov r0, r4
	b exit

_openfile:
	push {r1,r2,r7,lr}
	@open file
	ldr r0, =filename
	mov r1, #0x0 @readfile
	mov r2, #384 
	mov r7, #5
	svc 0

	cmp r0,#0
	/*push {r1}
	ldr r1,=arg_section
	add r0,#50
	strb r0,[r1]
	bl _test_print
	pop {r1}*/
	blt err

	@r0 return file descriptor
	pop {r1,r2,r7,lr}
	bx lr

_byte_option:
	push {r1,r2,r7}
        mov r0, #1 
        ldr r1, =byte_option @ input string
        mov r2, #(bo_end-byte_option) @ len
        mov r7, #4
        svc 0
	pop {r1,r2,r7}
	bx lr

_word_option:
	push {r1,r2,r6,r7}
	ldr r1,=word
	mov r2,#0
	get_all_word:
		ldrb r7,[r1,r2]
		cmp r7,#0
		add r2,r2,#1
		bne get_all_word
			
        mov r0, #1
        @ldr r1, =word_option @ input string
        @mov r2, #(wo_end-word_option) @ len
        mov r7, #4
        svc 0
	pop {r1,r2,r7}
	bx lr

_no_word_option:
	push {r1,r2,r7}
        mov r0, #1 
        ldr r1, =no_word_option@ input string
        mov r2, #(no_wo_end-no_word_option) @ len
        mov r7, #4
        svc 0
	pop {r1,r2,r7}
	bx lr

_zero_argument:
	push {r1,r2,r7,lr}
	
        mov r0, #1 
        ldr r1, =input @ input string
        mov r2, #(ip_end-input) @ len
        mov r7, #4
        svc 0
	
	/* simple read */
	mov r0,	#1
	ldr r1, =arg_section
	mov r2, #401
	mov r7, #3
	svc 0
	mov r5, r0
	cmp r0,#0
	popeq {r1,r2,r7,lr}
	beq err

	ldr r1, =arg_section
	mov r2,#0
	ldr r4,=filename
	get_filename:
		ldrb r3, [r1,r2]
		strb r3, [r4,r2]
		cmp r2, r5
		cmplt r3,#32
		add r2, r2, #1
		bgt get_filename
	mov r3, #0
	sub r2, r2,#1
	strb r3, [r4,r2]
	add r2, r2,#1

	cmp r2,r5
	bge no_option
	process_until_linefeed:
		ldr r4,=arg_section
		add r4, r4, r5
		@get word if word option is previous argument and word is empty
		ldr r7,=option
		ldrb r8,[r7]
		and r8,r8,#2
		cmp r8,#2
		ldreq r8,=word
		ldreqb r9,[r8]
		cmpeq r9,#0
		ldreq r4,=word

		mov r6,#0
		process_until_space:
			ldrb r3, [r1,r2]
			strb r3, [r4,r6]
			cmp r2, r5
			cmplt r3,#32
			add r2, r2, #1
			add r6, r6, #1
			bgt process_until_space
		mov r3, #0
		sub r6, r6,#1
		strb r3, [r4,r6]
		add r6, r6,#1
	
	/*	check option file only store in option
		find -b option and -w */
	
		ldrb r7,[r4,#0]
		ldrb r8,[r4,#1]
		ldrb r9,[r4,#2]
		/*check -b*/
		subs r7,r7,#45
		subeqs r8,r8,#98
		cmpeq r9,#0
		moveq r7,#1
		ldreq r4,=option
		ldreqb r9,[r4]
		orreq r7,r9,r7
		streqb r7,[r4]

		ldrb r7,[r4,#0]
		ldrb r8,[r4,#1]
		ldrb r9,[r4,#2]
		/*check -w*/
		subs r7,r7,#45
		subeqs r8,r8,#119
		cmpeq r9,#0
		moveq r7,#2
		ldreq r4,=option
		ldreqb r9,[r4]
		orreq r7,r9,r7
		streqb r7,[r4]

		cmp r2, r5
		bne process_until_linefeed
no_option:
	
	pop {r1,r2,r7,lr}
	b process
        
/* r0 contains the address of the message */
_getArgMess:
	push {r0,r1,r2,r7,r8,r9,lr}                          @ save  registres
	@get word if word option is previous argument and word is empty
	ldr r1,=option
	ldrb r7,[r1]
	and r7,r7,#2
	cmp r7,#2
	ldreq r2,=word
	ldreqb r8,[r2]
	cmpeq r8,#0
	mov r7,r6
	ldreq r6,=word
	@check if file name empty get filename
	ldr r2,=filename
	ldrb r8,[r2]
	cmp r8,#0
	ldreq r6,=filename
	mov r2,#0                                      @ counter length 
/* store argument to buffer*/
1:                       
	ldrb r1,[r0,r2] @ read octet start position + index 
	strb r1,[r6,r2]
	cmp r1,#0       @ if 0 its over 
	addne r2,r2,#1  @ else add 1 in the length 
	bne 1b		@and loop

	mov r6,r7 	@store address back to r6
	
	/*	check option file only store in option
	default_program name store in arg[0]
	find -b option and -w
	*/

	ldrb r7,[r6,#0]
	ldrb r8,[r6,#1]
	ldrb r9,[r6,#2]
	/*check -b*/
	subs r7,r7,#45
	subeqs r8,r8,#98
	cmpeq r9,#0
	moveq r7,#1
	ldreq r1,=option
	ldreqb r2,[r1]
	orreq r7,r2,r7
	streqb r7,[r1]
	beq _return_getArgMess

	ldrb r7,[r6,#0]
	ldrb r8,[r6,#1]
	ldrb r9,[r6,#2]
	/*check -w*/
	subs r7,r7,#45
	subeqs r8,r8,#119
	cmpeq r9,#0
	moveq r7,#2
	ldreq r1,=option
	ldreqb r2,[r1]
	orreq r7,r2,r7
	streqb r7,[r1]
	beq _return_getArgMess

_return_getArgMess:
	pop {r0,r1,r2,r7,r8,r9,lr}                           
	bx lr

_test_print:
	push {r0-r12,lr}
	mov r2, #1
	mov r0,#STDOUT                                 
	mov r7, #WRITE                                
	svc 0
	pop {r0-r12,pc}       
_enter:                                  
	push {r0-r12,lr}
	ldr r1,=szCarriageReturn
	mov r2, #1
	mov r0,#STDOUT                                 
	mov r7, #WRITE                                
	svc 0
	pop {r0-r12,pc}       
