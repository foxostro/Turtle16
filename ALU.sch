EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 12 21
Title "ALU"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 "The bits of the constant register provide the ALU control signals."
Comment3 "The ALU operands are directly wired to the A and B registers."
Comment4 "The ALU is based on the 74F181 4-bit ALU IC."
$EndDescr
$Comp
L 74xx:74LS181 U43
U 1 1 5D7E57B3
P 3050 2050
F 0 "U43" H 2800 3050 50  0000 C CNN
F 1 "74F181" H 2800 2950 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W15.24mm_Socket" H 3050 2050 50  0001 C CNN
F 3 "74xx/74F181.pdf" H 3050 2050 50  0001 C CNN
	1    3050 2050
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0139
U 1 1 5D7E905F
P 3050 1050
F 0 "#PWR0139" H 3050 900 50  0001 C CNN
F 1 "VCC" H 3067 1223 50  0000 C CNN
F 2 "" H 3050 1050 50  0001 C CNN
F 3 "" H 3050 1050 50  0001 C CNN
	1    3050 1050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0141
U 1 1 5D7EA36F
P 3050 3050
F 0 "#PWR0141" H 3050 2800 50  0001 C CNN
F 1 "GND" H 3055 2877 50  0000 C CNN
F 2 "" H 3050 3050 50  0001 C CNN
F 3 "" H 3050 3050 50  0001 C CNN
	1    3050 3050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5D7F19F0
P 2950 7600
AR Path="/5D2C0761/5D7F19F0" Ref="C?"  Part="1" 
AR Path="/5D2C0CE4/5D7F19F0" Ref="C45"  Part="1" 
F 0 "C45" H 3065 7646 50  0000 L CNN
F 1 "100nF" H 3065 7555 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 2988 7450 50  0001 C CNN
F 3 "~" H 2950 7600 50  0001 C CNN
	1    2950 7600
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5D7F19F6
P 3450 7600
AR Path="/5D2C0761/5D7F19F6" Ref="C?"  Part="1" 
AR Path="/5D2C0CE4/5D7F19F6" Ref="C46"  Part="1" 
F 0 "C46" H 3565 7646 50  0000 L CNN
F 1 "100nF" H 3565 7555 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 3488 7450 50  0001 C CNN
F 3 "~" H 3450 7600 50  0001 C CNN
	1    3450 7600
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5D7F19FC
P 3950 7600
AR Path="/5D2C0761/5D7F19FC" Ref="C?"  Part="1" 
AR Path="/5D2C0CE4/5D7F19FC" Ref="C50"  Part="1" 
F 0 "C50" H 4065 7646 50  0000 L CNN
F 1 "100nF" H 4065 7555 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 3988 7450 50  0001 C CNN
F 3 "~" H 3950 7600 50  0001 C CNN
	1    3950 7600
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5D7F1A02
P 4450 7600
AR Path="/5D2C0761/5D7F1A02" Ref="C?"  Part="1" 
AR Path="/5D2C0CE4/5D7F1A02" Ref="C51"  Part="1" 
F 0 "C51" H 4565 7646 50  0000 L CNN
F 1 "100nF" H 4565 7555 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 4488 7450 50  0001 C CNN
F 3 "~" H 4450 7600 50  0001 C CNN
	1    4450 7600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5D7F1A0E
P 2950 7750
AR Path="/5D2C0761/5D7F1A0E" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CE4/5D7F1A0E" Ref="#PWR0147"  Part="1" 
F 0 "#PWR0147" H 2950 7500 50  0001 C CNN
F 1 "GND" H 2955 7577 50  0000 C CNN
F 2 "" H 2950 7750 50  0001 C CNN
F 3 "" H 2950 7750 50  0001 C CNN
	1    2950 7750
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5D7F1A14
P 2950 7450
AR Path="/5D2C0761/5D7F1A14" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CE4/5D7F1A14" Ref="#PWR0150"  Part="1" 
F 0 "#PWR0150" H 2950 7300 50  0001 C CNN
F 1 "VCC" H 2967 7623 50  0000 C CNN
F 2 "" H 2950 7450 50  0001 C CNN
F 3 "" H 2950 7450 50  0001 C CNN
	1    2950 7450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2950 7450 3450 7450
