EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 7 33
Title "ID"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 "effect conditional instructions."
Comment3 "The decoder takes the condition code from the flags register into account to"
Comment4 "The instruction decoder turns a 5-bit opcode into an array of control signals."
$EndDescr
$Comp
L power:VCC #PWR?
U 1 1 5FF07E41
P 7350 6100
AR Path="/5D2C0B92/5FF07E41" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF07E41" Ref="#PWR084"  Part="1" 
F 0 "#PWR084" H 7350 5950 50  0001 C CNN
F 1 "VCC" H 7367 6273 50  0000 C CNN
F 2 "" H 7350 6100 50  0001 C CNN
F 3 "" H 7350 6100 50  0001 C CNN
	1    7350 6100
	1    0    0    -1  
$EndComp
Entry Wire Line
	6200 6400 6300 6500
Entry Wire Line
	6200 6500 6300 6600
Entry Wire Line
	6200 6600 6300 6700
Entry Wire Line
	6200 6700 6300 6800
Text Label 6300 6400 0    50   ~ 0
Ins11
Text Label 6300 6500 0    50   ~ 0
Ins12
Text Label 6300 6600 0    50   ~ 0
Ins13
Text Label 6300 6700 0    50   ~ 0
Ins14
Text Label 6300 6800 0    50   ~ 0
Ins15
Entry Wire Line
	6200 3350 6300 3450
Entry Wire Line
	6200 3450 6300 3550
Entry Wire Line
	6200 3550 6300 3650
Entry Wire Line
	6200 3650 6300 3750
Text Label 6300 3350 0    50   ~ 0
Ins11
Text Label 6300 3450 0    50   ~ 0
Ins12
Text Label 6300 3550 0    50   ~ 0
Ins13
Text Label 6300 3650 0    50   ~ 0
Ins14
Text Label 6300 3750 0    50   ~ 0
Ins15
Wire Bus Line
	6200 9050 5450 9050
Wire Wire Line
	5900 8750 5450 8750
Wire Wire Line
	6000 8850 5450 8850
$Comp
L power:GND #PWR?
U 1 1 5FF07F02
P 7350 7500
AR Path="/5D2C0B92/5FF07F02" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF07F02" Ref="#PWR085"  Part="1" 
F 0 "#PWR085" H 7350 7250 50  0001 C CNN
F 1 "GND" H 7355 7327 50  0000 C CNN
F 2 "" H 7350 7500 50  0001 C CNN
F 3 "" H 7350 7500 50  0001 C CNN
	1    7350 7500
	1    0    0    -1  
$EndComp
Entry Wire Line
	8900 6300 9000 6200
Entry Wire Line
	8900 6400 9000 6300
Entry Wire Line
	8900 6500 9000 6400
Entry Wire Line
	8900 6600 9000 6500
Entry Wire Line
	8900 6700 9000 6600
Entry Wire Line
	8900 6800 9000 6700
Entry Wire Line
	8900 6900 9000 6800
Entry Wire Line
	8900 7000 9000 6900
Text Label 8800 6300 2    50   ~ 0
ControlWord9
Wire Wire Line
	1300 10750 1050 10750
$Comp
L power:GND #PWR?
U 1 1 5FF07F3E
P 1050 10850
AR Path="/5D2C0761/5FF07F3E" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0B92/5FF07F3E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF07F3E" Ref="#PWR072"  Part="1" 
F 0 "#PWR072" H 1050 10600 50  0001 C CNN
F 1 "GND" H 1055 10677 50  0000 C CNN
F 2 "" H 1050 10850 50  0001 C CNN
F 3 "" H 1050 10850 50  0001 C CNN
	1    1050 10850
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FF07F56
P 1300 10600
AR Path="/5D2C0761/5FF07F56" Ref="C?"  Part="1" 
AR Path="/5D2C0B92/5FF07F56" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FF07F56" Ref="C22"  Part="1" 
F 0 "C22" H 1415 10646 50  0000 L CNN
F 1 "100nF" H 1415 10555 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1338 10450 50  0001 C CNN
F 3 "~" H 1300 10600 50  0001 C CNN
	1    1300 10600
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FF07F5C
P 800 10600
AR Path="/5D2C0761/5FF07F5C" Ref="C?"  Part="1" 
AR Path="/5D2C0B92/5FF07F5C" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FF07F5C" Ref="C21"  Part="1" 
F 0 "C21" H 915 10646 50  0000 L CNN
F 1 "100nF" H 915 10555 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 838 10450 50  0001 C CNN
F 3 "~" H 800 10600 50  0001 C CNN
	1    800  10600
	1    0    0    -1  
