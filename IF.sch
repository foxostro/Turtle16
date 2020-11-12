EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 5 86
Title "IF"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 "seated in ZIF sockets. There is no instruction RAM."
Comment4 "The Instruction Fetch stage retrieves sixteen-bit instructions from a pair of EEPROMs"
$EndDescr
$Comp
L Device:C C?
U 1 1 5FE3C778
P 1500 7000
AR Path="/5D8005AF/5D800742/5FE3C778" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3C778" Ref="C13"  Part="1" 
F 0 "C13" H 1615 7046 50  0000 L CNN
F 1 "100nF" H 1615 6955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 1538 6850 50  0001 C CNN
F 3 "~" H 1500 7000 50  0001 C CNN
	1    1500 7000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FE3C77E
P 2000 7000
AR Path="/5D8005AF/5D800742/5FE3C77E" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3C77E" Ref="C14"  Part="1" 
F 0 "C14" H 2115 7046 50  0000 L CNN
F 1 "100nF" H 2115 6955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 2038 6850 50  0001 C CNN
F 3 "~" H 2000 7000 50  0001 C CNN
	1    2000 7000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FE3C784
P 1500 7150
AR Path="/5D8005AF/5D800742/5FE3C784" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C784" Ref="#PWR050"  Part="1" 
F 0 "#PWR050" H 1500 6900 50  0001 C CNN
F 1 "GND" H 1505 6977 50  0000 C CNN
F 2 "" H 1500 7150 50  0001 C CNN
F 3 "" H 1500 7150 50  0001 C CNN
	1    1500 7150
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FE3C78A
P 1500 6850
AR Path="/5D8005AF/5D800742/5FE3C78A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C78A" Ref="#PWR049"  Part="1" 
F 0 "#PWR049" H 1500 6700 50  0001 C CNN
F 1 "VCC" H 1517 7023 50  0000 C CNN
F 2 "" H 1500 6850 50  0001 C CNN
F 3 "" H 1500 6850 50  0001 C CNN
	1    1500 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 6850 2000 6850
Connection ~ 1500 6850
Wire Wire Line
	2000 7150 1500 7150
Connection ~ 1500 7150
$Comp
L power:VCC #PWR?
U 1 1 5FE3C79A
P 4750 2050
AR Path="/5D8005AF/5D800742/5FE3C79A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C79A" Ref="#PWR051"  Part="1" 
F 0 "#PWR051" H 4750 1900 50  0001 C CNN
F 1 "VCC" H 4767 2223 50  0000 C CNN
F 2 "" H 4750 2050 50  0001 C CNN
F 3 "" H 4750 2050 50  0001 C CNN
	1    4750 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4750 2050 4750 2550
Wire Wire Line
	6800 2950 6800 2550
Connection ~ 4750 2550
Wire Wire Line
	4750 2550 4750 2950
$Comp
L power:GND #PWR?
U 1 1 5FE3C7A4
P 4750 6050
AR Path="/5D8005AF/5D800742/5FE3C7A4" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C7A4" Ref="#PWR052"  Part="1" 
F 0 "#PWR052" H 4750 5800 50  0001 C CNN
F 1 "GND" H 4755 5877 50  0000 C CNN
F 2 "" H 4750 6050 50  0001 C CNN
F 3 "" H 4750 6050 50  0001 C CNN
	1    4750 6050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4750 6050 4750 5550
Wire Wire Line
	6800 5550 6800 5350
Connection ~ 4750 5550
Wire Wire Line
	4750 5550 4750 5350
Entry Wire Line
	5750 3150 5850 3050
Entry Wire Line
	5750 3250 5850 3150
Entry Wire Line
	5750 3350 5850 3250
Entry Wire Line
	5750 3450 5850 3350
Entry Wire Line
	5750 3550 5850 3450
Entry Wire Line
	5750 3650 5850 3550
Entry Wire Line
	5750 3750 5850 3650
Entry Wire Line
	5750 3850 5850 3750
Entry Wire Line
	5750 3950 5850 3850
Entry Wire Line
	5750 4050 5850 3950
Entry Wire Line
	5750 4150 5850 4050
Entry Wire Line
	5750 4250 5850 4150
Entry Wire Line
	5750 4350 5850 4250
Entry Wire Line
	5750 4450 5850 4350
