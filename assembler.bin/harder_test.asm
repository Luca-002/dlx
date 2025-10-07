        addi    r7, r0, 40      ; r7 = base address for array 
        addi    r1, r0, -5
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, 3
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, -1
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, 7
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, -8
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, 12
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, 0
        sw      0(r7), r1
        addi    r7, r7, 4
        addi    r1, r0, 5
        sw      0(r7), r1
        addi    r7, r0, 40       ; reset pointer to base
        addi    r6, r0, 8        ; r6 = element count

        ; load first element to initialize some accumulators
        lw      r14, 0(r7)       ; r14 = current signed max = first element
        add     r5, r0, r14      ; r5 = sum = first element

        ; initialize pos/neg/zero counts from first element
        slt     r12, r14, r0     ; r12 = 1 if first < 0 (signed)
        beqz    r12, init_first_nonneg
        addi    r9, r0, 1        ; neg_count = 1
        j       init_after_sign
init_first_nonneg:
        seq     r13, r14, r0     ; r13 = 1 if first == 0
        beqz    r13, init_first_pos
        addi    r15, r0, 1       ; zero found (flag) -- r15 = 1
        j       init_after_sign
init_first_pos:
        addi    r8, r0, 1        ; pos_count = 1
init_after_sign:
        addi    r7, r7, 4        ; advance pointer past first
        addi    r6, r6, -1       ; decrement remaining count
scan_loop:
        beqz    r6, scan_done
        lw      r11, 0(r7)       ; r11 = current element
        add     r5, r5, r11      ; sum += element

        ; update signed max: if r14 < r11 (signed), then r14 = r11
        slt     r13, r14, r11
        beqz    r13, skip_max_update
        add     r14, r11, r0
skip_max_update:

        ; classify sign: negative / zero / positive
        slt     r13, r11, r0     ; r13 = 1 if element < 0 (signed)
        beqz    r13, not_neg_here
        addi    r9, r9, 1        ; neg_count++
        j       after_classify
not_neg_here:
        seq     r13, r11, r0     ; r13 = 1 if element == 0
        beqz    r13, is_positive
        addi    r15, r0, 1       ; zero found flag
        j       after_classify
is_positive:
        addi    r8, r8, 1        ; pos_count++

after_classify:
        addi    r7, r7, 4        ; advance pointer
        addi    r6, r6, -1       ; decrement counter
        j       scan_loop

scan_done:
        addi    r1, r0, -1       ; r1 = -1 (0xFFFFFFFF)
        addi    r2, r0, 1        ; r2 = 1
        slt     r3, r1, r2       ; signed: -1 < 1 -> r3 = 1
        sltu    r4, r1, r2       ; unsigned: 0xFFFFFFFF < 1 -> r4 = 0
        addi    r17, r0, 13
        seq     r18, r5, r17     ; sum==13 ?
        addi    r17, r0, 4
        seq     r19, r8, r17     ; pos_count==4 ?
        addi    r17, r0, 3
        seq     r20, r9, r17     ; neg_count==3 ?
        addi    r17, r0, 12
        seq     r21, r14, r17    ; signed max==12 ?
        addi    r17, r0, 1
        seq     r22, r3, r17     ; slt result == 1 ?
        addi    r17, r0, 0
        seq     r23, r4, r17     ; sltu result == 0 ?

        ; sum the check results 
        add     r24, r18, r19
        add     r24, r24, r20
        add     r24, r24, r21
        add     r24, r24, r22
        add     r24, r24, r23
        addi    r17, r0, 6
        seq     r26, r24, r17    ; all checks ok -> r26 = 1

        beqz    r26, hard_fail
        addi    r25, r0, 1       ; success flag = 1
        j       hard_done
hard_fail:
        addi    r25, r0, -1      ; failure flag = -1
hard_done:
        j       hard_done   
