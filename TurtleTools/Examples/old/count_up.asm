LI D, 0xaa
LI A, 0
LXY beginning
beginning:
LI B, 1
ADD U # We ned to discard the result of the first one.
ADD A
LI B, 255
CMP
CMP
NOP
JNE
NOP
NOP
LI D, 0xff
HLT
