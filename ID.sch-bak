EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 4 33
Title "ID"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 "effect conditional instructions."
Comment3 "The decoder takes the condition code from the flags register into account to"
Comment4 "The instruction decoder turns a 5-bit opcode into an array of control signals."
$EndDescr
Text HLabel 2300 3250 0    50   Input ~ 0
Carry
Text HLabel 2300 3350 0    50   Input ~ 0
Z
Text HLabel 950  850  0    50   Input ~ 0
Ins[0..15]
Text HLabel 9750 1050 2    50   Output ~ 0
ControlWord[1..19]
Text Notes 750  6650 0    50   ~ 0
Decode the instruction opcode into an array of control\nsignals. These signals are carried forward through each\npipeline stage until the stage where they are used. This\nkeeps stages synchronized with the corresponding\ninstruction.
Text Notes -2250 2800 0    50   ~ 0
#   Mnemonic\n——————————\n0  /HLT\n1   SelLeftOp\n2   SelRightOp\n3   SelStoreOpA\n4   SelStoreOpB\n5   /FI\n6   CarryIn\n7   I0\n8   I1\n9   I2\n10  RS0\n11  RS1\n12  /J\n13  /MemLoad\n14  /MemStore\n15  /WRL\n16  /WRH\n17  WriteBackSrcA\n18  WriteBackSrcB\n19  unused
Text HLabel 2300 3450 0    50   Input ~ 0
OVF
$Sheet
S 8450 650  1150 600 
U 5FD3D817
F0 "sheet5FD3D810" 50
F1 "ID_REG.sch" 50
F2 "PCIn[0..15]" I L 8450 950 50 
F3 "Phi1" I L 8450 750 50 
F4 "InsIn[0..15]" I L 8450 850 50 
F5 "PCOut[0..15]" O R 9600 950 50 
F6 "InsOut[0..15]" O R 9600 850 50 
F7 "Ctl[0..15]" I L 8450 1150 50 
F8 "ControlWord[0..23]" O R 9600 1050 50 
$EndSheet
Wire Bus Line
	8450 950  7700 950 
Text HLabel 7700 950  0    50   Input ~ 0
PCIn[0..15]
Text HLabel 2300 3550 0    50   Input ~ 0
~RST
Text HLabel 9750 1950 3    50   Output ~ 0
~HLT
Text Label 9750 1400 3    50   ~ 0
ControlWord0
Entry Wire Line
	9750 1150 9650 1050
Text Notes -1350 2800 0    50   ~ 0
Description\n————————\nHalt Clock\nSelect Left Operand\nSelect Right Operand\nSelect Store Operand 0\nSelect Store Operand 1\nFlags Register In\nALU Carry input\nALU I0 input\nALU I1 input\nALU I2 input\nALU RS0 input\nALU RS1 input\nJump\nMemory Store\nMemory Load\nWrite back low byte\nWrite back high byte\nSource of write back 0\nSource of write back 1\nunused
$Comp
L Device:C C?
U 1 1 5FC2DB53
P 800 7650
AR Path="/5D8005AF/5D800742/5FC2DB53" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FC2DB53" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FC2DB53" Ref="C16"  Part="1" 
F 0 "C16" H 915 7696 50  0000 L CNN
F 1 "100nF" H 915 7605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 838 7500 50  0001 C CNN
F 3 "~" H 800 7650 50  0001 C CNN
	1    800  7650
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FC2DB59
P 1300 7650
AR Path="/5D8005AF/5D800742/5FC2DB59" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FC2DB59" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FC2DB59" Ref="C17"  Part="1" 
F 0 "C17" H 1415 7696 50  0000 L CNN
F 1 "100nF" H 1415 7605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1338 7500 50  0001 C CNN
F 3 "~" H 1300 7650 50  0001 C CNN
	1    1300 7650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DB5F
P 800 7800
AR Path="/5D8005AF/5D800742/5FC2DB5F" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FC2DB5F" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DB5F" Ref="#PWR072"  Part="1" 
F 0 "#PWR072" H 800 7550 50  0001 C CNN
F 1 "GND" H 805 7627 50  0000 C CNN
F 2 "" H 800 7800 50  0001 C CNN
F 3 "" H 800 7800 50  0001 C CNN
	1    800  7800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DB65
P 800 7500
AR Path="/5D8005AF/5D800742/5FC2DB65" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FC2DB65" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DB65" Ref="#PWR071"  Part="1" 
F 0 "#PWR071" H 800 7350 50  0001 C CNN
F 1 "VCC" H 817 7673 50  0000 C CNN
F 2 "" H 800 7500 50  0001 C CNN
F 3 "" H 800 7500 50  0001 C CNN
	1    800  7500
	1    0    0    -1  
$EndComp
Wire Wire Line
	800  7500 1300 7500
Connection ~ 800  7500
Wire Wire Line
	1300 7800 800  7800
Connection ~ 800  7800
Entry Wire Line
	6600 4450 6500 4350
Entry Wire Line
	6600 4550 6500 4450
Entry Wire Line
	6600 4750 6500 4650
Entry Wire Line
	6600 4850 6500 4750
Entry Wire Line
	6600 4950 6500 4850
Entry Wire Line
	6600 5050 6500 4950
Entry Wire Line
	6600 5150 6500 5050
Entry Wire Line
	6600 4650 6500 4550
Text Label 6600 4450 0    50   ~ 0
Ctl8
Text Label 6600 4550 0    50   ~ 0
Ctl9
Text Label 2350 4850 2    50   ~ 0
Ctl4
Text Label 2350 4950 2    50   ~ 0
Ctl5
Text Label 2350 5050 2    50   ~ 0
Ctl6
Text Label 2350 5150 2    50   ~ 0
Ctl7
Text Label 6600 4650 0    50   ~ 0
Ctl10
Text Label 6600 4750 0    50   ~ 0
Ctl11
Text Label 6600 4850 0    50   ~ 0
Ctl12
Text Label 6600 4950 0    50   ~ 0
Ctl13
Text Label 6600 5050 0    50   ~ 0
Ctl14
Text Label 6600 5150 0    50   ~ 0
Ctl15
Text Label 2350 4650 2    50   ~ 0
Ctl2
Text Label 2350 4550 2    50   ~ 0
Ctl1
Text Label 2350 4450 2    50   ~ 0
Ctl0
Entry Wire Line
	1500 4350 1600 4450
