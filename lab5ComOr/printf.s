/* printf.s */
		.data
		.balign 4
message1:	.asciz	"Please enter a number : "

		.balign 4
message2:	.asciz	"I read the number %d\n"

		.balign 4
scan_pattern:	.asciz	"%d"

		.balign	4
number_read:	.word	0

		.balign	4
return:		.word	0

		.text
		.global main
		.global printf
		.global scanf
main:
		ldr	r1, =return	@ r1=&return
		str	lr, [r1]	@ *r1=lr

		ldr	r0, =message1	@ print message1
		bl	printf

		ldr	r0, =scan_pattern @ input via scanf
		ldr	r1, =number_read
		bl	scanf

		ldr	r0, =message2
		ldr	r1, =number_read
		ldr	r1, [r1]	@ r1 <- *r1
		bl	printf
		
		ldr	r0, =number_read
		ldr	r0, [r0]

		ldr	lr, =return
		ldr	lr, [lr]
		bx	lr
