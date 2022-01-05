#=========================================================================
# Book Cipher Decryption
#=========================================================================
# Decrypts a given encrypted text with a given book.
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

input_text_file_name:         .asciiz  "input_book_cipher.txt"
book_file_name:               .asciiz  "book.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
book:                         .space 10001       # Maximum size of book_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!
prep_cipher:                  .space 10001
.align 4

final_cipher:                 .space 10001
.align 4

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


# opening file for reading (book)

        li   $v0, 13                    # system call for open file
        la   $a0, book_file_name        # book file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # book[idx] = c_input
        la   $a1, book($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(book_file);
        blez $v0, END_LOOP1             # if(feof(book_file)) { break }
        lb   $t1, book($t0)          
        beq  $t1, $0,  END_LOOP1        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  book($t0)             # book[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(book_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
# You can add your code here!

 la $a1, input_text
   la $s1, prep_cipher
   la $s3, final_cipher
   
   addi $t0, $0, 2
   addi $t1, $0, 32   #ASCII number for 'space'
   addi $t2, $0, 10   #ASCII number for \n
   addi $t4, $0, 0   # X digit counter
   addi $t5, $0, 0   # Y digit counter
   
   cipher_X_loop:
     lb $t3, 0($a1)   #load byte from input cipher
     beq $t3, $0, end
     beq $t3, $t1, cipher_space   #if t3 is space then go to cipher space
     addi $t3, $t3, -48   #subtract 48 from t3 to convert ASCII number to actual number
     addi $t4, $t4, 1   #add 1 to the X digit counter
     sb $t3, 0($s1)
     addi $a1, $a1, 1
     addi $s1, $s1, 1
     j cipher_X_loop
     
   cipher_space:
     beq $t4, $t0, two_digit_X   #if X_count = 2 then go to two_digit_X
     sub $t4, $t4, $t4   #set t4 = 0
     addi $s1, $s1, -1   
     lb $t3, 0($s1)
     sb $t3, 0($s3)
     addi $s1, $s1, 1
     addi $s3, $s3, 1
     addi $a1, $a1, 1
     j cipher_Y_loop
     
   two_digit_X:
     sub $t4, $t4, $t4
     addi $s1, $s1, -1        
     lb $t3, 0($s1)
     addi $t3, $t3, 1   #get t3 + 1, ie. if X=10, then t3=0+1 =1
     addi $t3, $t3, 9   #now the line number is 1 digit
     sb $t3, 0($s3)
     addi $s1, $s1, 1
     addi $s3, $s3, 1
     addi $a1, $a1, 1
     j cipher_Y_loop
     
   cipher_Y_loop:
     lb $t3, 0($a1)   #load byte from input cipher
     beq $t3, $0, end
     beq $t3, $t2, cipher_line  #if t3 is space then go to cipher line
     addi $t3, $t3, -48   #subtract 48 from t3 to convert ASCII number to actual number
     addi $t5, $t5, 1   #add 1 to the Y digit counter
     sb $t3, 0($s1)
     addi $a1, $a1, 1
     addi $s1, $s1, 1
     j cipher_Y_loop   
     
   cipher_line:
     beq $t5, $t0, two_digit_Y   #if Y_count = 2 then go to two_digit_Y
     sub $t5, $t5, $t5   #set t4 = 0
     addi $s1, $s1, -1   
     lb $t3, 0($s1)
     sb $t3, 0($s3)
     addi $s1, $s1, 1
     addi $s3, $s3, 1
     addi $a1, $a1, 1
     j cipher_X_loop  
     
   two_digit_Y:
     sub $t5, $t5, $t5
     addi $s1, $s1, -1        
     lb $t3, 0($s1)
     addi $t3, $t3, 1   #get t3 + 1, ie. if X=10, then t3=0+1 =1
     addi $t3, $t3, 9   #now the line number is 1 digit
     sb $t3, 0($s3)
     addi $s1, $s1, 1
     addi $s3, $s3, 1
     addi $a1, $a1, 1
     j cipher_X_loop  
     
   end:
     #beq $t5, $t0, two_digit_Y_end   #if Y_count = 2 then go to two_digit_Y_end
     #sub $t5, $t5, $t5   #set t4 = 0
     #addi $s1, $s1, -1   
     #lb $t3, 0($s1)
     #sb $t3, 0($s3)
     #addi $s3, $s3, 1
     sb $0, 0($s3)
     
         
   la $s3, final_cipher
        
   la $a2, book
   
   addi $t0, $0, 1
   addi $t1, $0, 32   #ASCII number for 'space'
   addi $t2, $0, 10   #ASCII number for \n
   addi $t4, $0, 1   #line counter
   addi $t5, $0, 0   #space counter
   addi $t7, $0, 0   #any character counter
   addi $t9, $0, 0   #words printed per line in output counter
   
   #load:
     #la $a2, book
     #j loop
   
   loop:
     lb $t3, 0($a2)
     addi $t7, $t7, 1   #add 1 to character counter
     lb $t6, 0($s3)
     beq $t6, $0, end2
     beq $t6, $t0, get_word
     beq $t3, $t2, input_line   #if input byte is equal to newline then go to new_line
     addi $a2, $a2, 1
     j loop
     
   input_line:
     addi $t4, $t4, 1   #add 1 to line counter
     beq $t4, $t6, get_word   #if line count = x in cipher then go to get_word
     addi $a2, $a2, 1
     j loop
     
   get_word:
     addi $s3, $s3, 1   #go to corresponding Y value (word number)
     lb $t6, 0($s3)
     addi $t6, $t6, -1   #space before the word = word number - 1
     j get_word2
     
   get_word2:
     addi $a2, $a2, 1
     lb $t3, 0($a2)
     addi $t7, $t7, 1   #add 1 to character counter
     beq $t3, $t1, space   #if t3 is space then go to space
     beq $t3, $t2, print_ln   #if t3 is newline then go to print line
     beq $t3, $0, print_ln   #if t3 is end of file then go to print line            
     j get_word2
     
   space:
     addi $t5, $t5, 1   #add 1 to the space counter
     beq $t5, $t6, print_spc   #if space counter = word count -1 then go to print_spc
     j get_word2
     
   print_spc:
     beqz $t9, print_word   #if there are not any words printed on this line then don't put space before the word
     li $v0, 11
     add $a0, $0, $t1
     syscall
     j print_word
     
   print_word:
     addi $a2, $a2, 1
     lb $t3, 0($a2)
     beq $t3, $t1, prep
     beq $t3, $t2, prep
     beq $t3, $0, prep
     j print
     
   print:
     addi $t7, $t7, 1   #add 1 to the character count
     li $v0, 11
     add $a0, $0, $t3
     syscall
     j print_word
     
   prep:
     addi $t9, $t9, 1   #add 1 to the words printed
     sub $a2, $a2, $t7   #go back to the start of the book
     sub $t7, $t7, $t7   #set character count to 0
     addi $s3, $s3, 1   #go to the next X
     sub $t5, $t5, $t5
     addi $t4, $0, 1
     j loop
     #j load
     
   print_ln:
     li $v0, 11
     add $a0, $0, $t2
     syscall
     sub $a2, $a2, $t7   #go back to the start of the book
     sub $t7, $t7, $t7   #set character count to 0
     sub $t9, $t9, $t9   #set printed word per line count to 0
     sub $t5, $t5, $t5
     addi $t4, $0, 1
     addi $s3, $s3, 1   #go to the next X
     j loop                                                              
        
  end2:
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
