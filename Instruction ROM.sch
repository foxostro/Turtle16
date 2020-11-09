EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 6 21
Title "Instruction ROM"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 "This schematic describes the connectors by attach it to the main board."
Comment4 "Instruction ROM is located on a daughter board."
$EndDescr
Text GLabel 8800 2200 2    50   Output ~ 0
InsBus[0..15]
Text GLabel 2350 2100 0    50   Input ~ 0
PC_IF[0..15]
$Comp
L Device:C C9
U 1 1 5DCD89FF
P 1150 7300
F 0 "C9" H 1265 7346 50  0000 L CNN
F 1 "100nF" H 1265 7255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 1188 7150 50  0001 C CNN
F 3 "~" H 1150 7300 50  0001 C CNN
	1    1150 7300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C10
U 1 1 5DCD8A05
P 1650 7300
F 0 "C10" H 1765 7346 50  0000 L CNN
F 1 "100nF" H 1765 7255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 1688 7150 50  0001 C CNN
F 3 "~" H 1650 7300 50  0001 C CNN
	1    1650 7300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0143
U 1 1 5DCD8A1D
P 1150 7450
F 0 "#PWR0143" H 1150 7200 50  0001 C CNN
F 1 "GND" H 1155 7277 50  0000 C CNN
F 2 "" H 1150 7450 50  0001 C CNN
F 3 "" H 1150 7450 50  0001 C CNN
	1    1150 7450
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0144
U 1 1 5DCD8A23
P 1150 7150
F 0 "#PWR0144" H 1150 7000 50  0001 C CNN
F 1 "VCC" H 1167 7323 50  0000 C CNN
F 2 "" H 1150 7150 50  0001 C CNN
F 3 "" H 1150 7150 50  0001 C CNN
	1    1150 7150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1150 7150 1650 7150
Connection ~ 1150 7150
Wire Wire Line
	1650 7450 1150 7450
Connection ~ 1150 7450
$Comp
L Memory_EEPROM:GLS29EE010 U14
U 1 1 5D23BFD4
P 4850 2500
F 0 "U14" H 5150 2700 50  0000 C CNN
F 1 "Instruction ROM [0..7]" H 5150 2600 50  0000 C CNN
F 2 "Socket:DIP_Socket-32_W11.9_W12.7_W15.24_W17.78_W18.5_3M_232-1285-00-0602J" H 4850 2500 50  0001 C CNN
F 3 "" H 4850 2500 50  0001 C CNN
	1    4850 2500
	-1   0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0145
U 1 1 5D241E73
P 4850 1500
F 0 "#PWR0145" H 4850 1350 50  0001 C CNN
F 1 "VCC" H 4867 1673 50  0000 C CNN
F 2 "" H 4850 1500 50  0001 C CNN
F 3 "" H 4850 1500 50  0001 C CNN
	1    4850 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 1500 4850 2000
Wire Wire Line
	6900 2400 6900 2000
Connection ~ 4850 2000
Wire Wire Line
	4850 2000 4850 2400
$Comp
L power:GND #PWR0146
U 1 1 5D2423FD
P 4850 5500
F 0 "#PWR0146" H 4850 5250 50  0001 C CNN
F 1 "GND" H 4855 5327 50  0000 C CNN
F 2 "" H 4850 5500 50  0001 C CNN
F 3 "" H 4850 5500 50  0001 C CNN
	1    4850 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 5500 4850 5000
Wire Wire Line
	6900 5000 6900 4800
Connection ~ 4850 5000
Wire Wire Line
	4850 5000 4850 4800
Entry Wire Line
	5850 2600 5950 2500
Entry Wire Line
	5850 2700 5950 2600
Entry Wire Line
	5850 2800 5950 2700
Entry Wire Line
	5850 2900 5950 2800
Entry Wire Line
	5850 3000 5950 2900
Entry Wire Line
	5850 3100 5950 3000
Entry Wire Line
	5850 3200 5950 3100
Entry Wire Line
	5850 3300 5950 3200
Entry Wire Line
	5850 3400 5950 3300
Entry Wire Line
	5850 3500 5950 3400
Entry Wire Line
	5850 3600 5950 3500
Entry Wire Line
	5850 3700 5950 3600
Entry Wire Line
	5850 3800 5950 3700
Entry Wire Line
	5850 3900 5950 3800
Entry Wire Line
	5850 4000 5950 3900
Entry Wire Line
	5850 4100 5950 4000
Text Label 5850 2600 2    50   ~ 0
PC_IF0
Text Label 5850 2700 2    50   ~ 0
PC_IF1
Text Label 5850 2800 2    50   ~ 0
PC_IF2
Text Label 5850 2900 2    50   ~ 0
PC_IF3
Text Label 5850 3000 2    50   ~ 0
PC_IF4
Text Label 5850 3100 2    50   ~ 0
PC_IF5
Text Label 5850 3200 2    50   ~ 0
PC_IF6
Text Label 5850 3300 2    50   ~ 0
PC_IF7
Text Label 5850 3400 2    50   ~ 0
PC_IF8
Text Label 5850 3500 2    50   ~ 0
PC_IF9
Text Label 5850 3600 2    50   ~ 0
PC_IF10
Text Label 5850 3700 2    50   ~ 0
PC_IF11
Text Label 5850 3800 2    50   ~ 0
PC_IF12
Text Label 5850 3900 2    50   ~ 0
PC_IF13
Text Label 5850 4000 2    50   ~ 0
PC_IF14
Text Label 5850 4100 2    50   ~ 0
PC_IF15
Wire Wire Line
	5500 4400 6050 4400
Wire Wire Line
	5500 4600 6050 4600
Wire Wire Line
	6050 4600 6050 5000
Connection ~ 6050 4600
Wire Wire Line
	6050 4600 6250 4600
