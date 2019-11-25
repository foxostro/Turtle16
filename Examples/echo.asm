LI A, 0
LI B, 0
LI D, 0
LI X, 0
LI Y, 0
LI U, 0
LI V, 0


# Reset the serial interface.

LI Y, 0 # kCommandReset
LI D, 6 # kSerialInterface
LI P, 0 # Lower SCK
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK



# Print a welcome message.
LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, 'r'
LI P, 1
NOP
LI P, 0

LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, 'e'
LI P, 1
NOP
LI P, 0

LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, 'a'
LI P, 1
NOP
LI P, 0

LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, 'd'
LI P, 1
NOP
LI P, 0

LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, 'y'
LI P, 1
NOP
LI P, 0

LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, '.'
LI P, 1
NOP
LI P, 0

LI Y, 1 # kCommandPutByte
LI P, 1
NOP
LI P, 0
LI Y, 10
LI P, 1
NOP
LI P, 0


# Now, we enter a loop where we wait for serial input and then echo it to
# serial output.

beginningOfInputLoop:

waitForInput:
# Get the number of bytes available.
LI Y, 3 # kCommandGetNumBytes
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the return result in A
LI P, 0 # Lower SCK
LI B, 0
CMP
LXY waitForInput
JE
NOP
NOP
NOP

# Read a byte.
LI Y, 2 # kCommandGetByte
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the input byte in A
LI P, 0 # Lower SCK

# Echo it back.
LI D, 6 # kSerialInterface
LI Y, 1 # kCommandPutByte
LI P, 1 # Raise SCK
NOP
MOV B, P # Store the status in B
LI P, 0 # Lower SCK
MOV Y, A # Copy the character into Y.
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

LXY beginningOfInputLoop
JMP
NOP
NOP
NOP
