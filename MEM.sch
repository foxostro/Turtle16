EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 19 34
Title "MEM"
Date ""
Rev ""
Comp ""
Comment1 "place bus lines into tristate and halt the Phi1 clock."
Comment2 "Devices on the bus may take the open-collector ~RDY~ signal high to force the CPU to"
Comment3 "These devices connect to the main board via a connector described in another sheet."
Comment4 "The MEM stage interfaces with memory and memory-mapped peripherals."
$EndDescr
Text HLabel 1950 3900 0    50   Input ~ 0
StoreOp_MEM[0..15]
Text HLabel 1950 2300 0    50   Input ~ 0
Ctl_MEM[13..20]
Entry Wire Line
	2400 2300 2500 2400
Entry Wire Line
	2500 2300 2600 2400
Entry Bus Bus
	5900 2300 6000 2400
Wire Bus Line
	6000 2400 7200 2400
Text Label 6100 2400 0    50   ~ 0
Ctl_MEM[16..20]
Text Label 2600 2400 3    50   ~ 0
Ctl_MEM13
Text Label 2500 2400 3    50   ~ 0
Ctl_MEM14
Wire Bus Line
	1950 3900 3600 3900
Text HLabel 9250 3250 2    50   3State ~ 0
~MemStore
Text HLabel 9250 3150 2    50   3State ~ 0
~MemLoad
Entry Bus Bus
	6600 3550 6700 3450
Wire Bus Line
	6700 3450 9250 3450
Wire Bus Line
	6600 3550 6600 3900
Connection ~ 6600 3900
Wire Bus Line
	6600 3900 7350 3900
Text Label 6750 3450 0    50   ~ 0
SystemBus[0..7]
Text HLabel 9250 3450 2    50   3State ~ 0
SystemBus[0..7]
$Sheet
S 3600 3600 1800 400 
U 5FF1115C
F0 "Buffer StoreOp As Bus I/O" 50
F1 "BufferStoreOpAsBusIO.sch" 50
F2 "~AssertStoreOp" I L 3600 3800 50 
F3 "SystemBus[0..15]" T R 5400 3900 50 
F4 "StoreOp_MEM[0..15]" I L 3600 3900 50 
F5 "~RDY" I L 3600 3700 50 
$EndSheet
$Sheet
S 7350 4400 1150 200 
U 5FAF68C1
F0 "System Bus Pull-down" 50
F1 "SystemBusPulldown.sch" 50
F2 "SystemBus[0..15]" I L 7350 4500 50 
$EndSheet
Wire Bus Line
	6600 3900 6600 4500
Wire Bus Line
	6600 4500 7350 4500
Text HLabel 1950 4900 0    50   Input ~ 0
Y_MEM[0..15]
Wire Bus Line
	5400 3900 6600 3900
Text Label 6650 3900 0    50   ~ 0
SystemBus[0..15]
Text Label 6350 3900 2    50   ~ 0
SystemBus[0..15]
Text Label 6650 4500 0    50   ~ 0
SystemBus[0..15]
Wire Wire Line
	3300 4800 3600 4800
$Sheet
S 3600 4700 1250 300 
U 5FB92C55
F0 "Buffer Addr" 50
F1 "BufferALUResultAsAddr.sch" 50
F2 "~RDY" I L 3600 4800 50 
F3 "Addr[0..15]" T R 4850 4900 50 
F4 "Y_MEM[0..15]" I L 3600 4900 50 
$EndSheet
Wire Bus Line
	4850 4900 9250 4900
Text HLabel 9250 4900 2    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	1950 4900 3600 4900
$Sheet
S 3600 2950 1250 400 
U 5FB90806
F0 "Buffer Memory Control Signals" 50
F1 "BufferMemoryControlSignals.sch" 50
F2 "~MemLoadIn" I L 3600 3150 50 
F3 "~MemStoreIn" I L 3600 3250 50 
F4 "~MemLoad" T R 4850 3150 50 
F5 "~MemStore" T R 4850 3250 50 
F6 "~RDY" I L 3600 3050 50 
$EndSheet
Wire Wire Line
	2600 2400 2600 3150
