.global _start
_start:
	mov r0,#13
	bl fib
_exit:
	mov r7,#1 
	swi 0
fib:
	sub sp,sp,#8
	str lr,[sp,#4]
	str r0,[sp,#0]
	cmp r0,#1
	ble re
	sub r0,r0,#1
	bl fib
	mov r1, #2
	ldr r1,[sp,#0]
	sub r1,r1,#2
	str r0,[sp,#0]
	mov r0,r1
	bl fib
	ldr r1,[sp,#0]
	add r0,r1,r0
	ldr lr,[sp,#4]
	add sp,sp,#8
	bx lr
re:
	ldr lr,[sp,#4]
	add sp,sp,#8
	bx lr