Entry Wire Line
	5750 4550 5850 4450
Entry Wire Line
	5750 4650 5850 4550
Text Label 5750 3150 2    50   ~ 0
PC_IF0
Text Label 5750 3250 2    50   ~ 0
PC_IF1
Text Label 5750 3350 2    50   ~ 0
PC_IF2
Text Label 5750 3450 2    50   ~ 0
PC_IF3
Text Label 5750 3550 2    50   ~ 0
PC_IF4
Text Label 5750 3650 2    50   ~ 0
PC_IF5
Text Label 5750 3750 2    50   ~ 0
PC_IF6
Text Label 5750 3850 2    50   ~ 0
PC_IF7
Text Label 5750 3950 2    50   ~ 0
PC_IF8
Text Label 5750 4050 2    50   ~ 0
PC_IF9
Text Label 5750 4150 2    50   ~ 0
PC_IF10
Text Label 5750 4250 2    50   ~ 0
PC_IF11
Text Label 5750 4350 2    50   ~ 0
PC_IF12
Text Label 5750 4450 2    50   ~ 0
PC_IF13
Text Label 5750 4550 2    50   ~ 0
PC_IF14
Text Label 5750 4650 2    50   ~ 0
PC_IF15
Wire Wire Line
	5400 4950 5950 4950
Wire Wire Line
	5400 5150 5950 5150
Wire Wire Line
	5950 5150 5950 5550
Connection ~ 5950 5150
Wire Wire Line
	5950 5150 6150 5150
Connection ~ 5950 5550
Wire Wire Line
	5950 5550 6800 5550
Wire Wire Line
	5950 4950 5950 2550
Connection ~ 5950 4950
Wire Wire Line
	5950 4950 6150 4950
Connection ~ 5950 2550
Wire Wire Line
	5950 2550 4750 2550
Wire Wire Line
	4750 5550 5750 5550
Connection ~ 5750 4750
Wire Wire Line
	6150 4750 5750 4750
Connection ~ 5750 5550
Wire Wire Line
	5400 4750 5750 4750
Wire Wire Line
	5750 4750 5750 5550
Entry Wire Line
	8150 3150 8250 3050
Entry Wire Line
	8150 3250 8250 3150
Entry Wire Line
	8150 3450 8250 3350
Entry Wire Line
	8150 3550 8250 3450
Entry Wire Line
	8150 3650 8250 3550
Entry Wire Line
	8150 3750 8250 3650
Entry Wire Line
	8150 3850 8250 3750
Entry Wire Line
	8150 3350 8250 3250
Text Label 8150 3150 2    50   ~ 0
InstructionWord8
Text Label 8150 3250 2    50   ~ 0
InstructionWord9
Text Label 4050 3550 2    50   ~ 0
InstructionWord4
Text Label 4050 3650 2    50   ~ 0
InstructionWord5
Text Label 4050 3750 2    50   ~ 0
InstructionWord6
Text Label 4050 3850 2    50   ~ 0
InstructionWord7
Text Label 8150 3350 2    50   ~ 0
InstructionWord10
Text Label 8150 3450 2    50   ~ 0
InstructionWord11
Text Label 8150 3550 2    50   ~ 0
InstructionWord12
Text Label 8150 3650 2    50   ~ 0
InstructionWord13
Text Label 8150 3750 2    50   ~ 0
InstructionWord14
Text Label 8150 3850 2    50   ~ 0
InstructionWord15
Wire Wire Line
	6800 2550 5950 2550
Text Label 4050 3450 2    50   ~ 0
InstructionWord3
Text Label 4050 3350 2    50   ~ 0
InstructionWord2
Text Label 4050 3250 2    50   ~ 0
InstructionWord1
Text Label 4050 3150 2    50   ~ 0
InstructionWord0
Entry Wire Line
	3200 3050 3300 3150
Entry Wire Line
	3200 3750 3300 3850
Entry Wire Line
	3200 3650 3300 3750
Entry Wire Line
	3200 3550 3300 3650
Entry Wire Line
	3200 3450 3300 3550
Entry Wire Line
	3200 3350 3300 3450
Entry Wire Line
	3200 3250 3300 3350
Entry Wire Line
	3200 3150 3300 3250
