EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 32 33
Title "Instruction RAM"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Instructions are stored in a 64k x 16 dual port RAM with one port exposed on the bus."
$EndDescr
$Comp
L Device:C C?
U 1 1 5FD4710E
P 700 7350
AR Path="/5D8005AF/5D800742/5FD4710E" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FD4710E" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4710E" Ref="C72"  Part="1" 
F 0 "C72" H 815 7396 50  0000 L CNN
F 1 "100nF" H 815 7305 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 738 7200 50  0001 C CNN
F 3 "~" H 700 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 700 7350 50  0001 C CNN "Mouser"
	1    700  7350
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FD47114
P 1200 7350
AR Path="/5D8005AF/5D800742/5FD47114" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FD47114" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47114" Ref="C73"  Part="1" 
F 0 "C73" H 1315 7396 50  0000 L CNN
F 1 "100nF" H 1315 7305 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1238 7200 50  0001 C CNN
F 3 "~" H 1200 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1200 7350 50  0001 C CNN "Mouser"
	1    1200 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD4711A
P 700 7500
AR Path="/5D8005AF/5D800742/5FD4711A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD4711A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4711A" Ref="#PWR0434"  Part="1" 
F 0 "#PWR0434" H 700 7250 50  0001 C CNN
F 1 "GND" H 705 7327 50  0000 C CNN
F 2 "" H 700 7500 50  0001 C CNN
F 3 "" H 700 7500 50  0001 C CNN
	1    700  7500
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD47120
P 700 7200
AR Path="/5D8005AF/5D800742/5FD47120" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD47120" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47120" Ref="#PWR0433"  Part="1" 
F 0 "#PWR0433" H 700 7050 50  0001 C CNN
F 1 "VCC" H 717 7373 50  0000 C CNN
F 2 "" H 700 7200 50  0001 C CNN
F 3 "" H 700 7200 50  0001 C CNN
	1    700  7200
	1    0    0    -1  
$EndComp
Wire Wire Line
	700  7200 1200 7200
Connection ~ 700  7200
Wire Wire Line
	1200 7500 700  7500
Connection ~ 700  7500
Entry Wire Line
	6500 4250 6400 4150
Entry Wire Line
	6500 4350 6400 4250
Entry Wire Line
	6500 4550 6400 4450
Entry Wire Line
	6500 4650 6400 4550
Entry Wire Line
	6500 4750 6400 4650
Entry Wire Line
	6500 4850 6400 4750
Entry Wire Line
	6500 4950 6400 4850
Entry Wire Line
	6500 4450 6400 4350
Text Label 6500 4250 0    50   ~ 0
InstructionWord8
Text Label 6500 4350 0    50   ~ 0
InstructionWord9
Text Label 2250 4650 2    50   ~ 0
InstructionWord4
Text Label 2250 4750 2    50   ~ 0
InstructionWord5
Text Label 2250 4850 2    50   ~ 0
InstructionWord6
Text Label 2250 4950 2    50   ~ 0
InstructionWord7
Text Label 6500 4450 0    50   ~ 0
InstructionWord10
Text Label 6500 4550 0    50   ~ 0
InstructionWord11
Text Label 6500 4650 0    50   ~ 0
InstructionWord12
Text Label 6500 4750 0    50   ~ 0
InstructionWord13
Text Label 6500 4850 0    50   ~ 0
InstructionWord14
Text Label 6500 4950 0    50   ~ 0
InstructionWord15
Text Label 2250 4550 2    50   ~ 0
InstructionWord3
Text Label 2250 4450 2    50   ~ 0
InstructionWord2
Text Label 2250 4350 2    50   ~ 0
InstructionWord1
Text Label 2250 4250 2    50   ~ 0
InstructionWord0
Entry Wire Line
	1400 4150 1500 4250
Entry Wire Line
	1400 4850 1500 4950
Entry Wire Line
	1400 4750 1500 4850
Entry Wire Line
	1400 4650 1500 4750
Entry Wire Line
	1400 4550 1500 4650
Entry Wire Line
	1400 4450 1500 4550
Entry Wire Line
	1400 4350 1500 4450
Entry Wire Line
	1400 4250 1500 4350
Text HLabel 1300 650  0    50   Input ~ 0
PC[0..15]
Text HLabel 8650 950  2    50   Output ~ 0
InstructionWord[0..15]
Wire Wire Line
	1500 4550 2350 4550
Wire Wire Line
	1500 4650 2350 4650
Wire Wire Line
	1500 4750 2350 4750
Wire Wire Line
	1500 4850 2350 4850
Wire Wire Line
	1500 4950 2350 4950
Wire Wire Line
	1500 4250 2350 4250
Wire Wire Line
	1500 4350 2350 4350
Wire Wire Line
	1500 4450 2350 4450
$Comp
L Memory_RAM:IDT7008L15JG U?
U 1 1 5FD47161
P 3150 3200
AR Path="/5FE35007/5FD47161" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47161" Ref="U68"  Part="1" 
F 0 "U68" H 3150 3250 50  0000 C CNN
F 1 "IDT7008L15JG" H 3150 3150 50  0000 C CNN
F 2 "Package_LCC:PLCC-84_SMD-Socket" H 2650 5150 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/698/IDT_7008_DST_20190808-1711430.pdf" H 2650 5150 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Renesas-IDT/7008L15JG?qs=JcGQCygHkIZ1zP%252Bdu4e2ww%3D%3D" H 3150 3200 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/8484-21B1-RK-TP?qs=WZRMhwwaLl9l%2F%2FO6ipJKVw%3D%3D" H 3150 3200 50  0001 C CNN "Mouser2"
	1    3150 3200
	1    0    0    -1  
