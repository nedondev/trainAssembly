/* -- create.s -- */
	.text
	.global _start
_start:
	push {r4, lr}
	bl search
	pop {r4, lr}
	b exit
search:
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
input: .asciz "Input a ID for search: "
ip_end:
search_err: .asciz "NOTFOUND!!\n"
sher_end:
keyword: .asciz "0123456789"
file_buffer: .asciz "0123456789"
test:	.asciz	"1234"
buffer: .byte 100
/*versus
test after buffer is diferrent*/
