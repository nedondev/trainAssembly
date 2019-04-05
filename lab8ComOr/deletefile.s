/* -- create.s -- */
	.text
	.global _start
_start:
	push {r4, lr}
/* Open file */
	ldr r0, =newfile
	mov r1, #0x42 @ create R/W
	mov r2, #384 @= 600 octal (me)
	mov r7, #5
	svc 0
	mov r4, r0 @Save fil_descriptor

/* Close file */
	mov r0, r4
	mov r7, #6
	svc 0
	mov r0, r4

/* Rename File */
	ldr r0, =newfile
	mov r7, #0xa @ rename
	svc 0

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
newfile: .asciz "/home/pi/Documents/Computer_Organize_And_Assembly/lab8ComOr/testFile/unname.txt"
buffer: .byte 100
