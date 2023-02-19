.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, prompt
    syscall #prompt for integer to enter

    li $v0, 5
    syscall 
    move $a0, $v0 #get input which is put into a0
    #a0 is N and N slowly increments down
    jal recurse

    move $a0, $v0
    li $v0, 1
    syscall #print output of recurse
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0
    jr $ra

recurse: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    #base case
    li $s0 0
    beq $a0, $s0, _basecase #if n == 0 go to base case

    addi $sp, $sp, -4
    move $s0, $a0
    sw $s0, 0($sp)#save s0 to use for calculations
    addi $a0, $a0, -1 #goes down recursion recurse(n-1)
    jal recurse  
    #returning back up and doing calculations
    li $s1, 2
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    mult $s0, $s1
    mflo $s0
    add $v0, $v0, $s0
    addi $v0, $v0, -1
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
_basecase:
    li $v0, 2
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
.data
newline: .asciiz "\n"
prompt: .asciiz "Please enter an integer: "