$EndComp
Wire Bus Line
	1300 650  1500 650 
$Comp
L power:VCC #PWR?
U 1 1 5FD47168
P 3150 1250
AR Path="/5FE35007/5FD47168" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47168" Ref="#PWR0442"  Part="1" 
F 0 "#PWR0442" H 3150 1100 50  0001 C CNN
F 1 "VCC" H 3165 1423 50  0000 C CNN
F 2 "" H 3150 1250 50  0001 C CNN
F 3 "" H 3150 1250 50  0001 C CNN
	1    3150 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3050 1350 3050 1300
Wire Wire Line
	3250 1300 3250 1350
Wire Wire Line
	3050 1300 3150 1300
Wire Wire Line
	3150 1250 3150 1300
Connection ~ 3150 1300
Wire Wire Line
	3150 1300 3250 1300
Wire Wire Line
	3150 1300 3150 1350
$Comp
L power:GND #PWR?
U 1 1 5FD47175
P 3150 5300
AR Path="/5FE35007/5FD47175" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47175" Ref="#PWR0443"  Part="1" 
F 0 "#PWR0443" H 3150 5050 50  0001 C CNN
F 1 "GND" H 3155 5127 50  0000 C CNN
F 2 "" H 3150 5300 50  0001 C CNN
F 3 "" H 3150 5300 50  0001 C CNN
	1    3150 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 5200 2800 5250
Wire Wire Line
	2800 5250 2900 5250
Wire Wire Line
	3500 5250 3500 5200
Wire Wire Line
	3150 5300 3150 5250
Connection ~ 3150 5250
Wire Wire Line
	3150 5250 3200 5250
Wire Wire Line
	2900 5200 2900 5250
Connection ~ 2900 5250
Wire Wire Line
	2900 5250 3000 5250
Wire Wire Line
	3000 5200 3000 5250
Connection ~ 3000 5250
Wire Wire Line
	3000 5250 3100 5250
Wire Wire Line
	3100 5200 3100 5250
Connection ~ 3100 5250
Wire Wire Line
	3100 5250 3150 5250
Wire Wire Line
	3200 5200 3200 5250
Connection ~ 3200 5250
Wire Wire Line
	3200 5250 3300 5250
Wire Wire Line
	3300 5200 3300 5250
Connection ~ 3300 5250
Wire Wire Line
	3300 5250 3400 5250
Wire Wire Line
	3400 5200 3400 5250
Connection ~ 3400 5250
Wire Wire Line
	3400 5250 3500 5250
$Comp
L power:VCC #PWR?
U 1 1 5FD4719B
P 2350 2050
AR Path="/5FE35007/5FD4719B" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4719B" Ref="#PWR0438"  Part="1" 
F 0 "#PWR0438" H 2350 1900 50  0001 C CNN
F 1 "VCC" V 2365 2177 50  0000 L CNN
F 2 "" H 2350 2050 50  0001 C CNN
F 3 "" H 2350 2050 50  0001 C CNN
	1    2350 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD471A1
P 2350 1950
AR Path="/5FE35007/5FD471A1" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD471A1" Ref="#PWR0437"  Part="1" 
F 0 "#PWR0437" H 2350 1700 50  0001 C CNN
F 1 "GND" V 2355 1822 50  0000 R CNN
F 2 "" H 2350 1950 50  0001 C CNN
F 3 "" H 2350 1950 50  0001 C CNN
	1    2350 1950
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD471A7
P 2350 2150
AR Path="/5FE35007/5FD471A7" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD471A7" Ref="#PWR0439"  Part="1" 
F 0 "#PWR0439" H 2350 2000 50  0001 C CNN
F 1 "VCC" V 2365 2277 50  0000 L CNN
F 2 "" H 2350 2150 50  0001 C CNN
F 3 "" H 2350 2150 50  0001 C CNN
	1    2350 2150
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD471AD
P 2350 2250
AR Path="/5FE35007/5FD471AD" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD471AD" Ref="#PWR0440"  Part="1" 
F 0 "#PWR0440" H 2350 2100 50  0001 C CNN
F 1 "VCC" V 2365 2377 50  0000 L CNN
F 2 "" H 2350 2250 50  0001 C CNN
F 3 "" H 2350 2250 50  0001 C CNN
	1    2350 2250
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD471B3
P 2350 2350
AR Path="/5FE35007/5FD471B3" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD471B3" Ref="#PWR0441"  Part="1" 
F 0 "#PWR0441" H 2350 2100 50  0001 C CNN
F 1 "GND" V 2355 2222 50  0000 R CNN
F 2 "" H 2350 2350 50  0001 C CNN
F 3 "" H 2350 2350 50  0001 C CNN
	1    2350 2350
	0    1    1    0   
$EndComp
Entry Wire Line
	1600 2550 1500 2450
Entry Wire Line
	1600 2650 1500 2550
Entry Wire Line
	1600 2750 1500 2650
Entry Wire Line
	1600 2850 1500 2750
Entry Wire Line
	1600 2950 1500 2850
Entry Wire Line
	1600 3050 1500 2950
Entry Wire Line
	1600 3150 1500 3050
