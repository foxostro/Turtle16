EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 15 31
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
P 650 7600
AR Path="/5D8005AF/5D800742/5FE3C778" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3C778" Ref="C31"  Part="1" 
F 0 "C31" H 765 7646 50  0000 L CNN
F 1 "100nF" H 765 7555 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 688 7450 50  0001 C CNN
F 3 "~" H 650 7600 50  0001 C CNN
	1    650  7600
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FE3C77E
P 1150 7600
AR Path="/5D8005AF/5D800742/5FE3C77E" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3C77E" Ref="C32"  Part="1" 
F 0 "C32" H 1265 7646 50  0000 L CNN
F 1 "100nF" H 1265 7555 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1188 7450 50  0001 C CNN
F 3 "~" H 1150 7600 50  0001 C CNN
	1    1150 7600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FE3C784
P 650 7750
AR Path="/5D8005AF/5D800742/5FE3C784" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C784" Ref="#PWR0167"  Part="1" 
F 0 "#PWR0167" H 650 7500 50  0001 C CNN
F 1 "GND" H 655 7577 50  0000 C CNN
F 2 "" H 650 7750 50  0001 C CNN
F 3 "" H 650 7750 50  0001 C CNN
	1    650  7750
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FE3C78A
P 650 7450
AR Path="/5D8005AF/5D800742/5FE3C78A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C78A" Ref="#PWR0166"  Part="1" 
F 0 "#PWR0166" H 650 7300 50  0001 C CNN
F 1 "VCC" H 667 7623 50  0000 C CNN
F 2 "" H 650 7450 50  0001 C CNN
F 3 "" H 650 7450 50  0001 C CNN
	1    650  7450
	1    0    0    -1  
$EndComp
Wire Wire Line
	650  7450 1150 7450
Connection ~ 650  7450
Wire Wire Line
	1150 7750 650  7750
Connection ~ 650  7750
$Comp
L power:VCC #PWR?
U 1 1 5FE3C79A
P 3800 2350
AR Path="/5D8005AF/5D800742/5FE3C79A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C79A" Ref="#PWR0168"  Part="1" 
F 0 "#PWR0168" H 3800 2200 50  0001 C CNN
F 1 "VCC" H 3817 2523 50  0000 C CNN
F 2 "" H 3800 2350 50  0001 C CNN
F 3 "" H 3800 2350 50  0001 C CNN
	1    3800 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 2350 3800 2850
Wire Wire Line
	5850 3250 5850 2850
Connection ~ 3800 2850
Wire Wire Line
	3800 2850 3800 3250
$Comp
L power:GND #PWR?
U 1 1 5FE3C7A4
P 3800 6350
AR Path="/5D8005AF/5D800742/5FE3C7A4" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3C7A4" Ref="#PWR0169"  Part="1" 
F 0 "#PWR0169" H 3800 6100 50  0001 C CNN
F 1 "GND" H 3805 6177 50  0000 C CNN
F 2 "" H 3800 6350 50  0001 C CNN
F 3 "" H 3800 6350 50  0001 C CNN
	1    3800 6350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 6350 3800 5850
Wire Wire Line
	5850 5850 5850 5650
Connection ~ 3800 5850
Wire Wire Line
	3800 5850 3800 5650
Entry Wire Line
	4800 3450 4900 3350
Entry Wire Line
	4800 3550 4900 3450
Entry Wire Line
	4800 3650 4900 3550
Entry Wire Line
	4800 3750 4900 3650
Entry Wire Line
	4800 3850 4900 3750
Entry Wire Line
	4800 3950 4900 3850
Entry Wire Line
	4800 4050 4900 3950
Entry Wire Line
	4800 4150 4900 4050
Entry Wire Line
	4800 4250 4900 4150
Entry Wire Line
	4800 4350 4900 4250
Entry Wire Line
	4800 4450 4900 4350
Entry Wire Line
	4800 4550 4900 4450
Entry Wire Line
	4800 4650 4900 4550
Entry Wire Line
	4800 4750 4900 4650
Entry Wire Line
	4800 4850 4900 4750
Entry Wire Line
	4800 4950 4900 4850
