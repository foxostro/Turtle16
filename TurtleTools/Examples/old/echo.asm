let kSerialInterface = 7
let kDataPort = 1
let kControlPort = 0
let kResetCommand = 0
let kPutCommand = 1
let kGetCommand = 2
let kGetNumberOfBytesCommand = 3

LI A, 0
LI B, 0
LI D, kSerialInterface
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

HLT # unreachable





serial_init:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

LI D, kSerialInterface
LI Y, kDataPort
LI P, kResetCommand
LI Y, kControlPort
LI P, 0 # Lower SCK
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI Y, kDataPort
MOV A, P # Store the status in A
LI Y, kControlPort
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
JMP
NOP
NOP





serial_put:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

# The A register contains the character to output.
# Copy it into memory at address 5.
LI U, 0
LI V, 5
MOV M, A

LI D, 7 # The Serial Interface device
LI Y, kDataPort
LI P, kPutCommand
LI Y, kControlPort
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI Y, kControlPort
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP
LI Y, kDataPort
LI U, 0
LI V, 5
MOV P, M # Retrieve the byte from address 5 and pass it to the serial device.
LI Y, kControlPort
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI Y, kControlPort
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
JMP
NOP
NOP





serial_get:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

LI Y, kDataPort
LI P, kGetCommand
LI Y, kControlPort
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI U, 0
LI V, 5
MOV M, P # Store the input byte in memory at address 5.
LI Y, kControlPort
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP

# Set the return value in "A".
LI U, 0
LI V, 5
MOV A, M

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
JMP
NOP
NOP





serial_get_number_available_bytes:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

LI D, kSerialInterface
LI Y, kDataPort
LI P, kGetNumberOfBytesCommand
LI Y, kControlPort
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI U, 0
LI V, 5
MOV M, P # Store the number of available bytes in memory at address 5.
LI Y, kControlPort
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP

# Set the return value in "A".
LI U, 0
LI V, 5
MOV A, M

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
JMP
NOP
NOP






delay256:

LI A, 0
delay256_0:
# Increment A by 1. If the value is not equal to 255 then loop.
LI B, 1
ADD _
ADD A
LI B, 255
CMP
CMP
LXY delay256_0
JNE
NOP
NOP

MOV X, G
MOV Y, H
JMP
NOP
NOP




delay:

# Preserve the value of the link register by
# storing return address at address 0 and 1.
LI U, 0
LI V, 0
MOV M, G
LI V, 1
MOV M, H

LI A, 0
delay_0:

# Call delay256, making sure to preserve "A" in memory at address 2.
LI U, 0
LI V, 2
MOV M, A
LXY delay256
JALR
NOP
NOP
MOV A, M

# Increment A by 1. If the value is not equal to 1 then loop.
# Adjust the upper limit of the loop according to the CPU speed.
LI B, 1
ADD _
ADD A
LI B, 1
CMP
CMP
LXY delay_0
JNE
NOP
NOP

# Retrieve the return address from memory at address 0 and 1,
# and then return from the call.
LI U, 0
LI V, 0
MOV X, M
LI V, 1
MOV Y, M
JMP
NOP
NOP