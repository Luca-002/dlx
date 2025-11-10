       ; sets r29 = 1 on success, r29 = -1 on first failure

        addi    r29, r0, 1        ; r29 = success flag 

 
        ; simple arith tests
 
        addi    r1, r0, 10       ; r1 = 10
        addi    r2, r0, 3        ; r2 = 3
        add     r3, r1, r2       ; r3 = 13
        addi    r17, r0, 13
        seq     r30, r3, r17     ; r30 = 1 if 13 == r3
        beqz    r30, fail

        subi    r4, r3, 4        ; r4 = 9  (testing subi)
        addi    r17, r0, 9
        seq     r30, r4, r17
        beqz    r30, fail

        sub     r5, r4, r2       ; r5 = 6  (testing sub)
        addi    r17, r0, 6
        seq     r30, r5, r17
        beqz    r30, fail

        ; addu / addui / subu / subui (unsigned variants)
        addui   r6, r0, 0xFFFFFFFF ; r6 = -1 unsigned 
        addi    r7, r0, 1
        addu    r8, r6, r7        ; r8 = 0 (wrap-around)
        addi    r17, r0, 0
        seq     r30, r8, r17
        beqz    r30, fail

        subu    r9, r8, r7        ; r9 = -1 unsigned (wrap)
        addi    r17, r0, -1
        seq     r30, r9, r17
        beqz    r30, fail

        subui   r9, r9, 1         ; r9 = -2 (unsigned/subui test)
        addi    r17, r0, -2
        seq     r30, r9, r17
        beqz    r30, fail

 
        ; logical ops
 
        and     r10, r1, r2       ; r10 = 10 & 3 = 2
        addi    r17, r0, 2
        seq     r30, r10, r17
        beqz    r30, fail

        andi    r11, r1, 1        ; r11 = 10 & 1 = 0
        addi    r17, r0, 0
        seq     r30, r11, r17
        beqz    r30, fail

        or      r12, r1, r2       ; r12 = 11
        addi    r17, r0, 11
        seq     r30, r12, r17
        beqz    r30, fail

        ori     r13, r2, 8        ; r13 = 3 | 8 = 11
        addi    r17, r0, 11
        seq     r30, r13, r17
        beqz    r30, fail

        xor     r14, r1, r2       ; r14 = 10 ^ 3 = 9
        addi    r17, r0, 9
        seq     r30, r14, r17
        beqz    r30, fail

        xori    r15, r1, 8        ; r15 = 10 ^ 8 = 2
        addi    r17, r0, 2
        seq     r30, r15, r17
        beqz    r30, fail

 
        ; shifts: sll/slli, srl/srli, sra/srai
 
        sll     r16, r1, r2       ; r16 = r1 << r2 (10 << 3 = 80 if r2 was 3 but r2=3, ok)
        ; to be safe use slli as well:
        slli    r16, r1, 1        ; r16 = 10 << 1 = 20
        addi    r17, r0, 20
        seq     r30, r16, r17
        beqz    r30, fail

        srl     r16, r16, r2      ; logical shift right r16 >> 3: 20 >> 3 = 2
        addi    r17, r0, 2
        seq     r30, r16, r17
        beqz    r30, fail

        srli    r16, r16, 1       ; 2 >> 1 = 1
        addi    r17, r0, 1
        seq     r30, r16, r17
        beqz    r30, fail

        addi    r18, r0, -8       ; r18 = -8
        sra     r19, r18, r2      ; arithmetic shift right: -8 >> 3 = -1
        addi    r17, r0, -1
        seq     r30, r19, r17
        beqz    r30, fail

        srai    r19, r18, 1       ; -8 >> 1 = -4
        addi    r17, r0, -4
        seq     r30, r19, r17
        beqz    r30, fail

 
        ; comparisons: slt/slti/sl tu/sl tui, sge/sgei/sgeu/sgeui, sgt/sgti/sgtu/sgtui, sle/slei
 
        addi    r20, r0, 5
        addi    r21, r0, -1

        slt     r22, r21, r20     ; -1 < 5 -> r22 = 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        slti    r22, r20, 10      ; 5 < 10 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sltu    r22, r21, r20     ; unsigned: 0xFFFFFFFF < 5 -> 0
        addi    r17, r0, 0
        seq     r30, r22, r17
        beqz    r30, fail

        sltui   r22, r20, 10      ; unsigned 5 < 10 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sge     r22, r20, r21     ; 5 >= -1 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sgei    r22, r20, -1      ; 5 >= -1 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sgeu    r22, r20, r21     ; unsigned 5 >= 0xFFFFFFFF -> 0
        addi    r17, r0, 0
        seq     r30, r22, r17
        beqz    r30, fail

        sgeui   r22, r20, 5       ; 5 >= 5 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sgt     r22, r20, r21     ; 5 > -1 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sgti    r22, r20, 4       ; 5 > 4 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sgtu    r22, r20, r21     ; unsigned 5 > 0xFFFFFFFF -> 0 
        addi    r17, r0, 0
        seq     r30, r22, r17
        beqz    r30, fail

        sgtui   r22, r20, 1       ; 5 > 1 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        sle     r22, r21, r20     ; -1 <= 5 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

        slei    r22, r20, 5       ; 5 <= 5 -> 1
        addi    r17, r0, 1
        seq     r30, r22, r17
        beqz    r30, fail

 
        ; equality/inequality (seq, seqi, sne, snei)
 
        addi    r23, r0, 42
        add     r24, r23, r0
        seq     r22, r24, r23     ; equal -> 1
        beqz    r22, fail
        seqi    r22, r24, 42     ; immediate equal
        beqz    r22, fail
        addi    r17, r0, 100
        sne     r22, r24, r17     ; 42 != 100 -> 1
        beqz    r22, fail
        snei    r22, r24, 43      ; 42 != 43 -> 1
        beqz    r22, fail

 
        ; load/store word/half/byte tests
 
        addi    r20, r0, 10       ; r20 = base
        addi    r1, r0, 0x1234
        sw      0(r20), r1        ; mem[10] = 0x1234
        lw      r2, 0(r20)
        seq     r22, r2, r1
        beqz    r22, fail

        addi    r21, r0, 0x7F     ; byte value 127
        sb      4(r20), r21       ; store byte at 14
        lb      r22, 4(r20)       ; sign-extended -> 127
        addi    r17, r0, 127
        seq     r30, r22, r17
        beqz    r30, fail

        addi    r21, r0, -1
        sb      5(r20), r21       ; store byte -1 (0xFF)
        lb      r22, 5(r20)       ; sign-extended -> -1
        addi    r17, r0, -1
        seq     r30, r22, r17
        beqz    r30, fail

        lbu     r22, 5(r20)       ; unsigned -> 255
        addi    r17, r0, 255
        seq     r30, r22, r17
        beqz    r30, fail

        ; halfword tests

        addi    r21, r0, 0x7FFF
        sw      8(r20), r21       ; write as a word for simplicity
        lhu     r22, 8(r20)       ; lower half -> 0x7FFF
        addi    r17, r0, 0x7FFF
        seq     r30, r22, r17
        beqz    r30, fail

        ; lhi test: load-high immediate

        lhi     r25, 0x1234       ; r25 = 0x12340000 
        addi    r17, r0, 0x1234
        slli    r26, r17, 16
        seq     r30, r25, r26
        beqz    r30, fail

 
        ; load/store word check (sw/lw already tested above)
 
        addi    r3, r0, 77
        sw      12(r20), r3
        lw      r4, 12(r20)
        addi    r17, r0, 77
        seq     r30, r4, r17
        beqz    r30, fail

 
        ; jal / jr / jalr tests 
 
        jal     call_sub1        ; jump and link -> r31 should hold return
        ; after return, sub1 should have set r5 = 111
        addi    r17, r0, 111
        seq     r30, r5, r17
        beqz    r30, fail

        jal     call_sub2
        addi    r17, r0, 222
        seq     r30, r6, r17     ; call_sub2 sets r6 = 222
        beqz    r30, fail

 
        ; nop test

        nop

        ; div test (42 / 7 = 6)

        addi    r1, r0, 42       ; r1 = 42
        addi    r2, r0, 7        ; r2 = 7
        div     r27, r1, r2      ; r27 = 42 / 7 = 6
        addi    r17, r0, 6
        seq     r30, r27, r17
        beqz    r30, fail

        ; mult test

        addi    r1, r0, 6
        addi    r2, r0, 7
        mult    r3, r1, r2        ; r3 = 42 
        addi    r17, r0, 42
        seq     r30, r3, r17
        beqz    r30, fail

        ; if reached here all tests passed
        j       end

 
        ; subroutines for jal/jalr test

call_sub1:
        addi    r5, r0, 111     
        jr      r31              ; return 

call_sub2:
        addi    r6, r0, 222     
        jalr    r31              ; return using jalr with r31


fail:
        addi    r29, r0, -1      
        j       end

 
end:
        j       end