Wire Wire Line
	4850 3150 9250 3150
Wire Wire Line
	9250 3250 4850 3250
Wire Wire Line
	2500 2400 2500 3250
Wire Wire Line
	3300 3050 3600 3050
Text HLabel 3300 3050 0    50   Input ~ 0
~RDY
Wire Wire Line
	3300 3700 3600 3700
Text HLabel 3300 3700 0    50   Input ~ 0
~RDY
Text HLabel 3300 4800 0    50   Input ~ 0
~RDY
Text Notes 2700 5750 0    50   ~ 0
The ~RDY~ signal is an open-collector signal shared between all bus\ndevices. When a bus device takes this signal high, the CPU releases the\nsystem bus I/O lines, address lines, and control signals, putting them\ninto a high-Z state. This allows peripheral devices to drive the bus\nwhen needed.
Wire Wire Line
	2600 3150 3600 3150
Wire Wire Line
	2500 3250 3600 3250
Entry Wire Line
	2300 2300 2400 2400
Text Label 2400 2400 3    50   ~ 0
Ctl_MEM15
Wire Wire Line
	2400 2400 2400 3800
Wire Wire Line
	2400 3800 3600 3800
$Sheet
S 7350 3700 1600 400 
U 5FD56BFA
F0 "sheet5FD56BF4" 50
F1 "StoreOperandRegister3.sch" 50
F2 "Phi1" I L 7350 3800 50 
F3 "SystemBus[0..15]" I L 7350 3900 50 
F4 "StoreOp_WB[0..15]" O R 8950 3900 50 
$EndSheet
Wire Wire Line
	7250 3800 7350 3800
Text GLabel 7200 3700 0    50   Input ~ 0
Phi1c
Text HLabel 9250 3900 2    50   Output ~ 0
StoreOp_WB[0..15]
Wire Bus Line
	9250 3900 8950 3900
Wire Wire Line
	7200 3700 7250 3700
Wire Wire Line
	7250 3700 7250 3800
Text HLabel 9250 2500 2    50   Output ~ 0
SelC_WB[0..2]
Wire Bus Line
	8950 2500 9250 2500
$Sheet
S 7200 2200 1750 400 
U 5FD643E5
F0 "sheet5FD643DA" 50
F1 "Ctl_15_23_Register.sch" 50
F2 "Phi1" I L 7200 2300 50 
F3 "SelC_MEM[0..2]" I L 7200 2500 50 
F4 "SelC_WB[0..2]" O R 8950 2500 50 
F5 "Ctl_WB[16..20]" O R 8950 2400 50 
F6 "Ctl_MEM[16..20]" I L 7200 2400 50 
$EndSheet
Text HLabel 6750 2500 0    50   Input ~ 0
SelC_MEM[0..2]
Wire Bus Line
	7200 2500 6750 2500
Text GLabel 7000 2150 0    50   Input ~ 0
Phi1c
Text HLabel 9250 2400 2    50   Output ~ 0
Ctl_WB[16..20]
Wire Bus Line
	8950 2400 9250 2400
Wire Wire Line
	7200 2300 7100 2300
Wire Wire Line
	7100 2300 7100 2150
Wire Wire Line
	7100 2150 7000 2150
Text HLabel 9250 5600 2    50   Output ~ 0
Y_WB[0..15]
$Sheet
S 7350 5300 1350 400 
U 5FD9EFDB
F0 "Sheet5FD9EFDA" 50
F1 "ALUResultRegister_MEM_WB.sch" 50
F2 "Phi1" I L 7350 5400 50 
F3 "Y_MEM[0..15]" I L 7350 5600 50 
F4 "Y_WB[0..15]" O R 8700 5600 50 
$EndSheet
Text GLabel 7150 5400 0    50   Input ~ 0
Phi1c
Text HLabel 6750 5600 0    50   Input ~ 0
Y_MEM[0..15]
Wire Bus Line
	6750 5600 7350 5600
Wire Wire Line
	7150 5400 7350 5400
Wire Bus Line
	9250 5600 8700 5600
Wire Bus Line
	1950 2300 5900 2300
$EndSCHEMATC