Connection ~ 6050 5000
Wire Wire Line
	6050 5000 6900 5000
Wire Wire Line
	6050 4400 6050 2000
Connection ~ 6050 4400
Wire Wire Line
	6050 4400 6250 4400
Connection ~ 6050 2000
Wire Wire Line
	6050 2000 4850 2000
Wire Wire Line
	4850 5000 5850 5000
Connection ~ 5850 4200
Wire Wire Line
	6250 4200 5850 4200
Connection ~ 5850 5000
Wire Wire Line
	5500 4200 5850 4200
Wire Wire Line
	5850 4200 5850 5000
Entry Wire Line
	7900 2600 8000 2500
Entry Wire Line
	7900 2700 8000 2600
Entry Wire Line
	7900 2900 8000 2800
Entry Wire Line
	7900 3000 8000 2900
Entry Wire Line
	7900 3100 8000 3000
Entry Wire Line
	7900 3200 8000 3100
Entry Wire Line
	7900 3300 8000 3200
Entry Wire Line
	7900 2800 8000 2700
Text Label 7900 2600 2    50   ~ 0
InsBus8
Text Label 7900 2700 2    50   ~ 0
InsBus9
Text Label 4150 3000 2    50   ~ 0
InsBus4
Text Label 4150 3100 2    50   ~ 0
InsBus5
Text Label 4150 3200 2    50   ~ 0
InsBus6
Text Label 4150 3300 2    50   ~ 0
InsBus7
Text Label 7900 2800 2    50   ~ 0
InsBus10
Text Label 7900 2900 2    50   ~ 0
InsBus11
Text Label 7900 3000 2    50   ~ 0
InsBus12
Text Label 7900 3100 2    50   ~ 0
InsBus13
Text Label 7900 3200 2    50   ~ 0
InsBus14
Text Label 7900 3300 2    50   ~ 0
InsBus15
Wire Wire Line
	6900 2000 6050 2000
Text Label 4150 2900 2    50   ~ 0
InsBus3
Text Label 4150 2800 2    50   ~ 0
InsBus2
Text Label 4150 2700 2    50   ~ 0
InsBus1
Text Label 4150 2600 2    50   ~ 0
InsBus0
Entry Wire Line
	3750 2500 3850 2600
Entry Wire Line
	3750 3200 3850 3300
Entry Wire Line
	3750 3100 3850 3200
Entry Wire Line
	3750 3000 3850 3100
Entry Wire Line
	3750 2900 3850 3000
Entry Wire Line
	3750 2800 3850 2900
Entry Wire Line
	3750 2700 3850 2800
Entry Wire Line
	3750 2600 3850 2700
$Comp
L Memory_EEPROM:GLS29EE010 U15
U 1 1 5D23ED7B
P 6900 2500
F 0 "U15" H 6600 2700 50  0000 C CNN
F 1 "Instruction ROM [8..15]" H 6600 2600 50  0000 C CNN
F 2 "Socket:DIP_Socket-32_W11.9_W12.7_W15.24_W17.78_W18.5_3M_232-1285-00-0602J" H 6900 2500 50  0001 C CNN
F 3 "" H 6900 2500 50  0001 C CNN
	1    6900 2500
	1    0    0    -1  
$EndComp
Wire Bus Line
	2350 2100 5950 2100
Connection ~ 8000 2200
Wire Bus Line
	8000 2200 8800 2200
Wire Bus Line
	3750 2200 8000 2200
Wire Wire Line
	7500 2600 7900 2600
Wire Wire Line
	7500 2700 7900 2700
Wire Wire Line
	7500 2800 7900 2800
Wire Wire Line
	7500 2900 7900 2900
Wire Wire Line
	7500 3000 7900 3000
Wire Wire Line
	7500 3100 7900 3100
Wire Wire Line
	7500 3200 7900 3200
Wire Wire Line
	7500 3300 7900 3300
Wire Wire Line
	3850 2600 4250 2600
Wire Wire Line
	3850 2700 4250 2700
Wire Wire Line
	3850 2800 4250 2800
Wire Wire Line
	3850 2900 4250 2900
Wire Wire Line
	3850 3000 4250 3000
Wire Wire Line
	3850 3100 4250 3100
Wire Wire Line
	3850 3200 4250 3200
Wire Wire Line
	3850 3300 4250 3300
Wire Wire Line
	5500 4500 6150 4500
Wire Wire Line
	5850 5000 6050 5000
Wire Wire Line
	6150 4100 6150 4500
Connection ~ 6150 4100
Wire Wire Line
	6150 4100 6250 4100
Connection ~ 6150 4500
Wire Wire Line
	6150 4500 6250 4500
Wire Wire Line
	5500 4100 6150 4100
Wire Wire Line
	5500 2600 6250 2600
Wire Wire Line
	5500 2700 6250 2700
Wire Wire Line
	5500 2800 6250 2800
Wire Wire Line
	5500 2900 6250 2900
Wire Wire Line
	5500 3000 6250 3000
Wire Wire Line
	5500 3100 6250 3100
Wire Wire Line
	5500 3200 6250 3200
Wire Wire Line
	5500 3300 6250 3300
Wire Wire Line
	5500 3400 6250 3400
Wire Wire Line
	5500 3500 6250 3500
Wire Wire Line
	5500 3600 6250 3600
Wire Wire Line
	5500 3700 6250 3700
Wire Wire Line
	5500 3800 6250 3800
Wire Wire Line
	5500 3900 6250 3900
Wire Wire Line
	5500 4000 6250 4000
Wire Bus Line
	3750 2200 3750 3200
Wire Bus Line
	8000 2200 8000 3200
Wire Bus Line
	5950 2100 5950 4000
$EndSCHEMATC
