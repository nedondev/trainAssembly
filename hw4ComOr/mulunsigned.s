.global _start
_start:
	mov r1, #0x28	@8_50 -> #0x23 multiplicand
	mov r2, #0xb	@8_23 -> #0xb nultiplier
	mov r0, #0x0
	bl _mul
	and r0,r0,#0b111111
_exit:
	mov r7, #1
	swi 0
_mul:
	sub sp,sp,#4
	str lr,[sp,#0]
	cmp r2,#0
	beq _return4
	cmp r1,#0
	beq _return4
	and r3,r2,#1
	cmp r3,#1
	bleq _mul_inside1
	lsl r1,#1
	lsr r2,#1
	bl _mul
	ldr lr,[sp,#0]
	add sp,sp,#4
	bx lr
_mul_inside1:
	add r0, r0, r1
	bx lr
_return4:
	ldr lr,[sp,#0]
	add sp,sp,#4
	bx lr
	