Entry Wire Line
	1600 3250 1500 3150
Entry Wire Line
	1600 3350 1500 3250
Entry Wire Line
	1600 3450 1500 3350
Entry Wire Line
	1600 3550 1500 3450
Entry Wire Line
	1600 3650 1500 3550
Entry Wire Line
	1600 3750 1500 3650
Entry Wire Line
	1600 3850 1500 3750
Entry Wire Line
	1600 3950 1500 3850
Text Label 1600 2550 0    50   ~ 0
PC0
Text Label 1600 2650 0    50   ~ 0
PC1
Text Label 1600 2750 0    50   ~ 0
PC2
Text Label 1600 2850 0    50   ~ 0
PC3
Text Label 1600 2950 0    50   ~ 0
PC4
Text Label 1600 3050 0    50   ~ 0
PC5
Text Label 1600 3150 0    50   ~ 0
PC6
Text Label 1600 3250 0    50   ~ 0
PC7
Text Label 1600 3350 0    50   ~ 0
PC8
Text Label 1600 3450 0    50   ~ 0
PC9
Text Label 1600 3550 0    50   ~ 0
PC10
Text Label 1600 3650 0    50   ~ 0
PC11
Text Label 1600 3750 0    50   ~ 0
PC12
Text Label 1600 3850 0    50   ~ 0
PC13
Text Label 1600 3950 0    50   ~ 0
PC14
Wire Wire Line
	2350 3850 1600 3850
Wire Wire Line
	2350 3750 1600 3750
Wire Wire Line
	2350 3650 1600 3650
Wire Wire Line
	2350 3550 1600 3550
Wire Wire Line
	2350 3450 1600 3450
Wire Wire Line
	2350 3350 1600 3350
Wire Wire Line
	2350 3250 1600 3250
Wire Wire Line
	2350 3150 1600 3150
Wire Wire Line
	2350 3050 1600 3050
Wire Wire Line
	2350 2950 1600 2950
Wire Wire Line
	2350 2850 1600 2850
Wire Wire Line
	2350 2750 1600 2750
Wire Wire Line
	2350 2650 1600 2650
Wire Wire Line
	2350 2550 1600 2550
Wire Wire Line
	2350 3950 1600 3950
Wire Bus Line
	1400 950  6400 950 
Connection ~ 1500 650 
Wire Bus Line
	1500 650  6500 650 
$Comp
L Memory_RAM:IDT7008L15JG U?
U 1 1 5FD471EF
P 8150 3200
AR Path="/5FE35007/5FD471EF" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD471EF" Ref="U70"  Part="1" 
F 0 "U70" H 8150 3250 50  0000 C CNN
F 1 "IDT7008L15JG" H 8150 3150 50  0000 C CNN
F 2 "Package_LCC:PLCC-84_SMD-Socket" H 7650 5150 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/698/IDT_7008_DST_20190808-1711430.pdf" H 7650 5150 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Renesas-IDT/7008L15JG?qs=JcGQCygHkIZ1zP%252Bdu4e2ww%3D%3D" H 8150 3200 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/8484-21B1-RK-TP?qs=WZRMhwwaLl9l%2F%2FO6ipJKVw%3D%3D" H 8150 3200 50  0001 C CNN "Mouser2"
	1    8150 3200
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD471F5
P 8150 1250
AR Path="/5FE35007/5FD471F5" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD471F5" Ref="#PWR0457"  Part="1" 
F 0 "#PWR0457" H 8150 1100 50  0001 C CNN
F 1 "VCC" H 8165 1423 50  0000 C CNN
F 2 "" H 8150 1250 50  0001 C CNN
F 3 "" H 8150 1250 50  0001 C CNN
	1    8150 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 1350 8050 1300
Wire Wire Line
	8250 1300 8250 1350
Wire Wire Line
	8050 1300 8150 1300
Wire Wire Line
	8150 1250 8150 1300
Connection ~ 8150 1300
Wire Wire Line
	8150 1300 8250 1300
Wire Wire Line
	8150 1300 8150 1350
$Comp
L power:GND #PWR?
U 1 1 5FD47202
P 8150 5300
AR Path="/5FE35007/5FD47202" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47202" Ref="#PWR0458"  Part="1" 
F 0 "#PWR0458" H 8150 5050 50  0001 C CNN
F 1 "GND" H 8155 5127 50  0000 C CNN
F 2 "" H 8150 5300 50  0001 C CNN
F 3 "" H 8150 5300 50  0001 C CNN
	1    8150 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 5200 7800 5250
Wire Wire Line
	7800 5250 7900 5250
Wire Wire Line
	8500 5250 8500 5200
Wire Wire Line
	8150 5300 8150 5250
Connection ~ 8150 5250
Wire Wire Line
	8150 5250 8200 5250
Wire Wire Line
	7900 5200 7900 5250
Connection ~ 7900 5250
Wire Wire Line
	7900 5250 8000 5250
Wire Wire Line
	8000 5200 8000 5250
Connection ~ 8000 5250
Wire Wire Line
	8000 5250 8100 5250
Wire Wire Line
	8100 5200 8100 5250
Connection ~ 8100 5250
Wire Wire Line
	8100 5250 8150 5250
Wire Wire Line
	8200 5200 8200 5250
Connection ~ 8200 5250
Wire Wire Line
	8200 5250 8300 5250
Wire Wire Line
	8300 5200 8300 5250
