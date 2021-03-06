LI D, 0xff
beginning:
LI A, 254
LI B, 255
CMP
CMP
LXY not_equal
JNE
NOP
NOP
LI D, 1
HLT
not_equal:
LI D, 0
HLT