NOP
LI r0, 1
LI r1, 2
JMP target
STORE r0, r0, 0
NOP
NOP
HLT
target:
STORE r1, r1, 0
NOP
NOP
HLT
