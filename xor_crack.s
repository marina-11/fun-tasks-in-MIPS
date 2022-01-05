#=========================================================================
# XOR Cipher Cracking
#=========================================================================
# Finds the secret key for a given encrypted text with a given hint.
# 
# Inf2C Computer Systems
# 
# Dmitrii Ustiugov
# 9 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_xor_crack.txt"
hint_file_name:                .asciiz  "hint.txt"
newline:                      .asciiz  "\n"
error_output:                  .asciiz  "-1" 
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
hint:                         .space 101         # Maximum size of key_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading (text)

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)


# opening file for reading (hint)

        li   $v0, 13                    # system call for open file
        la   $a0, hint_file_name        # hint file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # hint[idx] = c_input
        la   $a1, hint($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, hint($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  hint($t0)             # hint[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


   la $a1, input_text
   la $a2, hint
   
   
   addi $t0, $0, 0   #t0 = 00000000 first, decryption key
   addi $t1, $0, 32   #ASCII number for 'space'
   addi $t2, $0, 10   #ASCII number for \n
   addi $t5, $0, 8   #counter for printing key
   addi $t6, $0, 256   #constant for terminating program
   addi $s0, $0, 0   #input text counter
   addi $s1, $0, 0   #hint counter
   
   
   XOR:
     lb $t3, 0($a1)
     addi $s0, $s0, 1   #add 1 to the input text counter
     beq $t3, $0, eof
     beq $t3, $t1, space
     beq $t3, $t2, XORline
     xor $s5, $t0, $t3
     addi $a1, $a1, 1  
     j check
     
   eof:
    addi $s5, $0, 0
    addi $a1, $a1, 1 
    j check
     
   space:
     add $s5, $0, $t1
     addi $a1, $a1, 1 
     j check
     
   XORline:
     add $s5, $0, $t2
     addi $a1, $a1, 1 
     j check      
     
       
   check:
     beq $s5, $0, no   #if s5 = end of file character then the hint phrase is not in the decrypted text and go to no
     lb $t4, 0($a2)
     addi $s1, $s1, 1   #add 1 to the hint counter
     beq $t4, $0, yes
     beq $s5, $t2, line
     beq $s5, $t4, sameprep  #if t3 is equal to t4 then go to prep to check further if the whole phrase is present in a3 - the decrypted text
     addi $s6, $s1, -1
     la $a2, hint
     #sub $a2, $a2, $s6
     sub $s1, $s1, $s1
     j XOR

   sameprep:
     addi $a2, $a2, 1
     j XOR
   
     
   line:
     beq $t4, $t1, sameprep
     la $a2, hint
     #addi $s1, $s1, -1
     #sub $a2, $a2, $s1
     j XOR
     
   no:
     beq $t0, $t6, terminate
     j add1
     
   terminate:
     #li $v0, 17
     #addi $a0, $0, -1
     #syscall
     la $a0, error_output
     li $v0, 4
     syscall
     li $v0, 11
     add $a0, $0, $t2
     syscall
     j main_end
     
     
   add1:
     addi $t0, $t0, 1
     j prep2
     
   prep2:
     la $a1, input_text
     #addi $s7, $s0, -1
     #addi $s1, $s1, -1
     #sub $a1, $a1, $s7  
     #sub $a2, $a2, $s1
     sub $s0, $s0, $s0
     sub $s1, $s1, $s1
     j XOR
     
   yes:
     sll $t0, $t0, 24   #drop unnecessary preceeding 24 bits from t0. decmals are represented as a 32-bit word
     j print_loop
     
   print_loop:
     srl $t9, $t0, 31   #get the msb to the position of lsb so it ca be preinted as a single digit
     addi $t9, $t9, 48   #add 48 to transform it into an ASCII character, 48 is 0 in ascii
     li $v0, 11
     add $a0, $0, $t9
     syscall
     addi $t5, $t5, -1
     beqz $t5, end
     sll $t0, $t0, 1   #drop leftmost bit
     j print_loop
     
    end:
      li $v0, 11
      add $a0, $0, $t2
      syscall
      j main_end 
            


#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