Entry Wire Line
	1500 5050 1600 5150
Entry Wire Line
	1500 4950 1600 5050
Entry Wire Line
	1500 4850 1600 4950
Entry Wire Line
	1500 4750 1600 4850
Entry Wire Line
	1500 4650 1600 4750
Entry Wire Line
	1500 4550 1600 4650
Entry Wire Line
	1500 4450 1600 4550
Text HLabel 9750 850  2    50   Output ~ 0
InsOut[0..10]
Text HLabel 9750 950  2    50   Output ~ 0
PCOut[0..15]
Text Label 7500 1150 0    50   ~ 0
Ctl[0..15]
Wire Bus Line
	9750 850  9600 850 
Wire Bus Line
	9600 950  9750 950 
Text HLabel 8350 750  0    50   Input ~ 0
Phi1
Wire Wire Line
	8450 750  8350 750 
Wire Wire Line
	1600 4750 2450 4750
Wire Wire Line
	1600 4850 2450 4850
Wire Wire Line
	1600 4950 2450 4950
Wire Wire Line
	1600 5050 2450 5050
Wire Wire Line
	1600 5150 2450 5150
Wire Wire Line
	1600 4450 2450 4450
Wire Wire Line
	1600 4550 2450 4550
Wire Wire Line
	1600 4650 2450 4650
$Comp
L Memory_RAM:IDT7008L15JG U?
U 1 1 5FC2DBA6
P 3250 3400
AR Path="/5FE35007/5FC2DBA6" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FC2DBA6" Ref="U11"  Part="1" 
F 0 "U11" H 3250 3450 50  0000 C CNN
F 1 "IDT7008L15JG" H 3250 3350 50  0000 C CNN
F 2 "Package_LCC:PLCC-84_SMD-Socket" H 2750 5350 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/698/IDT_7008_DST_20190808-1711430.pdf" H 2750 5350 50  0001 C CNN
	1    3250 3400
	1    0    0    -1  
$EndComp
Wire Bus Line
	950  850  1600 850 
$Comp
L power:VCC #PWR?
U 1 1 5FC2DBAD
P 3250 1450
AR Path="/5FE35007/5FC2DBAD" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBAD" Ref="#PWR087"  Part="1" 
F 0 "#PWR087" H 3250 1300 50  0001 C CNN
F 1 "VCC" H 3265 1623 50  0000 C CNN
F 2 "" H 3250 1450 50  0001 C CNN
F 3 "" H 3250 1450 50  0001 C CNN
	1    3250 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3150 1550 3150 1500
Wire Wire Line
	3350 1500 3350 1550
Wire Wire Line
	3150 1500 3250 1500
Wire Wire Line
	3250 1450 3250 1500
Connection ~ 3250 1500
Wire Wire Line
	3250 1500 3350 1500
Wire Wire Line
	3250 1500 3250 1550
$Comp
L power:GND #PWR?
U 1 1 5FC2DBBA
P 3250 5500
AR Path="/5FE35007/5FC2DBBA" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBBA" Ref="#PWR088"  Part="1" 
F 0 "#PWR088" H 3250 5250 50  0001 C CNN
F 1 "GND" H 3255 5327 50  0000 C CNN
F 2 "" H 3250 5500 50  0001 C CNN
F 3 "" H 3250 5500 50  0001 C CNN
	1    3250 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2900 5400 2900 5450
Wire Wire Line
	2900 5450 3000 5450
Wire Wire Line
	3600 5450 3600 5400
Wire Wire Line
	3250 5500 3250 5450
Connection ~ 3250 5450
Wire Wire Line
	3250 5450 3300 5450
Wire Wire Line
	3000 5400 3000 5450
Connection ~ 3000 5450
Wire Wire Line
	3000 5450 3100 5450
Wire Wire Line
	3100 5400 3100 5450
Connection ~ 3100 5450
Wire Wire Line
	3100 5450 3200 5450
Wire Wire Line
	3200 5400 3200 5450
Connection ~ 3200 5450
Wire Wire Line
	3200 5450 3250 5450
Wire Wire Line
	3300 5400 3300 5450
Connection ~ 3300 5450
Wire Wire Line
	3300 5450 3400 5450
Wire Wire Line
	3400 5400 3400 5450
Connection ~ 3400 5450
Wire Wire Line
	3400 5450 3500 5450
Wire Wire Line
	3500 5400 3500 5450
Connection ~ 3500 5450
Wire Wire Line
	3500 5450 3600 5450
NoConn ~ 4050 1950
NoConn ~ 2450 1950
$Comp
L power:VCC #PWR?
U 1 1 5FC2DBDA
P 2450 2050
AR Path="/5FE35007/5FC2DBDA" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBDA" Ref="#PWR074"  Part="1" 
F 0 "#PWR074" H 2450 1900 50  0001 C CNN
F 1 "VCC" V 2465 2177 50  0000 L CNN
F 2 "" H 2450 2050 50  0001 C CNN
F 3 "" H 2450 2050 50  0001 C CNN
	1    2450 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DBE0