Text Label 4800 3450 2    50   ~ 0
PC_IF0
Text Label 4800 3550 2    50   ~ 0
PC_IF1
Text Label 4800 3650 2    50   ~ 0
PC_IF2
Text Label 4800 3750 2    50   ~ 0
PC_IF3
Text Label 4800 3850 2    50   ~ 0
PC_IF4
Text Label 4800 3950 2    50   ~ 0
PC_IF5
Text Label 4800 4050 2    50   ~ 0
PC_IF6
Text Label 4800 4150 2    50   ~ 0
PC_IF7
Text Label 4800 4250 2    50   ~ 0
PC_IF8
Text Label 4800 4350 2    50   ~ 0
PC_IF9
Text Label 4800 4450 2    50   ~ 0
PC_IF10
Text Label 4800 4550 2    50   ~ 0
PC_IF11
Text Label 4800 4650 2    50   ~ 0
PC_IF12
Text Label 4800 4750 2    50   ~ 0
PC_IF13
Text Label 4800 4850 2    50   ~ 0
PC_IF14
Text Label 4800 4950 2    50   ~ 0
PC_IF15
Wire Wire Line
	4450 5250 5000 5250
Wire Wire Line
	4450 5450 5000 5450
Wire Wire Line
	5000 5450 5000 5850
Connection ~ 5000 5450
Wire Wire Line
	5000 5450 5200 5450
Connection ~ 5000 5850
Wire Wire Line
	5000 5850 5850 5850
Wire Wire Line
	5000 5250 5000 2850
Connection ~ 5000 5250
Wire Wire Line
	5000 5250 5200 5250
Connection ~ 5000 2850
Wire Wire Line
	5000 2850 3800 2850
Wire Wire Line
	3800 5850 4800 5850
Connection ~ 4800 5050
Wire Wire Line
	5200 5050 4800 5050
Connection ~ 4800 5850
Wire Wire Line
	4450 5050 4800 5050
Wire Wire Line
	4800 5050 4800 5850
Entry Wire Line
	7200 3450 7300 3350
Entry Wire Line
	7200 3550 7300 3450
Entry Wire Line
	7200 3750 7300 3650
Entry Wire Line
	7200 3850 7300 3750
Entry Wire Line
	7200 3950 7300 3850
Entry Wire Line
	7200 4050 7300 3950
Entry Wire Line
	7200 4150 7300 4050
Entry Wire Line
	7200 3650 7300 3550
Text Label 7200 3450 2    50   ~ 0
InstructionWord8
Text Label 7200 3550 2    50   ~ 0
InstructionWord9
Text Label 3100 3850 2    50   ~ 0
InstructionWord4
Text Label 3100 3950 2    50   ~ 0
InstructionWord5
Text Label 3100 4050 2    50   ~ 0
InstructionWord6
Text Label 3100 4150 2    50   ~ 0
InstructionWord7
Text Label 7200 3650 2    50   ~ 0
InstructionWord10
Text Label 7200 3750 2    50   ~ 0
InstructionWord11
Text Label 7200 3850 2    50   ~ 0
InstructionWord12
Text Label 7200 3950 2    50   ~ 0
InstructionWord13
Text Label 7200 4050 2    50   ~ 0
InstructionWord14
Text Label 7200 4150 2    50   ~ 0
InstructionWord15
Wire Wire Line
	5850 2850 5000 2850
Text Label 3100 3750 2    50   ~ 0
InstructionWord3
Text Label 3100 3650 2    50   ~ 0
InstructionWord2
Text Label 3100 3550 2    50   ~ 0
InstructionWord1
Text Label 3100 3450 2    50   ~ 0
InstructionWord0
Entry Wire Line
	2250 3350 2350 3450
Entry Wire Line
	2250 4050 2350 4150
Entry Wire Line
	2250 3950 2350 4050
Entry Wire Line
	2250 3850 2350 3950
Entry Wire Line
	2250 3750 2350 3850
Entry Wire Line
	2250 3650 2350 3750
Entry Wire Line
	2250 3550 2350 3650
Entry Wire Line
	2250 3450 2350 3550
$Comp
L MainBoard-rescue:GLS29EE010-Memory_EEPROM U?
U 1 1 5FE3C801
P 5850 3350
AR Path="/5D8005AF/5D800742/5FE3C801" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3C801" Ref="U31"  Part="1" 
F 0 "U31" H 5850 2850 50  0000 C CNN
F 1 "Instruction ROM [8..15]" V 5850 2300 50  0000 C CNN
F 2 "Socket:DIP_Socket-32_W11.9_W12.7_W15.24_W17.78_W18.5_3M_232-1285-00-0602J" H 5850 3350 50  0001 C CNN
F 3 "" H 5850 3350 50  0001 C CNN
	1    5850 3350
	1    0    0    -1  
$EndComp
Wire Bus Line
	1300 2750 4900 2750
