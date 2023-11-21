NOP
LI r0, 1
LI r3, -2
CMPI r0, 1
BEQ equal
LI r1, 1
STORE r1, r3, 0
NOP
NOP
HLT
equal:
LI r1, 2
STORE r1, r3, 0
NOP
NOP
HLT