$EndComp
Wire Wire Line
	800  10450 1050 10450
$Comp
L power:VCC #PWR?
U 1 1 5FF080AE
P 1050 10350
AR Path="/5D2C0761/5FF080AE" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0B92/5FF080AE" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF080AE" Ref="#PWR071"  Part="1" 
F 0 "#PWR071" H 1050 10200 50  0001 C CNN
F 1 "VCC" H 1067 10523 50  0000 C CNN
F 2 "" H 1050 10350 50  0001 C CNN
F 3 "" H 1050 10350 50  0001 C CNN
	1    1050 10350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1050 10350 1050 10450
Connection ~ 1050 10450
Wire Wire Line
	1050 10450 1300 10450
Wire Wire Line
	1050 10850 1050 10750
Connection ~ 1050 10750
Wire Wire Line
	1050 10750 800  10750
Wire Wire Line
	7850 6300 8900 6300
Wire Wire Line
	7850 6400 8900 6400
Wire Wire Line
	7850 6500 8900 6500
Wire Wire Line
	7850 6600 8900 6600
Wire Wire Line
	7850 6700 8900 6700
Wire Wire Line
	7850 6800 8900 6800
Wire Wire Line
	7850 6900 8900 6900
Wire Wire Line
	7850 7000 8900 7000
Text HLabel 5450 8750 0    50   Input ~ 0
Carry
Text HLabel 5450 8850 0    50   Input ~ 0
Z
Text HLabel 5450 9050 0    50   Input ~ 0
Ins[0..15]
Text HLabel 10450 7400 2    50   Output ~ 0
ControlWord[0..19]
Entry Wire Line
	6300 3350 6200 3250
Entry Wire Line
	6300 6400 6200 6300
Wire Wire Line
	6850 7200 6800 7200
Wire Wire Line
	6800 7300 6850 7300
Wire Wire Line
	6800 7300 6800 7200
Text Notes 6400 5500 0    50   ~ 0
Decode the instruction opcode into an array of control signals.\nThese signals are carried forward through each pipeline stage\nuntil the stage where they are used. This keeps stages\nsynchronized with the corresponding instruction.
Wire Bus Line
	9000 7400 10450 7400
Text Notes 10050 4950 0    50   ~ 0
#   Mnemonic\n——————————\n0  /HLT\n1   SelLeftOp\n2   SelRightOp\n3   SelStoreOpA\n4   SelStoreOpB\n5   /FI\n6   CarryIn\n7   I0\n8   I1\n9   I2\n10  RS0\n11  RS1\n12  /J\n13  /MemLoad\n14  /MemStore\n15  /WRL\n16  /WRH\n17  WriteBackSrcA\n18  WriteBackSrcB\n19  unused
Connection ~ 6000 7000
Wire Wire Line
	6000 7000 6000 8850
Wire Wire Line
	6300 6400 6850 6400
Wire Wire Line
	6300 6500 6850 6500
Wire Wire Line
	6300 6600 6850 6600
Wire Wire Line
	6300 6700 6850 6700
Wire Wire Line
	6300 6800 6850 6800
Wire Wire Line
	6000 7000 6850 7000
Wire Wire Line
	6800 7350 6800 7300
$Comp
L MainBoard-rescue:ATF22V10C-Logic_Programmable U19
U 1 1 5FBC01DB
P 7350 6750
F 0 "U19" H 7000 7400 50  0000 C CNN
F 1 "ATF22V10C" H 7000 7300 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W8.89mm_SMDSocket_LongPads" H 8200 6050 50  0001 C CNN
F 3 "" H 7350 6800 50  0001 C CNN
	1    7350 6750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC4D61A
