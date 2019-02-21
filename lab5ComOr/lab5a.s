/* printf.s */
		.data
		.balign 4
message1:	.asciz	"Please enter a number : "

		.balign 4
message2:	.asciz	"I read the number :%d\n"

		.balign 4
yes:	.asciz	"Leap Year \n"

		.balign 4
no:	.asciz	"Not Leap Year \n"

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
		@check Leap Year
		ldr	r1, =number_read
		ldr	r2, [r1]
		mov	r1, #400
		bl _div 
		cmp r2,#0
		bleq _print_yes
		blne _compare_100

		ldr	lr, =return
		ldr	lr, [lr]
		bx	lr

_compare_100:	
		sub sp,sp,#4
		str lr,[sp,#0]
		@check Leap Year
		ldr	r1, =number_read
		ldr	r2, [r1]
		mov	r1, #100
		bl _div 
		cmp r2,#0
		bleq _print_no
		blne _compare_4
		ldr lr, [sp,#0]
		add sp,sp,#4
		bx lr
_compare_4:	
		sub sp,sp,#4
		str lr,[sp,#0]
		@check Leap Year
		ldr	r1, =number_read
		ldr	r2, [r1]
		mov	r1, #4
		bl _div 
		cmp r2,#0
		bleq _print_yes
		blne _print_no
		ldr lr, [sp,#0]
		add sp,sp,#4
		bx lr
_print_yes:
		sub sp,sp,#4
		str lr,[sp,#0]
		ldr	r0, =yes
		ldr	r1, =number_read
		ldr	r1, [r1]	@ r1 <- *r1
		bl	printf
		ldr lr,[sp, #0]
		add sp,sp,#4
		bx lr
_print_no:
		sub sp,sp,#4
		str lr,[sp,#0]
		ldr	r0, =no
		ldr	r1, =number_read
		ldr	r1, [r1]	@ r1 <- *r1
		bl	printf
		ldr lr,[sp, #0]
		add sp,sp,#4
		bx lr
_div:
        sub sp, sp, #4
        str lr,[sp,#0]
        @initial
        mov r0, #0 @Quot
        mov r1,r1, lsl #1 @Divisor
        mov r1,r1, lsr #1 @Divisor
        mov r3,r1
        bl _sh_divisor_init
        mov r2,r2, lsl #1 @Remainder
        mov r2,r2, lsr #1 @Remainder
        bl _div_inside
        ldr lr, [sp,#0]
        add sp,sp,#4
        bx lr
_sh_divisor_init:
        sub sp,sp, #4
        str lr,[sp,#0]
        cmp r1,#0x3FFFFFFF
        bllt _sh_divisor
        ldr lr,[sp,#0]
        add sp,sp,#4
        bx lr
_sh_divisor:
        sub sp,sp, #4
        str lr,[sp,#0]
        mov r1,r1, lsl #1
        bl _sh_divisor_init
        ldr lr,[sp,#0]
        add sp,sp,#4
        bx lr
_div_inside:
        sub sp, sp, #8
        str r2,[sp,#4]
        str lr,[sp,#0]
        sub r2,r2,r1 @Rem = Rem -Div
        cmp r2,#0
        blge _div_ge
        bllt _div_lt
        mov r1, r1, lsr #1
        cmp r1, r3
        blge _div_inside
        ldr lr, [sp, #0]
        add sp, sp, #8
        bx lr
_div_ge:
        mov r0,r0, lsl #1
        add r0,r0, #1
        bx lr
_div_lt:
        ldr r2,[sp,#4]
        mov r0,r0, lsl #1
        bx lr

