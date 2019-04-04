/* Append file with specific Data 
One line only have
________________________________________
|Specific Data		| Size(byte) 	|
|-----------------------|---------------|
| ID 			| 8		|
| space(ASCII 32) 	| 1		|
| Content		| 80		|
| End line		| 1		|
-----------------------------------------
with end of file 1 byte
/*source code*/
	.text
	.global _start
_start:
	ldr r1,=return
	str lr, [r1]
	push {r4,r12, lr}
/*Show Input String */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =input_advice0 @ input string
	mov r2, #(ip0_end-input_advice0) @ len
	mov r7, #4
	svc 0

/* Read Input String */
	mov r0, #0 @ stdin – 0 = keyboard
	ldr r1, =function_buffer @ address of input buffer
	mov r2, #4 @ max. len. of input
	mov r7, #3 @ read
	svc 0

/*compare and branch to function*/
	ldrb r12,[r1]	
	cmp r12,#105 @i
	push {r12}
	bleq _append_data
	pop {r12}
	cmp r12,#115 @s
	push {r12}
	bleq _search_data
	pop {r12}
	cmp r12,#101 @e
	beq exit
	pop {r4, r12, lr}
	ldr r1,=return
	ldr lr, [r1]
	b _start

_append_data:
	push {r4,r12, lr}
/* Open (Create) File */
	ldr r0, =newfile
	mov r1, #0x42 @ create R/W
	mov r2, #384 @ = 600 (octal)
	mov r7, #5 @ open (create)
	svc 0
	cmp r0, #-1 @ open error?
	beq err
	mov r4, r0 @ save file descriptor 
        svc 0

/*Show Input String */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =input_advice1 @ input string
	mov r2, #(ip1_end-input_advice1) @ len
	mov r7, #4
	svc 0
/*Clear Buffer by fill it with space(ASCII 32)*/
	mov r12, #0
	ldr r1, =buffer @ address of input buffer
	mov r2, #32 @set space ascii
spacebuffer:
	strb r2, [r1,r12]
	add r12, r12, #1
	cmp r12, #89
	blt spacebuffer
	mov r2, #10 @set End line ascii
	strb r2, [r1,r12]
	add r12, r12, #1
	mov r2, #0 @set End file ascii
	strb r2, [r1,r12]
	

/* Read Input String */
	mov r0, #0 @ stdin – 0 = keyboard
	ldr r1, =buffer @ address of input buffer
	mov r2, #89 @ max. len. of input
	mov r7, #3 @ read
	svc 0
	mov r5, r0 @ save no. of character

	mov r2, #32 @set End line ascii
	sub r5, r5, #1
	strb r2, [r1,r5]

/* lseek */
	mov r0, r4 @ file descriptor
	mov r1, #-1 @ position
	mov r2, #2 @ seek_set
	mov r7, #19
	svc 0

/* Write to File */
	mov r0, r4 @ file descriptor
	ldr r1, =buffer @ address of buffer to write
	mov r2, #91 @ length of data to write
	mov r7, #4
	svc 0

/* Close File */ 
        mov r7, #6 @ close 
        svc 0 
        mov r0, r4 @ return file descriptor 

/* branch back */
	pop {r4, r12, pc}

_search_data:
	push {r4, lr}
	/* Open (Create) File */
	ldr r0, =newfile
	mov r1, #0x42 @ create R/W
	mov r2, #384 @ = 600 (octal)
	mov r7, #5 @ open (create)
	svc 0

	cmp r0, #-1 @ open error?
	beq err

	mov r4, r0 @ save file descriptor

	/* Show Input String */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =input_advice2 @ input string
	mov r2, #(ip2_end-input_advice2) @ len
	mov r7, #4
	svc 0

	/* input read */
	mov r0,	#1 @ monitor
	ldr r1, =keyword
	mov r2, #10
	mov r7, #3
	svc 0

	mov r3,#0
	bl fine_line

	cmp r0,#-1
	blne show_result
	bleq not_found

	/* Close File */
	mov r7, #6 @ close
	svc 0
	mov r0, r4 @ return file descriptor

	pop {r4, pc}

fine_line:
	push {r4, lr}

	/* lseek */
	mov r0, r4 @ file descriptor
	mov r1, r3 @ position
	mov r2, #0 @ seek_set
	mov r7, #19
	svc 0

	/* simple read */
	mov r0,	r4 @ file descriptor
	ldr r1, =file_buffer
	mov r2, #8
	mov r7, #3
	svc 0
	
	/* check eof */
	mov r0,#0
	ldr r1, =file_buffer
	ldrb r5, [r1, r0]
	cmp r5,#0
	moveq r0,#-1
	popeq {r4, pc}
	check_string:
		cmp r0,#8
		bge out_of_string
		ldr r1, =file_buffer
		ldrb r5, [r1, r0]
		ldr r1, =keyword
		ldrb r6, [r1, r0]
		cmp r5,r6
		movne r0,#-1
		bne out_of_string
		add r0, r0, #1
		b check_string
	out_of_string:
		cmp r0,#-1
		movne r0,r3
		popne {r4, pc}
	add r3,r3,#90
	bl fine_line
	pop {r4, pc}

show_result:
	push {r4, lr}

	/* lseek */
	add r3,r0,#9
	mov r0, r4 @ file descriptor
	mov r1, r3 @ position
	mov r2, #0 @ seek_set
	mov r7, #19
	svc 0

	/* simple read */
	mov r0,	r4 @ file descriptor
	ldr r1, =buffer
	mov r2, #81
	mov r7, #3
	svc 0

	/* Show Input String */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =buffer @ input string
	mov r2, #81
	mov r7, #4
	svc 0
	
	pop {r4, pc}	

not_found:
	push {r4, lr}

	/* Show NOTFOUND!! */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =search_err@ input string
	mov r2, #(sher_end-search_err)
	mov r7, #4
	svc 0
	
	pop {r4, pc}	
 
exit:   pop {r4, r12, lr} 
        mov r7, #1 @ exit 
        svc 0 
 
err:    mov r4, r0 
        mov r0, #1 
        ldr r1, =errmsg 
        mov r2, #(errmsgend-errmsg) 
        mov r7, #4 
        svc 0 
        mov r0, r4 
        b exit 
        .data 
errmsg: .asciz "create failed" 
errmsgend: 
newfile: .asciz "/home/pi/Documents/Computer_Organize_And_Assembly/lab8ComOr/testFile/specificData2.txt" 
input_advice2: .asciz "Input a ID for search: "
ip2_end:
input_advice1: .asciz "Input a string in form like (ID) (Content)\n Example: 62010000 John Smith\n: " 
ip1_end: 
input_advice0: .asciz "Select function (Case Sensitive) \n\ti (insert Data)\n\ts (search Data)\n\te (exit)\n : "
ip0_end: 
search_err: .asciz "NOTFOUND!!\n"
sher_end:
keyword: .asciz "0123456789"
file_buffer: .asciz "0123456789"
function_buffer: .asciz "0   "
return: .byte 0
buffer: .byte 100 
