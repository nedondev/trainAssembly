.data
str1: .ascii "1234567890"
.text
.global _start

_start:
	ldr r0, =str1
	add r0,r0,#3
	mov r2, #65
	strb r2, [r0]
_print:
	mov r7, #4
	mov r0, #1
	mov r2, #8
	ldr r1, =str1
	swi 0
_exit:
	mov r7,#1
	swi 0
