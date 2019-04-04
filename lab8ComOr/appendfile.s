/* Append file with specific Data 
One line only have
________________________________________
|Specific Data		| Size(byte) 	|
|-----------------------|---------------|
| ID 			| 8		|
| space(ASCII 32) 	| 1		|
| Content		| 80		|
| End line		| 1		|
-----------------------------------------
with end of file 1 byte
/*source code*/
	.text
	.global _start
_start:
	bl _append_data
	b exit
_append_data:
	push {r4, lr}
/* Open (Create) File */
	ldr r0, =newfile
	mov r1, #0x42 @ create R/W
	mov r2, #384 @ = 600 (octal)
	mov r7, #5 @ open (create)
	svc 0
	cmp r0, #-1 @ open error?
	beq err
	mov r4, r0 @ save file descriptor 
        svc 0

/*Show Input String */
	mov r0, #1 @ stdout – 1 = monitor
	ldr r1, =input @ input string
	mov r2, #(ip_end-input) @ len
	mov r7, #4
	svc 0
/*Clear Buffer by fill it with space(ASCII 32)*/
	mov r12, #0
	ldr r1, =buffer @ address of input buffer
	mov r2, #32 @set space ascii
spacebuffer:
	strb r2, [r1,r12]
	add r12, r12, #1
	cmp r12, #89
	blt spacebuffer
	mov r2, #10 @set End line ascii
	strb r2, [r1,r12]
	add r12, r12, #1
	mov r2, #0 @set End file ascii
	strb r2, [r1,r12]
	

/* Read Input String */
	mov r0, #0 @ stdin – 0 = keyboard
	ldr r1, =buffer @ address of input buffer
	mov r2, #89 @ max. len. of input
	mov r7, #3 @ read
	svc 0
	mov r5, r0 @ save no. of character

	mov r2, #32 @set End line ascii
	sub r5, r5, #1
	strb r2, [r1,r5]

/* lseek */
	mov r0, r4 @ file descriptor
	mov r1, #-1 @ position
	mov r2, #2 @ seek_set
	mov r7, #19
	svc 0

/* Write to File */
	mov r0, r4 @ file descriptor
	ldr r1, =buffer @ address of buffer to write
	mov r2, #91 @ length of data to write
	mov r7, #4
	svc 0

/* Close File */ 
        mov r7, #6 @ close 
        svc 0 
        mov r0, r4 @ return file descriptor 

/* branch back */
	pop {r4, lr}
 
exit:   pop {r4, lr} 
        mov r7, #1 @ exit 
        svc 0 
 
err:    mov r4, r0 
        mov r0, #1 
        ldr r1, =errmsg 
        mov r2, #(errmsgend-errmsg) 
        mov r7, #4 
        svc 0 
        mov r0, r4 
        b exit 
        .data 
errmsg: .asciz "create failed" 
errmsgend: 
newfile: .asciz "/home/pi/Documents/Computer_Organize_And_Assembly/lab8ComOr/testFile/specificData2.txt" 
input: .asciz "Input a string: \n" 
ip_end: 
buffer: .byte 100 
