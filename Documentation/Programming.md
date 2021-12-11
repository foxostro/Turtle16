# Turtle16: Programming the EEPROMs and GALs

There are three EEPROMs used for decoding instructions in the ID stage, two EEPROMs containing instruction memory for the IF stage, and two ATF22V10 GALs used in the Hazard Control unit.

Flash the contents of the EEPROMs using `minipro` like so:
```
% minipro -p 'SST39SF010A@PLCC32' -y -w contents.bin
```

Ideally, you could also program the GALs using `minipro` on Mac and Linux. Unfortunately, I've only ever been able to program an ATF22V10 with Xgpro on Windows.

## Which chips?

* Instruction Memory (Lower eight bits) --> U57
* Instruction Memory (Upper eight bits) --> U58
* OpcodeDecodeROM1.bin --> U37
* OpcodeDecodeROM2.bin --> U38
* OpcodeDecodeROM3.bin --> U39
* HazardControl1.jed --> U51
* HazardControl2.jed --> U52

## Using what firmware?

The contents of the decoder EEPROMs are included in the repo under the Generated/ directory. Ditto the .jed files for the Hazard Control GALs.

Alternatively, use the Simulator16 app to dump the contents of the simulated computer's EEPROMs to file.