Connection ~ 2950 7450
Wire Wire Line
	3450 7450 3950 7450
Connection ~ 3450 7450
Wire Wire Line
	3950 7450 4450 7450
Connection ~ 3950 7450
Wire Wire Line
	4450 7750 3950 7750
Wire Wire Line
	3950 7750 3450 7750
Connection ~ 3950 7750
Wire Wire Line
	3450 7750 2950 7750
Connection ~ 3450 7750
Connection ~ 2950 7750
Text GLabel 850  1250 0    50   Input ~ 0
A[0..7]
Text GLabel 850  1650 0    50   Input ~ 0
B[0..7]
Entry Wire Line
	2150 1250 2250 1350
Wire Wire Line
	2250 1350 2450 1350
Text Label 2300 1350 0    50   ~ 0
A0
Entry Wire Line
	2150 1350 2250 1450
Wire Wire Line
	2250 1450 2450 1450
Text Label 2300 1450 0    50   ~ 0
A1
Entry Wire Line
	2150 1450 2250 1550
Wire Wire Line
	2250 1550 2450 1550
Text Label 2300 1550 0    50   ~ 0
A2
Entry Wire Line
	2150 1550 2250 1650
Wire Wire Line
	2250 1650 2450 1650
Text Label 2300 1650 0    50   ~ 0
A3
Entry Wire Line
	2150 1650 2250 1750
Wire Wire Line
	2250 1750 2450 1750
Text Label 2300 1750 0    50   ~ 0
B0
Entry Wire Line
	2150 1750 2250 1850
Wire Wire Line
	2250 1850 2450 1850
Text Label 2300 1850 0    50   ~ 0
B1
Entry Wire Line
	2150 1850 2250 1950
Wire Wire Line
	2250 1950 2450 1950
Text Label 2300 1950 0    50   ~ 0
B2
Entry Wire Line
	2150 1950 2250 2050
Wire Wire Line
	2250 2050 2450 2050
Text Label 2300 2050 0    50   ~ 0
B3
Entry Wire Line
	2150 2050 2250 2150
Wire Wire Line
	2250 2150 2450 2150
Text Label 2300 2150 0    50   ~ 0
C0
Entry Wire Line
	2150 2150 2250 2250
Wire Wire Line
	2250 2250 2450 2250
Text Label 2300 2250 0    50   ~ 0
C1
Entry Wire Line
	2150 2250 2250 2350
Wire Wire Line
	2250 2350 2450 2350
Text Label 2300 2350 0    50   ~ 0
C2
Entry Wire Line
	2150 2350 2250 2450
Wire Wire Line
	2250 2450 2450 2450
Text Label 2300 2450 0    50   ~ 0
C3
Text GLabel 850  2050 0    50   Input ~ 0
C[0..7]
Entry Wire Line
	2150 2550 2250 2650
Wire Wire Line
	2250 2650 2450 2650
Text Label 2300 2650 0    50   ~ 0
C4
NoConn ~ 3650 2550
NoConn ~ 3650 2650
Wire Bus Line
	950  2050 850  2050
Wire Bus Line
	2150 2050 950  2050
Connection ~ 950  2050
Wire Bus Line
	2150 1250 1150 1250
Wire Bus Line
	2150 1650 1050 1650
Connection ~ 1050 1650
Wire Bus Line
	1050 1650 850  1650
Connection ~ 1150 1250
Wire Bus Line
	1150 1250 850  1250
Wire Wire Line
	3650 2250 3800 2250
Wire Wire Line
	3800 2250 3800 3350
Wire Wire Line
	3800 3350 1950 3350
Wire Wire Line
	1950 5350 2450 5350
Wire Bus Line
	1150 3850 2150 3850
Wire Bus Line
	1050 4250 2150 4250
Wire Bus Line
	2150 4650 950  4650
NoConn ~ 3650 5250
NoConn ~ 3650 5150
Text Label 2300 5250 0    50   ~ 0
C4
Wire Wire Line
	2250 5250 2450 5250
