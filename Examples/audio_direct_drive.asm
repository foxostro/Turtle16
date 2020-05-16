let kAudioDevice = 6
let kDirectDriveRegister = 3

# The simulator is quite slow. This program is heavily optimized to allow the
# Simulator to produce an audible tone.
# First, assume all registers are initialized to zero. This is not true on real
# hardware. So, this program will not actually run on real hardware.

# Set the audio device as the active peripheral.
LI D, kAudioDevice

# Set the lower address byte to 0x3. This is both the value of the sound card's
# Direct Drive register as well as the address of the JMP instruction. We use
# it both to set the branch target as well as to ensure that writes to P are
# used to directly drive the speaker cone.
LI Y, kDirectDriveRegister

# Jump to address 0x3.
JMP

# Branch delay slot one of two: increment the UV register pair.
INUV

# Branch delay slot two of two: Write V into P. This directly drives the speaker
# cone to synthesize sound.
MOV P, V