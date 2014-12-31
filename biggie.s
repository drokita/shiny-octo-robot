# PURPOSE:  this program finds the maximum number of a set of data items
#

# VARIBLES:  The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# the following memory locations are uses:
#
# data_items - contains the item data.  A 0 is used
#              to terminate the data.
#

.section .data

data_items:                      #These are the data items
   .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .text

.globl _start

_start:
   movl $0, %eax                       # move 0 into the index register
   movl data_items(,%edi,4), %eax      # load the first byte of data
   movl %eax, %ebx                     # since this the first item, %eax is the
                                       # biggest

start_loop:
   cmpl $0, %eax                       # checkto see if we have hit the end of the list
   je loop_exit
   incl %edi                           # load next value
   movl data_items(,%edi,4), %eax
   cmpl %ebx, %eax                     # compare biggest with current
   jle start_loop                      # jump to loop beginning if the new
                                       # one isn't bigger
   movl %eax, %ebx                     # move the valie as the largest
   jmp start_loop                      # jump to loop beginning

loop_exit:
   movl $1, %eax                       # set 1 for the exit() syscall
   int $0x80

