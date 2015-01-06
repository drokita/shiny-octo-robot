# PURPOSE: This program will write a string 10 times
# 
# INPUT:   No input
#
# OUTPUT:  This program will print string to STDOUT 10x
#
.include "linux.s"

.section .data

message:
   .ascii "Hello World!\n"

.equ ST_TIMES, 4
.equ RECORD_SIZE, 13 
.equ TIMES, 10 

.globl _start

_start:
   movl %esp, %ebp
   pushl $TIMES
   movl $0, %edi
   
loop:
   cmpl $TIMES, %edi
   je loop_end

   movl $SYS_WRITE, %eax
   movl $STDOUT, %ebx
   movl $message, %ecx
#   movl %edi, %ecx
   movl $RECORD_SIZE, %edx
   int  $LINUX_SYSCALL
   incl %edi 
   jmp loop

loop_end:
   movl $SYS_EXIT, %eax
   movl %edi, %ebx
   int $LINUX_SYSCALL