Entry Wire Line
	2150 5150 2250 5250
Text Label 2300 5050 0    50   ~ 0
C3
Wire Wire Line
	2250 5050 2450 5050
Entry Wire Line
	2150 4950 2250 5050
Text Label 2300 4950 0    50   ~ 0
C2
Wire Wire Line
	2250 4950 2450 4950
Entry Wire Line
	2150 4850 2250 4950
Text Label 2300 4850 0    50   ~ 0
C1
Wire Wire Line
	2250 4850 2450 4850
Entry Wire Line
	2150 4750 2250 4850
Text Label 2300 4750 0    50   ~ 0
C0
Wire Wire Line
	2250 4750 2450 4750
Entry Wire Line
	2150 4650 2250 4750
Text Label 2300 4650 0    50   ~ 0
B7
Wire Wire Line
	2250 4650 2450 4650
Entry Wire Line
	2150 4550 2250 4650
Text Label 2300 4550 0    50   ~ 0
B6
Wire Wire Line
	2250 4550 2450 4550
Entry Wire Line
	2150 4450 2250 4550
Text Label 2300 4450 0    50   ~ 0
B5
Wire Wire Line
	2250 4450 2450 4450
Entry Wire Line
	2150 4350 2250 4450
Text Label 2300 4350 0    50   ~ 0
B4
Wire Wire Line
	2250 4350 2450 4350
Entry Wire Line
	2150 4250 2250 4350
Text Label 2300 4250 0    50   ~ 0
A7
Wire Wire Line
	2250 4250 2450 4250
Entry Wire Line
	2150 4150 2250 4250
Text Label 2300 4150 0    50   ~ 0
A6
Wire Wire Line
	2250 4150 2450 4150
Entry Wire Line
	2150 4050 2250 4150
Text Label 2300 4050 0    50   ~ 0
A5
Wire Wire Line
	2250 4050 2450 4050
Entry Wire Line
	2150 3950 2250 4050
Text Label 2300 3950 0    50   ~ 0
A4
Wire Wire Line
	2250 3950 2450 3950
Entry Wire Line
	2150 3850 2250 3950
$Comp
L power:GND #PWR0289
U 1 1 5D7EA8C4
P 3050 5650
F 0 "#PWR0289" H 3050 5400 50  0001 C CNN
F 1 "GND" H 3055 5477 50  0000 C CNN
F 2 "" H 3050 5650 50  0001 C CNN
F 3 "" H 3050 5650 50  0001 C CNN
	1    3050 5650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS181 U44
U 1 1 5D7E72AF
P 3050 4650
F 0 "U44" H 2800 5650 50  0000 C CNN
F 1 "74F181" H 2800 5550 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W15.24mm_Socket" H 3050 4650 50  0001 C CNN
F 3 "74xx/74F181.pdf" H 3050 4650 50  0001 C CNN
	1    3050 4650
	1    0    0    -1  
$EndComp
Wire Bus Line
	1150 1250 1150 3850
Wire Bus Line
	1050 1650 1050 4250
Wire Bus Line
	950  2050 950  4650
Wire Wire Line
	1950 3350 1950 5350
Wire Bus Line
	6850 600  9150 600 
Text GLabel 9150 600  2    50   Output ~ 0
DataBus[0..7]
Text Label 6400 2050 0    50   ~ 0
DataBus7
Text Label 6400 1950 0    50   ~ 0
DataBus6
Text Label 6400 1850 0    50   ~ 0
DataBus5
Text Label 6400 1750 0    50   ~ 0
DataBus4
Text Label 6400 1650 0    50   ~ 0
DataBus3
Text Label 6400 1550 0    50   ~ 0
DataBus2
Text Label 6400 1450 0    50   ~ 0
DataBus1
Text Label 6400 1350 0    50   ~ 0
DataBus0
Wire Wire Line
	6750 2050 6400 2050
Wire Wire Line
	6400 1950 6750 1950
Wire Wire Line
	6750 1850 6400 1850
Wire Wire Line
	6400 1750 6750 1750
