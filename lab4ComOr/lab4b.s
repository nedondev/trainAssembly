	.data
string: .ascii "input1: "
input1: .ascii "0123456789012345678901234567890123456789"
input2: .ascii "0123456789012345678901234567890123456789"
write_size: .word 8
write_size1: .word 8
write_size2: .word 8
	
	.text
	.global _start
_start:
	@0x2d = '-' need implement in collect input
	@input
	bl _write
	ldr r1,=input1
	bl _read @int
	bl _count_size1
	ldr r1,=write_size1
	str r0,[r1]
	ldr r1,=write_size1
	ldr r2,[r1]
	ldr r1,=input1
	@bl _write_in

	ldr r1,=string
	mov r0,#0x32
	strb r0,[r1,#5]
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1]
	bl _write
	ldr r1,=input2
	bl _read @int
	bl _count_size2
	ldr r1,=write_size2
	str r0,[r1]
	ldr r1,=write_size2
	ldr r2,[r1]
	ldr r1,=input2
	@bl _write_in
	
	@check in String
	mov r0,#0
	mov r4,#0 @string A ilter
	mov r5,#0 @string B ilter
	bl _check_initial

	@show result
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1]
	bl _write_re
	bl _write

	b _exit
	
_check_initial:
	sub sp,sp,#4
	str lr,[sp,#0]
	ldr r1,=write_size1
	ldr r6,[r1]
	ldr r1,=write_size2
	ldr r7,[r1]
	cmp r4,r6
	bge _to_main4
	cmp r5,r7
	bge _to_main4
	cmp r0,#1
	bleq _to_main4
	blne _check_initial
	b _to_main4
	
_count_size1:
	sub sp, sp, #4
	str lr ,[sp,#0]
	mov r0, #0
	sub r0,r0,#1
	bl _check_new_line1
	b _to_main4
	
_check_new_line1:
	sub sp, sp, #4
	str lr ,[sp,#0]
	add r0, r0, #1
	ldr r1, =input1
	ldrb r2, [r1,r0]
	cmp r2, #0xa @0xa = newline
	blne _check_new_line1
	b _to_main4
_count_size2:
	sub sp, sp, #4
	str lr ,[sp,#0]
	mov r0, #0
	sub r0,r0,#1
	bl _check_new_line2
	b _to_main4
	
_check_new_line2:
	sub sp, sp, #4
	str lr ,[sp,#0]
	add r0, r0, #1
	ldr r1, =input2
	ldrb r2, [r1,r0]
	cmp r2, #0xa @0xa = newline
	blne _check_new_line2
	b _to_main4
_read:
	mov r7,#3
	mov r0,#0
	mov r2,#100
	swi 0
	bx lr
_write_in:
	mov r7,#4
	mov r0,#1
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
