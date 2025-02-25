#Ethan Tarkington
#Assembulers
#Project 2
#1583380
#ethantark

.data
error_message: .asciiz "input error!"     # Error message for invalid input
string_buff: .space 120                    # Buffer for user input strings
new_line: .asciiz "\n"                     # Newline
mult_char: .asciiz "X"                     # X for output (Multiply)
space_char: .asciiz " "                    # spacing
dash_line: .asciiz "----------"            # Dash line
max: .asciiz "2147483647"                  # Maximum 
min: .asciiz "-2147483648"                 # Minimum

.text

########### Main #########

main:
add $v1, $ra, $zero                        # Preserve return

## multiplier string from user input
li $v0, 8                                  # Syscall code 8: Read string
la $a0, string_buff                        # Load string buffer
li $a1, 120                                # maximum input length 120 char
syscall                                    # Read string

## Convert multiplier(string) to an integer
add $s2, $ra, $zero                        # Preserve return address
jal convert                                # Call convert string to integer

add $ra, $s2, $zero                        # Restore return address
add $s5, $v0, $zero                        # Save result of conversion(multiplier)

## Read multiplicand string
li $v0, 8                                  # Syscall code 8: Read string
la $a0, string_buff                        # Load address of string buffer
li $a1, 120                                # maximum input length 120 char
syscall                                    # Read string

## Convert multiplicand(string) to integer
add $s2, $ra, $zero                        # return address
jal convert                                # convert string to integer
add $ra, $s2, $zero                        # Restore return address
add $s4, $v0, $zero                        # Save result of conversion(multiplicand)

## Output the multiplier in binary
li $v0, 4                                  # Syscall code 4: Print string
la $a0, space_char                         # Load address of space character
syscall                                    # Print space

add $s2, $ra, $zero                        # Preserve return address
add $a0, $s5, $zero                        # Load multiplier value
jal binary_print                          # print binary

add $ra, $s2, $zero                        # Restore return address
li $v0, 4                                  # Syscall code 4: Print string
la $a0, new_line                           # Load address of newline character
syscall                                    # Print newline

## Output the multiplicand in binary
li $v0, 4                                  # Syscall code 4: Print string
la $a0, mult_char                          # load 'X' character
syscall                                    # Print 'X'

add $s2, $ra, $zero                        # Preserve return address
add $a0, $s4, $zero                        # Load multiplicand value
jal binary_print                          # print binary

add $ra, $s2, $zero                        # Restore return address
li $v0, 4                                  # Syscall code 4: Print string
la $a0, new_line                           # Load newline character
syscall                                    # Print newline

## call Booth's algorithm function
add $s2, $ra, $zero                        # Preserve return address
jal booth                                  # Call for Booth's algorithm
add $ra, $s2, $zero                        # Restore return address
jr $ra                                     # Return control OS

######## Int Casting Function ###############

convert:
    ## Initialize var
    li $s0, 10           # newline comparison
    li $s3, 0            # Exponent counter
    li $t0, 0            # Digit counter(for longer numbers)
    li $t8, 0            # Sign bit - 0 pos, 1 neg

## Loop to read each char of the string
counter:
    lbu $t1, string_buff($t0)    # Load byte from buffer for use
    
    beq $t1, $s0, checker        # Check for newline(\n)
    beq $t1, $zero, checker      # Check for null terminator(null)
    beq $t1, 45, negative_sign   # Check for "-" (negative sign)
    addi $t0, $t0, 1             # Move to next character
    j counter                    # Repeat

## Handling for negative sign
negative_sign:
    addi $t0, $t0, 1                # Move to next character
    li $t8, 1                        # Mark number as negative
    j counter                        # Continue loop

## Check for minimum input length
checker:
li $s1, 1                           # Minimum length
add $s1, $t8, $s1                   # remember for negative(-) character
bgt $s1, $t0, done2                 # input error for no number
li $s1, 0                           # Loop for string comparison

## Check for valid input range
beq $t8, 1, negative_range      #Checking what sign
bge $t0, 11, done2              # Checking if number 2 large
ble $t0, 9, range               #Checking numbers
j string_comp

## Handling for negative range
negative_range:
bge $t0, 12, done2              #Works about the same as pos just neg and different min
ble $t0, 10, range
j negative_comp

## String comparison for positive range
string_comp:
    lbu $t1, string_buff($s1)       # Load byte(Buff) 
    lbu $t2, max($s1)               # Load byte maximum value
    blt $t2, $t1, done2              # input error for value max
    bgt $t2, $t1, range
    beq $s1, 9, range               # Close loop
    addi $s1, $s1, 1                # add loop
    j string_comp                   # Repeat loop

