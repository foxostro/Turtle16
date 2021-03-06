LI D, 1
LI A, 254
LI B, 255
CMP
LXY not_equal
JNE
NOP
NOP
LI D, 2
HLT
not_equal:
LI D, 255
HLT