P 2450 2250
AR Path="/5FE35007/5FC2DBE0" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBE0" Ref="#PWR076"  Part="1" 
F 0 "#PWR076" H 2450 2100 50  0001 C CNN
F 1 "VCC" V 2465 2377 50  0000 L CNN
F 2 "" H 2450 2250 50  0001 C CNN
F 3 "" H 2450 2250 50  0001 C CNN
	1    2450 2250
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DBE6
P 2450 2150
AR Path="/5FE35007/5FC2DBE6" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBE6" Ref="#PWR075"  Part="1" 
F 0 "#PWR075" H 2450 1900 50  0001 C CNN
F 1 "GND" V 2455 2022 50  0000 R CNN
F 2 "" H 2450 2150 50  0001 C CNN
F 3 "" H 2450 2150 50  0001 C CNN
	1    2450 2150
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DBEC
P 2450 2350
AR Path="/5FE35007/5FC2DBEC" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBEC" Ref="#PWR077"  Part="1" 
F 0 "#PWR077" H 2450 2200 50  0001 C CNN
F 1 "VCC" V 2465 2477 50  0000 L CNN
F 2 "" H 2450 2350 50  0001 C CNN
F 3 "" H 2450 2350 50  0001 C CNN
	1    2450 2350
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DBF2
P 2450 2450
AR Path="/5FE35007/5FC2DBF2" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBF2" Ref="#PWR078"  Part="1" 
F 0 "#PWR078" H 2450 2300 50  0001 C CNN
F 1 "VCC" V 2465 2577 50  0000 L CNN
F 2 "" H 2450 2450 50  0001 C CNN
F 3 "" H 2450 2450 50  0001 C CNN
	1    2450 2450
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DBF8
P 2450 2550
AR Path="/5FE35007/5FC2DBF8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DBF8" Ref="#PWR079"  Part="1" 
F 0 "#PWR079" H 2450 2300 50  0001 C CNN
F 1 "GND" V 2455 2422 50  0000 R CNN
F 2 "" H 2450 2550 50  0001 C CNN
F 3 "" H 2450 2550 50  0001 C CNN
	1    2450 2550
	0    1    1    0   
$EndComp
Entry Wire Line
	1700 2750 1600 2650
Entry Wire Line
	1700 2850 1600 2750
Entry Wire Line
	1700 2950 1600 2850
Entry Wire Line
	1700 3050 1600 2950
Entry Wire Line
	1700 3150 1600 3050
Text Label 1700 2750 0    50   ~ 0
Ins11
Text Label 1700 2850 0    50   ~ 0
Ins12
Text Label 1700 2950 0    50   ~ 0
Ins13
Text Label 1700 3050 0    50   ~ 0
Ins14
Text Label 1700 3150 0    50   ~ 0
Ins15
Wire Wire Line
	2450 3150 1700 3150
Wire Wire Line
	2450 3050 1700 3050
Wire Wire Line
	2450 2950 1700 2950
Wire Wire Line
	2450 2850 1700 2850
Wire Wire Line
	2450 2750 1700 2750
Wire Bus Line
	1500 1150 6500 1150
Connection ~ 1600 850 
Wire Bus Line
	1600 850  6600 850 
$Comp
L power:VCC #PWR?
U 1 1 5FC2DC2E
P 2450 1750
AR Path="/5FE35007/5FC2DC2E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC2E" Ref="#PWR073"  Part="1" 
F 0 "#PWR073" H 2450 1600 50  0001 C CNN
F 1 "VCC" V 2465 1877 50  0000 L CNN
F 2 "" H 2450 1750 50  0001 C CNN
F 3 "" H 2450 1750 50  0001 C CNN
	1    2450 1750
	0    -1   -1   0   
$EndComp
$Comp
L Memory_RAM:IDT7008L15JG U?
U 1 1 5FC2DC34
P 8250 3400
AR Path="/5FE35007/5FC2DC34" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FC2DC34" Ref="U13"  Part="1" 
F 0 "U13" H 8250 3450 50  0000 C CNN
F 1 "IDT7008L15JG" H 8250 3350 50  0000 C CNN
F 2 "Package_LCC:PLCC-84_SMD-Socket" H 7750 5350 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/698/IDT_7008_DST_20190808-1711430.pdf" H 7750 5350 50  0001 C CNN
	1    8250 3400
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DC3A
P 8250 1450
AR Path="/5FE35007/5FC2DC3A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC3A" Ref="#PWR0109"  Part="1" 
F 0 "#PWR0109" H 8250 1300 50  0001 C CNN
F 1 "VCC" H 8265 1623 50  0000 C CNN
F 2 "" H 8250 1450 50  0001 C CNN
F 3 "" H 8250 1450 50  0001 C CNN
	1    8250 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	8150 1550 8150 1500
Wire Wire Line
	8350 1500 8350 1550
Wire Wire Line
	8150 1500 8250 1500
Wire Wire Line
	8250 1450 8250 1500
Connection ~ 8250 1500
Wire Wire Line
	8250 1500 8350 1500
Wire Wire Line
	8250 1500 8250 1550
$Comp
L power:GND #PWR?
U 1 1 5FC2DC47
P 8250 5500
AR Path="/5FE35007/5FC2DC47" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC47" Ref="#PWR0110"  Part="1" 
F 0 "#PWR0110" H 8250 5250 50  0001 C CNN
F 1 "GND" H 8255 5327 50  0000 C CNN
F 2 "" H 8250 5500 50  0001 C CNN
F 3 "" H 8250 5500 50  0001 C CNN
	1    8250 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 5400 7900 5450
Wire Wire Line
	7900 5450 8000 5450
Wire Wire Line
	8600 5450 8600 5400
Wire Wire Line
	8250 5500 8250 5450
Connection ~ 8250 5450
Wire Wire Line
	8250 5450 8300 5450
Wire Wire Line
	8000 5400 8000 5450
Connection ~ 8000 5450
Wire Wire Line
	8000 5450 8100 5450
Wire Wire Line
	8100 5400 8100 5450
Connection ~ 8100 5450
Wire Wire Line
	8100 5450 8200 5450
Wire Wire Line
	8200 5400 8200 5450
Connection ~ 8200 5450
Wire Wire Line
	8200 5450 8250 5450
Wire Wire Line
	8300 5400 8300 5450
Connection ~ 8300 5450
Wire Wire Line
	8300 5450 8400 5450
Wire Wire Line
	8400 5400 8400 5450
Connection ~ 8400 5450
Wire Wire Line
	8400 5450 8500 5450
Wire Wire Line
	8500 5400 8500 5450
Connection ~ 8500 5450
Wire Wire Line
	8500 5450 8600 5450
