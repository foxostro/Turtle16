# Turtle16 program to compute fibonacci numbers.
LI r0, 0
LI r1, 1
LI r7, 0
loop:
ADD r2, r0, r1
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
BLT loop
HLT
