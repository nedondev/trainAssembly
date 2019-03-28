	.global main
	.func main
main:
	sub sp, sp, #40
	
	ldr r1, =matrix1
	
	vldr s8, [r1]
	vldr s9, [r1,#4]
	vldr s10,[r1,#8]
	vldr s11,[r1,#12]
	vldr s12,[r1,#16]
	vldr s13,[r1,#20]
	ldr r0, =matrix1_string
	vcvt.f64.f32 d0, s8
	vmov r2, r3, d0
	vcvt.f64.f32 d0, s9
	vstr d0, [sp]
	vcvt.f64.f32 d0, s10
	vstr d0, [sp, #8]
	vcvt.f64.f32 d0, s11
	vstr d0, [sp, #16]
	vcvt.f64.f32 d0, s12
	vstr d0, [sp, #24]
	vcvt.f64.f32 d0, s13
	vstr d0, [sp, #32]
	bl printf

	ldr r1, =matrix2
	
	vldr s14, [r1]
	vldr s15, [r1,#4]
	vldr s16, [r1,#8]
	vldr s17, [r1,#12]
	vldr s18, [r1,#16]
	vldr s19, [r1,#20]
	ldr r0, =matrix2_string
	vcvt.f64.f32 d0, s14
	vmov r2, r3, d0
	vcvt.f64.f32 d0, s15
	vstr d0, [sp]
	vcvt.f64.f32 d0, s16
	vstr d0, [sp, #8]
	vcvt.f64.f32 d0, s17
	vstr d0, [sp, #16]
	vcvt.f64.f32 d0, s18
	vstr d0, [sp, #24]
	vcvt.f64.f32 d0, s19
	vstr d0, [sp, #32]
	bl printf

	ldr r1, =matrix1
	
	vldr s8, [r1]
	vldr s9, [r1,#4]
	vldr s10,[r1,#8]
	vldr s11,[r1,#12]
	vldr s12,[r1,#16]
	vldr s13,[r1,#20]

	ldr r1, =matrix2
	
	vldr s16, [r1]
	vldr s17, [r1,#8]
	vldr s18, [r1,#16]
	vldr s19, [r1,#4]
	vldr s20, [r1,#12]
	vldr s21, [r1,#20]

	/*set LEN = 3 0b010 and STRIDE= 1 0b00
	@use with armv6
	vmrs	r1, FPSCR	@get current FPSCR
	mov	r2, #0b000010	@bit pattern
	mov	r2, r2, lsl #16 @move across to b21
	orr	r2, r1, r2	@keep all 1's
	vmsr	FPSCR, r2	@transfer to FPSCR
	vmrs	r1, FPSCR	@get current FPSCR*/

	vmul.f32 s24,s8,s16
	vmul.f32 s25,s9,s17
	vmul.f32 s26,s10,s18
	vadd.f32 s0,s24,s25
	vadd.f32 s0,s0,s26

	vmul.f32 s24,s8,s19
	vmul.f32 s25,s9,s20
	vmul.f32 s26,s10,s21
	vadd.f32 s2,s24,s25
	vadd.f32 s2,s2,s26

	vmul.f32 s24,s11,s16
	vmul.f32 s25,s12,s17
	vmul.f32 s26,s13,s18
	vadd.f32 s3,s24,s25
	vadd.f32 s3,s3,s26

	vmul.f32 s24,s11,s19
	vmul.f32 s25,s12,s20
	vmul.f32 s26,s13,s21
	vadd.f32 s4,s24,s25
	vadd.f32 s4,s4,s26

	ldr r0, =result_string
	vcvt.f64.f32 d0, s0
	vmov r2, r3, d0
	vcvt.f64.f32 d0, s2
	vstr d0, [sp]
	vcvt.f64.f32 d0, s3
	vstr d0, [sp, #8]
	vcvt.f64.f32 d0, s4
	vstr d0, [sp, #16]
	bl printf

	add sp, sp, #40
_exit:
	mov	r0, #0
	mov	r7, #1
	swi	0
	.data
matrix1:	.float	1.0,2.0,3.0
		.float	4.0,5.0,6.0
matrix2:	.float	1.0,1.0
		.float	2.0,3.0
		.float	5.0,0.0
matrix1_string:	.asciz "Matrix1:\n%.1f\t%.1f\t%.1f\n%.1f\t%.1f\t%.1f\n"
matrix2_string: .asciz "Matrix2:\n%.1f\t%.1f\n%.1f\t%.1f\n%.1f\t%.1f\n"
result_string:	.asciz "Multiplication result:\n%.1f\t%.1f\n%.1f\t%.1f\n"