NoConn ~ 9050 1950
NoConn ~ 7450 1950
$Comp
L power:VCC #PWR?
U 1 1 5FC2DC67
P 7450 2050
AR Path="/5FE35007/5FC2DC67" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC67" Ref="#PWR096"  Part="1" 
F 0 "#PWR096" H 7450 1900 50  0001 C CNN
F 1 "VCC" V 7465 2177 50  0000 L CNN
F 2 "" H 7450 2050 50  0001 C CNN
F 3 "" H 7450 2050 50  0001 C CNN
	1    7450 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DC6D
P 7450 2250
AR Path="/5FE35007/5FC2DC6D" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC6D" Ref="#PWR098"  Part="1" 
F 0 "#PWR098" H 7450 2100 50  0001 C CNN
F 1 "VCC" V 7465 2377 50  0000 L CNN
F 2 "" H 7450 2250 50  0001 C CNN
F 3 "" H 7450 2250 50  0001 C CNN
	1    7450 2250
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DC73
P 7450 2150
AR Path="/5FE35007/5FC2DC73" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC73" Ref="#PWR097"  Part="1" 
F 0 "#PWR097" H 7450 1900 50  0001 C CNN
F 1 "GND" V 7455 2022 50  0000 R CNN
F 2 "" H 7450 2150 50  0001 C CNN
F 3 "" H 7450 2150 50  0001 C CNN
	1    7450 2150
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DC79
P 7450 2350
AR Path="/5FE35007/5FC2DC79" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC79" Ref="#PWR099"  Part="1" 
F 0 "#PWR099" H 7450 2200 50  0001 C CNN
F 1 "VCC" V 7465 2477 50  0000 L CNN
F 2 "" H 7450 2350 50  0001 C CNN
F 3 "" H 7450 2350 50  0001 C CNN
	1    7450 2350
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DC7F
P 7450 2450
AR Path="/5FE35007/5FC2DC7F" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC7F" Ref="#PWR0100"  Part="1" 
F 0 "#PWR0100" H 7450 2300 50  0001 C CNN
F 1 "VCC" V 7465 2577 50  0000 L CNN
F 2 "" H 7450 2450 50  0001 C CNN
F 3 "" H 7450 2450 50  0001 C CNN
	1    7450 2450
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DC85
P 7450 2550
AR Path="/5FE35007/5FC2DC85" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DC85" Ref="#PWR0101"  Part="1" 
F 0 "#PWR0101" H 7450 2300 50  0001 C CNN
F 1 "GND" V 7455 2422 50  0000 R CNN
F 2 "" H 7450 2550 50  0001 C CNN
F 3 "" H 7450 2550 50  0001 C CNN
	1    7450 2550
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCB8
P 7450 1750
AR Path="/5FE35007/5FC2DCB8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCB8" Ref="#PWR095"  Part="1" 
F 0 "#PWR095" H 7450 1600 50  0001 C CNN
F 1 "VCC" V 7465 1877 50  0000 L CNN
F 2 "" H 7450 1750 50  0001 C CNN
F 3 "" H 7450 1750 50  0001 C CNN
	1    7450 1750
	0    -1   -1   0   
$EndComp
Connection ~ 6500 1150
Wire Bus Line
	6500 1150 8450 1150
Connection ~ 6600 850 
Wire Bus Line
	6600 850  8450 850 
Wire Wire Line
	6600 4450 7450 4450
Wire Wire Line
	6600 4550 7450 4550
Wire Wire Line
	6600 4650 7450 4650
Wire Wire Line
	6600 4750 7450 4750
Wire Wire Line
	6600 4850 7450 4850
Wire Wire Line
	6600 4950 7450 4950
Wire Wire Line
	6600 5050 7450 5050
Wire Wire Line
	6600 5150 7450 5150
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCCA
P 4050 2050
AR Path="/5FE35007/5FC2DCCA" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCCA" Ref="#PWR091"  Part="1" 
F 0 "#PWR091" H 4050 1900 50  0001 C CNN
F 1 "VCC" V 4065 2177 50  0000 L CNN
F 2 "" H 4050 2050 50  0001 C CNN
F 3 "" H 4050 2050 50  0001 C CNN
	1    4050 2050
	0    1    -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCD0
P 4050 2250
AR Path="/5FE35007/5FC2DCD0" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCD0" Ref="#PWR093"  Part="1" 
F 0 "#PWR093" H 4050 2100 50  0001 C CNN
F 1 "VCC" V 4065 2377 50  0000 L CNN
F 2 "" H 4050 2250 50  0001 C CNN
F 3 "" H 4050 2250 50  0001 C CNN
	1    4050 2250
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DCD6
P 4050 2150
AR Path="/5FE35007/5FC2DCD6" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCD6" Ref="#PWR092"  Part="1" 
F 0 "#PWR092" H 4050 1900 50  0001 C CNN
F 1 "GND" V 4055 2022 50  0000 R CNN
F 2 "" H 4050 2150 50  0001 C CNN
F 3 "" H 4050 2150 50  0001 C CNN
	1    4050 2150
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCDC
P 4050 2350
AR Path="/5FE35007/5FC2DCDC" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCDC" Ref="#PWR094"  Part="1" 
F 0 "#PWR094" H 4050 2200 50  0001 C CNN
F 1 "VCC" V 4065 2477 50  0000 L CNN
F 2 "" H 4050 2350 50  0001 C CNN
F 3 "" H 4050 2350 50  0001 C CNN
	1    4050 2350
	0    1    -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCE2
P 9050 2050
AR Path="/5FE35007/5FC2DCE2" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCE2" Ref="#PWR0111"  Part="1" 
F 0 "#PWR0111" H 9050 1900 50  0001 C CNN
F 1 "VCC" V 9065 2177 50  0000 L CNN
F 2 "" H 9050 2050 50  0001 C CNN
F 3 "" H 9050 2050 50  0001 C CNN
	1    9050 2050
	0    1    -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCE8