Connection ~ 8300 5250
Wire Wire Line
	8300 5250 8400 5250
Wire Wire Line
	8400 5200 8400 5250
Connection ~ 8400 5250
Wire Wire Line
	8400 5250 8500 5250
$Comp
L power:VCC #PWR?
U 1 1 5FD47228
P 7350 2050
AR Path="/5FE35007/5FD47228" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47228" Ref="#PWR0453"  Part="1" 
F 0 "#PWR0453" H 7350 1900 50  0001 C CNN
F 1 "VCC" V 7365 2177 50  0000 L CNN
F 2 "" H 7350 2050 50  0001 C CNN
F 3 "" H 7350 2050 50  0001 C CNN
	1    7350 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD4722E
P 7350 1950
AR Path="/5FE35007/5FD4722E" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4722E" Ref="#PWR0452"  Part="1" 
F 0 "#PWR0452" H 7350 1700 50  0001 C CNN
F 1 "GND" V 7355 1822 50  0000 R CNN
F 2 "" H 7350 1950 50  0001 C CNN
F 3 "" H 7350 1950 50  0001 C CNN
	1    7350 1950
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD47234
P 7350 2150
AR Path="/5FE35007/5FD47234" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47234" Ref="#PWR0454"  Part="1" 
F 0 "#PWR0454" H 7350 2000 50  0001 C CNN
F 1 "VCC" V 7365 2277 50  0000 L CNN
F 2 "" H 7350 2150 50  0001 C CNN
F 3 "" H 7350 2150 50  0001 C CNN
	1    7350 2150
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD4723A
P 7350 2250
AR Path="/5FE35007/5FD4723A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4723A" Ref="#PWR0455"  Part="1" 
F 0 "#PWR0455" H 7350 2100 50  0001 C CNN
F 1 "VCC" V 7365 2377 50  0000 L CNN
F 2 "" H 7350 2250 50  0001 C CNN
F 3 "" H 7350 2250 50  0001 C CNN
	1    7350 2250
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD47240
P 7350 2350
AR Path="/5FE35007/5FD47240" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47240" Ref="#PWR0456"  Part="1" 
F 0 "#PWR0456" H 7350 2100 50  0001 C CNN
F 1 "GND" V 7355 2222 50  0000 R CNN
F 2 "" H 7350 2350 50  0001 C CNN
F 3 "" H 7350 2350 50  0001 C CNN
	1    7350 2350
	0    1    1    0   
$EndComp
Entry Wire Line
	6600 2550 6500 2450
Entry Wire Line
	6600 2650 6500 2550
Entry Wire Line
	6600 2750 6500 2650
Entry Wire Line
	6600 2850 6500 2750
Entry Wire Line
	6600 2950 6500 2850
Entry Wire Line
	6600 3050 6500 2950
Entry Wire Line
	6600 3150 6500 3050
Entry Wire Line
	6600 3250 6500 3150
Entry Wire Line
	6600 3350 6500 3250
Entry Wire Line
	6600 3450 6500 3350
Entry Wire Line
	6600 3550 6500 3450
Entry Wire Line
	6600 3650 6500 3550
Entry Wire Line
	6600 3750 6500 3650
Entry Wire Line
	6600 3850 6500 3750
Entry Wire Line
	6600 3950 6500 3850
Text Label 6600 2550 0    50   ~ 0
PC0
Text Label 6600 2650 0    50   ~ 0
PC1
Text Label 6600 2750 0    50   ~ 0
PC2
Text Label 6600 2850 0    50   ~ 0
PC3
Text Label 6600 2950 0    50   ~ 0
PC4
Text Label 6600 3050 0    50   ~ 0
PC5
Text Label 6600 3150 0    50   ~ 0
PC6
Text Label 6600 3250 0    50   ~ 0
PC7
Text Label 6600 3350 0    50   ~ 0
PC8
Text Label 6600 3450 0    50   ~ 0
PC9
Text Label 6600 3550 0    50   ~ 0
PC10
Text Label 6600 3650 0    50   ~ 0
PC11
Text Label 6600 3750 0    50   ~ 0
PC12
Text Label 6600 3850 0    50   ~ 0
PC13
Text Label 6600 3950 0    50   ~ 0
PC14
Wire Wire Line
	7350 3850 6600 3850
Wire Wire Line
	7350 3750 6600 3750
Wire Wire Line
	7350 3650 6600 3650
Wire Wire Line
	7350 3550 6600 3550
Wire Wire Line
	7350 3450 6600 3450
Wire Wire Line
	7350 3350 6600 3350
Wire Wire Line
	7350 3250 6600 3250
Wire Wire Line
	7350 3150 6600 3150
Wire Wire Line
	7350 3050 6600 3050
Wire Wire Line
	7350 2950 6600 2950
Wire Wire Line
	7350 2850 6600 2850
Wire Wire Line
	7350 2750 6600 2750
Wire Wire Line
	7350 2650 6600 2650
Wire Wire Line
	7350 2550 6600 2550
Wire Wire Line
	7350 3950 6600 3950
Connection ~ 6400 950 
Wire Wire Line
	6500 4250 7350 4250
Wire Wire Line
	6500 4350 7350 4350
Wire Wire Line
	6500 4450 7350 4450
Wire Wire Line
	6500 4550 7350 4550
Wire Wire Line
	6500 4650 7350 4650
Wire Wire Line
	6500 4750 7350 4750
