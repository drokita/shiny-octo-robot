# Purpose - Recreate the factorial program
#           without using recursive functions
#

.section .data
.section .text
.globl _start
.globl factorial

_start:
   pushl $4
   call factorial
   addl $4, %esp
   movl %eax, %ebx
   movl $1, %eax
   int $0x80

.type factorial,@function
factorial:
   pushl %ebp
   movl %esp, %ebp
   movl 8(%ebp), %eax
   movl %eax, %ebx

factorial_loop_start:   
   dec %ebx
   cmpl $1, %ebx
   je end_factorial
   imul %ebx, %eax
   jmp factorial_loop_start

end_factorial:
   movl %ebp, %esp
   popl %ebp
   ret