P 9050 2250
AR Path="/5FE35007/5FC2DCE8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCE8" Ref="#PWR0113"  Part="1" 
F 0 "#PWR0113" H 9050 2100 50  0001 C CNN
F 1 "VCC" V 9065 2377 50  0000 L CNN
F 2 "" H 9050 2250 50  0001 C CNN
F 3 "" H 9050 2250 50  0001 C CNN
	1    9050 2250
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DCEE
P 9050 2150
AR Path="/5FE35007/5FC2DCEE" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCEE" Ref="#PWR0112"  Part="1" 
F 0 "#PWR0112" H 9050 1900 50  0001 C CNN
F 1 "GND" V 9055 2022 50  0000 R CNN
F 2 "" H 9050 2150 50  0001 C CNN
F 3 "" H 9050 2150 50  0001 C CNN
	1    9050 2150
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FC2DCF4
P 9050 2350
AR Path="/5FE35007/5FC2DCF4" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DCF4" Ref="#PWR0114"  Part="1" 
F 0 "#PWR0114" H 9050 2200 50  0001 C CNN
F 1 "VCC" V 9065 2477 50  0000 L CNN
F 2 "" H 9050 2350 50  0001 C CNN
F 3 "" H 9050 2350 50  0001 C CNN
	1    9050 2350
	0    1    -1   0   
$EndComp
Entry Wire Line
	4800 5250 4700 5150
Entry Wire Line
	4800 4550 4700 4450
Entry Wire Line
	4800 4650 4700 4550
Entry Wire Line
	4800 4750 4700 4650
Entry Wire Line
	4800 4850 4700 4750
Entry Wire Line
	4800 4950 4700 4850
Entry Wire Line
	4800 5050 4700 4950
Entry Wire Line
	4800 5150 4700 5050
Wire Wire Line
	4700 4850 4050 4850
Wire Wire Line
	4700 4750 4050 4750
Wire Wire Line
	4700 4650 4050 4650
Wire Wire Line
	4700 4550 4050 4550
Wire Wire Line
	4700 4450 4050 4450
Wire Wire Line
	4700 5150 4050 5150
Wire Wire Line
	4700 5050 4050 5050
Wire Wire Line
	4700 4950 4050 4950
$Comp
L power:VCC #PWR?
U 1 1 5FC2DD0A
P 4000 6350
AR Path="/5D2C0B92/5FC2DD0A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DD0A" Ref="#PWR089"  Part="1" 
AR Path="/5D2C07CD/5FC2DD0A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FC2DD0A" Ref="#PWR?"  Part="1" 
F 0 "#PWR089" H 4000 6200 50  0001 C CNN
F 1 "VCC" H 4017 6523 50  0000 C CNN
F 2 "" H 4000 6350 50  0001 C CNN
F 3 "" H 4000 6350 50  0001 C CNN
	1    4000 6350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC2DD10
P 4000 7750
AR Path="/5D2C0B92/5FC2DD10" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DD10" Ref="#PWR090"  Part="1" 
AR Path="/5D2C07CD/5FC2DD10" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FC2DD10" Ref="#PWR?"  Part="1" 
F 0 "#PWR090" H 4000 7500 50  0001 C CNN
F 1 "GND" H 4005 7577 50  0000 C CNN
F 2 "" H 4000 7750 50  0001 C CNN
F 3 "" H 4000 7750 50  0001 C CNN
	1    4000 7750
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FC2DD16
P 1800 7650
AR Path="/5D8005AF/5D800742/5FC2DD16" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FC2DD16" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FC2DD16" Ref="C18"  Part="1" 
F 0 "C18" H 1915 7696 50  0000 L CNN
F 1 "100nF" H 1915 7605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1838 7500 50  0001 C CNN
F 3 "~" H 1800 7650 50  0001 C CNN
	1    1800 7650
	1    0    0    -1  
$EndComp
Wire Wire Line
	1300 7500 1800 7500
Wire Wire Line
	1800 7800 1300 7800
Text HLabel 1350 5850 0    50   3State ~ 0
IO[0..7]
Text HLabel 1350 5950 0    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	1350 5850 4800 5850
Wire Bus Line
	4800 5850 9800 5850
Connection ~ 4800 5850
Connection ~ 4900 5950
Text Label 4700 4450 2    50   ~ 0
IO0
Text Label 4700 4550 2    50   ~ 0
IO1
Text Label 4700 4650 2    50   ~ 0
IO2
Text Label 4700 4750 2    50   ~ 0
IO3
Text Label 4700 4850 2    50   ~ 0
IO4
Text Label 4700 4950 2    50   ~ 0
IO5
Text Label 4700 5050 2    50   ~ 0
IO6
Text Label 4700 5150 2    50   ~ 0
IO7
Entry Wire Line
	9800 5250 9700 5150
Entry Wire Line
	9800 4550 9700 4450
Entry Wire Line
	9800 4650 9700 4550
Entry Wire Line
	9800 4750 9700 4650
Entry Wire Line
	9800 4850 9700 4750
Entry Wire Line
	9800 4950 9700 4850
Entry Wire Line
	9800 5050 9700 4950
Entry Wire Line
	9800 5150 9700 5050
Wire Wire Line
	9700 4850 9050 4850
Wire Wire Line
	9700 4750 9050 4750
Wire Wire Line
	9700 4650 9050 4650
Wire Wire Line
	9700 4550 9050 4550
Wire Wire Line
	9700 4450 9050 4450
Wire Wire Line
	9700 5150 9050 5150
Wire Wire Line
	9700 5050 9050 5050
Wire Wire Line
	9700 4950 9050 4950
Text Label 9700 4450 2    50   ~ 0
IO0
Text Label 9700 4550 2    50   ~ 0
IO1
Text Label 9700 4650 2    50   ~ 0
IO2
Text Label 9700 4750 2    50   ~ 0
IO3
Text Label 9700 4850 2    50   ~ 0
IO4
Text Label 9700 4950 2    50   ~ 0
IO5
Text Label 9700 5050 2    50   ~ 0
IO6
Text Label 9700 5150 2    50   ~ 0
IO7
Wire Wire Line
	4050 2550 5150 2550
Wire Wire Line
	4050 2450 5250 2450
Wire Wire Line
	9050 2550 10150 2550
Wire Wire Line
	10150 2550 10150 6400
Wire Wire Line
	10150 6400 5450 6400
