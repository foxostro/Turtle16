LI A, 0
LI B, 0
LI D, 6 # Serial Module
LI X, 0 # X0 is SCK
LI Y, 0 # Y[0..7] is MOSI

# Reset Serial Interface
LI A, 0
LI Y, 0 # doCommandReset
LI X, 1
NOP
MOV A, P # Store the status in A
LI X, 0

# Put an '@'
LI A, 0
LI Y, 1 # kCommandPutByte
LI X, 1
NOP
MOV A, P # Store the status in A
LI X, 0

LI A, 0
LI Y, '@'
LI X, 1
NOP
MOV A, P # Store the status in A
LI X, 0

# Get the number of bytes available
LI A, 0
LI Y, 3 # kCommandGetByte
LI X, 1
NOP
MOV B, P
LI X, 0

# Get a byte
LI A, 0
LI Y, 2 # kCommandGetByte
LI X, 1
NOP
MOV A, P
LI X, 0

HLT
