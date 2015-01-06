# PURPOSE - Given a number, this program computes the
#          factorial.  For example the factorial of 
#          3 is 3 * 2 * 1, or 6. 
#

# This program shows how to call a function.  You
# call a function by first pushing all of the arguments,
# then you call the function, and the resulting 
# value is in %eax.  The program can also change the
# passed parameters if it wants to.

.section .data  # This program has no global data
.section .text
.globl _start
.globl factorial

_start:
   pushl $4         # single argument for the factorial function

   call factorial
   popl %ebx  
   movl %eax, %ebx  # The function returns the value to eax
                    # but we have to move it to %ebx to send
                    # it as our exit status
   movl $1, %eax    # set the kernel's exit function
   int $0x80

.type factorial,@function
factorial:

   pushl %ebp         # move the base pointer onto stack
   movl %esp, %ebp    # take the current stack pointer and move
                      # make it the new base pointer.  This 
                      # reduces the risk of destroying the stack
   movl 8(%ebp), %eax # This moves the first argument in %eax
                      # 4(%ebp) holds the return address, and
                      # 8(%ebp) holds the address of the first 
                      # parameter
   
   cmpl $1, %eax   # The base case is 1
   je end_factorial
   decl %eax       # otherwise, decrease the value
   pushl %eax      # push it for next call to factorial
   call factorial
   popl %ebx       # this is the number we called factorial with
                   # we have to pop it off, but we also need
                   # it to find the number we were called with
   incl %ebx       # add one to what was pushed
   imul %ebx, %eax # multiply that by the result of the last
                   # call to factorial (stored in %eax)
                   # the answer is stored in %eax, which is good
                   # since that is where return values go
end_factorial:
   movl %ebp, %esp  # standard function return stuff - we
   popl %ebp       # restore %ebp and %esp to where
                   # they were before the function started
   ret             # return to the function (this pops the return
                   # value)
   
