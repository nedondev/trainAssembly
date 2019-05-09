	.data
billion: .word 1000000000
filename: .asciz "test.txt"
word: .asciz "fish"
linefeed: .asciz "\n"
buffer: .space 10
line_buffer: .space 1000
count_byte: .word 0
count_ascii: .word 0
count_line: .word 0
count_word: .word 0
errmsg:	.asciz "create failed"
errmsgend:
	.text
	.global _start
_start:	
	push {r4, lr}
	ldr r0, =filename
	mov r1, #0x0
	mov r2, #384
	mov r7, #5
	svc 0
	
	cmp r0, #0
	blt err
	
	mov r4, r0         
	@bl _byte_count_option
	bl _word_option
	mov r12,#0
read_out_until_end:
/* lseek */
        mov r0, r4 @ file descriptor
        mov r1, r12 @ position
        mov r2, #0 @ seek_set
        mov r7, #19
        svc 0

/* simple read */
        mov r0, r4 @ file descriptor
        ldr r1, =buffer
        mov r2, #2
        mov r7, #3
        svc 0

/* show a read character*/
        mov r0, #1
        ldr r1, =buffer

        @add to check end of file
        ldrb r5,[r1]
        cmp r5, #127
        bge end_file
        
        mov r2, #1
        mov r7, #4
        @svc 0
        
        add r5,r5,#127
        strb r5,[r1]
        add r12,r12,#1
        #cmp r12,#32
        b read_out_until_end

end_file:
	ldr r1,=count_byte
	ldr r1, [r1]
	bl _print_int
	bl _print_line
	ldr r1,=count_ascii
	ldr r1, [r1]
	bl _print_int
	bl _print_line
	ldr r1,=count_line
	ldr r1, [r1]
	bl _print_int
	bl _print_line
	ldr r1,=count_word
	ldr r1, [r1]
	bl _print_int
	bl _print_line


/* Close File */
        mov r7, #6 @ close
        svc 0
        mov r0, r4 @ return file descriptor
exit:	
	pop {r4, lr}
	mov r7, #1
	svc 0
err:
	mov r4, r0
	mov r0, #1
	ldr r1, =errmsg
	mov r2, #(errmsgend-errmsg)
	mov r7, #4
	svc 0
	mov r0,r4
	b exit

@need file descriptor r4
_byte_count_option:
	push {r1-r12, lr}
	mov r12,#0
	read_out_until_end_byte_option:
	/* lseek */
        mov r0, r4 @ file descriptor
        mov r1, r12 @ position
        mov r2, #0 @ seek_set
        mov r7, #19
        svc 0

	/* simple read */
        mov r0, r4 @ file descriptor
        ldr r1, =buffer
        mov r2, #1
        mov r7, #3
        svc 0
	
	@count byte
        @add to check end of file
        ldrb r5,[r1]
        cmp r5, #127
	popge {r1-r12, pc}
	bl _add_byte
        
        add r5,r5,#127
        strb r5,[r1]
        add r12,r12,#1
        b read_out_until_end_byte_option

