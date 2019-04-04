/* -- create.s -- */
	.text
	.global _start
_start:
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

/* lseek */
	mov r0, r4 @ file descriptor
	mov r1, #0 @ position
	mov r2, #0 @ seek_set
	mov r7, #19
	svc 0
/* simple read */
	mov r0,	r4 @ file descriptor
	ldr r1, =input
	mov r2, #5
	mov r7, #3
	svc 0

/* Show Input String */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =input @ input string
	mov r2, #5
	@mov r2, #(ip_end-input) @ len
	mov r7, #4
	svc 0

/* Close File */
	mov r7, #6 @ close
	svc 0
	mov r0, r4 @ return file descriptor

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
newfile: .asciz "/home/pi/Documents/Computer_Organize_And_Assembly/lab8ComOr/testFile/newFile.txt"
input: .asciz "Input a string: \n"
ip_end:
test:	.asciz	"1234"
buffer: .byte 100
/*versus
test after buffer is diferrent*/
