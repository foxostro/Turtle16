LI A, 0
LI B, 0
LI D, 6 # Serial Module
LI Y, 0 # Y[0..7] is MOSI

# Reset Serial Interface
LI A, 0
LI Y, 0 # doCommandReset
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

# Put an '@'
LI A, 0
LI Y, 1 # kCommandPutByte
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

LI A, 0
LI Y, '@'
LI P, 1 # Raise SCK
NOP
MOV A, P # Store the status in A
LI P, 0 # Lower SCK

# Get the number of bytes available
LI A, 0
LI Y, 3 # kCommandGetByte
LI P, 1 # Raise SCK
NOP
MOV B, P
LI P, 0 # Lower SCK

# Get a byte
LI A, 0
LI Y, 2 # kCommandGetByte
LI P, 1 # Raise SCK
NOP
MOV A, P
LI P, 0 # Lower SCK

HLT