$Comp
L MainBoard-rescue:GLS29EE010-Memory_EEPROM U?
U 1 1 5FE3C801
P 6800 3050
AR Path="/5D8005AF/5D800742/5FE3C801" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3C801" Ref="U12"  Part="1" 
F 0 "U12" H 6500 3250 50  0000 C CNN
F 1 "Instruction ROM [8..15]" H 6500 3150 50  0000 C CNN
F 2 "Socket:DIP_Socket-32_W11.9_W12.7_W15.24_W17.78_W18.5_3M_232-1285-00-0602J" H 6800 3050 50  0001 C CNN
F 3 "" H 6800 3050 50  0001 C CNN
	1    6800 3050
	1    0    0    -1  
$EndComp
Wire Bus Line
	2250 2650 5850 2650
Wire Wire Line
	5400 5050 6050 5050
Wire Wire Line
	5750 5550 5950 5550
Wire Wire Line
	6050 4650 6050 5050
Connection ~ 6050 4650
Wire Wire Line
	6050 4650 6150 4650
Connection ~ 6050 5050
Wire Wire Line
	6050 5050 6150 5050
Text HLabel 2250 2650 0    50   Input ~ 0
PC_IF[0..15]
Text HLabel 8700 2750 2    50   Output ~ 0
InstructionWord[0..15]
Connection ~ 8250 2750
Wire Bus Line
	8250 2750 8700 2750
Wire Wire Line
	7400 3150 8150 3150
Wire Wire Line
	7400 3250 8150 3250
Wire Wire Line
	7400 3350 8150 3350
Wire Wire Line
	7400 3450 8150 3450
Wire Wire Line
	7400 3550 8150 3550
Wire Wire Line
	7400 3650 8150 3650
Wire Wire Line
	7400 3750 8150 3750
Wire Wire Line
	7400 3850 8150 3850
Wire Wire Line
	3300 3150 4150 3150
Wire Wire Line
	3300 3250 4150 3250
Wire Wire Line
	3300 3350 4150 3350
Wire Wire Line
	3300 3450 4150 3450
Wire Wire Line
	3300 3550 4150 3550
Wire Wire Line
	3300 3650 4150 3650
Wire Wire Line
	3300 3750 4150 3750
Wire Wire Line
	3300 3850 4150 3850
NoConn ~ 4150 4050
NoConn ~ 4150 4150
NoConn ~ 7400 4050
NoConn ~ 7400 4150
Wire Bus Line
	3200 2750 8250 2750
$Comp
L MainBoard-rescue:GLS29EE010-Memory_EEPROM U?
U 1 1 5FE3C794
P 4750 3050
AR Path="/5D8005AF/5D800742/5FE3C794" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3C794" Ref="U11"  Part="1" 
F 0 "U11" H 5050 3250 50  0000 C CNN
F 1 "Instruction ROM [0..7]" H 5050 3150 50  0000 C CNN
F 2 "Socket:DIP_Socket-32_W11.9_W12.7_W15.24_W17.78_W18.5_3M_232-1285-00-0602J" H 4750 3050 50  0001 C CNN
F 3 "" H 4750 3050 50  0001 C CNN
	1    4750 3050
	-1   0    0    -1  
$EndComp
Wire Bus Line
	5850 2650 5850 4550
Wire Wire Line
	5400 4650 6050 4650
Wire Wire Line
	5400 3150 6150 3150
Wire Wire Line
	5400 3250 6150 3250
Wire Wire Line
	5400 3350 6150 3350
Wire Wire Line
	5400 3450 6150 3450
Wire Wire Line
	5400 3550 6150 3550
Wire Wire Line
	5400 3650 6150 3650
Wire Wire Line
	5400 3750 6150 3750
Wire Wire Line
	5400 3850 6150 3850
Wire Wire Line
	5400 3950 6150 3950
Wire Wire Line
	5400 4050 6150 4050
Wire Wire Line
	5400 4150 6150 4150
Wire Wire Line
	5400 4250 6150 4250
Wire Wire Line
	5400 4350 6150 4350
Wire Wire Line
	5400 4450 6150 4450
Wire Wire Line
	5400 4550 6150 4550
Wire Bus Line
	3200 2750 3200 3750
Wire Bus Line
	8250 2750 8250 3750
$EndSCHEMATC
