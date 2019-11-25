LI A, 0
LI B, 0
LI D, 0
LI X, 0
LI Y, 0
LI U, 0
LI V, 0

LXY serial_init
JALR
NOP
NOP

LI A, 'r'
LXY serial_put
JALR
NOP
NOP

LI A, 'e'
LXY serial_put
JALR
NOP
NOP

LI A, 'a'
LXY serial_put
JALR
NOP
NOP

LI A, 'd'
LXY serial_put
JALR
NOP
NOP

LI A, 'y'
LXY serial_put
JALR
NOP
NOP

LI A, '.'
LXY serial_put
JALR
NOP
NOP

LI A, 10
LXY serial_put
JALR
NOP
NOP


# Now, we enter a loop where we wait for serial input and then echo it to
# serial output.

beginningOfInputLoop:

waitForInput:
LXY serial_get_number_available_bytes
JALR
NOP
NOP
LI B, 0
CMP
LXY waitForInput
JE
NOP
NOP

# Read a byte and echo it back.
LXY serial_get
JALR # The return value is in "A".
NOP
NOP

LXY serial_put # The parameter is in "A".
JALR
NOP
NOP

LXY beginningOfInputLoop
JMP
NOP
NOP





serial_init:

LI Y, 0 # kCommandReset
LI D, 6 # kSerialInterface
LI P, 0 # Lower SCK
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

MOV X, G
MOV Y, H
INXY
JMP
NOP
NOP





serial_put:

# The A register contains the character to output.
LI D, 6 # kSerialInterface

LI Y, 1 # kCommandPutByte
LI P, 1 # Raise SCK
NOP
MOV B, P # Store the status in B
LI P, 0 # Lower SCK

MOV Y, A # Copy the character into A.
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

MOV X, G
MOV Y, H
INXY
JMP
NOP
NOP





serial_get:

LI D, 6 # kSerialInterface
LI Y, 2 # kCommandGetByte
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

MOV X, G
MOV Y, H
INXY
JMP
NOP
NOP





serial_get_number_available_bytes:

LI D, 6 # kSerialInterface
LI Y, 3 # kCommandGetNumBytes
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the return result in A
LI P, 0 # Lower SCK

MOV X, G
MOV Y, H
INXY
JMP
NOP
NOP

