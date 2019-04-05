	.text
	.global _start
_start:
	push {r4, lr}
	bl delete
	pop {r4, lr}
	b exit
delete:
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
	ldr r1, =input @ input string
	mov r2, #(ip_end-input) @ len
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
	push {r0}
	blne show_del_result
	pop {r0}
	cmp r0,#-1
	push {r0}
	blne delete_process
	pop {r0}
	cmp r0,#-1
	bleq not_found

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

delete_process:
	push {r4, lr}
		
	mov r5, r0 @delete place
	
	/* Open (Create) File */
	ldr r0, =tempfile
	mov r1, #0x42 @ create R/W
	mov r2, #384 @ = 600 (octal)
	mov r7, #5 @ open (create)
	svc 0
	
	cmp r0, #-1 @ open error?
	beq err
 
	mov r3, r0 @ save file descriptor
		
	mov r12, #0
	read_and_write:
		cmp r12, r5
		addeq r12, r12, #90

		/* lseek */
		mov r0, r4 @ file descriptor
		mov r1, r12 @ position
		mov r2, #0 @ seek_set
		mov r7, #19
		svc 0

		/* simple read file*/
		mov r0,	r4 @ file descriptor
		ldr r1, =buffer
		mov r2, #90
		mov r7, #3
		svc 0

		mov r8,#90
		ldrb r0, [r1]
		cmp r0, #0
		moveq r8,#1
		/* simple write file */
		mov r0, r3
		ldr r1, =buffer @ input string	
		mov r2, r8
		mov r7, #4
		svc 0

		add r12, r12, #90
		ldrb r0, [r1]
		cmp r0, #0
		bne read_and_write

	/* Close file */
	mov r0, r3
	mov r7, #6
	svc 0

	/* Close file */
	mov r0, r4
	mov r7, #6
	svc 0
		
	/*unlink file*/
	ldr r0, =newfile
	mov r7, #0xa @ unlink (delete)
	svc 0

	/*rename temp to original*/
	ldr r0, =tempfile
	ldr r1, =newfile
	mov r7, #0x26 @ unlink (delete)
	svc 0

	pop {r4, pc}

show_del_result:
	push {r4, lr}

	add r3,r0,#0
	/* Show Delete  */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =del @ input string
	mov r2, #(del_end-del)
	mov r7, #4
	svc 0

	/* lseek */
	mov r0, r4 @ file descriptor
	mov r1, r3 @ position
	mov r2, #0 @ seek_set
	mov r7, #19
	svc 0

	/* simple read */
	mov r0,	r4 @ file descriptor
	ldr r1, =buffer
	mov r2, #90
	mov r7, #3
	svc 0

	/* Show Delete line */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =buffer @ input string
	mov r2, #90
	mov r7, #4
	svc 0
	
	pop {r4, pc}	

not_found:
	push {r4, lr}

	/* Close file */
	mov r0, r4
	mov r7, #6
	svc 0

	/* Show NOTFOUND!! */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =search_err@ input string
	mov r2, #(sher_end-search_err)
	mov r7, #4
	svc 0
	
	pop {r4, pc}	

exit: 	pop {r4, lr}
	mov r7, #1 @ exit
	svc 0

err: 	mov r4, r0
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
newfile: .asciz "/home/pi/Documents/Computer_Organize_And_Assembly/lab8ComOr/testFile/specificData.txt"
tempfile: .asciz "/home/pi/Documents/Computer_Organize_And_Assembly/lab8ComOr/testFile/tempspecificData.txt"
input: .asciz "Input a ID for delete: "
ip_end:
del: .asciz "Delete : "
del_end:
search_err: .asciz "NOTFOUND!!\n"
sher_end:
keyword: .asciz "0123456789"
file_buffer: .asciz "0123456789"
buffer: .byte 100