P 7900 7300
AR Path="/5D2C0B92/5FC4D61A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC4D61A" Ref="#PWR0165"  Part="1" 
F 0 "#PWR0165" H 7900 7050 50  0001 C CNN
F 1 "GND" V 7905 7172 50  0000 R CNN
F 2 "" H 7900 7300 50  0001 C CNN
F 3 "" H 7900 7300 50  0001 C CNN
	1    7900 7300
	0    -1   1    0   
$EndComp
Wire Wire Line
	7850 7300 7900 7300
Entry Wire Line
	8900 7100 9000 7000
Wire Wire Line
	7850 7100 8900 7100
Entry Wire Line
	8900 7200 9000 7100
Wire Wire Line
	7850 7200 8900 7200
Text Label 8800 6400 2    50   ~ 0
ControlWord8
Text Label 8800 6500 2    50   ~ 0
ControlWord7
Text Label 8800 6600 2    50   ~ 0
ControlWord6
Text Label 8800 6700 2    50   ~ 0
ControlWord5
Text Label 8800 6800 2    50   ~ 0
ControlWord4
Text Label 8800 6900 2    50   ~ 0
ControlWord3
Text Label 8800 7000 2    50   ~ 0
ControlWord2
Text Label 8800 7100 2    50   ~ 0
ControlWord1
Text Label 8800 7200 2    50   ~ 0
ControlWord0
$Comp
L power:VCC #PWR?
U 1 1 5FC69C6C
P 7350 3050
AR Path="/5D2C0B92/5FC69C6C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC69C6C" Ref="#PWR0166"  Part="1" 
F 0 "#PWR0166" H 7350 2900 50  0001 C CNN
F 1 "VCC" H 7367 3223 50  0000 C CNN
F 2 "" H 7350 3050 50  0001 C CNN
F 3 "" H 7350 3050 50  0001 C CNN
	1    7350 3050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC69C72
P 7350 4450
AR Path="/5D2C0B92/5FC69C72" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC69C72" Ref="#PWR0193"  Part="1" 
F 0 "#PWR0193" H 7350 4200 50  0001 C CNN
F 1 "GND" H 7355 4277 50  0000 C CNN
F 2 "" H 7350 4450 50  0001 C CNN
F 3 "" H 7350 4450 50  0001 C CNN
	1    7350 4450
	1    0    0    -1  
$EndComp
Entry Wire Line
	8900 3250 9000 3150
Entry Wire Line
	8900 3350 9000 3250
Entry Wire Line
	8900 3450 9000 3350
Entry Wire Line
	8900 3550 9000 3450
Entry Wire Line
	8900 3650 9000 3550
Entry Wire Line
	8900 3750 9000 3650
Entry Wire Line
	8900 3850 9000 3750
Entry Wire Line
	8900 3950 9000 3850
Text Label 8800 3250 2    50   ~ 0
ControlWord19
Wire Wire Line
	7850 3250 8900 3250
Wire Wire Line
	7850 3350 8900 3350
Wire Wire Line
	7850 3450 8900 3450
Wire Wire Line
	7850 3550 8900 3550
Wire Wire Line
	7850 3650 8900 3650
Wire Wire Line
	7850 3750 8900 3750
Wire Wire Line
	7850 3850 8900 3850
Wire Wire Line
	7850 3950 8900 3950
$Comp
L MainBoard-rescue:ATF22V10C-Logic_Programmable U14
U 1 1 5FC69C89
P 7350 3700
F 0 "U14" H 7000 4350 50  0000 C CNN
F 1 "ATF22V10C" H 7000 4250 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W8.89mm_SMDSocket_LongPads" H 8200 3000 50  0001 C CNN
F 3 "" H 7350 3750 50  0001 C CNN
	1    7350 3700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FC69C8F
P 7900 4250
AR Path="/5D2C0B92/5FC69C8F" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC69C8F" Ref="#PWR0194"  Part="1" 
F 0 "#PWR0194" H 7900 4000 50  0001 C CNN
F 1 "GND" V 7905 4122 50  0000 R CNN
F 2 "" H 7900 4250 50  0001 C CNN
F 3 "" H 7900 4250 50  0001 C CNN
	1    7900 4250
	0    -1   1    0   
$EndComp
Wire Wire Line
	7850 4250 7900 4250
Entry Wire Line
	8900 4050 9000 3950
Wire Wire Line
	7850 4050 8900 4050
