/*check String2 inside String1 or not*/
	.data
string: .ascii "input1: "
input1: .ascii "0123456789012345678901234567890123456789"
input2: .ascii "0123456789012345678901234567890123456789"
write_size: .word 8
write_size1: .word 8
write_size2: .word 8
same_string: .space 1
	
	.text
	.global _start
_start:
	@0x2d = '-' need implement in collect input
	@input
	bl _write

	@read input1
	ldr r1,=input1
	bl _read @int
	bl _count_size1
	ldr r1,=write_size1
	str r0,[r1]

	/*
	@check input1
	ldr r1,=write_size1
	ldr r2,[r1]
	add r2,r2,#1
	ldr r1,=input1
	bl _write_in
	mov r0,r2
	@b _exit
	*/

	@show "input2:"
	ldr r1,=string
	mov r0,#0x32
	strb r0,[r1,#5]
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1]
	bl _write

	@read input2
	ldr r1,=input2
	bl _read @int
	bl _count_size2
	ldr r1,=write_size2
	str r0,[r1]
	/*
	@check input2
	ldr r1,=write_size2
	ldr r2,[r1]
	ldr r1,=input2
	bl _write_in
	mov r0,r2
	b _exit
	*/
	
	@check in String
	mov r0,#0 @result 0 = false 1 = true
	@r1 reserve for load data
	@r2 reserve for string1 input ascii check
	@r3 reserve for string2 input ascii check
	mov r4,#0 @string A ilter start value with 0
	@load size just once
	ldr r1,=write_size1
	ldr r6,[r1] 
	ldr r1,=write_size2
	ldr r7,[r1]
	sub r6,r6,r7 @StringA ilter limit = len1-len2
	bl _check_initial
	ldr r1,=same_string
	strb r0,[r1]

	@show "result: "
	ldr r1,=write_size
	mov r0,#8
	str r0,[r1]
	bl _write_re
	bl _write
	
	ldr r1,=same_string
	ldrb r0,[r1]
        cmp r0,#0
        bleq _set_String_No
        blne _set_String_Yes
        bl _write

        b _exit

_set_String_No:
        ldr r1,=string
        mov r0,#0x4e @N
        strb r0,[r1,#0]
        mov r0,#0x6f @o
        strb r0,[r1,#1]
        mov r0,#0xa @New line
        strb r0,[r1,#2]
        ldr r1,=write_size
        mov r0,#0x3
        str r0,[r1]


_set_String_Yes:
        ldr r1,=string
        mov r0,#0x59 @Y
        strb r0,[r1,#0]
        mov r0,#0x65 @e
        strb r0,[r1,#1]
        mov r0,#0x73 @s
        strb r0,[r1,#2]
        mov r0,#0xa @New line
        strb r0,[r1,#3]
        ldr r1,=write_size
        mov r0,#0x4
        str r0,[r1]

@check first letter that string1 and string2 match
_check_initial:
	sub sp,sp,#8
	str lr,[sp,#0]
	str r4,[sp,#4]
	cmp r4,r6 
	bgt _to_main8 @iltA break limit
	mov r5,#0 @string B ilter start value with 0
	bl _check_string_inside
	ldr r4,[sp,#4]
	cmp r0,#1 @result have been true
	bleq _to_main8
	add r4,r4,#1
	blne _check_initial @check next character in string1
	b _to_main8

_check_string_inside:
	sub sp,sp,#4
	str lr,[sp,#0]
	cmp r5,r7
	bge _to_main4 @iltB break limit
	ldr r1,=input1
	ldrb r2, [r1, r4] @load character ilt stringA
	ldr r1,=input2
	ldrb r3, [r1, r5] @load character ilt stringB
	cmp r2,r3
	bne _to_main4
	sub r7,r7,#1
	cmp r5,r7 @check is it last character that same
	beq _return_true4
	add r7,r7,#1
	@ilterate to next character
	add r5,r5,#1 
	add r4,r4,#1
	bl _check_string_inside
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
_return_true4:
	mov r0, #1
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