Wire Wire Line
	6500 4850 7350 4850
Wire Wire Line
	6500 4950 7350 4950
$Comp
L power:VCC #PWR?
U 1 1 5FD4728B
P 3950 2050
AR Path="/5FE35007/5FD4728B" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4728B" Ref="#PWR0448"  Part="1" 
F 0 "#PWR0448" H 3950 1900 50  0001 C CNN
F 1 "VCC" V 3965 2177 50  0000 L CNN
F 2 "" H 3950 2050 50  0001 C CNN
F 3 "" H 3950 2050 50  0001 C CNN
	1    3950 2050
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD47291
P 3950 1950
AR Path="/5FE35007/5FD47291" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47291" Ref="#PWR0447"  Part="1" 
F 0 "#PWR0447" H 3950 1700 50  0001 C CNN
F 1 "GND" V 3955 1822 50  0000 R CNN
F 2 "" H 3950 1950 50  0001 C CNN
F 3 "" H 3950 1950 50  0001 C CNN
	1    3950 1950
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD47297
P 3950 2150
AR Path="/5FE35007/5FD47297" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD47297" Ref="#PWR0449"  Part="1" 
F 0 "#PWR0449" H 3950 2000 50  0001 C CNN
F 1 "VCC" V 3965 2277 50  0000 L CNN
F 2 "" H 3950 2150 50  0001 C CNN
F 3 "" H 3950 2150 50  0001 C CNN
	1    3950 2150
	0    1    -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD472A3
P 8950 2050
AR Path="/5FE35007/5FD472A3" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD472A3" Ref="#PWR0461"  Part="1" 
F 0 "#PWR0461" H 8950 1900 50  0001 C CNN
F 1 "VCC" V 8965 2177 50  0000 L CNN
F 2 "" H 8950 2050 50  0001 C CNN
F 3 "" H 8950 2050 50  0001 C CNN
	1    8950 2050
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD472A9
P 8950 1950
AR Path="/5FE35007/5FD472A9" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD472A9" Ref="#PWR0460"  Part="1" 
F 0 "#PWR0460" H 8950 1700 50  0001 C CNN
F 1 "GND" V 8955 1822 50  0000 R CNN
F 2 "" H 8950 1950 50  0001 C CNN
F 3 "" H 8950 1950 50  0001 C CNN
	1    8950 1950
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FD472AF
P 8950 2150
AR Path="/5FE35007/5FD472AF" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD472AF" Ref="#PWR0462"  Part="1" 
F 0 "#PWR0462" H 8950 2000 50  0001 C CNN
F 1 "VCC" V 8965 2277 50  0000 L CNN
F 2 "" H 8950 2150 50  0001 C CNN
F 3 "" H 8950 2150 50  0001 C CNN
	1    8950 2150
	0    1    -1   0   
$EndComp
Entry Wire Line
	4700 5050 4600 4950
Entry Wire Line
	4700 4350 4600 4250
Entry Wire Line
	4700 4450 4600 4350
Entry Wire Line
	4700 4550 4600 4450
Entry Wire Line
	4700 4650 4600 4550
Entry Wire Line
	4700 4750 4600 4650
Entry Wire Line
	4700 4850 4600 4750
Entry Wire Line
	4700 4950 4600 4850
Wire Wire Line
	4600 4650 3950 4650
Wire Wire Line
	4600 4550 3950 4550
Wire Wire Line
	4600 4450 3950 4450
Wire Wire Line
	4600 4350 3950 4350
Wire Wire Line
	4600 4250 3950 4250
Wire Wire Line
	4600 4950 3950 4950
Wire Wire Line
	4600 4850 3950 4850
Wire Wire Line
	4600 4750 3950 4750
$Comp
L power:VCC #PWR?
U 1 1 5FD472C5
P 3900 6150
AR Path="/5D2C0B92/5FD472C5" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FD472C5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FD472C5" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD472C5" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD472C5" Ref="#PWR0444"  Part="1" 
F 0 "#PWR0444" H 3900 6000 50  0001 C CNN
F 1 "VCC" H 3917 6323 50  0000 C CNN
F 2 "" H 3900 6150 50  0001 C CNN
F 3 "" H 3900 6150 50  0001 C CNN
	1    3900 6150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD472CB
P 3900 7550
AR Path="/5D2C0B92/5FD472CB" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FD472CB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FD472CB" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD472CB" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD472CB" Ref="#PWR0445"  Part="1" 
F 0 "#PWR0445" H 3900 7300 50  0001 C CNN
F 1 "GND" H 3905 7377 50  0000 C CNN
F 2 "" H 3900 7550 50  0001 C CNN
F 3 "" H 3900 7550 50  0001 C CNN
	1    3900 7550
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FD472D1
P 1700 7350
AR Path="/5D8005AF/5D800742/5FD472D1" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FD472D1" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD472D1" Ref="C74"  Part="1" 
F 0 "C74" H 1815 7396 50  0000 L CNN
F 1 "100nF" H 1815 7305 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1738 7200 50  0001 C CNN
F 3 "~" H 1700 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1700 7350 50  0001 C CNN "Mouser"
	1    1700 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1200 7200 1700 7200
Wire Wire Line
	1700 7500 1200 7500
Text HLabel 1250 5650 0    50   3State ~ 0
IO[0..7]
Text HLabel 1250 5750 0    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	1250 5650 4700 5650
Wire Bus Line
	4700 5650 9700 5650