Wire Wire Line
	4450 5350 5100 5350
Wire Wire Line
	4800 5850 5000 5850
Wire Wire Line
	5100 4950 5100 5350
Connection ~ 5100 4950
Wire Wire Line
	5100 4950 5200 4950
Connection ~ 5100 5350
Wire Wire Line
	5100 5350 5200 5350
Text HLabel 1300 2750 0    50   Input ~ 0
PC_IF[0..15]
Connection ~ 7300 3050
Wire Wire Line
	6450 3450 7200 3450
Wire Wire Line
	6450 3550 7200 3550
Wire Wire Line
	6450 3650 7200 3650
Wire Wire Line
	6450 3750 7200 3750
Wire Wire Line
	6450 3850 7200 3850
Wire Wire Line
	6450 3950 7200 3950
Wire Wire Line
	6450 4050 7200 4050
Wire Wire Line
	6450 4150 7200 4150
NoConn ~ 3200 4350
NoConn ~ 3200 4450
NoConn ~ 6450 4350
NoConn ~ 6450 4450
Wire Bus Line
	2250 3050 7300 3050
$Sheet
S 8350 2550 1150 600 
U 5FCE2082
F0 "sheet5FCE207B" 50
F1 "IF_ID.sch" 50
F2 "PCIn[0..15]" I L 8350 2750 50 
F3 "PCOut[0..15]" O R 9500 2650 50 
F4 "InsIn[0..15]" I L 8350 3050 50 
F5 "InsOut[0..15]" O R 9500 2750 50 
F6 "Phi1" I L 8350 2650 50 
$EndSheet
Text HLabel 9800 2750 2    50   Output ~ 0
InsOut[0..15]
Text HLabel 9800 2650 2    50   Output ~ 0
PCOut[0..15]
Text Label 7400 3050 0    50   ~ 0
InstructionWord[0..15]
Wire Bus Line
	9800 2650 9500 2650
Wire Bus Line
	9500 2750 9800 2750
Wire Bus Line
	7300 3050 8350 3050
Wire Bus Line
	4900 2750 8350 2750
Connection ~ 4900 2750
Text HLabel 8250 2650 0    50   Input ~ 0
Phi1
Wire Wire Line
	8350 2650 8250 2650
Wire Bus Line
	4900 2750 4900 4850
Wire Bus Line
	2250 3050 2250 4050
Wire Bus Line
	7300 3050 7300 4050
Wire Wire Line
	4450 4950 5100 4950
Wire Wire Line
	4450 4850 5200 4850
Wire Wire Line
	4450 4750 5200 4750
Wire Wire Line
	4450 4650 5200 4650
Wire Wire Line
	4450 4550 5200 4550
Wire Wire Line
	4450 4450 5200 4450
Wire Wire Line
	4450 4350 5200 4350
Wire Wire Line
	4450 4250 5200 4250
Wire Wire Line
	4450 4150 5200 4150
Wire Wire Line
	4450 4050 5200 4050
Wire Wire Line
	4450 3950 5200 3950
Wire Wire Line
	4450 3850 5200 3850
Wire Wire Line
	4450 3750 5200 3750
Wire Wire Line
	4450 3650 5200 3650
Wire Wire Line
	4450 3550 5200 3550
Wire Wire Line
	4450 3450 5200 3450
Wire Wire Line
	2350 3750 3200 3750
Wire Wire Line
	2350 3850 3200 3850
Wire Wire Line
	2350 3950 3200 3950
Wire Wire Line
	2350 4050 3200 4050
Wire Wire Line
	2350 4150 3200 4150
Wire Wire Line
	2350 3450 3200 3450
Wire Wire Line
	2350 3550 3200 3550
Wire Wire Line
	2350 3650 3200 3650
$Comp
L MainBoard-rescue:GLS29EE010-Memory_EEPROM U?
U 1 1 5FE3C794
P 3800 3350
AR Path="/5D8005AF/5D800742/5FE3C794" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3C794" Ref="U30"  Part="1" 
F 0 "U30" H 3800 2850 50  0000 C CNN
F 1 "Instruction ROM [0..7]" V 3800 2300 50  0000 C CNN
F 2 "Socket:DIP_Socket-32_W11.9_W12.7_W15.24_W17.78_W18.5_3M_232-1285-00-0602J" H 3800 3350 50  0001 C CNN
F 3 "" H 3800 3350 50  0001 C CNN
	1    3800 3350
	-1   0    0    -1  
$EndComp
$EndSCHEMATC
