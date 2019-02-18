@Bug operation can only process 8 bits value
.data
str_result: .ascii "0000000000"
num: .word 0x3FFFFFF
divisor: .word 52123
dividend: .word 1000000000
str_size: .word 0
.text
.global _start

_start:
	bl _int_to_str 
	@b _exit
	bl _print
	b _exit
_print:
	ldr r1,=str_size
	ldr r2,[r1]
	mov r7, #4
	mov r0, #1
	@mov r2, #4
	ldr r1, =str_result
	swi 0
	bx lr
_exit:
	mov r7,#1
	swi 0
_int_to_str: @initial int to string
	sub sp, sp, #8 
	str lr,[sp, #0]
	ldr r0, =divisor
	ldr r2, [r0]
	str r2,[sp,#4]
	ldr r0, =dividend
	ldr r1, [r0] 
	bl _check_initial_dividend
	b _to_main8
_check_initial_dividend:
	sub sp, sp, #12
	ldr r2,[sp, #16]
	str r1,[sp, #8] 
	str lr,[sp, #0]
	cmp r1,#0
	ble _to_main12
	cmp r1,r2
	bllt _loop_div
	str r2,[sp, #4] @store remainder 
	ldr r1,[sp, #8]
	mov r2, r1
	mov r1, #10
	bl _div
	mov r1, r0
	bl _check_initial_dividend
	b _to_main12
_loop_div:
	sub sp,sp,#4
	str lr,[sp, #0]
	bl _div
	ldr r3,=str_result
	add r0,r0,#0x30
	ldr r4,=str_size
	ldr r1,[r4]
	strb r0,[r3,r1]
	add r1,r1,#1
	str r1,[r4]
	b _to_main4
	
_to_main12:
	ldr lr,[sp, #0]
	add sp,sp,#12
	bx lr
_to_main8:
	ldr lr,[sp, #0]
	add sp,sp,#8
	bx lr
_to_main4:
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
