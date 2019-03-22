.data
testval:
	.float 0.5
	.float 0.25
	.float -1.0
	.float 100.0
	.float 1234.567
	.float -9876.543
	.float 7070.7070
	.float 3.3333
	.float 694.3e-9
	.float 6.0221e2
	.float 6.0221e23
	.word 0 @ end of list
minus_symbol: .asciz "-"
dot_symbol: .asciz "."
print_newline: .asciz "\n"
print_type: .asciz "%d"
.text
.global main
main:
	str lr, [sp, #-4]! @ stack return variable

	@store return variable
	ldr r2,=testval
	bl _print_float_value_init

	ldr pc, [sp], #4 @load return variable

_print_float_value_init:
	str lr, [sp, #-4]! @ stack return variable
	ldr r3,[r2],#4
	cmp r3,#0
	ldreq pc, [sp], #4 @load return variable 
	bl _print_float_value
	ldr r0, =print_newline
	stmdb sp!,{r2,r3}
	bl printf
	ldmia sp!,{r3,r2}
	bl _print_float_value_init
	ldr pc, [sp], #4 @load return variable

_print_float_value:	
	str lr, [sp, #-4]! @ stack return variable
	@check sign in thee first bit and print out
	and r4, r3, #0x80000000
	cmp r4, #0x80000000
	stmdb sp!,{r2,r3}
	ldr r0, =minus_symbol
	bleq printf
	ldmia sp!,{r3,r2}
	
	@get shift value
	mov r4, r3, lsl #1
	mov r4, r4, lsr #24
	sub r4, r4, #127
	
	@get value bofore dot
	mov r3, r3, lsl #8
	orr r3, r3, #0x80000000
	mov r5, #31
	sub r5, r5, r4 
	cmp r5, #32
	add r4,r4,#1
	movlt r5, r3, lsr r5
	movlt r3, r3, lsl r4
	movge r5, #0
	movge r6, #-1
	mulge r7, r6, r4
	movge r3, r3, lsr r7

	stmdb sp!,{r2,r3}
	mov r1,r5
	ldr r0, =print_type
	bl printf
	ldr r0, =dot_symbol
	bl printf
	ldmia sp!,{r3,r2}

	bl _find_after_dot

	ldr pc, [sp], #4 @load return variable
_find_after_dot:
	str lr, [sp, #-4]! @ stack return variable
	@get value after dot
	mov r5, #10
	umull r3, r7, r5, r3
	mov r1, r7
	ldr r0, =print_type
	stmdb sp!,{r2,r3}
	bl printf
	ldmia sp!,{r3,r2}
	cmp r3,#0
	blne _find_after_dot
	ldr pc, [sp], #4 @load return variable
