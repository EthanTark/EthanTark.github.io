# User Input for terminal 10 is the code for user input
.text
main:

# User Input for terminal 10 is the code for user input
li $v0, 8              
la $a0, buffer            
li $a1, 10                 
add $s0, $a0, $zero            
syscall

# Printing user input string 
la $a0,input
li $v0,4
syscall

# Printing the user input
add $a0,$s0, $zero
li $v0,4
syscall

#loading bits & sending over to convert
li $s1, 0                  
lbu $t0, ($s0)
addi $t0, $t0, -48        
add $s1, $s1, $t0          
addi $s0, $s0, 1  
add $a2, $s0, $zero
lbu $t0, ($s0) 

jal convert                

# Call the Fibonacci function while loading it up for function
add $a0, $s1, $zero 
li $t9,2
li $t8,1
li $t7,0
li $v0,1
jal fibo
add $t3, $v0, $zero  # Storing the Fibonacci result in $t3


# Printing "the Fibonacci number is "
la $a0,fibbo
li $v0,4
syscall

# Printing awn
add $a0,$t3, $zero  
li $v0,1
syscall

#Print new line or '\n' 
la $a0,end
li $v0,4
syscall


# end
li $v0,10
syscall

convert:
   beq $t0, $a1, exit    
    addi $t0, $t0, -48      
    mul $t2, $s1, 10          
    add $s1, $t2, $t0          
    addi $s0 $s0, 1            
    lbu $t0, ($s0)            

    j convert      
exit:
    jr $ra 

fibo:
    # return fibo
    # for 0 and 1 return
    beq $a0,1,ze 
    beq $a0,2,one 

    bge $a0, 48, done2 
    beq $t9,$a0, done

    add $v0,$t8, $t7
    add $t7,$t8, $zero
    add $t8,$v0, $zero
    addi $t9,$t9, 1

    j fibo

    done:
        jr $ra
    done2:
    li $v0,-1
    jr $ra

ze:
    li $v0,0
    jr $ra
    one:
    li $v0,1
    jr $ra

out:
   # Printing "the Fibonacci number is "
    la $a0,fibbo
    li $v0,4
    syscall

    # Printing awn
    li $v0, -1
    add $a0,$v0, $zero  
    li $v0,1
    syscall

    #Print new line or '\n' 
    la $a0,end
    li $v0,4
    syscall


    # end
    li $v0,10
    syscall

    jr $ra

.data
    end: .asciiz "\n"
    buffer: .space 8
    input: .asciiz "user input value = "
    fibbo: .asciiz "the Fibonacci number is "
