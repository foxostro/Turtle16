# let kSerialInterface = 6
# let kPortStatus = 0
# let kPortCommand = 1
# let kPortData = 2
# let kStatusReady = 0
# let kStatusWaiting = 1
# let kCommandAck = 0
# let kCommandRead = 1
# let kCommandWrite = 2
# let kCommandAvail = 3

LI A, 0
LI B, 0
LI D, 0
LI U, 0
LI V, 0
LI X, 0
LI Y, 0

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, 'r'

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_0:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_0
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_1:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_1
JNE
NOP
NOP

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, 'e'

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_2:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_2
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_3:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_3
JNE
NOP
NOP

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, 'a'

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_4:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_4
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_5:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_5
JNE
NOP
NOP

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, 'd'

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_6:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_6
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_7:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_7
JNE
NOP
NOP

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, 'y'

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_8:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_8
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_9:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_9
JNE
NOP
NOP

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, '.'

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_10:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_10
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_11:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_11
JNE
NOP
NOP

# #############################################################################

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
LI P, 10

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
wait_for_serial_write_12:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_12
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
wait_for_serial_write_13:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY wait_for_serial_write_13
JNE
NOP
NOP

HLT

# #############################################################################

LI A, 'r'
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

LI A, 'e'
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

LI A, 'a'
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

LI A, 'd'
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

LI A, 'y'
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

LI A, '.'
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

LI A, 10
LXY serial_putc
JALR
NOP
NOP

# #############################################################################

HLT





# #############################################################################
# Output a character through the serial interface device.
# The character is passed in the A register.

serial_putc:

# Write the character into the data port.
LI D, 6 # kSerialInterface
LI X, 0
LI Y, 2 # kPortData
MOV P, A

# Send the command to write.
LI Y, 1 # kPortCommand
LI P, 2 # kCommandWrite

# Wait for the serial device finish. It needs our acknowledgement to continue.
LI B, 1 # kStatusWaiting
serial_putc_0:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY serial_putc_0
JNE
NOP
NOP

# Send acknowledgement.
LI Y, 1 # kPortCommand
LI P, 0 # kCommandAck

# Wait for the serial device to become ready again.
LI B, 0 # kStatusReady
serial_putc_1:
LI X, 0
LI Y, 0 # kPortStatus
MOV A, P
CMP
LXY serial_putc_1
JNE
NOP
NOP

# Return
MOV X, G
MOV Y, H
JMP
NOP
NOP