Wire Wire Line
	6750 1650 6400 1650
Wire Wire Line
	6400 1550 6750 1550
Wire Wire Line
	6750 1450 6400 1450
Wire Wire Line
	6400 1350 6750 1350
Entry Wire Line
	6750 1450 6850 1350
Entry Wire Line
	6750 1350 6850 1250
Entry Wire Line
	6750 2050 6850 1950
Entry Wire Line
	6750 1950 6850 1850
Entry Wire Line
	6750 1850 6850 1750
Entry Wire Line
	6750 1750 6850 1650
Entry Wire Line
	6750 1650 6850 1550
Entry Wire Line
	6750 1550 6850 1450
$Comp
L power:GND #PWR0296
U 1 1 5D8049CB
P 5900 2650
F 0 "#PWR0296" H 5900 2400 50  0001 C CNN
F 1 "GND" H 5905 2477 50  0000 C CNN
F 2 "" H 5900 2650 50  0001 C CNN
F 3 "" H 5900 2650 50  0001 C CNN
	1    5900 2650
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0303
U 1 1 5D80445D
P 5900 1050
F 0 "#PWR0303" H 5900 900 50  0001 C CNN
F 1 "VCC" H 5917 1223 50  0000 C CNN
F 2 "" H 5900 1050 50  0001 C CNN
F 3 "" H 5900 1050 50  0001 C CNN
	1    5900 1050
	1    0    0    -1  
$EndComp
Entry Wire Line
	4100 1550 4200 1450
Entry Wire Line
	4100 1650 4200 1550
Entry Wire Line
	4100 1750 4200 1650
Entry Wire Line
	4100 1850 4200 1750
Wire Wire Line
	4100 1550 3650 1550
Wire Wire Line
	3650 1650 4100 1650
Wire Wire Line
	4100 1750 3650 1750
Wire Wire Line
	3650 1850 4100 1850
Entry Wire Line
	4100 4150 4200 4050
Entry Wire Line
	4100 4250 4200 4150
Entry Wire Line
	4100 4350 4200 4250
Entry Wire Line
	4100 4450 4200 4350
Wire Wire Line
	4100 4150 3650 4150
Wire Wire Line
	3650 4250 4100 4250
Wire Wire Line
	4100 4350 3650 4350
Wire Wire Line
	3650 4450 4100 4450
Text Label 4050 1550 2    50   ~ 0
AluResult0
Text Label 4050 1650 2    50   ~ 0
AluResult1
Text Label 4050 1750 2    50   ~ 0
AluResult2
Text Label 4050 1850 2    50   ~ 0
AluResult3
Text Label 4050 4150 2    50   ~ 0
AluResult4
Text Label 4050 4250 2    50   ~ 0
AluResult5
Text Label 4050 4350 2    50   ~ 0
AluResult6
Text Label 4050 4450 2    50   ~ 0
AluResult7
Entry Wire Line
	4850 1250 4950 1350
Entry Wire Line
	4850 1350 4950 1450
Entry Wire Line
	4850 1450 4950 1550
Entry Wire Line
	4850 1550 4950 1650
Entry Wire Line
	4850 1650 4950 1750
Entry Wire Line
	4850 1750 4950 1850
Entry Wire Line
	4850 1850 4950 1950
Entry Wire Line
	4850 1950 4950 2050
Wire Bus Line
	4200 1150 4850 1150
Wire Wire Line
	4950 1350 5400 1350
Wire Wire Line
	5400 1450 4950 1450
Wire Wire Line
	4950 1550 5400 1550
Wire Wire Line
	5400 1650 4950 1650
Wire Wire Line
	5400 1750 4950 1750
Wire Wire Line
	4950 1850 5400 1850
Wire Wire Line
	5400 1950 4950 1950
Wire Wire Line
	4950 2050 5400 2050
