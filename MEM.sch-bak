EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 14 33
Title "MEM"
Date ""
Rev ""
Comp ""
Comment1 "place bus lines into tristate and halt the Phi1 clock."
Comment2 "Devices on the bus may take the open-collector ~RDY~ signal high to force the CPU to"
Comment3 "These devices connect to the main board via a connector described in another sheet."
Comment4 "The MEM stage interfaces with memory and memory-mapped peripherals."
$EndDescr
Text HLabel 2300 2350 0    50   Input ~ 0
StoreOpIn[0..15]
Text HLabel 2300 1150 0    50   Input ~ 0
CtlIn[13..19]
Text HLabel 8800 1250 2    50   Output ~ 0
Ctl[15..19]
Text HLabel 8800 2250 2    50   Output ~ 0
StoreOp[0..15]
Entry Wire Line
	2500 1150 2600 1250
Entry Wire Line
	2600 1150 2700 1250
Entry Bus Bus
	6250 1150 6350 1250
Wire Bus Line
	6350 1250 8800 1250
Text Label 6450 1250 0    50   ~ 0
CtlIn[15..19]
Text Label 2700 1250 3    50   ~ 0
CtlIn13
Text Label 2600 1250 3    50   ~ 0
CtlIn14
Wire Bus Line
	2300 2350 3950 2350
Text HLabel 8800 1700 2    50   3State ~ 0
~MemStore
Text HLabel 8800 1600 2    50   3State ~ 0
~MemLoad
Wire Wire Line
	2600 2250 3950 2250
Entry Bus Bus
	6950 2100 7050 2000
Wire Bus Line
	7050 2000 8800 2000
Wire Bus Line
	6950 2100 6950 2250
Connection ~ 6950 2250
Wire Bus Line
	6950 2250 8800 2250
Text Label 7600 2000 2    50   ~ 0
StoreOp[0..7]
Text HLabel 8800 2000 2    50   3State ~ 0
SystemBus[0..7]
$Sheet
S 3950 2050 1250 400 
U 5FF1115C
F0 "Buffer StoreOp As Bus I/O" 50
F1 "BufferStoreOpAsBusIO.sch" 50
F2 "~MemStoreIn" I L 3950 2250 50 
F3 "Q[0..15]" T R 5200 2250 50 
F4 "D[0..15]" I L 3950 2350 50 
F5 "~RDY" I L 3950 2150 50 
$EndSheet
$Sheet
S 7700 2400 1150 200 
U 5FAF68C1
F0 "System Bus Pull-down" 50
F1 "SystemBusPulldown.sch" 50
F2 "StoreOp[0..15]" I L 7700 2500 50 
$EndSheet
Wire Bus Line
	6950 2250 6950 2500
Wire Bus Line
	6950 2500 7700 2500
Text HLabel 2300 2900 0    50   Input ~ 0
ALUResult[0..15]
Wire Bus Line
	5200 2250 6950 2250
Text Label 7550 2250 2    50   ~ 0
StoreOp[0..15]
Text Label 6700 2250 2    50   ~ 0
StoreOp[0..15]
Text Label 7550 2500 2    50   ~ 0
StoreOp[0..15]
Wire Wire Line
	3650 2800 3950 2800
$Sheet
S 3950 2700 1250 300 
U 5FB92C55
F0 "sheet5FB92C48" 50
F1 "BufferALUResultAsAddr.sch" 50
F2 "~RDY" I L 3950 2800 50 
F3 "Addr[0..15]" T R 5200 2900 50 
F4 "ALUResult[0..15]" I L 3950 2900 50 
$EndSheet
Wire Bus Line
	5200 2900 8800 2900
Text HLabel 8800 2900 2    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	2300 2900 3950 2900
$Sheet
S 3950 1400 1250 400 
U 5FB90806
F0 "Buffer Memory Control Signals" 50
F1 "BufferMemoryControlSignals.sch" 50
F2 "~MemLoadIn" I L 3950 1600 50 
F3 "~MemStoreIn" I L 3950 1700 50 
F4 "~MemLoad" T R 5200 1600 50 
F5 "~MemStore" T R 5200 1700 50 
F6 "~RDY" I L 3950 1500 50 
$EndSheet
Wire Wire Line
	3950 1700 2600 1700
Wire Wire Line
	3950 1600 2700 1600
Wire Wire Line
	2700 1250 2700 1600
Wire Wire Line
	5200 1600 8800 1600
Wire Wire Line
	8800 1700 5200 1700
Wire Wire Line
	2600 1250 2600 1700
Connection ~ 2600 1700
Wire Wire Line
	3650 1500 3950 1500
Text HLabel 3650 1500 0    50   Input ~ 0
~RDY
Wire Wire Line
	2600 1700 2600 2250
Wire Wire Line
	3650 2150 3950 2150
Text HLabel 3650 2150 0    50   Input ~ 0
~RDY
Text HLabel 3650 2800 0    50   Input ~ 0
~RDY
Text Notes 3050 3750 0    50   ~ 0
The ~RDY~ signal is an open-collector signal shared between all bus\ndevices. When a bus device takes this signal high, the CPU releases the\nsystem bus I/O lines, address lines, and control signals, putting them\ninto a high-Z state. This allows peripheral devices to drive the bus\nwhen needed.
Wire Bus Line
	2300 1150 6250 1150
$EndSCHEMATC
