    ADDI 31, 2, 5
    SB r31, 1(r0)
    ADDU r2, r1, r0
load:
    LB r1, 4(r0)
    J add
    BEQ r2, r4, load
    JALR 10, 11
add:
    ADDI 11, 2, 5
    nop
    halt