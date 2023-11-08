# Turtle16 program to compute fibonacci numbers.
# Results are output on the system bus on each iteration.
#
# BUG: This program cannot be run with ControlModule, Rev C because a jump
# instruction must stall the pipeline. The Rev C PCB has a hardware bug where
# any stall will cause the CPU to execute incorrect instructions.
#
# BUG: I think there's a bug where STORE does not stall the pipeline to resolve
# RAW hazards. I had to insert two NOPs between ADD and STORE to ensure the r2
# register had the correct when STORE gets its operands.
LI r0, 0
LI r1, 1
LI r7, 0
LI r6, -1
loop:
ADD r2, r0, r1
NOP
NOP
STORE r2, r6
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
BLT loop
HLT
