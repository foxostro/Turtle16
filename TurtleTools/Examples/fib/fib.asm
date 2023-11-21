# Turtle16 program to compute fibonacci numbers.
# Results are output on the system bus on each iteration.
LI r0, 0
LI r1, 1
LI r7, 0
LI r6, -2
loop:
ADD r2, r0, r1
STORE r2, r6
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 5
NOP
BLT loop
HLT
