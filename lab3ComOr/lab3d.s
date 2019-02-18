/* How to use Syscall 4 to write a string*/
.data
num: .word 4
	.global _start
_start:
	ldr r0, addr_num
	mov r1,#50
	mov r2,#60
	adds r3,r1,r2
	mov r4,r3
	mov r2,#0
	str r3,[r0]
	@b _print_digit
	@cmp r3,#100
	@bhs _print3
	@cmp r3,#10
	@bhs _print2
	@adds r3,r3,#48	
	@str r3,[r0]
	@;b _print_digit
	swi 0
_print3:
	mov r1,#1
	adds r1,r1,#48
	str r1,[r0]
	b _print_digit
	sub r3,r3,#100
_print2:
	mov r1,#0
	b _loopdiv
	adds r1,r1,#48
	str r1,[r0]
	b _print_digit
_loopdiv:
	cmp r3,#10
	bge _dele10
_dele10:
	adds r1,r1,#1
	sub r3,r3,#10
	b _loopdiv
_loopr4:
	mov r1,r3
	cmp r4,#0
	bge _loopr3
	
_loopr3:
	cmp r3,#10
	blt _print_digit
	
	
_print_digit: 
	mov r7,#4
	mov r0,#1
	mov r2,#4
	ldr r1,=addr_num
	swi 0
_exit:
	mov r7,#1	@exit syscall
	swi 0

	.data
addr_num:	.word num
