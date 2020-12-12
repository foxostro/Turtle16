EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 21 33
Title "MEM"
Date ""
Rev ""
Comp ""
Comment1 "place bus lines into tristate and halt the Phi1 clock."
Comment2 "Devices on the bus may take the open-collector ~RDY~ signal high to force the CPU to"
Comment3 "These devices connect to the main board via a connector described in another sheet."
Comment4 "The MEM stage interfaces with memory and memory-mapped peripherals."
$EndDescr
Text HLabel 2300 3900 0    50   Input ~ 0
StoreOpIn[0..15]
Text HLabel 2300 2300 0    50   Input ~ 0
Ctl_MEM[13..20]
Text HLabel 8800 2400 2    50   Output ~ 0
Ctl_MEM[16..20]
Text HLabel 8800 3800 2    50   Output ~ 0
StoreOp[0..15]
Entry Wire Line
	2750 2300 2850 2400
Entry Wire Line
	2850 2300 2950 2400
Entry Bus Bus
	6250 2300 6350 2400
Wire Bus Line
	6350 2400 8800 2400
Text Label 6450 2400 0    50   ~ 0
Ctl_MEM[16..20]
Text Label 2950 2400 3    50   ~ 0
Ctl_MEM13
Text Label 2850 2400 3    50   ~ 0
Ctl_MEM14
Wire Bus Line
	2300 3900 3950 3900
Text HLabel 8800 3250 2    50   3State ~ 0
~MemStore
Text HLabel 8800 3150 2    50   3State ~ 0
~MemLoad
Entry Bus Bus
	6950 3650 7050 3550
Wire Bus Line
	7050 3550 8800 3550
Wire Bus Line
	6950 3650 6950 3800
Connection ~ 6950 3800
Wire Bus Line
	6950 3800 8800 3800
Text Label 7600 3550 2    50   ~ 0
StoreOp[0..7]
Text HLabel 8800 3550 2    50   3State ~ 0
SystemBus[0..7]
$Sheet
S 3950 3600 1250 400 
U 5FF1115C
F0 "Buffer StoreOp As Bus I/O" 50
F1 "BufferStoreOpAsBusIO.sch" 50
F2 "~AssertStoreOp" I L 3950 3800 50 
F3 "Q[0..15]" T R 5200 3800 50 
F4 "D[0..15]" I L 3950 3900 50 
F5 "~RDY" I L 3950 3700 50 
$EndSheet
$Sheet
S 7700 3950 1150 200 
U 5FAF68C1
F0 "System Bus Pull-down" 50
F1 "SystemBusPulldown.sch" 50
F2 "StoreOp[0..15]" I L 7700 4050 50 
$EndSheet
Wire Bus Line
	6950 3800 6950 4050
Wire Bus Line
	6950 4050 7700 4050
Text HLabel 2300 4450 0    50   Input ~ 0
Y_MEM[0..15]
Wire Bus Line
	5200 3800 6950 3800
Text Label 7550 3800 2    50   ~ 0
StoreOp[0..15]
Text Label 6700 3800 2    50   ~ 0
StoreOp[0..15]
Text Label 7550 4050 2    50   ~ 0
StoreOp[0..15]
Wire Wire Line
	3650 4350 3950 4350
$Sheet
S 3950 4250 1250 300 
U 5FB92C55
F0 "Buffer Addr" 50
F1 "BufferALUResultAsAddr.sch" 50
F2 "~RDY" I L 3950 4350 50 
F3 "Addr[0..15]" T R 5200 4450 50 
F4 "Y_MEM[0..15]" I L 3950 4450 50 
$EndSheet
Wire Bus Line
	5200 4450 8800 4450
Text HLabel 8800 4450 2    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	2300 4450 3950 4450
$Sheet
S 3950 2950 1250 400 
U 5FB90806
F0 "Buffer Memory Control Signals" 50
F1 "BufferMemoryControlSignals.sch" 50
F2 "~MemLoadIn" I L 3950 3150 50 
F3 "~MemStoreIn" I L 3950 3250 50 
F4 "~MemLoad" T R 5200 3150 50 
F5 "~MemStore" T R 5200 3250 50 
F6 "~RDY" I L 3950 3050 50 
$EndSheet
Wire Wire Line
	2950 2400 2950 3150
Wire Wire Line
	5200 3150 8800 3150
Wire Wire Line
	8800 3250 5200 3250
Wire Wire Line
	2850 2400 2850 3250
Wire Wire Line
	3650 3050 3950 3050
Text HLabel 3650 3050 0    50   Input ~ 0
~RDY
Wire Wire Line
	3650 3700 3950 3700
Text HLabel 3650 3700 0    50   Input ~ 0
~RDY
Text HLabel 3650 4350 0    50   Input ~ 0
~RDY
Text Notes 3050 5300 0    50   ~ 0
The ~RDY~ signal is an open-collector signal shared between all bus\ndevices. When a bus device takes this signal high, the CPU releases the\nsystem bus I/O lines, address lines, and control signals, putting them\ninto a high-Z state. This allows peripheral devices to drive the bus\nwhen needed.
Wire Wire Line
	2950 3150 3950 3150
Wire Wire Line
	2850 3250 3950 3250
Entry Wire Line
	2650 2300 2750 2400
Text Label 2750 2400 3    50   ~ 0
Ctl_MEM15
Wire Wire Line
	2750 2400 2750 3800
Wire Wire Line
	2750 3800 3950 3800
Wire Bus Line
	2300 2300 6250 2300
$EndSCHEMATC
