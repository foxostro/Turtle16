EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 36 39
Title "IF"
Date "2021-04-24"
Rev "A (ad8706e6)"
Comp ""
Comment1 "All jumps are PC-relative jumps which add an offset to the program counter."
Comment2 "address space to allow the program to be modified."
Comment3 "RAM serving as Instruction Memory. The second port of the RAM is mapped into the data"
Comment4 "The Instruction Fetch stage retrieves sixteen-bit instructions from a dual port"
$EndDescr
Text HLabel 8000 3450 2    50   Output ~ 0
Ins_ID[0..15]
Text HLabel 8000 3700 2    50   Output ~ 0
PC_EX[0..15]
Wire Bus Line
	8000 3700 7700 3700
Wire Bus Line
	7700 3450 8000 3450
Wire Bus Line
	4500 4000 4750 4000
Wire Bus Line
	4850 4000 4750 4000
Wire Bus Line
	4750 4000 4750 3550
Wire Bus Line
	4750 3550 6550 3550
Wire Bus Line
	6300 4000 6550 4000
Wire Wire Line
	3050 3850 2700 3850
Text HLabel 2700 4000 0    50   Input ~ 0
Y_EX[0..15]
Text HLabel 2700 4100 0    50   Input ~ 0
~J
Wire Wire Line
	3050 4100 2700 4100
Wire Bus Line
	2700 4000 3050 4000
$Sheet
S 4850 3900 1450 300 
U 5FD0D8DC
F0 "Instruction Memory" 50
F1 "InstructionRAM.sch" 50
F2 "PC[0..15]" I L 4850 4000 50 
F3 "Ins_IF[0..15]" O R 6300 4000 50 
F4 "FLUSH_IF" I L 4850 4100 50 
$EndSheet
Text GLabel 2700 3850 0    50   Input ~ 0
~RST
$Sheet
S 3050 3600 1450 800 
U 5FE3DA1C
F0 "sheet5FE3DA15" 50
F1 "Program Counter.sch" 50
F2 "~RST" I L 3050 3850 50 
F3 "~J" I L 3050 4100 50 
F4 "PC[0..15]" O R 4500 4000 50 
F5 "Y_EX[0..15]" I L 3050 4000 50 
F6 "~JABS" I L 3050 4200 50 
F7 "STALL" I L 3050 4300 50 
F8 "FLUSH_IF" O R 4500 4100 50 
$EndSheet
$Sheet
S 6550 3350 1150 750 
U 5FCE2082
F0 "sheet5FCE207B" 50
F1 "IF_ID.sch" 50
F2 "PC[0..15]" I L 6550 3550 50 
F3 "PC_EX[0..15]" O R 7700 3700 50 
F4 "Ins_IF[0..15]" I L 6550 4000 50 
F5 "Ins_ID[0..15]" O R 7700 3450 50 
F6 "STALL" I L 6550 3450 50 
$EndSheet
Text HLabel 2700 4200 0    50   Input ~ 0
~JABS
Wire Wire Line
	3050 4200 2700 4200
Wire Wire Line
	4850 4100 4500 4100
Connection ~ 4750 4000
Text HLabel 2700 4300 0    50   Input ~ 0
STALL
Wire Wire Line
	3050 4300 2700 4300
Text HLabel 6200 3450 0    50   Input ~ 0
STALL
Wire Wire Line
	6550 3450 6200 3450
Wire Wire Line
	2800 5200 2600 5200
Wire Wire Line
	3950 5200 4100 5200
$Comp
L Connector:TestPoint TP?
U 1 1 6084902E
P 2800 5200
AR Path="/5D2C0720/6084902E" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6084902E" Ref="TP39"  Part="1" 
F 0 "TP39" V 2754 5388 50  0000 L CNN
F 1 "~J" V 2845 5388 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 3000 5200 50  0001 C CNN
F 3 "~" H 3000 5200 50  0001 C CNN
	1    2800 5200
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP?
U 1 1 60849034
P 3950 5200
AR Path="/5D2C0720/60849034" Ref="TP?"  Part="1" 
AR Path="/5FE35007/60849034" Ref="TP41"  Part="1" 
F 0 "TP41" V 3900 5550 50  0000 R CNN
F 1 "GND" V 4000 5550 50  0000 R CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 4150 5200 50  0001 C CNN
F 3 "~" H 4150 5200 50  0001 C CNN
	1    3950 5200
	0    -1   1    0   
$EndComp
Text HLabel 2600 5200 0    50   Input ~ 0
~J
Wire Wire Line
	2800 5500 2600 5500
$Comp
L power:GND #PWR?
U 1 1 60849966
P 4100 5650
AR Path="/5D2C0720/60849966" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/60849966" Ref="#PWR0425"  Part="1" 
F 0 "#PWR0425" H 4100 5400 50  0001 C CNN
F 1 "GND" H 4105 5477 50  0000 C CNN
F 2 "" H 4100 5650 50  0001 C CNN
F 3 "" H 4100 5650 50  0001 C CNN
	1    4100 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 5500 4100 5500
Wire Wire Line
	4100 5500 4100 5650
Wire Wire Line
	4100 5200 4100 5500
Connection ~ 4100 5500
$Comp
L Connector:TestPoint TP?
U 1 1 60849970
P 2800 5500
AR Path="/5D2C0720/60849970" Ref="TP?"  Part="1" 
AR Path="/5FE35007/60849970" Ref="TP40"  Part="1" 
F 0 "TP40" V 2754 5688 50  0000 L CNN
F 1 "~JABS" V 2845 5688 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 3000 5500 50  0001 C CNN
F 3 "~" H 3000 5500 50  0001 C CNN
	1    2800 5500
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP?
U 1 1 60849976
P 3950 5500
AR Path="/5D2C0720/60849976" Ref="TP?"  Part="1" 
AR Path="/5FE35007/60849976" Ref="TP42"  Part="1" 
F 0 "TP42" V 3900 5850 50  0000 R CNN
F 1 "GND" V 4000 5850 50  0000 R CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 4150 5500 50  0001 C CNN
F 3 "~" H 4150 5500 50  0001 C CNN
	1    3950 5500
	0    -1   1    0   
$EndComp
Text HLabel 2600 5500 0    50   Input ~ 0
~JABS
$EndSCHEMATC