Connection ~ 4700 5650
Connection ~ 4800 5750
Text Label 4600 4250 2    50   ~ 0
IO0
Text Label 4600 4350 2    50   ~ 0
IO1
Text Label 4600 4450 2    50   ~ 0
IO2
Text Label 4600 4550 2    50   ~ 0
IO3
Text Label 4600 4650 2    50   ~ 0
IO4
Text Label 4600 4750 2    50   ~ 0
IO5
Text Label 4600 4850 2    50   ~ 0
IO6
Text Label 4600 4950 2    50   ~ 0
IO7
Entry Wire Line
	9700 5050 9600 4950
Entry Wire Line
	9700 4350 9600 4250
Entry Wire Line
	9700 4450 9600 4350
Entry Wire Line
	9700 4550 9600 4450
Entry Wire Line
	9700 4650 9600 4550
Entry Wire Line
	9700 4750 9600 4650
Entry Wire Line
	9700 4850 9600 4750
Entry Wire Line
	9700 4950 9600 4850
Wire Wire Line
	9600 4650 8950 4650
Wire Wire Line
	9600 4550 8950 4550
Wire Wire Line
	9600 4450 8950 4450
Wire Wire Line
	9600 4350 8950 4350
Wire Wire Line
	9600 4250 8950 4250
Wire Wire Line
	9600 4950 8950 4950
Wire Wire Line
	9600 4850 8950 4850
Wire Wire Line
	9600 4750 8950 4750
Text Label 9600 4250 2    50   ~ 0
IO0
Text Label 9600 4350 2    50   ~ 0
IO1
Text Label 9600 4450 2    50   ~ 0
IO2
Text Label 9600 4550 2    50   ~ 0
IO3
Text Label 9600 4650 2    50   ~ 0
IO4
Text Label 9600 4750 2    50   ~ 0
IO5
Text Label 9600 4850 2    50   ~ 0
IO6
Text Label 9600 4950 2    50   ~ 0
IO7
Wire Wire Line
	3950 2350 5050 2350
Wire Wire Line
	3950 2250 5150 2250
Wire Wire Line
	8950 2350 10050 2350
Wire Wire Line
	10050 2350 10050 6200
Wire Wire Line
	10050 6200 5350 6200
Wire Wire Line
	5450 6300 10150 6300
Wire Wire Line
	10150 6300 10150 2250
Wire Wire Line
	10150 2250 8950 2250
Entry Wire Line
	3000 6250 3100 6350
Wire Wire Line
	3100 6350 3400 6350
Text Label 3100 6350 0    50   ~ 0
Addr15
Text HLabel 1250 5850 0    50   Input ~ 0
Bank[0..7]
Entry Wire Line
	3000 6350 3100 6450
Text Label 3100 6450 0    50   ~ 0
Bank0
Entry Wire Line
	3000 6450 3100 6550
Text Label 3100 6550 0    50   ~ 0
Bank1
Entry Wire Line
	3000 6550 3100 6650
Text Label 3100 6650 0    50   ~ 0
Bank2
Wire Bus Line
	1250 5850 2900 5850
Text Label 9700 3950 2    50   ~ 0
Addr14
Text Label 9700 3850 2    50   ~ 0
Addr13
Text Label 9700 3750 2    50   ~ 0
Addr12
Text Label 9700 3650 2    50   ~ 0
Addr11
Text Label 9700 3550 2    50   ~ 0
Addr10
Text Label 9700 3450 2    50   ~ 0
Addr9
Text Label 9700 3350 2    50   ~ 0
Addr8
Text Label 9700 3250 2    50   ~ 0
Addr7
Text Label 9700 3150 2    50   ~ 0
Addr6
Text Label 9700 3050 2    50   ~ 0
Addr5
Text Label 9700 2950 2    50   ~ 0
Addr4
Text Label 9700 2850 2    50   ~ 0
Addr3
Text Label 9700 2750 2    50   ~ 0
Addr2
Text Label 9700 2650 2    50   ~ 0
Addr1
Wire Wire Line
	8950 2650 9700 2650
Wire Wire Line
	8950 3950 9700 3950
Wire Wire Line
	8950 3850 9700 3850
Wire Wire Line
	8950 3750 9700 3750
Wire Wire Line
	8950 3650 9700 3650
Wire Wire Line
	8950 3550 9700 3550
Wire Wire Line
	8950 3450 9700 3450
Wire Wire Line
	8950 3350 9700 3350
Wire Wire Line
	8950 3250 9700 3250
Wire Wire Line
	8950 3150 9700 3150
Wire Wire Line
	8950 3050 9700 3050
Wire Wire Line
	8950 2950 9700 2950
Wire Wire Line
	8950 2850 9700 2850
Wire Wire Line
	8950 2750 9700 2750
Entry Wire Line
	9700 2650 9800 2750
Entry Wire Line
	9700 2750 9800 2850
Entry Wire Line
	9700 2850 9800 2950
Entry Wire Line
	9700 2950 9800 3050
Entry Wire Line
	9700 3050 9800 3150
Entry Wire Line
	9700 3150 9800 3250
Entry Wire Line
	9700 3250 9800 3350
Entry Wire Line
	9700 3350 9800 3450
Entry Wire Line
	9700 3450 9800 3550
Entry Wire Line
	9700 3550 9800 3650
Entry Wire Line
	9700 3650 9800 3750
Entry Wire Line
	9700 3750 9800 3850
