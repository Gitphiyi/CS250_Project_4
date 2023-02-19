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
        sub $t4, $t1, $t2
        add $t4, $t4, $t3 #t4 has the metric    

        #making the List Nodes
        li $a0, 72 #must be a multiple of 4. string(63) + int(4) + address(4)
        li $v0, 9
        syscall #creates node
        move $s3, $v0 #puts address of the node into s3
        sw $t0, 0($s3)
        sw $t4, 62($s3)

        beqz $s1, _else #if statement to see if head == NULL
        #if head is first node
        move $s1, $s3 #moves node into head
        move $s2, $s1 #sets curr = head
        j _while_loop

        _else:
        la $t0, 66($s1) #load address of curr->next
        la $t0, 0($s3) #set curr->next = node
        la $s1, 0($t0) #set curr= curr->next
        j _while_loop
    
    _break:
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
