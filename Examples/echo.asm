# let kSerialInterface = 6
# let kIORegister = 0
# let kStatusRegister = 1
# let kCommandPort = 0
# let kDataPort = 1
# let kReady = 0
# let kCommandRead = 1
# let kCommandWrite = 2
# let kCommandAvail = 3
# let kCommandInit = 4

LI A, 0
LI B, 0
LI U, 0
LI V, 0
LI X, 0
LI D, 6 # kSerialInterface

# Initialize the serial interface device.
LI Y, 0 # kCommandPort
LI P, 4 # kCommandInit
LI B, 0 # kReady
LXY wait_for_serial_init
wait_for_serial_init:
MOV A, P
CMP
NOP
JNE
NOP
NOP

# Send a command to write a character.
LI Y, 1 # kDataPort
LI P, '!'
LI Y, 0 # kCommandPort
LI P, 2 # kCommandWrite
LI B, 0 # kReady
LXY wait_for_character_write
wait_for_character_write:
MOV A, P
CMP
NOP
JNE
NOP
NOP

HLT
