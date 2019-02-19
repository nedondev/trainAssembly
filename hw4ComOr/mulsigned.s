/*
mulipication for only 8 bit signed values
expect: that we have only 8 bit register
*/
.global _start
_start:
	mov r1, #0x54	@0x54 Multiplicand
	mov r2, #0x87	@0x87 Multiplier
	@manage signed bit
	eor r4, r1, r2
	and r4, r4, #0x80
	cmp r1,#0x7F
	blhi _multiplicand_2complement
	cmp r2,#0x7F
	blhi _multiplier_2complement
	and r1,r1,#0x7F @expect that we have only 8bit with 1st signed bit
	and r2,r2,#0x7F	@expect that we have only 8bit with 1st signed bit

	@use mul unsinged code
	mov r0, #0x0
	bl _mul
	and r0,r0,#0x7F
	orr r0,r0,r4
_exit:
	mov r7, #1
	swi 0
_multiplicand_2complement:
	mvn r1,r1
	add r1,r1,#1
	bx lr
_multiplier_2complement:
	mvn r2,r2
	add r2,r2,#2
	bx lr
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
	
