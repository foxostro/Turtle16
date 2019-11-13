# let kSerialInterface = 6
# let kIORegister = 0
# let kStatusRegister = 2

LI A, 0
LI B, 0
LI X, 0
LI Y, 0
LI U, 0
LI V, 0

LI D, 6 # kSerialInterface
LI P, 'r'
NOP
LI P, 'e'
NOP
LI P, 'a'
NOP
LI P, 'd'
NOP
LI P, 'y'
NOP
LI P, '.'
NOP
LI P, 10
NOP


# Now, we enter a loop where we wait for serial input and then echo it to
# serial output.

beginningOfInputLoop:

waitForInput:
LI Y, 2 # kStatusRegister
MOV A, P
NOP
LI B, 0
CMP
LXY waitForInput
JE
NOP
NOP

# Read a byte and echo it back.
LI Y, 0 # kIORegister
MOV A, P
NOP
MOV P, A
NOP

LXY beginningOfInputLoop
JMP
NOP
NOP