@need file descriptor r4
_no_word_option:
	push {r1-r12, lr}
	mov r12,#0
	count_until_end_no_word_option:
	/* lseek */
        mov r0, r4 @ file descriptor
        mov r1, r12 @ position
        mov r2, #0 @ seek_set
        mov r7, #19
        svc 0

	/* simple read */
        mov r0, r4 @ file descriptor
        ldr r1, =buffer
        mov r2, #2
        mov r7, #3
        svc 0

        @add to check end of file
        ldrb r5,[r1]
        cmp r5, #127
	popge {r1-r12, pc}
	cmp r5, #10
	bleq _add_line
	bl _add_ascii
	cmp r5, #32
	bgt check_white_space_no_word_option
	ble end_check_word_no_word_option
	check_white_space_no_word_option:
		ldrb r6,[r1,#1]
		cmp r6, #32
		blle _add_word
		ble end_check_word_no_word_option
		@check end file
		cmp r6, #127
		blge _add_word
	end_check_word_no_word_option:
        
        add r5,r5,#127
	strb r5,[r1]
        add r12,r12,#1
        b count_until_end_no_word_option

@need file descriptor r4
_word_option:
	push {r1-r12, lr}
	mov r12,#0
	mov r6, r12
	ldr r8, =line_buffer
	mov r9, #0
	count_until_end_word_option:
	/* lseek */
        mov r0, r4 @ file descriptor
        ldr r1, =buffer
        mov r1, r12 @ position
        mov r2, #0 @ seek_set
        mov r7, #19
        svc 0

	/* simple read */
        mov r0, r4 @ file descriptor
        ldr r1, =buffer
        mov r2, #1
        mov r7, #3
        svc 0

        @add to check end of file
        ldrb r5,[r1]
	strb r5,[r8,r9]
        cmp r5, #127
	popge {r1-r12, pc}
	@check word in line when find end line
	cmp r5, #10
	pusheq {r1-r7}
        moveq r0, #1
        ldreq r1, =line_buffer
        
        moveq r2, r9
	addeq r2, r2, #1
        moveq r7, #4
        svceq 0
	popeq {r1-r7}
	
	bne not_end_line
	beq check_word_in_line
	check_word_in_line:
		push {r1-r12}
		mov r5,#0
		strb r5,[r8,r9]
		mov r8,r6 @start at char
		mov r7,r4 @file descriptor
		ldr r1,=word
		ldr r2,=line_buffer
		mov r3,#0
		mov r4,#0
		compare_word:
			ldrb r5,[r1,r3]
			ldrb r6,[r2,r4]
			cmp r6,#0
			beq end_compare
			cmp r5,r6
			push {r3,r4}
			beq same_start_char
			bne end_check_char
			same_start_char:
				add r4,r4,#1
				add r3,r3,#1
				ldrb r5,[r1,r3]
				ldrb r6,[r2,r4]
				cmp r6,#32
				movle r6,#0
				cmp r5,r6
				bne end_check_char
				cmp r5, #0
				pusheq {r4,r6}
				moveq r4,r7
				moveq r6,r8
				bleq _add_until_new_line
				cmp r5, #0
				popeq {r4,r6}
				popeq {r3,r4}
				beq end_compare
				b same_start_char
				
			end_check_char:
			pop {r3,r4}
			add r4,r4,#1
			b compare_word
		end_compare:
		pop {r1-r12}
	not_end_line:

	@save the start of line
	cmp r5, #10
	addeq r6,r12,#1
	moveq r9,#-1
        
        add r5,r5,#127
	strb r5,[r1]
        add r12,r12,#1
	add r9,r9,#1
        b count_until_end_word_option

@r4 need file descriptor r6 need num start char
_add_until_new_line:
	push {r1-r12, lr}
	mov r12, r6
	count_until_end:
	/* lseek */
        mov r0, r4 @ file descriptor
        mov r1, r12 @ position
        mov r2, #0 @ seek_set
        mov r7, #19
        svc 0

	/* simple read */
        mov r0, r4 @ file descriptor
        ldr r1, =buffer
        mov r2, #2
        mov r7, #3
        svc 0

        @add to check end of file
        ldrb r5,[r1]
        cmp r5, #127
	popge {r1-r12, pc}
	cmp r5, #10
	bleq _add_line
	bl _add_ascii
	cmp r5, #32
	bgt check_white_space
	ble end_check_word
	check_white_space:
		ldrb r6,[r1,#1]
		cmp r6, #32
		blle _add_word
		ble end_check_word
		@check end file
		cmp r6, #127
		blge _add_word
	end_check_word:
	cmp r5, #10
	popeq {r1-r12, pc}
        
        add r5,r5,#127
	strb r5,[r1]
        add r12,r12,#1
        b count_until_end

_add_byte:
	push {r1-r12,lr}
	ldr r1,=count_byte
	ldr r2, [r1]
	add r2, r2, #1
	str r2, [r1]
	pop {r1-r12,pc}
_add_ascii:
	push {r1-r12,lr}
	ldr r1,=count_ascii
	ldr r2, [r1]
	add r2, r2, #1
	str r2, [r1]
	pop {r1-r12,pc}
_add_line:
	push {r1-r12,lr}
	ldr r1,=count_line
	ldr r2, [r1]
	add r2, r2, #1
	str r2, [r1]
	pop {r1-r12,pc}
_add_word:
	push {r1-r12,lr}
	ldr r1,=count_word
	ldr r2, [r1]
	add r2, r2, #1
	str r2, [r1]
	pop {r1-r12,pc}
_print_int:
	push {r1-r12,lr}
	cmp r1,#0
	moveq r4,r1
	bleq _print_digit
	popeq {r1-r12,pc}
	mov r2,r1
	ldr r1, =billion
	ldr r1, [r1]
	find_all_zero:
		push {r1,r2}
		bl _div
		pop {r1,r2}
		movs r4,r0
		bne find_all_digit
		push {r2}
		mov r2,r1
		mov r1,#10
		bl _div
		mov r1,r0
		pop {r2}
		cmp r1,#0
		bne find_all_zero
	find_all_digit:
		push {r1}
		bl _div
		pop {r1}
		movs r4,r0
		bl _print_digit
		push {r2}
		mov r2,r1
		mov r1,#10
		bl _div
		mov r1,r0
		pop {r2}
		cmp r1,#0
		bne find_all_digit
	pop {r1-r12,pc}
_print_digit:
	push {r1-r7,lr}
	mov r0, #1
	ldr r1, =buffer
	add r4, r4, #48
	strb r4, [r1]
	mov r2, #1
	mov r7, #4
	svc 0
	pop {r1-r7,pc}
_print_line:
	push {r1-r7,lr}
	mov r0, #1
	ldr r1, =linefeed
	mov r2, #1
	mov r7, #4
	svc 0
	pop {r1-r7,pc}
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
