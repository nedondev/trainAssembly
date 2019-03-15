/* printf.s */
		.data
		.balign 4
message1:	.asciz	"Please enter text : "

		.balign 4
message2:	.asciz	"Encrypted text: %s\n"

		.balign 4
scan_pattern:	.asciz	"%s"

		.balign	4
string_read:	.zero	81
		
		.balign 4
encrypt:	.asciz "AIWGZVFUTHSOJLKDECNMRQPYXBAIWGZ"

		.balign	4
return:		.word	0

		.text
		.global main
		.global printf
		.global scanf
main:
		ldr	r1, =return	@ r1=&return
		str	lr, [r1]	@ *r1=lr
		stm	sp!,{r4-r13}
		bl	input
		bl	process
		bl	output
		add	sp,sp,#36
		bl	exit
input:
		str	lr,[sp, #-4]!
		ldr	r0, =message1	@ print message1
		bl	printf

		ldr	r0, =scan_pattern @ input via scanf
		ldr	r1, =string_read
		bl	scanf
		ldr	pc,[sp],#4
process:
		str	lr,[sp, #-4]!
		ldr r0,=string_read
		bl process_inside
		ldr	pc,[sp],#4
process_inside:
		str	lr,[sp, #-4]!
		ldrb r2, [r0], #1
		cmp r2,#0
		ldreq	pc,[sp],#4
		ldr r1,=encrypt
		bl process_inside2
		bl process_inside
		ldr	pc,[sp],#4
		
process_inside2:
		str	lr,[sp, #-4]!
		ldrb r3,[r1], #1
		cmp r3,#0
		ldreq	pc,[sp],#4
		cmp r3,r2
		ldreqb r3,[r1, #4] @add 4 cause pointer have been add 1
		streqb r3,[r0, #-1] @sub 1 cause pointer have been add 1
		ldreq	pc,[sp],#4
		bl process_inside2
		ldr	pc,[sp],#4
		
output:
		str	lr,[sp, #-4]!
		ldr	r0, =message2
		ldr	r1, =string_read
		bl	printf
		ldr	pc,[sp],#4

exit:
		ldr	lr, =return
		ldr	lr, [lr]
		bx	lr
