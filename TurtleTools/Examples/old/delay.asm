beginning:

LI A, 0
LI B, 0
LI D, 0
LI X, 0
LI Y, 0
LI U, 0
LI V, 0

LI A, 0
delay65536_0:
MOV U, A
LI A, 0
delay256_0:
LI B, 1
ADD A
LI B, 255
CMP
LXY delay256_0
JNE
NOP
NOP
MOV A, U
LI B, 1
ADD A
LI B, 255
CMP
LXY delay65536_0
JNE
NOP
NOP

LI D, 255

LI A, 0
delay65536_1:
MOV U, A
LI A, 0
delay256_1:
LI B, 1
ADD A
LI B, 255
CMP
LXY delay256_1
JNE
NOP
NOP
MOV A, U
LI B, 1
ADD A
LI B, 255
CMP
LXY delay65536_1
JNE
NOP
NOP

LXY beginning
JMP
NOP
NOP

HLT