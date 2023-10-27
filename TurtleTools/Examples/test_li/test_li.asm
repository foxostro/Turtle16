# Loads the value -1 into r7.
# Arranges for the CPU to halt after the LI instruction retires.
NOP
LI r7, -1
NOP
NOP
NOP
NOP
HLT
