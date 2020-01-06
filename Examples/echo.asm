LI A, 0
LI B, 0
LI D, 6 # The Serial Interface device
LI X, 0
LI Y, 0
LI U, 0
LI V, 0


LXY serial_init
LINK
JMP
NOP
NOP

LI A, 'r'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'e'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'a'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'd'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'y'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, '.'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 10
LXY serial_put
LINK
JMP
NOP
NOP


# Now, we enter a loop where we wait for serial input and then echo it to
# serial output.

beginningOfInputLoop:

waitForInput:
LXY serial_get_number_available_bytes
LINK
JMP
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
LINK
JMP # The return value is in "A".
NOP
NOP

LXY serial_put # The parameter is in "A".
LINK
JMP
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

LI D, 6 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 0 # Reset Command
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 1 # Data Port
MOV A, P # Store the status in A
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
NOP
NOP

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
INXY # Must adjust the return address.
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

LI D, 6 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 1 # Data Port
LI U, 0
LI V, 5
MOV P, M # Retrieve the byte from address 5 and pass it to the serial device.
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
NOP
NOP

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
INXY # Must adjust the return address.
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

LI Y, 1 # Data Port
LI P, 2 # "Get" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI U, 0
LI V, 5
MOV M, P # Store the input byte in memory at address 5.
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
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
INXY # Must adjust the return address.
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

LI D, 6 # kSerialInterface
LI Y, 1 # Data Port
LI P, 3 # "Get Number of Bytes" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI U, 0
LI V, 5
MOV M, P # Store the number of available bytes in memory at address 5.
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
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
INXY # Must adjust the return address.
JMP
NOP
NOP






delay256:

LI A, 0
delay256_0:
# Increment A by 1. If the value is not equal to 255 then loop.
LI B, 1
ADD A
LI B, 255
CMP
LXY delay256_0
JNE
NOP
NOP

MOV X, G
MOV Y, H
INXY # Must adjust the return address.
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
LINK
JMP
NOP
NOP
MOV A, M

# Increment A by 1. If the value is not equal to 255 then loop.
LI B, 1
ADD A
LI B, 255
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
INXY # Must adjust the return address.
JMP
NOP
NOP