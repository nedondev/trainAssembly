.data
num: .word 4
	.global _start
_start:
	ldr r0, addr_num
	mov r1, #50
	mov r2, #60
	add r3, r2, r1
	cmp r3,#100
	blge _print3
	bl _print_digit
	b _exit
_print3:
	sub r3,r3, #100
	sub sp,sp, #4
	str lr,[sp,#0]
	mov r1,#1
	add r1,r1,#48
	str r1,[r0]
	bl _print_digit
	ldr lr,[sp,#0]
	add sp,sp,#4
	bx lr
_print_digit:
	mov r7,#4
	ldr r1,addr_num
	mov r0,#1
	mov r2,#1
	swi 0
	bx lr
	
_exit:
	mov r7,#1
	swi 0
addr_num:	.word num
