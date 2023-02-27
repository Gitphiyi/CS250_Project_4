.text
.align 2
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $s1, 0 #head = null pointer
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
        la $a1, escape
        jal strcmp
        move $t1, $v0 #check if its eequal or not
        beqz $t1, _break

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
        move $s1, $s3 #move node into head
        sw $0, 68($s1) #save 0 register to curr->next
        #move $a0, $s1 #put head as an argument
        #jal printList
        j _while_loop

        _else: #inserting node into correct place
        move $a0, $s3
        move $a1, $s1
        jal insertNode #insert node into list
        move $s1, $v0 #makes new head
        j _while_loop

    _break:
    #print out the sorted linked list
    move $a0, $s1 #put head as an argument
    jal printList
    j _exit_read

    #prints the entire list out in the terminal
    printList: 
        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s1, 4($sp)
        sw $s2, 8($sp)

        move $s1, $a0 #head node
        move $s2, $s1 #curr node
        _read_loop:
            la $a0, 0($s1) #name
            li $v0, 4
            syscall
            la $a0, spacebar #space
            li $v0, 4
            syscall
            lw $a0, 64($s1) #metric
            li $v0, 1
            syscall
            la $a0, newline
            li $v0, 4
            syscall
            lw $s2, 68($s1) #store next pointer
            beqz $s2, _done_reading
            move $s1, $s2
            j _read_loop
        _done_reading:
        lw $ra, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        addi $sp, $sp, 12
        jr $ra

    #inserts the node into the correct spot in the linked list. returns new head
    insertNode: # $a0 = node to be inserted, $a1 head
        addi $sp, $sp, -32
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)
        sw $s6, 28($sp)
        
        move $s0, $a0 #insert node (Node that needs to be inserted into the list)
        move $s1, $a1 #head
        move $s2, $s1 #curr
        _list_loop:
            #if node reaches pointer 0 or the end of the list
            beqz $s2, _break_list_loop
            #load metric into $s3 and $s4
            lw $s3, 64($s0)
            lw $s4, 64($s2)
            #if node is less than head loop through the list
            blt $s3, $s4, _less
            #if node is greater than head put before it 
            bgt $s3, $s4, _break_list_loop
            _equal:
            #if node is equal than compare by string
                la $a0, 0($s0)
                la $a1, 0($s2)
                jal strcmp
                move $s5, $v0 #this stores the comparison
                blt $s5, $0, _break_list_loop #if its less than the same metric then place before
                beqz $s5, _break_list_loop
                #if its greater than the same metric then place after
                j _less
            _less: #curr = curr->next 
                lw $s6, 68($s2) #load pointer in $s6
                move $s2, $s6 #make curr go to next node
                j _list_loop

        _break_list_loop:
        #if the node is bigger than the first node head then go to else. Check this by seeing if curr = head
        beq $s1, $s2, _greater_than_head
        #inserts it right before the current node
        move $s5, $s1 #load temporary curr node
        _loop_until_curr:
            lw $s6, 68($s5) #puts pointer of temp curr node into $s6
            beq $s6, $s2, _insert_before # if the pointer equals curr node then insert right before it
            #if node doesn't point to curr make temp curr equal its pointer
            move $s5, $s6
            j _loop_until_curr

            _insert_before: #puts the insert node right between $s5 and $s6
            sw $s0, 68($s5) #make $s5 point to $s0 which is insert node
            sw $s2, 68($s0) #make the insert node point to what $s5 used to point to which is $s6
            j _done
        _greater_than_head:
        sw $s1, 68($s0)
        move $s1, $s0

        _done:
        move $v0, $s1 #makes node the new head
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        addi $sp, $sp, 32
        jr $ra

    strcmp: #$a0 = string 1, $a1 = string 2     returns -1 for less than, 0 for same, and 1 for greater than
        addi $sp, $sp, -24
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)

        move $s0, $a0 #word 1
        move $s1, $a1 #word 2
        lb $s4, newline
        _compare_word_loop:
            lb $s2, 0($s0)
            lb $s3, 0($s1)
            bgt $s2, $s3, _bigger
            blt $s2, $s3, _lower
            #if the characters are equal make bigger or end
            beq $s2, $s4, _equal_string
            addi $s0, $s0, 1
            addi $s1, $s1, 1
            j _compare_word_loop
            _equal_string:
                li $v0, 0
                j _return
            _lower: #first word smaller than second. return -1
                li $v0, -1
                j _return
            _bigger: #first word larger than second. return 1
                li $v0, 1
                j _return
        _return:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        addi $sp, $sp, 24
        jr $ra
             

    lw_into_struct: #a0 = struct memory address, $a1 = string memory address
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        move $t0, $a1 #word
        move $t1, $a0 #node
        li $t4, 0
        #li $t3, 64
        lb $t3, newline
        _load_word_loop: #load in the word into memory one byte at a time and increases the register by 4 bytes after loading it in
            lb $t2, 0($t0) #word
            #beq $t4, $t3, _word_loaded #fix this by reading until new line rather than going all the way to 64 bytes
            beq $t2, $t3, _word_loaded
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
rebound: .asciiz "Please input the average rebounding differential per game: \n"
buffer: .space 63
escape: .asciiz "DONE\n"
spacebar: .asciiz " "