Text Label 5400 1350 2    50   ~ 0
AluResult0
Text Label 5400 1450 2    50   ~ 0
AluResult1
Text Label 5400 1550 2    50   ~ 0
AluResult2
Text Label 5400 1650 2    50   ~ 0
AluResult3
Text Label 5400 1750 2    50   ~ 0
AluResult4
Text Label 5400 1850 2    50   ~ 0
AluResult5
Text Label 5400 1950 2    50   ~ 0
AluResult6
Text Label 5400 2050 2    50   ~ 0
AluResult7
$Comp
L power:VCC #PWR0304
U 1 1 5D7E9918
P 3050 3650
F 0 "#PWR0304" H 3050 3500 50  0001 C CNN
F 1 "VCC" H 3067 3823 50  0000 C CNN
F 2 "" H 3050 3650 50  0001 C CNN
F 3 "" H 3050 3650 50  0001 C CNN
	1    3050 3650
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0305
U 1 1 5D8713D2
P 4450 1000
F 0 "#PWR0305" H 4450 850 50  0001 C CNN
F 1 "VCC" H 4467 1173 50  0000 C CNN
F 2 "" H 4450 1000 50  0001 C CNN
F 3 "" H 4450 1000 50  0001 C CNN
	1    4450 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4450 1000 4450 1950
Wire Wire Line
	4450 2350 3650 2350
Wire Wire Line
	4450 4950 3650 4950
Connection ~ 4450 2350
$Comp
L power:GND #PWR0306
U 1 1 5D87C428
P 5900 6150
F 0 "#PWR0306" H 5900 5900 50  0001 C CNN
F 1 "GND" H 5905 5977 50  0000 C CNN
F 2 "" H 5900 6150 50  0001 C CNN
F 3 "" H 5900 6150 50  0001 C CNN
	1    5900 6150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5400 5750 4850 5750
Wire Wire Line
	4850 5750 4850 6850
Wire Wire Line
	4850 6850 1250 6850
Wire Wire Line
	5400 2350 4750 2350
Wire Wire Line
	4950 5850 5400 5850
Wire Wire Line
	4750 2350 4750 6700
Text GLabel 1250 6700 0    50   Input ~ 0
~EO
Wire Wire Line
	4750 6700 1250 6700
Wire Wire Line
	4450 2350 4450 4950
Wire Wire Line
	5400 4950 4450 4950
Connection ~ 4450 4950
Wire Wire Line
	3650 4850 5400 4850
Wire Wire Line
	4950 7000 4950 5850
Text GLabel 1250 7000 0    50   Input ~ 0
~FI
Wire Wire Line
	1250 7000 4950 7000
Text GLabel 9150 950  2    50   Output ~ 0
~A=B
Text GLabel 9150 750  2    50   Output ~ 0
~CarryOut
Wire Wire Line
	6950 750  9150 750 
Wire Wire Line
	9150 950  7050 950 
Wire Wire Line
	10100 3200 10100 3500
$Comp
L power:GND #PWR?
U 1 1 5D8E51A7
P 10100 3200
AR Path="/5D2C12A5/5D8E51A7" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CE4/5D8E51A7" Ref="#PWR0308"  Part="1" 
F 0 "#PWR0308" H 10100 2950 50  0001 C CNN
F 1 "GND" H 10105 3027 50  0000 C CNN
F 2 "" H 10100 3200 50  0001 C CNN
F 3 "" H 10100 3200 50  0001 C CNN
	1    10100 3200
	-1   0    0    1   
$EndComp
Entry Wire Line
	9400 3050 9300 2950
Wire Wire Line
	9400 3050 9400 3500
Text Label 9400 3450 1    50   ~ 0
AluResult6
Wire Wire Line
	9600 3050 9600 3500
Text Label 9600 3450 1    50   ~ 0
AluResult4
$Comp
L Connector:Conn_01x09_Female J?
U 1 1 5D8E51B2
P 9700 3700
AR Path="/5D29E36D/5D8E51B2" Ref="J?"  Part="1" 
AR Path="/5D2C12A5/5D8E51B2" Ref="J?"  Part="1" 
AR Path="/5D2C0CE4/5D8E51B2" Ref="J10"  Part="1" 
F 0 "J10" V 9850 3650 50  0000 C CNN
F 1 "ALU Result LED Connector" V 9950 3650 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x09_P2.54mm_Vertical" H 9700 3700 50  0001 C CNN
F 3 "~" H 9700 3700 50  0001 C CNN
	1    9700 3700
	0    1    1    0   
