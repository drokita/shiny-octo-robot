#Purpose: Simple program that exits and returns a 
#         Status code back to the Linux Kernel
#

#INPUT: none
#

#OUTPUT returns a status code.  This can be viewed
#       by typing 
#
#       echo $?
#
#       after running the program
#

#VAriaBLES:
#               %eax holds the system call number
#               (this is always the case)
#
#               %ebx holds the return status

.section .data

.section .text

.globl _start

_start:
   movl $1, %eax     # this is the linux kernel command
                     # number (system call) for exiting
                     # a program

   movl $9, %ebx     # this is the status number we will
                     # return to the operating system.
                     # Change this around and it will
                     # return different codes

   int $0x80

