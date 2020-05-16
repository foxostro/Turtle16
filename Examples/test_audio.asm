let kAudioDevice = 6
let kFrequencyRegister = 0
let kGainRegister = 1

LI A, 1
LI B, 2
LI D, 3
LI U, 4
LI V, 5
LI X, 6
LI Y, 7

LI D, kAudioDevice
LI X, 0
LI Y, kFrequencyRegister
LI P, 0x80
LI Y, kGainRegister
LI P, 0x80

LXY delay
JALR
NOP
NOP

# Go silent again and halt the computer.
LI D, kAudioDevice
LI X, 0
LI Y, kFrequencyRegister
LI P, 0
LI Y, kGainRegister
LI P, 0

LI A, 0xff
HLT



test_func:
MOV X, G
MOV Y, H
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

# Increment A by 1. If the value is not equal to 255 then loop.
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