Entry Wire Line
	9700 3850 9800 3950
Entry Wire Line
	9700 3950 9800 4050
Text Label 4700 3950 2    50   ~ 0
Addr14
Text Label 4700 3850 2    50   ~ 0
Addr13
Text Label 4700 3750 2    50   ~ 0
Addr12
Text Label 4700 3650 2    50   ~ 0
Addr11
Text Label 4700 3550 2    50   ~ 0
Addr10
Text Label 4700 3450 2    50   ~ 0
Addr9
Text Label 4700 3350 2    50   ~ 0
Addr8
Text Label 4700 3250 2    50   ~ 0
Addr7
Text Label 4700 3150 2    50   ~ 0
Addr6
Text Label 4700 3050 2    50   ~ 0
Addr5
Text Label 4700 2950 2    50   ~ 0
Addr4
Text Label 4700 2850 2    50   ~ 0
Addr3
Text Label 4700 2750 2    50   ~ 0
Addr2
Text Label 4700 2650 2    50   ~ 0
Addr1
Wire Wire Line
	3950 2650 4700 2650
Wire Wire Line
	3950 3950 4700 3950
Wire Wire Line
	3950 3850 4700 3850
Wire Wire Line
	3950 3750 4700 3750
Wire Wire Line
	3950 3650 4700 3650
Wire Wire Line
	3950 3550 4700 3550
Wire Wire Line
	3950 3450 4700 3450
Wire Wire Line
	3950 3350 4700 3350
Wire Wire Line
	3950 3250 4700 3250
Wire Wire Line
	3950 3150 4700 3150
Wire Wire Line
	3950 3050 4700 3050
Wire Wire Line
	3950 2950 4700 2950
Wire Wire Line
	3950 2850 4700 2850
Wire Wire Line
	3950 2750 4700 2750
Entry Wire Line
	4700 2650 4800 2750
Entry Wire Line
	4700 2750 4800 2850
Entry Wire Line
	4700 2850 4800 2950
Entry Wire Line
	4700 2950 4800 3050
Entry Wire Line
	4700 3050 4800 3150
Entry Wire Line
	4700 3150 4800 3250
Entry Wire Line
	4700 3250 4800 3350
Entry Wire Line
	4700 3350 4800 3450
Entry Wire Line
	4700 3450 4800 3550
Entry Wire Line
	4700 3550 4800 3650
Entry Wire Line
	4700 3650 4800 3750
Entry Wire Line
	4700 3750 4800 3850
Entry Wire Line
	4700 3850 4800 3950
Entry Wire Line
	4700 3950 4800 4050
Text Label 9700 2550 2    50   ~ 0
Addr0
Wire Wire Line
	9700 2550 8950 2550
Entry Wire Line
	9700 2550 9800 2650
Text Label 4700 2550 2    50   ~ 0
Addr0
Wire Wire Line
	4700 2550 3950 2550
Entry Wire Line
	4700 2550 4800 2650
Text Notes 650  6800 0    50   ~ 0
The Bank Select is an eight-bit value which controls the\nmapping of the upper 32KB of the address space. This\nGAL maps four banks to instruction RAM to allow the\nentire 64KB memory to be used.
Wire Bus Line
	1250 5750 3000 5750
Connection ~ 3000 5750
Wire Bus Line
	3000 5750 4800 5750
Wire Bus Line
	4800 5750 9800 5750
NoConn ~ 4400 6950
NoConn ~ 4400 7050
NoConn ~ 4400 7150
NoConn ~ 4400 7250
NoConn ~ 4400 7350
NoConn ~ 3400 7250
NoConn ~ 3400 7350
Wire Bus Line
	3000 5750 3000 6250
Wire Wire Line
	3100 6450 3400 6450
Wire Wire Line
	3100 6550 3400 6550
Wire Wire Line
	3100 6650 3400 6650
Wire Bus Line
	3000 6350 2900 6350
Wire Bus Line
	2900 6350 2900 5850
$Comp
L MainBoard-rescue:ATF22V10C-Logic_Programmable U?
U 1 1 5FD4737E
P 3900 6800
AR Path="/5FED3839/5FD4737E" Ref="U?"  Part="1" 
AR Path="/5D2C07CD/5FD4737E" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD4737E" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4737E" Ref="U69"  Part="1" 
F 0 "U69" H 3550 7450 50  0000 C CNN
F 1 "ATF22V10C-7PX" H 3550 7350 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W8.89mm_SMDSocket_LongPads" H 4750 6100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/268/doc0735-1369018.pdf" H 3900 6850 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology-Atmel/ATF22V10C-7PX?qs=%2Fha2pyFadugqFuTUlWvkuaZr7DXQ8Rnu3dOZcKuoHGuPC51te6MYUw%3D%3D" H 3900 6800 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/575-4462401" H 3900 6800 50  0001 C CNN "Mouser2"
	1    3900 6800
	1    0    0    -1  
$EndComp
Entry Wire Line
	3000 6650 3100 6750
Text Label 3100 6750 0    50   ~ 0
Bank3
Entry Wire Line
	3000 6750 3100 6850
Text Label 3100 6850 0    50   ~ 0
Bank4
Entry Wire Line
	3000 6850 3100 6950
Text Label 3100 6950 0    50   ~ 0
Bank5
Wire Wire Line
	3100 6750 3400 6750
Wire Wire Line
	3100 6850 3400 6850
