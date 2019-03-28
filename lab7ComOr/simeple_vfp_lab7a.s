	.global main
	.func	main
main:
	ldr r1, addr_value1 	@ Get addr of value1
	vldr s10, [r1]		@ Move value1 into s10
	
	vcvt.f64.f32 d4,s10	@ Convert to B64
	ldr r0, = string0	@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r2, addr_value2	@ Get addr of value2
	vldr s12, [r2]		@ Move value1 into s11
	
	vcvt.f64.f32 d4,s12	@ Convert to B64
	ldr r0, = float		@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r0, =add		@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r1, addr_value1 	@ Get addr of value1
	ldr r2, addr_value2	@ Get addr of value2
	vldr s10, [r1]		@ Move value1 into s10
	vldr s12, [r2]		@ Move value1 into s12
	
	vadd.f32 s8,s10,s12	@ s8 = s10 + s12
	vcvt.f64.f32 d4,s8	@ Convert to B64
	ldr r0, = string	@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r0, =sub		@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r1, addr_value1 	@ Get addr of value1
	ldr r2, addr_value2	@ Get addr of value2
	vldr s10, [r1]		@ Move value1 into s10
	vldr s12, [r2]		@ Move value1 into s12

	vsub.f32 s8,s10,s12	@ s8 = s10 - s12
	vcvt.f64.f32 d4,s8	@ Convert to B64
	ldr r0, = string	@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r0, =mul		@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r1, addr_value1 	@ Get addr of value1
	ldr r2, addr_value2	@ Get addr of value2
	vldr s10, [r1]		@ Move value1 into s10
	vldr s12, [r2]		@ Move value1 into s12

	vmul.f32 s8,s10,s12	@ s8 = s10 * s12
	vcvt.f64.f32 d4,s8	@ Convert to B64
	ldr r0, = string	@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r0, =div	@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function

	ldr r1, addr_value1 	@ Get addr of value1
	ldr r2, addr_value2	@ Get addr of value2
	vldr s10, [r1]		@ Move value1 into s10
	vldr s12, [r2]		@ Move value1 into s12

	vdiv.f32 s8,s10,s12	@ s8 = s10 / s12
	vcvt.f64.f32 d4,s8	@ Convert to B64
	ldr r0, = string	@ point r0 to string
	vmov r2, r3, d4		@ convert to b64
	bl printf		@ call function
	
	mov  r7, #1		@ Exit Syscall
	swi 0
	
addr_value1:	.word value1
addr_value2:	.word value2

	.data
value1:	.float 1.0
value2: .float 2.0
add: .asciz "ADD:\n"
sub: .asciz "SUB:\n"
mul: .asciz "MUL:\n"
div: .asciz "DIV:\n"
string: .asciz "Floating point value is: %f\n"
string0: .asciz "Initial FVP is: %f"
float: .asciz " %f\n"