## String comparison for negative range
negative_comp:
    lbu $t1, string_buff($s1)     # Load current byte from buffer
    lbu $t2, min($s1)         # Load current byte from maximum absolute value
    blt $t2, $t1, done2         # Jump if input is larger than absolute value max
    bgt $t2, $t1, range 
    beq $s1, 9, range          # Close loop
    addi $s1, $s1, 1                # Increment loop
    j negative_comp           # Repeat loop

## Handling for valid range
range:
    addi $t0, $t0, -1               # Adjust digits for zero indexing
    add $s3, $s3, $t0               # Used in exponentiation subloop

## Convert string to integer digit by digit
    li $s1, 0                        # Store sum of new integer
    bge $t8, 1, negative               # Multiply final answer by -1
    loop:
        lbu $t1, string_buff($t0) # Load current byte from buffer
        beq $t0, -1, done            # Quit when string ends (all 0-X digits processed)
        beq $t1, 45, skip      # Do not process "-" mathematically
        addi $t1, $t1, -48          # Convert ASCII character to integer
        ble $t1, -1, done2      # If number is negative, not a digit
        bge $t1, 10, done2      # If number has two digits, not a digit
        addi $t2, $t0, 0            # Incrementor for exponentiation
        li $t3, 1                    # First digit multiplied by one
        subloop:
            beq $t2, $s3, pass      # End loop
            mul $t3, $t3, 10        # Multiply by ten
            addi $t2, $t2, 1        # Increment loop counter
            j subloop               # Restart loop
        pass:                        # Return to superloop
        mul $t1, $t1, $t3            # Transform digit to fit decimal place
        add $s1, $s1, $t1            # Add digit to sum
        skip:                    # Jump here for negative signs
        addi $t0, $t0, -1            # Decrement decimal place
        j loop                        # Return to top to process next digit
    done:                            # Exit string to integer loop
    move $v0, $s1                   # Set return value
    jr $ra                          # Return control to caller

## Handling for negative number conversion
negative:
    lbu $t1, string_buff($t0)      # Load current byte from buffer
    beq $t0, -1, negative_done              # Quit when string ends (all 0-X digits processed)
    beq $t1, 45, negative_workaround             # Do not process "-" mathematically
    addi $t1, $t1, -48               # Convert ASCII character to integer
    addi $t2, $t0, 0                 # Incrementor for exponent
    li $t3, 1                         # First digit multiplied by one (Building Digit(Int))
    negative_loop:
        beq $t2, $s3, negative_end         # End loop
        mul $t3, $t3, 10             # Multiply by ten(Building Int)
        addi $t2, $t2, 1             # Increment loop counter
        j negative_loop              # start loop
    negative_end:                          # end of negative loop
    mul $t1, $t1, $t3                # Transform digit to fit decimal place
    sub $s1, $s1, $t1                # Subtract digit from sum (due to negative sign)
    negative_workaround:             # for negative signs
    addi $t0, $t0, -1                # Decrement decimal place
    j negative                          # Return for next digit
negative_done:                               # Exit string to integer loop
move $v0, $s1                        # Set return value
jr $ra                               # Return control to caller

######## Booth's Algorithm #############