Wire Wire Line
	3100 6950 3400 6950
Entry Wire Line
	3000 6950 3100 7050
Text Label 3100 7050 0    50   ~ 0
Bank6
Entry Wire Line
	3000 7050 3100 7150
Text Label 3100 7150 0    50   ~ 0
Bank7
Wire Wire Line
	3100 7050 3400 7050
Wire Wire Line
	3100 7150 3400 7150
Wire Wire Line
	4950 6350 4400 6350
Wire Wire Line
	4400 6450 5050 6450
Wire Wire Line
	5050 2350 5050 6450
Wire Wire Line
	4400 6550 5150 6550
Wire Wire Line
	5150 2250 5150 6550
Wire Wire Line
	4400 6650 5250 6650
Wire Wire Line
	4400 6750 5350 6750
Wire Wire Line
	4950 4150 4700 4150
Wire Wire Line
	4700 4150 4700 4050
Wire Wire Line
	3950 4050 4700 4050
Wire Wire Line
	4950 4150 4950 6350
Wire Wire Line
	8950 4050 9700 4050
Wire Wire Line
	9700 4050 9700 4150
Wire Wire Line
	9700 4150 9950 4150
Wire Wire Line
	9950 4150 9950 6100
Wire Wire Line
	9950 6100 5250 6100
Wire Wire Line
	4400 6850 5450 6850
Wire Wire Line
	5450 6850 5450 6300
Wire Wire Line
	5250 6100 5250 6650
Wire Wire Line
	5350 6750 5350 6200
Entry Wire Line
	1600 4050 1500 3950
Text Label 1600 4050 0    50   ~ 0
PC15
Wire Wire Line
	2350 4050 1600 4050
Entry Wire Line
	6600 4050 6500 3950
Text Label 6600 4050 0    50   ~ 0
PC15
Wire Wire Line
	7350 4050 6600 4050
Wire Bus Line
	6400 950  8650 950 
$Comp
L power:GND #PWR?
U 1 1 5FCA5180
P 2350 1550
AR Path="/5FE35007/5FCA5180" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCA5180" Ref="#PWR0435"  Part="1" 
F 0 "#PWR0435" H 2350 1300 50  0001 C CNN
F 1 "GND" V 2355 1422 50  0000 R CNN
F 2 "" H 2350 1550 50  0001 C CNN
F 3 "" H 2350 1550 50  0001 C CNN
	1    2350 1550
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCA55ED
P 7350 1550
AR Path="/5FE35007/5FCA55ED" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCA55ED" Ref="#PWR0450"  Part="1" 
F 0 "#PWR0450" H 7350 1300 50  0001 C CNN
F 1 "GND" V 7355 1422 50  0000 R CNN
F 2 "" H 7350 1550 50  0001 C CNN
F 3 "" H 7350 1550 50  0001 C CNN
	1    7350 1550
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FCA773B
P 2350 1750
AR Path="/5FE35007/5FCA773B" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCA773B" Ref="#PWR0436"  Part="1" 
F 0 "#PWR0436" H 2350 1600 50  0001 C CNN
F 1 "VCC" V 2365 1877 50  0000 L CNN
F 2 "" H 2350 1750 50  0001 C CNN
F 3 "" H 2350 1750 50  0001 C CNN
	1    2350 1750
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FCA7B10
P 7350 1750
AR Path="/5FE35007/5FCA7B10" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCA7B10" Ref="#PWR0451"  Part="1" 
F 0 "#PWR0451" H 7350 1600 50  0001 C CNN
F 1 "VCC" V 7365 1877 50  0000 L CNN
F 2 "" H 7350 1750 50  0001 C CNN
F 3 "" H 7350 1750 50  0001 C CNN
	1    7350 1750
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FCA8368
P 3950 1750
AR Path="/5FE35007/5FCA8368" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCA8368" Ref="#PWR0446"  Part="1" 
F 0 "#PWR0446" H 3950 1600 50  0001 C CNN
F 1 "VCC" V 3965 1877 50  0000 L CNN
F 2 "" H 3950 1750 50  0001 C CNN
F 3 "" H 3950 1750 50  0001 C CNN
	1    3950 1750
	0    1    -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FCA866B
P 8950 1750
AR Path="/5FE35007/5FCA866B" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCA866B" Ref="#PWR0459"  Part="1" 
F 0 "#PWR0459" H 8950 1600 50  0001 C CNN
F 1 "VCC" V 8965 1877 50  0000 L CNN
F 2 "" H 8950 1750 50  0001 C CNN
F 3 "" H 8950 1750 50  0001 C CNN
	1    8950 1750
	0    1    -1   0   
$EndComp
NoConn ~ 8950 1850
NoConn ~ 7350 1850
NoConn ~ 2350 1850
NoConn ~ 3950 1850
Wire Bus Line
	3000 6350 3000 7050
Wire Bus Line
	9700 4350 9700 5650
Wire Bus Line
	4700 4350 4700 5650
Wire Bus Line
	1400 950  1400 4850
Wire Bus Line
	6400 950  6400 4850
Wire Bus Line
	9800 2650 9800 5750
Wire Bus Line
	4800 2650 4800 5750
Wire Bus Line
	6500 650  6500 3950
Wire Bus Line
	1500 650  1500 3950
Text Notes 3100 7900 0    50   ~ 0
TODO: The ATF22V10 data sheet suggests connecting pin 15
$EndSCHEMATC