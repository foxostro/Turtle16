# let kSerialInterface = 6
# let kIORegister = 0
# let kStatusRegister = 1

LI A, 0
LI B, 0
LI X, 0
LI Y, 0
LI U, 0
LI V, 0

LI D, 6 # kSerialInterface
LI P, 'r'
LI P, 'e'
LI P, 'a'
LI P, 'd'
LI P, 'y'
LI P, '.'
LI P, 10


# Now, we enter a loop where we wait for serial input and then echo it to
# serial output.

beginningOfInputLoop:

waitForInput:
LI Y, 1 # kStatusRegister
MOV B, P
LI A, 0
CMP
LXY waitForInput
JC
NOP
NOP

# Read a byte and echo it back.
LI Y, 0 # kIORegister
MOV A, P
MOV P, A

LXY beginningOfInputLoop
JMP
NOP
NOP
LI A, 0xff
LI B, 0xff
LI U, 0xff
LI V, 0xff
LI X, 0xff
LI Y, 0xff
HLT