Wire Wire Line
	5550 6500 10250 6500
Wire Wire Line
	10250 6500 10250 2450
Wire Wire Line
	10250 2450 9050 2450
Entry Wire Line
	3100 6450 3200 6550
Wire Wire Line
	3200 6550 3500 6550
Text Label 3200 6550 0    50   ~ 0
Addr15
Text HLabel 1350 6050 0    50   Input ~ 0
Bank[0..7]
Entry Wire Line
	3100 6550 3200 6650
Text Label 3200 6650 0    50   ~ 0
Bank0
Entry Wire Line
	3100 6650 3200 6750
Text Label 3200 6750 0    50   ~ 0
Bank1
Entry Wire Line
	3100 6750 3200 6850
Text Label 3200 6850 0    50   ~ 0
Bank2
Wire Bus Line
	1350 6050 3000 6050
Text Label 9800 4150 2    50   ~ 0
Addr14
Text Label 9800 4050 2    50   ~ 0
Addr13
Text Label 9800 3950 2    50   ~ 0
Addr12
Text Label 9800 3850 2    50   ~ 0
Addr11
Text Label 9800 3750 2    50   ~ 0
Addr10
Text Label 9800 3650 2    50   ~ 0
Addr9
Text Label 9800 3550 2    50   ~ 0
Addr8
Text Label 9800 3450 2    50   ~ 0
Addr7
Text Label 9800 3350 2    50   ~ 0
Addr6
Text Label 9800 3250 2    50   ~ 0
Addr5
Text Label 9800 3150 2    50   ~ 0
Addr4
Text Label 9800 3050 2    50   ~ 0
Addr3
Text Label 9800 2950 2    50   ~ 0
Addr2
Text Label 9800 2850 2    50   ~ 0
Addr1
Wire Wire Line
	9050 2850 9800 2850
Wire Wire Line
	9050 4150 9800 4150
Wire Wire Line
	9050 4050 9800 4050
Wire Wire Line
	9050 3950 9800 3950
Wire Wire Line
	9050 3850 9800 3850
Wire Wire Line
	9050 3750 9800 3750
Wire Wire Line
	9050 3650 9800 3650
Wire Wire Line
	9050 3550 9800 3550
Wire Wire Line
	9050 3450 9800 3450
Wire Wire Line
	9050 3350 9800 3350
Wire Wire Line
	9050 3250 9800 3250
Wire Wire Line
	9050 3150 9800 3150
Wire Wire Line
	9050 3050 9800 3050
Wire Wire Line
	9050 2950 9800 2950
Entry Wire Line
	9800 2850 9900 2950
Entry Wire Line
	9800 2950 9900 3050
Entry Wire Line
	9800 3050 9900 3150
Entry Wire Line
	9800 3150 9900 3250
Entry Wire Line
	9800 3250 9900 3350
Entry Wire Line
	9800 3350 9900 3450
Entry Wire Line
	9800 3450 9900 3550
Entry Wire Line
	9800 3550 9900 3650
Entry Wire Line
	9800 3650 9900 3750
Entry Wire Line
	9800 3750 9900 3850
Entry Wire Line
	9800 3850 9900 3950
Entry Wire Line
	9800 3950 9900 4050
Entry Wire Line
	9800 4050 9900 4150
Entry Wire Line
	9800 4150 9900 4250
Text Label 4800 4150 2    50   ~ 0
Addr14
Text Label 4800 4050 2    50   ~ 0
Addr13
Text Label 4800 3950 2    50   ~ 0
Addr12
Text Label 4800 3850 2    50   ~ 0
Addr11
Text Label 4800 3750 2    50   ~ 0
Addr10
Text Label 4800 3650 2    50   ~ 0
Addr9
Text Label 4800 3550 2    50   ~ 0
Addr8
Text Label 4800 3450 2    50   ~ 0
Addr7
Text Label 4800 3350 2    50   ~ 0
Addr6
Text Label 4800 3250 2    50   ~ 0
Addr5
Text Label 4800 3150 2    50   ~ 0
Addr4
Text Label 4800 3050 2    50   ~ 0
Addr3
Text Label 4800 2950 2    50   ~ 0
Addr2
Text Label 4800 2850 2    50   ~ 0
Addr1
Wire Wire Line
	4050 2850 4800 2850
Wire Wire Line
	4050 4150 4800 4150
Wire Wire Line
	4050 4050 4800 4050
Wire Wire Line
	4050 3950 4800 3950
Wire Wire Line
	4050 3850 4800 3850
Wire Wire Line
	4050 3750 4800 3750
Wire Wire Line
	4050 3650 4800 3650
Wire Wire Line
	4050 3550 4800 3550
Wire Wire Line
	4050 3450 4800 3450
Wire Wire Line
	4050 3350 4800 3350
Wire Wire Line
	4050 3250 4800 3250
Wire Wire Line
	4050 3150 4800 3150
Wire Wire Line
	4050 3050 4800 3050
Wire Wire Line
	4050 2950 4800 2950
Entry Wire Line
	4800 2850 4900 2950
Entry Wire Line
	4800 2950 4900 3050
Entry Wire Line
	4800 3050 4900 3150
Entry Wire Line
	4800 3150 4900 3250
Entry Wire Line
	4800 3250 4900 3350
Entry Wire Line
	4800 3350 4900 3450
Entry Wire Line
	4800 3450 4900 3550
Entry Wire Line
	4800 3550 4900 3650
Entry Wire Line
	4800 3650 4900 3750
Entry Wire Line
	4800 3750 4900 3850
Entry Wire Line
	4800 3850 4900 3950
Entry Wire Line
	4800 3950 4900 4050
Entry Wire Line
	4800 4050 4900 4150
Entry Wire Line
	4800 4150 4900 4250
Text Label 9800 2750 2    50   ~ 0
Addr0
Wire Wire Line
	9800 2750 9050 2750
Entry Wire Line
	9800 2750 9900 2850
Text Label 4800 2750 2    50   ~ 0
Addr0
Wire Wire Line
	4800 2750 4050 2750
Entry Wire Line
	4800 2750 4900 2850
