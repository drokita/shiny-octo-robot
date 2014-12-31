# Purpose:     This program converts an input file to an
#              output file with all letters in upper-case
#
# Processing:  1) Open the input file
#              2) Open the output file
#              3) While we are not at the end  of the input file
#                 a) read part of the file into our piece of memory
#                 b) go through each byte of memory, it the byte is 
#                    lower case, convert it to upper case
#                 c) write the piece of memory to a file

.section .data  # There is no need as the data comes from file

# rename system calls
   .equ OPEN, 5
   .equ WRITE, 4
   .equ READ, 3
   .equ CLOSE, 6
   .equ EXIT, 1

# options for open
   .equ O_RDONLY, 0
   .equ O_CREAT_WRONLY_TRUNC, 03101

# system call interrupt
   .equ LINUX_SYSCALL, 0x80

# end-of-file result status, return value of read at end of file
   .equ END_OF_FILE, 0       

.section .bss
# This is where the data is loaded into from the file
# and where the data is written from into output
# This shoudl never exceed 16,000 for various reasons
   .equ BUFFER_SIZE, 4096 
   .lcomm BUFFER_DATA, BUFFER_SIZE
# Program Code
.section .text

# Stack Positions
   .equ ST_SIZE_RESERVE, 8
   .equ ST_FD_IN, 0
   .equ ST_FD_OUT, 4
   .equ ST_ARGC, 8       # Number of arguments
   .equ ST_ARGV_0, 12    # Name of program
   .equ ST_ARGV_1, 16    # Input file name
   .equ ST_ARGV_2, 20    # Output file name

.globl _start

_start:
# Initialize Program
subl $ST_SIZE_RESERVE, %esp    # Allocate space for pointers on stack
movl %esp, %ebp

open_files:
open_fd_in:
   # Open input file
   movl ST_ARGV_1(%ebp), %ebx    # input filename into %ebx
   movl $O_RDONLY, %ecx          # read-only flag
   movl $0666, %edx              # set mode (not really required for reading)
   movl $OPEN, %eax              # open syscall
   int $LINUX_SYSCALL            # call Linux

store_fd_in:
   movl %eax, ST_FD_IN(%ebp)     # save the given file descriptor

open_fd_out:
   # Open output file
   movl ST_ARGV_2(%ebp), %ebx         # output filename into %ebx
   movl $O_CREAT_WRONLY_TRUNC, %ecx  # flags for writing to file
   movl $0666, %edx                   # mode for new file (if created)
   movl $OPEN, %eax                   # open the file
   int  $LINUX_SYSCALL                # call Linux

store_fd_out:
   movl %eax, ST_FD_OUT(%ebp)         # get the input file descriptor

# Begin Main Loop
read_loop_begin:
   # Read in a block from the input file
   movl ST_FD_IN(%ebp), %ebx   # get the input file descriptor
   movl $BUFFER_DATA, %ecx     # the location to read into
   movl $BUFFER_SIZE, %edx     # load the size of the buffer
   movl $READ, %eax
   int $LINUX_SYSCALL          # size of buffer read is returned to %eax

   # Exit if we've reached the end
   cmpl $END_OF_FILE, %eax    # check for end of file marker
   jle end_loop                # if found, go to the end

continue_read_loop:
   # Convert the block to upper-case
   pushl $BUFFER_DATA        # location of the buffer
   pushl %eax                # size of the buffer
   call convert_to_upper
   popl %eax
   popl %ebx 

   # Write the block to the output file
   movl ST_FD_OUT(%ebp), %ebx       # file to use
   movl $BUFFER_DATA, %ecx          # location of the buffer
   movl %eax, %edx                  # size of the buffer
   movl $WRITE, %eax
   int $LINUX_SYSCALL

   # Continue the loop
   jmp read_loop_begin

end_loop:
   # close the files
   # Note - there is no error checking on these, because
   #        error conditions don't signify anything special
   #
   movl ST_FD_OUT(%ebp), %ebx
   movl $CLOSE, %eax
   int $LINUX_SYSCALL

   movl ST_FD_IN(%ebp), %ebx
   movl $CLOSE, %eax
   int $LINUX_SYSCALL

   # exit
   movl $0, %ebx
   movl $EXIT, %eax
   int $LINUX_SYSCALL

   # FUNCITON convert_to_upper
   #
   # PURPOSE:  This function actually does the conversion to upper case for a block
   #
   # INPUT:    This parameter is the location of the block of memory to convert
   #           The second parameter is the length of that buffer
   # 
   # OUTPUT:   This function overwrites the current buffer with the upper-casified
   #           version
   #
   # VARIABLE: 
   #           %eax - beginning of buffer
   #           %ebx - length of the buffer
   #           %edi - current buffer offset
   #           %cl - current byte being examined (%cl is the first byte of $ecx)
   #

   # CONSTANTS
   .equ LOWERCASE_A, 'a'            # The lower boundary of our search
   .equ LOWERCASE_Z, 'z'            # The upper boundary of our search
   .equ UPPER_CONVERSION, 'A' - 'a' # Conversion between uppper and lower case

   # STACK POSITIONS
   .equ ST_BUFFER_LEN, 8            # Length of buffer
   .equ ST_BUFFER, 12               # Actual buffer

convert_to_upper:
   pushl %ebp
   movl %esp, %ebp

   # Set up Variables
   movl ST_BUFFER(%ebp), %eax
   movl ST_BUFFER_LEN(%ebp), %ebx
   movl $0, %edi

   # if a buffer with zero length was given, leave
   cmpl $0, %ebx
   je end_convert_loop

convert_loop:
   # get the current byte
   movb (%eax,%edi,1), %cl

   # go to the next byte unless it is between is between 'a' and 'z'
   cmpb $LOWERCASE_A, %cl
   jl next_byte
   cmpb $LOWERCASE_Z, %cl
   jg next_byte

   # otherwise convert the byte to uppercase
   addb  $UPPER_CONVERSION, %cl
   
   # store it back
   movb %cl, (%eax,%edi,1)

next_byte:
   incl %edi           # augment buffer offset
   cmpl %edi, %ebx     # continue unless we've reached the end of buffer
   jne convert_loop    

end_convert_loop:
   # no return value, just leave
   movl %ebp, %esp
   popl %ebp
   ret 