booth:

    ## Print dash line preceding tracing of Booth's algorithm
    li $v0, 4            # Syscall code 4: Print string
    la $a0, dash_line    # Loading dash line
    syscall               # Print dash line

    li $v0, 4            # Syscall code 4: Print string
    la $a0, new_line     # Load newline
    syscall               # Print newline

    ## Initialize variables
    li $s0, 0            # $s0 is A(Accumulator) Remember! look at worksheet
    move $t1, $s4        # Q(multiplier) 1st
    ## M (multiplicand) is $s5 2nd
    li $t3, 33           # Counter
    li $t4, 0            # Q(-1)

    li $t7, 0            # Check counter for loop num
    check:                # check current value to do what is next
    beq $t3, $zero, finish  # Check if complete

    beq $t7, 0, first_run    # For first calculation
    ## Saving variables for function call
    move $s4, $t1

    li $v0, 4
    la $a0, space_char
    syscall

    ## Print A
    move $s6, $ra        # Preserve return address (A) $t1
    move $a0, $s0        # Load integer into arg field
    jal binary_print     # Call binary print

    move $ra, $s6        # Restore return address

    ## Print Q
    move $s6, $ra        # Preserve return address (Q) $t1
    move $a0, $s4        # Load integer into arg field
    jal binary_print    # Call function
    move $ra, $s6        # Restore return address

    ## Print newline
    li $v0, 4            # Syscall code 4: Print string
    la $a0, new_line     # Load newline string address
    syscall               # Print newline

    ## Restoring variables
    move $t1, $s4

    first_run:
        addi $t7, 1          # Stop prints from being skipped

        addi $t3, $t3, -1     # Decrement loop counter
        beq $t3, $zero, finish  # Check if calc is done


        ## Decide branch
        and $s7, $t1, 1          # Extract Q(0) to $s7
        beq $s7, $t4, equivalent  # If Q(0) equals Q(-1), go to equivalent
        slt $t5, $s7, $t4        # Determine whether to proceed with zero_one or one_zero
        beq $t5, 1, zero_one     # If Q(0) < Q(-1), go to zero_one
        beq $t5, 0, one_zero     # If Q(0) >= Q(-1), go to one_zero

    equivalent:              # Calc (1->1) or (0->0)
        and $t4, $t1, 1          # Set Q(-1) to Q(0)
        and $t6, $s0, 1          # Grab LSB of A for changing into Q
        sll $t6, $t6, 31         # Shift LSB to MSB position
        srl $t1, $t1, 1          # Shift right on Q
        or $t1, $t1, $t6         # Set MSB of Q to LSB of A(old)
        sra $s0, $s0, 1          # Shift right on A
        j check

    zero_one:                # Calculate (0->1)
        add $s0, $s0, $s5        # Add M to A
        and $t4, $t1, 1          # Set Q(-1) to Q(0)
        and $t6, $s0, 1          # Grab LSB of A for changing into Q
        sll $t6, $t6, 31         # Shift LSB to MSB position
        srl $t1, $t1, 1          # Shift right on Q
        or $t1, $t1, $t6         # Set MSB of Q to old LSB of A
        sra $s0, $s0, 1          # Shift right on A
        j check

    one_zero:                # Calculate (1->0)
        sub $s0, $s0, $s5        # Subtract M from A
        and $t4, $t1, 1          # Set Q(-1) to Q(0)
        and $t6, $s0, 1          # Grab LSB of A for changing into Q
        sll $t6, $t6, 31         # Shift LSB to MSB position
        srl $t1, $t1, 1          # Shift right on Q
        or $t1, $t1, $t6         # Set MSB of Q to old LSB of A
        sra $s0, $s0, 1          # Shift right on A
        j check

    finish:
        ## Print dash line after Booth algorithm
        li $v0, 4                # Syscall code 4: Print string
        la $a0, dash_line        # Load dash line string 
        syscall                  # Print dash line
        li $v0, 4                # Syscall code 4: Print string
        la $a0, new_line         # Load newline string
        syscall                  # Print newline

        ## Print final finish
        li $v0, 4
        la $a0, space_char
        syscall
        move $s6, $ra            # Preserve return address
        move $a0, $s0            # Load integer at $s0 into argument field
        jal binary_print       # Call binary print
        move $ra, $s6            # Restore return address
        move $s6, $ra            # Preserve return address
        move $a0, $s4            # Load integer at $t1 into argument field
        jal binary_print       # Call function
        move $ra, $s6            # Restore return address
        li $v0, 4                # Print string
        la $a0, new_line         # Load newline
        syscall                  # Print newline

        jr $ra                    # Return command


########### Binary Printing #############

binary_print:   # $a0 = register to print
    li $t0, 32     # Counter register length
    move $t2, $a0
    print_loop:
    srl $t1, $t2, 31     # Take LSB from register
    sll $t2, $t2, 1    # Loading register next bit
    li $v0, 1           # Syscall code 1: Print integer with syscall
    add $a0, $t1, $zero  # load to proper bit
    syscall             # Print integer
    addi $t0, $t0, -1  # -1 counter loop
    ble $t0, 0, end     # end when 0 go back to call
    j print_loop        # back to start of loop start
    end:                      # Exit
    jr $ra           # Return command

########## Input Error ############

done2:
    li $v0, 4        # Syscall code 4: Print string
    la $a0, error_message  # Load error message
    syscall           # Print error message

    li $v0, 4        # Syscall code 4: Print string
    la $a0, new_line # Load newline string address
    syscall           # Print newline

jr $v1           # Return control to OS
