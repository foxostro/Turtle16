# let kSerialInterface = 6
# let kIORegister = 0
# let kControlRegister = 2

LI D, 6 # kSerialInterface
LI Y, 2 # kControlRegister

LI P, 'r' # 'r' is the command for Reset
LI P, 'r' # 'r' is the command for Reset
LI P, 'r' # 'r' is the command for Reset
LI P, 'r' # 'r' is the command for Reset
LI P, 'r' # 'r' is the command for Reset
NOP
NOP
NOP
NOP
NOP

LI Y, 0 # kIORegister

LI P, 'H'
LI P, 'H'
LI P, 'H'
LI P, 'H'
LI P, 'H'
NOP
NOP
NOP
NOP
NOP

LI P, 'e'
LI P, 'e'
LI P, 'e'
LI P, 'e'
LI P, 'e'
NOP
NOP
NOP
NOP
NOP

LI P, 'l'
LI P, 'l'
LI P, 'l'
LI P, 'l'
LI P, 'l'
NOP
NOP
NOP
NOP
NOP

LI P, 'l'
LI P, 'l'
LI P, 'l'
LI P, 'l'
LI P, 'l'
NOP
NOP
NOP
NOP
NOP

LI P, 'o'
LI P, 'o'
LI P, 'o'
LI P, 'o'
LI P, 'o'
NOP
NOP
NOP
NOP
NOP

LI P, ','
LI P, ','
LI P, ','
LI P, ','
LI P, ','
NOP
NOP
NOP
NOP
NOP

LI P, ' '
LI P, ' '
LI P, ' '
LI P, ' '
LI P, ' '
NOP
NOP
NOP
NOP
NOP

LI P, 'W'
LI P, 'W'
LI P, 'W'
LI P, 'W'
LI P, 'W'
NOP
NOP
NOP
NOP
NOP

LI P, 'o'
LI P, 'o'
LI P, 'o'
LI P, 'o'
LI P, 'o'
NOP
NOP
NOP
NOP
NOP

LI P, 'r'
LI P, 'r'
LI P, 'r'
LI P, 'r'
LI P, 'r'
NOP
NOP
NOP
NOP
NOP

LI P, 'l'
LI P, 'l'
LI P, 'l'
LI P, 'l'
LI P, 'l'
NOP
NOP
NOP
NOP
NOP

LI P, 'd'
LI P, 'd'
LI P, 'd'
LI P, 'd'
LI P, 'd'
NOP
NOP
NOP
NOP
NOP

LI P, '!'
LI P, '!'
LI P, '!'
LI P, '!'
LI P, '!'
NOP
NOP
NOP
NOP
NOP

LI P, 10
LI P, 10
LI P, 10
LI P, 10
LI P, 10
NOP
NOP
NOP
NOP
NOP

HLT