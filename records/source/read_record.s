.include "record-def.s"
.include "linux.s"

# PURPOSE: This function reads a record from the file descriptor
#
# INPUT:   The file descriptor and a buffer
#
# OUTPUT:  This function writes the data to the buffer and returns
#          a status code.
#

# Stack local variables
.equ ST_READ_BUFFER, 8        # Stack locator for the location of the read buffer
.equ ST_FILEDES, 12           # Stack locator for the location of the file descriptor

.section .text
.globl read_record
.type read_record, @function

read_record:
   pushl %ebp                  # Save the current base pointer until end of function
   movl %esp, %ebp             # Save the stack pointer as new base pointer
   
   pushl %ebx                  # The contents of %ebx are stored for restoration after
                               # the function is completed
   movl ST_FILEDES(%ebp), %ebx
   movl ST_READ_BUFFER(%ebp), %ecx
   movl $RECORD_SIZE, %edx
   movl $SYS_READ, %eax
   int $LINUX_SYSCALL

   # Note = %eax has the return value, which we will give back to calling program
   popl %ebx                   # Restore %ebx
   movl %ebp, %esp
   popl %ebp
   ret



