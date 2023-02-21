.text
.align 2
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $s1, 0 #head = null pointer
    li $s2, 0 #curr
    #creates all the list nodes
    _while_loop:
        #asks for team name
        la $a0, team_prompt
        li $v0, 4
        syscall
        la $a0, buffer
        li $a1, 63
        li $v0, 8
        syscall

        move $t0, $a0 #name stored in $t0
        lb $t5, newline
        la $t1, escape #puts DONE in $t1
        _loop:
            lb $t2, 0($t0)
            lb $t3, 0($t1)
            sub $t4, $t3, $t2
            bne $t4, $0, _end_loop #branch doesn't match up so it is not DONE
            
            #if characters are equal
            beq $t2, $t5, _break #if it reaches last character
            #increment both addresses by one
            addi $t0, $t0, 1
            addi $t1, $t1, 1
            j _loop
        _end_loop:
        #asks for avg points
        la $a0, avg_pts
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t1, $v0
        #asks for avg conceded
        la $a0, avg_conceded
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t2, $v0
        #asks for rebounds
        la $a0, rebound
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t3, $v0
        sub $t1, $t1, $t2
        add $t4, $t1, $t3 #t4 has the metric    


        #making the List Nodes ($t0 = name, $t4 = metric)
        li $a0, 72 #must be a multiple of 4. string(63) + int(4) + address(4) all in bytes
        li $v0, 9
        syscall #creates node
        move $s3, $v0 #puts address of the node into s3
        sw $t4, 64($s3) #put metric into node

        move $a0, $s3 #put node address as an argument
        move $a1, $t0 #put string as an argument
            addi $sp, $sp, -20
            sw $t0, 0($sp)
            sw $t1, 4($sp)
            sw $t2, 8($sp)
            sw $t3, 12($sp)
            sw $t4, 16($sp)
                jal lw_into_struct #stores the name into node
            lw $t0, 0($sp)
            lw $t1, 4($sp)
            lw $t2, 8($sp)
            lw $t3, 12($sp)
            sw $t4, 16($sp)
            addi $sp, $sp, 20

        bnez $s1, _else #if statement to see if head == NULL
        #if head is first node
        move $s1, $s3 #move node into head
        move $s2, $s1 #set curr = head
        #sw $0, 68($s2) #set curr->next = null
        j _while_loop

        _else:
        sw $s3, 68($s2) #set curr->next = node
        move $s2, $s3 #set curr = curr->next
        j _while_loop

    _break:
    sw $0, 68($s2) #save 0 register to curr->next
    #sort the linked list
    #print out the linked list
    _read_loop:
        la $a0, 0($s1) #name
        li $v0, 4
        syscall
        lw $a0, 64($s1) #metric
        li $v0, 1
        syscall
        la $a0, newline
        li $v0, 4
        syscall
        
        lw $s3, 68($s1) #store next pointer
        beqz $s3, _exit_read
        move $s1, $s3
        j _read_loop


    lw_into_struct: #a0 = struct memory address, $a1 = string memory address
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        move $t0, $a1 #word
        move $t1, $a0 #node
        li $t4, 0
        li $t3, 64
        _load_word_loop: #load in the word into memory one byte at a time and increases the register by 4 bytes after loading it in
            lb $t2, 0($t0) #word
            beq $t4, $t3, _word_loaded
            sb $t2, 0($t1)
            addi $t0, $t0, 1
            addi $t1, $t1, 1
            addi $t4, $t4, 4
            j _load_word_loop
        _word_loaded:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    _exit_read:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0
    jr $ra        

.data
newline: .asciiz "\n"
team_prompt: .asciiz "Please input a Team Name: \n"
avg_pts: .asciiz "Please input the average points scored per game: \n"
avg_conceded: .asciiz "Please input the average points given up per game: \n"
rebound: .asciiz "Please input the average reboinding differential per game: \n"
buffer: .space 63
escape: .asciiz "DONE\n"