Text Notes 750  7100 0    50   ~ 0
The Bank Select is an eight-bit value which controls the\nmapping of the upper 32KB of the address space. This\nGAL maps four banks to the instruction decoder memory\nto allow the entire 64KB memory to be used.
Wire Bus Line
	1350 5950 3100 5950
Connection ~ 3100 5950
Wire Bus Line
	3100 5950 4900 5950
Wire Bus Line
	4900 5950 9900 5950
NoConn ~ 4500 7150
NoConn ~ 4500 7250
NoConn ~ 4500 7350
NoConn ~ 4500 7450
NoConn ~ 4500 7550
NoConn ~ 3500 7450
NoConn ~ 3500 7550
Wire Bus Line
	3100 5950 3100 6450
Wire Wire Line
	3200 6650 3500 6650
Wire Wire Line
	3200 6750 3500 6750
Wire Wire Line
	3200 6850 3500 6850
Wire Bus Line
	3100 6550 3000 6550
Wire Bus Line
	3000 6550 3000 6050
$Comp
L MainBoard-rescue:ATF22V10C-Logic_Programmable U12
U 1 1 5FC2DDCF
P 4000 7000
AR Path="/5FED3839/5FC2DDCF" Ref="U12"  Part="1" 
AR Path="/5D2C07CD/5FC2DDCF" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FC2DDCF" Ref="U?"  Part="1" 
F 0 "U12" H 3650 7650 50  0000 C CNN
F 1 "ATF22V10C-7PX" H 3650 7550 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W8.89mm_SMDSocket_LongPads" H 4850 6300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/268/doc0735-1369018.pdf" H 4000 7050 50  0001 C CNN
	1    4000 7000
	1    0    0    -1  
$EndComp
Entry Wire Line
	3100 6850 3200 6950
Text Label 3200 6950 0    50   ~ 0
Bank3
Entry Wire Line
	3100 6950 3200 7050
Text Label 3200 7050 0    50   ~ 0
Bank4
Entry Wire Line
	3100 7050 3200 7150
Text Label 3200 7150 0    50   ~ 0
Bank5
Wire Wire Line
	3200 6950 3500 6950
Wire Wire Line
	3200 7050 3500 7050
Wire Wire Line
	3200 7150 3500 7150
Entry Wire Line
	3100 7150 3200 7250
Text Label 3200 7250 0    50   ~ 0
Bank6
Entry Wire Line
	3100 7250 3200 7350
Text Label 3200 7350 0    50   ~ 0
Bank7
Wire Wire Line
	3200 7250 3500 7250
Wire Wire Line
	3200 7350 3500 7350
Wire Wire Line
	5050 6550 4500 6550
Wire Wire Line
	4500 6650 5150 6650
Wire Wire Line
	5150 2550 5150 6650
Wire Wire Line
	4500 6750 5250 6750
Wire Wire Line
	5250 2450 5250 6750
Wire Wire Line
	4500 6850 5350 6850
Wire Wire Line
	4500 6950 5450 6950
Wire Wire Line
	5050 4350 4800 4350
Wire Wire Line
	4800 4350 4800 4250
Wire Wire Line
	4050 4250 4800 4250
Wire Wire Line
	5050 4350 5050 6550
Wire Wire Line
	9050 4250 9800 4250
Wire Wire Line
	9800 4250 9800 4350
Wire Wire Line
	9800 4350 10050 4350
Wire Wire Line
	10050 4350 10050 6300
Wire Wire Line
	10050 6300 5350 6300
Wire Wire Line
	4500 7050 5550 7050
Wire Wire Line
	5550 7050 5550 6500
Wire Wire Line
	5350 6300 5350 6850
Wire Wire Line
	5450 6950 5450 6400
Entry Wire Line
	6700 2750 6600 2650
Entry Wire Line
	6700 2850 6600 2750
Entry Wire Line
	6700 2950 6600 2850
Entry Wire Line
	6700 3050 6600 2950
Entry Wire Line
	6700 3150 6600 3050
Text Label 6700 2750 0    50   ~ 0
Ins11
Text Label 6700 2850 0    50   ~ 0
Ins12
Text Label 6700 2950 0    50   ~ 0
Ins13
Text Label 6700 3050 0    50   ~ 0
Ins14
Text Label 6700 3150 0    50   ~ 0
Ins15
Wire Wire Line
	7450 3150 6700 3150
Wire Wire Line
	7450 3050 6700 3050
Wire Wire Line
	7450 2950 6700 2950
Wire Wire Line
	7450 2850 6700 2850
Wire Wire Line
	7450 2750 6700 2750
Wire Wire Line
	2300 3250 2450 3250
Wire Wire Line
	2450 3350 2300 3350
Wire Wire Line
	2300 3450 2450 3450
Wire Wire Line
	2450 3550 2300 3550
$Comp
L power:GND #PWR?
U 1 1 5FDBFDC8
P 2450 3650
AR Path="/5FE35007/5FDBFDC8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDBFDC8" Ref="#PWR080"  Part="1" 
F 0 "#PWR080" H 2450 3400 50  0001 C CNN
F 1 "GND" V 2455 3522 50  0000 R CNN
F 2 "" H 2450 3650 50  0001 C CNN
F 3 "" H 2450 3650 50  0001 C CNN
	1    2450 3650
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC0350
P 2450 3750
AR Path="/5FE35007/5FDC0350" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC0350" Ref="#PWR081"  Part="1" 
F 0 "#PWR081" H 2450 3500 50  0001 C CNN
F 1 "GND" V 2455 3622 50  0000 R CNN
F 2 "" H 2450 3750 50  0001 C CNN
F 3 "" H 2450 3750 50  0001 C CNN
	1    2450 3750
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC05FD
P 2450 3850
AR Path="/5FE35007/5FDC05FD" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC05FD" Ref="#PWR082"  Part="1" 
F 0 "#PWR082" H 2450 3600 50  0001 C CNN
F 1 "GND" V 2455 3722 50  0000 R CNN
F 2 "" H 2450 3850 50  0001 C CNN
F 3 "" H 2450 3850 50  0001 C CNN
	1    2450 3850
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC08AA
P 2450 3950
AR Path="/5FE35007/5FDC08AA" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC08AA" Ref="#PWR083"  Part="1" 
F 0 "#PWR083" H 2450 3700 50  0001 C CNN
F 1 "GND" V 2455 3822 50  0000 R CNN
F 2 "" H 2450 3950 50  0001 C CNN
F 3 "" H 2450 3950 50  0001 C CNN
	1    2450 3950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC0BDF
