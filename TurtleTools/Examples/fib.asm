# Turtle16 program to compute fibonacci numbers.
LI r0, 0
LI r1, 1
LI r7, 0
LI r6, -1
loop:
ADD r2, r0, r1
STORE r2, r6
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
BLT loop
HLT
