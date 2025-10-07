        addi    r1, r0, 6          ; r1 = 6
        addi    r2, r0, 7          ; r2 = 7
        addi    r3, r0, 9          ; r3 = 9
        addi    r4, r0, 5          ; r4 = 5

        mult    r5, r1, r2          ; r5 = 6 * 7 = 42
        mult    r6, r3, r4          ; r6 = 9 * 5 = 45 

        addi    r7, r0, 42
        sub     r8, r5, r7
        bnez    r8, fail            ; check first mult result
        addi    r7, r0, 45
        sub     r9, r6, r7
        bnez    r9, fail            ; check second mult result

        div     r10, r5, r1         ; r10 = 42 / 6 = 7
        div     r11, r6, r4         ; r11 = 45 / 5 = 9 

        addi    r13, r0, 7
        sub     r14, r10, r13
        bnez    r14, fail           ; wrong quotient 1

        addi    r13, r0, 9
        sub     r15, r11, r13
        bnez    r15, fail           ; wrong quotient 2


        addi    r12, r0, 1          ; success flag
        j       done

fail:
        addi    r12, r0, -1         ; failure flag

done:
        j       done               
