let kAudioDevice = 6
let kDirectDrive = 0x00
let kTriangleWaveFrequency = 0x01
let kPulseWaveModulation = 0x02
let kPulseWaveFrequency = 0x03
let kTriangleWaveAmplitude = 0x04
let kPulseWaveAmplitude = 0x05
let kNoiseAmplitude = 0x06
let kMasterGain = 0x07

LI A, 1
LI B, 2
LI D, 3
LI U, 4
LI V, 5
LI X, 6
LI Y, 7

LI D, kAudioDevice
LI X, 0
LI Y, kTriangleWaveFrequency
LI P, 153 # Corresponds to CV=3V which is A3.
LI Y, kTriangleWaveAmplitude
LI P, 0x80
LI Y, kMasterGain
LI P, 0xff

forever:
LXY forever
JMP
NOP
NOP