Entry Wire Line
	8900 4150 9000 4050
Wire Wire Line
	7850 4150 8900 4150
Text Label 8800 3350 2    50   ~ 0
ControlWord18
Text Label 8800 3450 2    50   ~ 0
ControlWord17
Text Label 8800 3550 2    50   ~ 0
ControlWord16
Text Label 8800 3650 2    50   ~ 0
ControlWord15
Text Label 8800 3750 2    50   ~ 0
ControlWord14
Text Label 8800 3850 2    50   ~ 0
ControlWord13
Text Label 8800 3950 2    50   ~ 0
ControlWord12
Text Label 8800 4050 2    50   ~ 0
ControlWord11
Text Label 8800 4150 2    50   ~ 0
ControlWord10
Wire Wire Line
	6300 3350 6850 3350
Wire Wire Line
	6300 3450 6850 3450
Wire Wire Line
	6300 3550 6850 3550
Wire Wire Line
	6300 3650 6850 3650
Wire Wire Line
	6300 3750 6850 3750
Wire Wire Line
	5900 3850 6850 3850
Wire Wire Line
	6000 3950 6850 3950
Text HLabel 5450 8650 0    50   Input ~ 0
Phi1
Wire Wire Line
	5450 8650 5800 8650
Wire Wire Line
	5800 8650 5800 6200
Wire Wire Line
	5800 6200 6750 6200
Wire Wire Line
	6750 6200 6750 6300
Wire Wire Line
	6750 6300 6850 6300
Wire Wire Line
	5800 6200 5800 3150
Wire Wire Line
	5800 3150 6750 3150
Wire Wire Line
	6750 3150 6750 3250
Wire Wire Line
	6750 3250 6850 3250
Connection ~ 5800 6200
Wire Wire Line
	5900 3850 5900 6900
Wire Wire Line
	6000 3950 6000 7000
Wire Wire Line
	5900 6900 6850 6900
Connection ~ 5900 6900
Wire Wire Line
	5900 6900 5900 8750
Text HLabel 5450 8950 0    50   Input ~ 0
OVF
Connection ~ 6800 7300
$Comp
L power:GND #PWR?
U 1 1 5FD8555E
P 6800 7350
AR Path="/5D2C0B92/5FD8555E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FD8555E" Ref="#PWR0101"  Part="1" 
F 0 "#PWR0101" H 6800 7100 50  0001 C CNN
F 1 "GND" H 6805 7177 50  0000 C CNN
F 2 "" H 6800 7350 50  0001 C CNN
F 3 "" H 6800 7350 50  0001 C CNN
	1    6800 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	6850 4150 6800 4150
Wire Wire Line
	6800 4250 6850 4250
Wire Wire Line
	6800 4250 6800 4150
Wire Wire Line
	6800 4300 6800 4250
Connection ~ 6800 4250
$Comp
L power:GND #PWR?
U 1 1 5FD8935D
P 6800 4300
AR Path="/5D2C0B92/5FD8935D" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FD8935D" Ref="#PWR0127"  Part="1" 
F 0 "#PWR0127" H 6800 4050 50  0001 C CNN
F 1 "GND" H 6805 4127 50  0000 C CNN
F 2 "" H 6800 4300 50  0001 C CNN
F 3 "" H 6800 4300 50  0001 C CNN
	1    6800 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 8950 6100 7100
Wire Wire Line
	6100 7100 6850 7100
Wire Wire Line
	5450 8950 6100 8950
Wire Wire Line
	6100 7100 6100 4050
Wire Wire Line
	6100 4050 6850 4050
Connection ~ 6100 7100
Text Notes 10950 4950 0    50   ~ 0
Description\n————————\nHalt Clock\nSelect Left Operand\nSelect Right Operand\nSelect Store Operand 0\nSelect Store Operand 1\nFlags Register In\nALU Carry input\nALU I0 input\nALU I1 input\nALU I2 input\nALU RS0 input\nALU RS1 input\nJump\nMemory Store\nMemory Load\nWrite back low byte\nWrite back high byte\nSource of write back 0\nSource of write back 1\nunused
Wire Bus Line
	6200 3250 6200 9050
Wire Bus Line
	9000 3150 9000 7400
$EndSCHEMATC
