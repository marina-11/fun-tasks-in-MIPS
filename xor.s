#=========================================================================
# XOR Cipher Encryption
#=========================================================================
# Encrypts a given text with a given key.
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

input_text_file_name:         .asciiz  "input_xor.txt"
key_file_name:                .asciiz  "key_xor.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
key:                          .space 33          # Maximum size of key_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

new_key:                      .space 5
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


# opening file for reading (key)

        li   $v0, 13                    # system call for open file
        la   $a0, key_file_name         # key file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # key[idx] = c_input
        la   $a1, key($t0)              # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, key($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  key($t0)              # key[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
# You can add your code here!

    #la $a0, key
    #li $v0, 4
    #syscall
    #move $s1, $a0

    la $s1, key			
    la $a0, new_key
    
    #addi $t4, $0, 48   #ASCII number for '0'
    #addi $t5, $0, 49   #ASCII number for '1'
    addi $s5, $0, 9   #counter for characters in each 'byte' of the key
    addi $s6, $0, 1   #counter for for 'bytes' in a key / should go up to 4
    
    addi $s0, $0, 0   # value for 1st KEY-byte
    addi $s2, $0, 0   # value for 2nd KEY-byte
    addi $s3, $0, 0   # value for 3rd KEY-byte
    addi $s4, $0, 0   # value for 4th KEY-byte
    
    addi $t0, $0, 8
    addi $t4, $0, 7
    addi $t5, $0, 6
    addi $t6, $0, 5
    addi $t7, $0, 4
    addi $t8, $0, 3
    addi $t9, $0, 2
    addi $s7, $0, 1
    # $0
    
    
  modify_key:
       lb $t3, 0($s1) 
       beq $t3, $0, end
       addi $s5, $s5, -1   #counter = counter - 1
       beqz $s5, reset_counter
       addi $t3, $t3, -48
       beq $t3, $s7, get_number   #if the character is 1 then go to get_number
       addi $s1, $s1, 1
       j modify_key
       
  get_number:
       beq $s5, $t0, onetwoeight
       beq $s5, $t4, sixtyfour
       beq $s5, $t5, thirtytwo
       beq $s5, $t6, sixteen
       beq $s5, $t7, eight
       beq $s5, $t8, four
       beq $s5, $t9, two
       beq $s5, $s7, one
              
  onetwoeight:
      beq $s6, $s7, key1_pos8
      beq $s6, $t9, key2_pos8
      beq $s6, $t8, key3_pos8
      beq $s6, $t7, key4_pos8
      
    key1_pos8:
      addi $s0, $s0, 128
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos8:
      addi $s2, $s2, 128
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos8:
      addi $s3, $s3, 128
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos8:
      addi $s4, $s4, 128
      addi $s1, $s1, 1
      j modify_key
                  
  sixtyfour:
      beq $s6, $s7, key1_pos7
      beq $s6, $t9, key2_pos7
      beq $s6, $t8, key3_pos7
      beq $s6, $t7, key4_pos7
      
    key1_pos7:
      addi $s0, $s0, 64
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos7:
      addi $s2, $s2, 64
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos7:
      addi $s3, $s3, 64
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos7:
      addi $s4, $s4, 64   
      addi $s1, $s1, 1
      j modify_key                                         
      
  thirtytwo:
      beq $s6, $s7, key1_pos6
      beq $s6, $t9, key2_pos6
      beq $s6, $t8, key3_pos6
      beq $s6, $t7, key4_pos6
      
    key1_pos6:
      addi $s0, $s0, 32
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos6:
      addi $s2, $s2, 32
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos6:
      addi $s3, $s3, 32
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos6:
      addi $s4, $s4, 32 
      addi $s1, $s1, 1
      j modify_key                                 
      
  sixteen:
      beq $s6, $s7, key1_pos5
      beq $s6, $t9, key2_pos5
      beq $s6, $t8, key3_pos5
      beq $s6, $t7, key4_pos5
     
    key1_pos5:
      addi $s0, $s0, 16
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos5:
      addi $s2, $s2, 16
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos5:
      addi $s3, $s3, 16
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos5:
      addi $s4, $s4, 16  
      addi $s1, $s1, 1
      j modify_key                             
      
  eight:
      beq $s6, $s7, key1_pos4
      beq $s6, $t9, key2_pos4
      beq $s6, $t8, key3_pos4
      beq $s6, $t7, key4_pos4
      
    key1_pos4:
      addi $s0, $s0, 8
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos4:
      addi $s2, $s2, 8
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos4:
      addi $s3, $s3, 8
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos4:
      addi $s4, $s4, 8   
      addi $s1, $s1, 1 
      j modify_key                          
      
  four:
      beq $s6, $s7, key1_pos3
      beq $s6, $t9, key2_pos3
      beq $s6, $t8, key3_pos3
      beq $s6, $t7, key4_pos3
      
    key1_pos3:
      addi $s0, $s0, 4
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos3:
      addi $s2, $s2, 4
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos3:
      addi $s3, $s3, 4
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos3:
      addi $s4, $s4, 4 
      addi $s1, $s1, 1
      j modify_key                               
                                                                                                        
  two:
      beq $s6, $s7, key1_pos2
      beq $s6, $t9, key2_pos2
      beq $s6, $t8, key3_pos2
      beq $s6, $t7, key4_pos2
      
    key1_pos2:
      addi $s0, $s0, 2
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos2:
      addi $s2, $s2, 2
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos2:
      addi $s3, $s3, 2
      addi $s1, $s1, 1
      j modify_key
      
    key4_pos2:
      addi $s4, $s4, 2 
      addi $s1, $s1, 1  
      j modify_key                           
      
  one:
      beq $s6, $s7, key1_pos1
      beq $s6, $t9, key2_pos1
      beq $s6, $t8, key3_pos1
      beq $s6, $t7, key4_pos1
      
    key1_pos1:
      addi $s0, $s0, 1
      addi $s1, $s1, 1
      j modify_key
      
    key2_pos1:
      addi $s2, $s2, 1
      addi $s1, $s1, 1
      j modify_key
      
    key3_pos1: 
      addi $s3, $s3, 1
      addi $s1, $s1, 1
      j modify_key 
      
    key4_pos1:
      addi $s4, $s4, 1
      addi $s1, $s1, 1
      j modify_key                               
                           
       
  reset_counter:
       addi $s5, $0, 9
       addi $s6, $s6, 1  
       j modify_key   
         
  end:
    beq $s6, $s7, onekey
    beq $s6, $t9, twokeys
    beq $s6, $t8, threekeys
    beq $s6, $t7, fourkeys
    
   onekey:
    sb $s0, 0($a0)
    addi $a0, $a0, 1
    sb $0, 0($a0) 
    
   twokeys:
    sb $s0, 0($a0)
    addi $a0, $a0, 1
    sb $s2, 0($a0)
    addi $a0, $a0, 1
    sb $0, 0($a0)
    
   threekeys:
    sb $s0, 0($a0)
    addi $a0, $a0, 1
    sb $s2, 0($a0)
    addi $a0, $a0, 1
    sb $s3, 0($a0)
    addi $a0, $a0, 1
    sb $0, 0($a0)
    
   fourkeys:
    sb $s0, 0($a0)
    addi $a0, $a0, 1
    sb $s2, 0($a0)
    addi $a0, $a0, 1
    sb $s3, 0($a0)
    addi $a0, $a0, 1    
    sb $s4, 0($a0)
    addi $a0, $a0, 1 
    sb $0, 0($a0)  
    
  move $s0, $a0
  
 #print_loop:
  # lb $a0, 0($s0)
  # beq $a0, $0, main_end
  # li $v0, 1
  # syscall
  # addi $s0, $s0, 1
  # j print_loop    
   
   
  la $a1, input_text
  la $s0, new_key
  
  addi $s1, $0, 0   #counter for newkey
  addi $t1, $0, 32   #ASCII number for 'space'
  addi $t2, $0, 10   #ASCII number for \n
  
  loop:
    lb $a2, 0($a1)   #load byte from input text
    beq $a2, $0, main_end
    lb $a3, 0($s0)   #load byte from new key
    beq $a3, $0, rescount   #if byte from new key is \0 then restore count
    beq $a2, $t1, space
    beq $a2, $t2, line
    xor $v1, $a2, $a3
    add $a0, $0, $v1
    li $v0, 11
    syscall
    addi $s1, $s1, 1
    addi $a1, $a1, 1
    addi $s0, $s0, 1
    j loop
    
  rescount:
    #addi $v1, $s1, -1   #counter-1
    sub $s0, $s0, $s1   #go back to the beginning of array
    sub $s1, $s1, $s1
    j loop
    
  space:
    addi $s1, $s1, 1      
    addi $a1, $a1, 1
    addi $s0, $s0, 1
    li $v0, 11
    add $a0, $0, $t1
    syscall 
    j loop
    
  line:
    addi $s1, $s1, 1      
    addi $a1, $a1, 1
    addi $s0, $s0, 1
    li $v0, 11
    add $a0, $0, $t2
    syscall 
    j loop  
    

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
