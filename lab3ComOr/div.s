@Bug operation can only process 8 bits value
.data
str1: .ascii "1234567890"
num: .word 0x3FFFFFF
a: .word 52
b: .word 23
.text
.global _start

_start:
	ldr r0, =a
	ldr r2, [r0]
	ldr r0, =b
	ldr r1, [r0] 
	bl _div
	@mov r0,r2
	b _exit
	ldr r1, =num
	add r0,r0,#48
	str r0, [r1]
	bl _print
	b _exit
_print:
	mov r7, #4
	mov r0, #1
	mov r2, #4
	ldr r1, =num
	swi 0
	bx lr
_exit:
	mov r7,#1
	swi 0
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