$EndComp
Text Label 10000 3450 1    50   ~ 0
AluResult0
Text Label 9900 3450 1    50   ~ 0
AluResult1
Text Label 9800 3450 1    50   ~ 0
AluResult2
Text Label 9700 3450 1    50   ~ 0
AluResult3
Text Label 9500 3450 1    50   ~ 0
AluResult5
Text Label 9300 3450 1    50   ~ 0
AluResult7
Wire Wire Line
	9300 3050 9300 3500
Wire Wire Line
	9500 3050 9500 3500
Wire Wire Line
	9700 3050 9700 3500
Wire Wire Line
	9800 3050 9800 3500
Wire Wire Line
	9900 3050 9900 3500
Wire Wire Line
	10000 3050 10000 3500
Entry Wire Line
	9300 3050 9200 2950
Entry Wire Line
	9500 3050 9400 2950
Entry Wire Line
	10000 3050 9900 2950
Entry Wire Line
	9900 3050 9800 2950
Entry Wire Line
	9800 3050 9700 2950
Entry Wire Line
	9700 3050 9600 2950
Entry Wire Line
	9600 3050 9500 2950
Connection ~ 4200 2950
Wire Wire Line
	4450 2250 4450 2350
$Comp
L Device:R R?
U 1 1 5D8CF661
P 4450 2100
AR Path="/5D2C0CA7/5D8CF661" Ref="R?"  Part="1" 
AR Path="/5D2C0CE4/5D8CF661" Ref="R3"  Part="1" 
F 0 "R3" H 4520 2146 50  0000 L CNN
F 1 "4.7kΩ" H 4520 2055 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 4380 2100 50  0001 C CNN
F 3 "~" H 4450 2100 50  0001 C CNN
	1    4450 2100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5400 5050 5300 5050
Wire Wire Line
	5300 5050 5300 5150
Wire Wire Line
	5300 5550 5400 5550
Wire Wire Line
	5400 5450 5300 5450
Connection ~ 5300 5450
Wire Wire Line
	5300 5450 5300 5550
Wire Wire Line
	5300 5350 5400 5350
Connection ~ 5300 5350
Wire Wire Line
	5300 5350 5300 5450
Wire Wire Line
	5400 5250 5300 5250
Connection ~ 5300 5250
Wire Wire Line
	5300 5250 5300 5350
Wire Wire Line
	5300 5150 5400 5150
Connection ~ 5300 5150
Wire Wire Line
	5300 5150 5300 5250
Text GLabel 850  2750 0    50   Input ~ 0
~CarryIn
Wire Wire Line
	850  2750 2450 2750
$Comp
L power:VCC #PWR0310
U 1 1 5DD31F24
P 5900 4550
F 0 "#PWR0310" H 5900 4400 50  0001 C CNN
F 1 "VCC" H 5917 4723 50  0000 C CNN
F 2 "" H 5900 4550 50  0001 C CNN
F 3 "" H 5900 4550 50  0001 C CNN
	1    5900 4550
	1    0    0    -1  
$EndComp
Text GLabel 1250 6850 0    50   Input ~ 0
ControlClock0
$Comp
L 74xx:74LS574 U?
U 1 1 5E1531EE
P 5900 1850
AR Path="/5D2C14C3/5E1531EE" Ref="U?"  Part="1" 
AR Path="/5D2C0B92/5E1531EE" Ref="U?"  Part="1" 
AR Path="/5D2C0CE4/5E1531EE" Ref="U49"  Part="1" 
F 0 "U49" H 5550 2650 50  0000 C CNN
F 1 "74AHCT574" H 5550 2550 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 5900 1850 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct574.pdf" H 5900 1850 50  0001 C CNN
	1    5900 1850
	1    0    0    -1  
$EndComp
NoConn ~ 6400 5450
NoConn ~ 6400 5550
Wire Wire Line
	5150 5350 5150 5450
