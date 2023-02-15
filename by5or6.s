.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, prompt
    syscall#prompt for integer to enter

    li $v0, 5
    syscall 
    move $t0, $v0 #get input which is put into t0

    li $v0, 4
    la $a0, newline
    syscall#new line

    li $t1, 0 #counter
    _while_loop:
        beq $t1, $t0, _exit_loop #loops until user input
        li $s0, 5
        div $t1, $s0
        mfhi $s0
        beq $s0, 0, add_counter #if number is divisible by 5
        li $s0, 6
        div $t1, $s0
        mfhi $s0
        beq $s0, 0, add_counter #if number is divisible by 6
        addi $t1, $t1, 1
        j _while_loop

        add_counter: #if the number is divisible by 5 or 6 print it out
            addi $a0, $t1, 0
            li $v0, 1
            syscall #print number
            li $v0, 4 
            la $a0, newline
            syscall#print newline
            addi $t1, $t1, 1
            j _while_loop
    
    _exit_loop:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        li $v0, 0 #return successfully
        jr $ra

.data
prompt: .asciiz "Please enter an integer: "
newline: .asciiz "\n"