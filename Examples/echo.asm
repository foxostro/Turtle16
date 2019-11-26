LI A, 0
LI B, 0
LI D, 6 # The Serial Interface device
LI X, 0
LI Y, 0
LI U, 0
LI V, 0


# Reset the serial interface.
LI Y, 1 # Data Port
LI P, 0 # Reset Command
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 1 # Data Port
MOV A, P # Store the status in A
LI Y, 0 # Control Port
LI P, 0 # Lower SCK


# Print a welcome message.
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, 'r'
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, 'e'
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, 'a'
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, 'd'
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, 'y'
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, '.'
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI P, 10
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK


# Now, we enter a loop where we wait for serial input and then echo it to
# serial output.

beginningOfInputLoop:

waitForInput:

# Get the number of bytes available.
LI Y, 1 # Data Port
LI P, 3 # "Get Number of Bytes" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
MOV A, P # Store the number of available bytes in "A"
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

# If the number of available bytes is zero then loop.
LI B, 0
CMP
LXY waitForInput
JE
NOP
NOP
NOP

# Read a byte.
LI Y, 1 # Data Port
LI P, 2 # "Get" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI U, 0
LI V, 10
MOV M, P # Store the input byte in memory at address 3.
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

# Echo the byte back.
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LI Y, 1 # Data Port
LI U, 0
LI V, 10
MOV P, M # Retrieve the input byte from memory at address 3.
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay65536
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK

LXY beginningOfInputLoop
JMP
NOP
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
JMP
NOP
NOP




delay65536:

# Preserve the value of the link register by
# storing return address at address 0 and 1.
LI U, 0
LI V, 0
MOV M, G
LI V, 1
MOV M, H

LI A, 0
delay65536_0:

# Call delay256, making sure to preserve "A" in memory at address 2.
LI U, 0
LI V, 2
MOV M, A
LXY delay256
JALR
NOP
NOP
MOV A, M

# Increment A by 1. If the value is not equal to 255 then loop.
LI B, 1
ADD A
LI B, 255
CMP
LXY delay65536_0
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