P 2450 4050
AR Path="/5FE35007/5FDC0BDF" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC0BDF" Ref="#PWR084"  Part="1" 
F 0 "#PWR084" H 2450 3800 50  0001 C CNN
F 1 "GND" V 2455 3922 50  0000 R CNN
F 2 "" H 2450 4050 50  0001 C CNN
F 3 "" H 2450 4050 50  0001 C CNN
	1    2450 4050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC1458
P 2450 4150
AR Path="/5FE35007/5FDC1458" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC1458" Ref="#PWR085"  Part="1" 
F 0 "#PWR085" H 2450 3900 50  0001 C CNN
F 1 "GND" V 2455 4022 50  0000 R CNN
F 2 "" H 2450 4150 50  0001 C CNN
F 3 "" H 2450 4150 50  0001 C CNN
	1    2450 4150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC166C
P 2450 4250
AR Path="/5FE35007/5FDC166C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC166C" Ref="#PWR086"  Part="1" 
F 0 "#PWR086" H 2450 4000 50  0001 C CNN
F 1 "GND" V 2455 4122 50  0000 R CNN
F 2 "" H 2450 4250 50  0001 C CNN
F 3 "" H 2450 4250 50  0001 C CNN
	1    2450 4250
	0    1    1    0   
$EndComp
Text HLabel 7300 3250 0    50   Input ~ 0
Carry
Text HLabel 7300 3350 0    50   Input ~ 0
Z
Text HLabel 7300 3450 0    50   Input ~ 0
OVF
Text HLabel 7300 3550 0    50   Input ~ 0
~RST
Wire Wire Line
	7300 3250 7450 3250
Wire Wire Line
	7450 3350 7300 3350
Wire Wire Line
	7300 3450 7450 3450
Wire Wire Line
	7450 3550 7300 3550
$Comp
L power:GND #PWR?
U 1 1 5FDC2884
P 7450 3650
AR Path="/5FE35007/5FDC2884" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC2884" Ref="#PWR0102"  Part="1" 
F 0 "#PWR0102" H 7450 3400 50  0001 C CNN
F 1 "GND" V 7455 3522 50  0000 R CNN
F 2 "" H 7450 3650 50  0001 C CNN
F 3 "" H 7450 3650 50  0001 C CNN
	1    7450 3650
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC288A
P 7450 3750
AR Path="/5FE35007/5FDC288A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC288A" Ref="#PWR0103"  Part="1" 
F 0 "#PWR0103" H 7450 3500 50  0001 C CNN
F 1 "GND" V 7455 3622 50  0000 R CNN
F 2 "" H 7450 3750 50  0001 C CNN
F 3 "" H 7450 3750 50  0001 C CNN
	1    7450 3750
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC2890
P 7450 3850
AR Path="/5FE35007/5FDC2890" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC2890" Ref="#PWR0104"  Part="1" 
F 0 "#PWR0104" H 7450 3600 50  0001 C CNN
F 1 "GND" V 7455 3722 50  0000 R CNN
F 2 "" H 7450 3850 50  0001 C CNN
F 3 "" H 7450 3850 50  0001 C CNN
	1    7450 3850
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC2896
P 7450 3950
AR Path="/5FE35007/5FDC2896" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC2896" Ref="#PWR0105"  Part="1" 
F 0 "#PWR0105" H 7450 3700 50  0001 C CNN
F 1 "GND" V 7455 3822 50  0000 R CNN
F 2 "" H 7450 3950 50  0001 C CNN
F 3 "" H 7450 3950 50  0001 C CNN
	1    7450 3950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC289C
P 7450 4050
AR Path="/5FE35007/5FDC289C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC289C" Ref="#PWR0106"  Part="1" 
F 0 "#PWR0106" H 7450 3800 50  0001 C CNN
F 1 "GND" V 7455 3922 50  0000 R CNN
F 2 "" H 7450 4050 50  0001 C CNN
F 3 "" H 7450 4050 50  0001 C CNN
	1    7450 4050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC28A2
P 7450 4150
AR Path="/5FE35007/5FDC28A2" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC28A2" Ref="#PWR0107"  Part="1" 
F 0 "#PWR0107" H 7450 3900 50  0001 C CNN
F 1 "GND" V 7455 4022 50  0000 R CNN
F 2 "" H 7450 4150 50  0001 C CNN
F 3 "" H 7450 4150 50  0001 C CNN
	1    7450 4150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC28A8
P 7450 4250
AR Path="/5FE35007/5FDC28A8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDC28A8" Ref="#PWR0108"  Part="1" 
F 0 "#PWR0108" H 7450 4000 50  0001 C CNN
F 1 "GND" V 7455 4122 50  0000 R CNN
F 2 "" H 7450 4250 50  0001 C CNN
F 3 "" H 7450 4250 50  0001 C CNN
	1    7450 4250
	0    1    1    0   
$EndComp
Connection ~ 1300 7500
Connection ~ 1300 7800
Text Label 2350 4750 2    50   ~ 0
Ctl3
Wire Wire Line
	9750 1150 9750 1950
Wire Bus Line
	9600 1050 9750 1050
Wire Bus Line
	1600 850  1600 3050
Wire Bus Line
	6600 850  6600 3050
Wire Bus Line
	3100 6550 3100 7250
Wire Bus Line
	9800 4550 9800 5850
Wire Bus Line
	4800 4550 4800 5850
Wire Bus Line
	1500 1150 1500 5050
Wire Bus Line
	6500 1150 6500 5050
Wire Bus Line
	9900 2850 9900 5950
Wire Bus Line
	4900 2850 4900 5950
$EndSCHEMATC