$Comp
L power:VCC #PWR0309
U 1 1 5DA97BAF
P 5150 5350
F 0 "#PWR0309" H 5150 5200 50  0001 C CNN
F 1 "VCC" H 5167 5523 50  0000 C CNN
F 2 "" H 5150 5350 50  0001 C CNN
F 3 "" H 5150 5350 50  0001 C CNN
	1    5150 5350
	1    0    0    -1  
$EndComp
Wire Wire Line
	5150 5450 5300 5450
Text Notes 6150 4450 0    50   ~ 0
ALU Flags Register
Wire Wire Line
	9150 5500 9150 5800
$Comp
L power:GND #PWR?
U 1 1 5E22AF33
P 9150 5500
AR Path="/5D2C12A5/5E22AF33" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CE4/5E22AF33" Ref="#PWR0231"  Part="1" 
F 0 "#PWR0231" H 9150 5250 50  0001 C CNN
F 1 "GND" H 9155 5327 50  0000 C CNN
F 2 "" H 9150 5500 50  0001 C CNN
F 3 "" H 9150 5500 50  0001 C CNN
	1    9150 5500
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x09_Female J?
U 1 1 5E22AF3E
P 8750 6000
AR Path="/5D29E36D/5E22AF3E" Ref="J?"  Part="1" 
AR Path="/5D2C12A5/5E22AF3E" Ref="J?"  Part="1" 
AR Path="/5D2C0CE4/5E22AF3E" Ref="J13"  Part="1" 
F 0 "J13" V 8900 5950 50  0000 C CNN
F 1 "ALU Flags LED Connector" V 9000 5950 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x09_P2.54mm_Vertical" H 8750 6000 50  0001 C CNN
F 3 "~" H 8750 6000 50  0001 C CNN
	1    8750 6000
	0    1    1    0   
$EndComp
Wire Wire Line
	8950 4950 8950 5800
Wire Wire Line
	9050 4850 9050 5800
$Comp
L 74xx:74LS377 U?
U 1 1 5D879A71
P 5900 5350
AR Path="/5D2C0CA7/5D879A71" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5D879A71" Ref="U?"  Part="1" 
AR Path="/5D2C0CE4/5D879A71" Ref="U46"  Part="1" 
F 0 "U46" H 5700 6150 50  0000 C CNN
F 1 "74F377" H 5650 6050 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 5900 5350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 5900 5350 50  0001 C CNN
	1    5900 5350
	1    0    0    -1  
$EndComp
NoConn ~ 6400 5350
NoConn ~ 6400 5250
NoConn ~ 6400 5150
NoConn ~ 6400 5050
NoConn ~ 8850 5800
NoConn ~ 8750 5800
NoConn ~ 8650 5800
NoConn ~ 8550 5800
NoConn ~ 8450 5800
NoConn ~ 8350 5800
Wire Wire Line
	6400 4850 6950 4850
Wire Wire Line
	6400 4950 7050 4950
Wire Wire Line
	5400 2250 4850 2250
Wire Wire Line
	4850 2250 4850 5750
Connection ~ 4850 5750
Connection ~ 6950 4850
Wire Wire Line
	6950 750  6950 4850
Wire Wire Line
	6950 4850 9050 4850
Connection ~ 7050 4950
Wire Wire Line
	7050 950  7050 4950
Wire Wire Line
	7050 4950 8950 4950
Text Notes 6050 1100 0    50   ~ 0
ALU Results Latch
Wire Bus Line
	2150 1250 2150 1550
Wire Bus Line
	2150 1650 2150 1950
Wire Bus Line
	2150 4250 2150 4550
Wire Bus Line
	2150 3850 2150 4150
Wire Bus Line
	4200 2950 4200 4350
Wire Bus Line
	4200 1150 4200 2950
Wire Bus Line
	2150 4650 2150 5150
Wire Bus Line
	2150 2050 2150 2550
Wire Bus Line
	4200 2950 9900 2950
Wire Bus Line
	4850 1150 4850 1950
Wire Bus Line
	6850 600  6850 1950
$EndSCHEMATC
