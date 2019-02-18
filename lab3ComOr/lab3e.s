	.data
string: .ascii "input1: "
result_str: .ascii "0123456789"
input: .ascii "012345678901"
input1: .word 0
input2: .word 0
result: .word 0
write_size: .word 8

@int to string
str_result: .ascii "0000000000"
num: .word 0x3FFFFFF
divisor: .word 52123
dividend: .word 1000000000
str_size: .word 0
	
	.text
	.global _start
_start:
	@0x2d = '-' need implement in collect input
	@input
	bl _write
	bl _read @int
	bl _count_size
	ldr r1,=write_size
	str r0,[r1]
	bl _collect_input1
	@bl _write_in
	
	@b _exit

	ldr r1,=string
	mov r0,#0x32
	strb r0,[r1,#5]
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1]
	bl _write
	bl _read @int
	bl _count_size
	ldr r1,=write_size
	str r0,[r1]
	bl _collect_input2
	
	@add process
	ldr r1,=input1
	ldr r2,[r1]
	ldr r1,=input2
	ldr r3,[r1]
	add r0,r2,r3
	ldr r1,=result
	str r0,[r1]

	@show result
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1]
	bl _write_re
	bl _write
	
	@int to string
	ldr r1,=result
	ldr r0,[r1]
	ldr r1,=divisor
	str r0,[r1]
        bl _int_to_str
	bl _print_str_result
	b _exit
_collect_input1:
	sub sp, sp, #4
	str lr ,[sp,#0]
	ldr r4,=write_size
	ldr r3,[r4]
	mov r4,#1
	ldr r2,=input1
	mov r0, #0
	str r0,[r2]
	bl _collect_input_inside
	b _to_main4
_collect_input2:
	sub sp, sp, #4
	str lr ,[sp,#0]
	ldr r4,=write_size
	ldr r3,[r4]
	mov r4,#1
	ldr r2,=input2
	mov r0, #0
	str r0,[r2]
	bl _collect_input_inside
	b _to_main4
_collect_input_inside:
	sub sp, sp, #4
	str lr ,[sp,#0]
	cmp r3,#0
	ble _to_main4
	sub r3,r3,#1
	ldr r1,=input
	ldrb r0,[r1,r3]
	cmp r0,#0x2d @negative?
	sub r0, r0, #0x30
	mul r0, r4, r0
	ldr r1,[r2]
	add r0, r0, r1
	str r0,[r2]
	mov r5, #10
	mul r4,r5,r4
	bl _collect_input_inside
	b _to_main4
	
_count_size:
	sub sp, sp, #4
	str lr ,[sp,#0]
	mov r0, #0
	sub r0,r0,#1
	bl _check_new_line
	b _to_main4
	
_check_new_line:
	sub sp, sp, #4
	str lr ,[sp,#0]
	add r0, r0, #1
	ldr r1, =input
	ldrb r2, [r1,r0]
	cmp r2, #0xa @0xa = newline
	blne _check_new_line
	b _to_main4
_read:
	mov r7,#3
	mov r0,#0
	mov r2,#10
	ldr r1,=input
	swi 0
	bx lr
_write_in:
	ldr r1,=write_size
	ldr r2,[r1]
	mov r7,#4
	mov r0,#1
	ldr r1,=input
	swi 0
	bx lr
	
_write_re:
	ldr r1,=string
	mov r0,#0x52
	strb r0,[r1,#0]
	mov r0,#0x65
	strb r0,[r1,#1]
	mov r0,#0x73
	strb r0,[r1,#2]
	mov r0,#0x75
	strb r0,[r1,#3]
	mov r0,#0x6c
	strb r0,[r1,#4]
	mov r0,#0x74
	strb r0,[r1,#5]
	mov r0,#0x3a
	strb r0,[r1,#6]
	mov r0,#0x20
	strb r0,[r1,#7]
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1,#5]
	bx lr
	
_write:
	ldr r1,=write_size
	ldr r2,[r1]
	mov r7,#4
	mov r0,#1
	ldr r1,=string
	swi 0
	bx lr
_exit:
	mov r7,#1
	swi 0

@lab3ComOr
_print_str_result:
        ldr r1,=str_size
        ldr r2,[r1]
        mov r7, #4
        mov r0, #1
        @mov r2, #4
        ldr r1, =str_result
        swi 0
        bx lr
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
	ldr lr,[sp,#0]
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
