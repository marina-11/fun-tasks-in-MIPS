#=========================================================================
# Steganography
#=========================================================================
# Retrive a secret message from a given text.
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

input_text_file_name:         .asciiz  "input_steg.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
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

# opening file for reading

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


#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
# You can add your code here!

    la $a0, input_text   #input text to be processed
    #li $v0, 4
    #syscall
    move $s1, $a0
   
    addi $t1, $0, 32   #ASCII number for 'space'
    addi $t2, $0, 10   #ASCII number for \n
    addi $t4, $0, 0   #space counter
    addi $t5, $0, 1   #line counter
    addi $t0, $0, 1
    addi $v1, $0, 0   #newline in output counter
    addi $s2, $0, 0   #new character per line in output counter
    #addi $t6, $0, 2
    
  loop:
     lb $t3, 0($s1)   #load byte
     beq $t3, $t1, space   #if the character is a space go to space  
     beq $t3, $t2, line   #if the character is a new line go to line
     slti $t6, $t4, 1   #set t6 to 1 if the space counter is less than 1
     slti $t7, $t5, 2   #set t7 to 1 if the line counter is less than 2
     and $t6, $t6, $t7   
     beq $t6, $t0, print_ch   #if space count = 0 and line count = 1 then print char
     addi $s1, $s1, 1
     beq $t3, $0, end
     j loop
    
 
    
    space:
        addi $t4, $t4, 1   #add 1 to the space counter
        addi $t8, $t5, -1   #t8 = line count - 1
        beq $t4, $t8, print_spc   #if space count = line count - 1 then print the next word
        addi $s1, $s1, 1
        j loop
        
      
      print_spc:
           slt $s3, $s2, $t0
           sgt $s4, $v1, $0
           and $s4, $s3, $s4
           beq $s4, $t0, print_word
           li $v0, 11
           add $a0, $0, $t1
           syscall
           #addi $t4, $t4, 1   #add 1 to the space counter
           #addi $s1, $s1, 1
           j print_word
          
      print_word:
           addi $s1, $s1, 1
           lb $t3, 0($s1)
           beq $t3, $t1, spc  #if the character is a space go to space  
           beq $t3, $t2, ln  #if the character is a new line go to line
           #bne $t3, $0, print
           beq $t3, $0, end
           j print
           
         spc:
            addi $s2, $s2, 1
            j space
              
        
         ln:
            addi $s2, $s2, 1
            j line  
              
         print:
            li $v0, 11
            add $a0, $0, $t3
            syscall
            j print_word
            
     line:
        addi $t8, $t5, -1   #t8 = line count - 1
        slt $t9, $t4, $t8   #set t9 to 1 if the space count is less than the line count - 1
        beq $t9, $t0, print_line
        j line_prep
        
       print_line:
            li $v0, 11
            add $a0, $0, $t2
            syscall
            addi $v1, $v1, 1
            sub $s2, $s2, $s2
            j line_prep
            
       line_prep:
            addi $t5, $t5, 1
            sub $t4, $t4, $t4
            addi $s1, $s1, 1
            j loop
                
            
   print_ch:
       li $v0, 11
       add $a0, $0, $t3
       syscall
       addi $s1, $s1, 1
       j loop    
       
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
