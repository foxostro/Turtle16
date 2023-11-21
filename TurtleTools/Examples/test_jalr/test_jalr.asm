NOP
LA r0, target
LI r1, -2
JALR r5, r0
NOP
NOP
HLT
target:
STORE r1, r1, 0
JR r5
