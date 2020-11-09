EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 13 21
Title "Bus Display"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L power:GND #PWR0193
U 1 1 5D7E5A44
P 5550 3250
F 0 "#PWR0193" H 5550 3000 50  0001 C CNN
F 1 "GND" H 5555 3077 50  0000 C CNN
F 2 "" H 5550 3250 50  0001 C CNN
F 3 "" H 5550 3250 50  0001 C CNN
	1    5550 3250
	1    0    0    -1  
$EndComp
Text GLabel 3700 2200 0    50   Input ~ 0
DataBus[0..7]
Entry Wire Line
	5150 2300 5050 2200
Entry Wire Line
	5250 2300 5150 2200
Entry Wire Line
	5350 2300 5250 2200
Entry Wire Line
	5050 2300 4950 2200
Entry Wire Line
	4950 2300 4850 2200
Entry Wire Line
	4850 2300 4750 2200
Text Label 4850 2650 1    50   ~ 0
DataBus7
Text Label 4950 2650 1    50   ~ 0
DataBus6
Text Label 5050 2650 1    50   ~ 0
DataBus5
Text Label 5150 2650 1    50   ~ 0
DataBus4
Text Label 5250 2650 1    50   ~ 0
DataBus3
Text Label 5350 2650 1    50   ~ 0
DataBus2
Text Notes 4300 3250 0    50   ~ 0
Data Bus Pull-down Resistors
Wire Wire Line
	5550 3150 5550 3250
Wire Wire Line
	6850 2450 6850 2650
$Comp
L power:GND #PWR0195
U 1 1 5D8AA8B4
P 6850 2450
F 0 "#PWR0195" H 6850 2200 50  0001 C CNN
F 1 "GND" H 6855 2277 50  0000 C CNN
F 2 "" H 6850 2450 50  0001 C CNN
F 3 "" H 6850 2450 50  0001 C CNN
	1    6850 2450
	-1   0    0    1   
$EndComp
Entry Wire Line
	6150 2300 6050 2200
Wire Wire Line
	6150 2300 6150 2650
Text Label 6150 2650 1    50   ~ 0
DataBus6
Wire Wire Line
	6350 2300 6350 2650
Text Label 6350 2650 1    50   ~ 0
DataBus4
$Comp
L Connector:Conn_01x09_Female J?
U 1 1 5D870367
P 6450 2850
AR Path="/5D29E36D/5D870367" Ref="J?"  Part="1" 
AR Path="/5D2C12A5/5D870367" Ref="J12"  Part="1" 
F 0 "J12" V 6600 2800 50  0000 C CNN
F 1 "Data Bus LED Connector" V 6700 2800 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x09_P2.54mm_Vertical" H 6450 2850 50  0001 C CNN
F 3 "~" H 6450 2850 50  0001 C CNN
	1    6450 2850
	0    1    1    0   
$EndComp
Text Label 6750 2650 1    50   ~ 0
DataBus0
Text Label 6650 2650 1    50   ~ 0
DataBus1
Text Label 6550 2650 1    50   ~ 0
DataBus2
Text Label 6450 2650 1    50   ~ 0
DataBus3
Text Label 6250 2650 1    50   ~ 0
DataBus5
Text Label 6050 2650 1    50   ~ 0
DataBus7
Wire Wire Line
	6050 2300 6050 2650
Wire Wire Line
	6250 2300 6250 2650
Wire Wire Line
	6450 2300 6450 2650
Wire Wire Line
	6550 2300 6550 2650
Wire Wire Line
	6650 2300 6650 2650
Wire Wire Line
	6750 2300 6750 2650
Entry Wire Line
	6050 2300 5950 2200
Entry Wire Line
	6250 2300 6150 2200
Entry Wire Line
	6750 2300 6650 2200
Entry Wire Line
	6650 2300 6550 2200
Entry Wire Line
	6550 2300 6450 2200
Entry Wire Line
	6450 2300 6350 2200
Entry Wire Line
	6350 2300 6250 2200
Text Label 5550 2650 1    50   ~ 0
DataBus0
Text Label 5450 2650 1    50   ~ 0
DataBus1
Entry Wire Line
	5550 2300 5450 2200
Entry Wire Line
	5450 2300 5350 2200
$Comp
L Device:R_Network08 RN1
U 1 1 5D8F8D59
P 5150 2950
F 0 "RN1" H 4670 2904 50  0000 R CNN
F 1 "1kΩ" H 4670 2995 50  0000 R CNN
F 2 "Resistor_THT:R_Array_SIP9" V 5625 2950 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 5150 2950 50  0001 C CNN
	1    5150 2950
	-1   0    0    1   
$EndComp
Wire Wire Line
	5550 2300 5550 2750
Wire Wire Line
	5450 2750 5450 2300
Wire Wire Line
	5350 2300 5350 2750
Wire Wire Line
	5250 2750 5250 2300
Wire Wire Line
	5150 2300 5150 2750
Wire Wire Line
	5050 2750 5050 2300
Wire Wire Line
	4950 2300 4950 2750
Wire Wire Line
	4850 2750 4850 2300
$Comp
L Device:C C?
U 1 1 5E04BCE9
P 4950 4800
AR Path="/5D2C0761/5E04BCE9" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E04BCE9" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E04BCE9" Ref="C58"  Part="1" 
F 0 "C58" H 5065 4846 50  0000 L CNN
F 1 "100pF" H 5065 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 4988 4650 50  0001 C CNN
F 3 "~" H 4950 4800 50  0001 C CNN
	1    4950 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E04BCEF
P 4950 4400
AR Path="/5D2C0720/5E04BCEF" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E04BCEF" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E04BCEF" Ref="R9"  Part="1" 
F 0 "R9" H 5018 4446 50  0000 L CNN
F 1 "51Ω" H 5018 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 4990 4390 50  0001 C CNN
F 3 "~" H 4950 4400 50  0001 C CNN
	1    4950 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 4550 4950 4650
$Comp
L power:GND #PWR?
U 1 1 5E04BCF6
P 4950 5150
AR Path="/5D2C0761/5E04BCF6" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E04BCF6" Ref="#PWR?"  Part="1" 
AR Path="/5D2C12A5/5E04BCF6" Ref="#PWR0313"  Part="1" 
F 0 "#PWR0313" H 4950 4900 50  0001 C CNN
F 1 "GND" H 4955 4977 50  0000 C CNN
F 2 "" H 4950 5150 50  0001 C CNN
F 3 "" H 4950 5150 50  0001 C CNN
	1    4950 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 4950 4950 5050
Entry Wire Line
	5350 3800 5450 3700
Text Label 5350 4150 1    50   ~ 0
DataBus6
Text Label 6150 4150 1    50   ~ 0
DataBus4
Text Label 7750 4150 1    50   ~ 0
DataBus0
Text Label 7350 4150 1    50   ~ 0
DataBus1
Text Label 6950 4150 1    50   ~ 0
DataBus2
Text Label 6550 4150 1    50   ~ 0
DataBus3
Text Label 5750 4150 1    50   ~ 0
DataBus5
Text Label 4950 4150 1    50   ~ 0
DataBus7
Entry Wire Line
	4950 3800 5050 3700
Entry Wire Line
	5750 3800 5850 3700
Entry Wire Line
	7750 3800 7850 3700
Entry Wire Line
	7350 3800 7450 3700
Entry Wire Line
	6950 3800 7050 3700
Entry Wire Line
	6550 3800 6650 3700
Entry Wire Line
	6150 3800 6250 3700
Wire Wire Line
	4950 3800 4950 4250
$Comp
L Device:C C?
U 1 1 5E05807D
P 5350 4800
AR Path="/5D2C0761/5E05807D" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E05807D" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E05807D" Ref="C59"  Part="1" 
F 0 "C59" H 5465 4846 50  0000 L CNN
F 1 "100pF" H 5465 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 5388 4650 50  0001 C CNN
F 3 "~" H 5350 4800 50  0001 C CNN
	1    5350 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E058083
P 5350 4400
AR Path="/5D2C0720/5E058083" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E058083" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E058083" Ref="R10"  Part="1" 
F 0 "R10" H 5418 4446 50  0000 L CNN
F 1 "51Ω" H 5418 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 5390 4390 50  0001 C CNN
F 3 "~" H 5350 4400 50  0001 C CNN
	1    5350 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 4550 5350 4650
Wire Wire Line
	5350 4950 5350 5050
$Comp
L Device:C C?
U 1 1 5E059945
P 5750 4800
AR Path="/5D2C0761/5E059945" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E059945" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E059945" Ref="C60"  Part="1" 
F 0 "C60" H 5865 4846 50  0000 L CNN
F 1 "100pF" H 5865 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 5788 4650 50  0001 C CNN
F 3 "~" H 5750 4800 50  0001 C CNN
	1    5750 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E05994B
P 5750 4400
AR Path="/5D2C0720/5E05994B" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E05994B" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E05994B" Ref="R11"  Part="1" 
F 0 "R11" H 5818 4446 50  0000 L CNN
F 1 "51Ω" H 5818 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 5790 4390 50  0001 C CNN
F 3 "~" H 5750 4400 50  0001 C CNN
	1    5750 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5750 4550 5750 4650
Wire Wire Line
	5750 4950 5750 5050
$Comp
L Device:C C?
U 1 1 5E05A8A7
P 6150 4800
AR Path="/5D2C0761/5E05A8A7" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E05A8A7" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E05A8A7" Ref="C61"  Part="1" 
F 0 "C61" H 6265 4846 50  0000 L CNN
F 1 "100pF" H 6265 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 6188 4650 50  0001 C CNN
F 3 "~" H 6150 4800 50  0001 C CNN
	1    6150 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E05A8AD
P 6150 4400
AR Path="/5D2C0720/5E05A8AD" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E05A8AD" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E05A8AD" Ref="R12"  Part="1" 
F 0 "R12" H 6218 4446 50  0000 L CNN
F 1 "51Ω" H 6218 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6190 4390 50  0001 C CNN
F 3 "~" H 6150 4400 50  0001 C CNN
	1    6150 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6150 4550 6150 4650
Wire Wire Line
	6150 4950 6150 5050
$Comp
L Device:C C?
U 1 1 5E060D31
P 6550 4800
AR Path="/5D2C0761/5E060D31" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E060D31" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E060D31" Ref="C62"  Part="1" 
F 0 "C62" H 6665 4846 50  0000 L CNN
F 1 "100pF" H 6665 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 6588 4650 50  0001 C CNN
F 3 "~" H 6550 4800 50  0001 C CNN
	1    6550 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E060D37
P 6550 4400
AR Path="/5D2C0720/5E060D37" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E060D37" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E060D37" Ref="R13"  Part="1" 
F 0 "R13" H 6618 4446 50  0000 L CNN
F 1 "51Ω" H 6618 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6590 4390 50  0001 C CNN
F 3 "~" H 6550 4400 50  0001 C CNN
	1    6550 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 4550 6550 4650
Wire Wire Line
	6550 4950 6550 5050
$Comp
L Device:C C?
U 1 1 5E060D45
P 6950 4800
AR Path="/5D2C0761/5E060D45" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E060D45" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E060D45" Ref="C63"  Part="1" 
F 0 "C63" H 7065 4846 50  0000 L CNN
F 1 "100pF" H 7065 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 6988 4650 50  0001 C CNN
F 3 "~" H 6950 4800 50  0001 C CNN
	1    6950 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E060D4B
P 6950 4400
AR Path="/5D2C0720/5E060D4B" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E060D4B" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E060D4B" Ref="R14"  Part="1" 
F 0 "R14" H 7018 4446 50  0000 L CNN
F 1 "51Ω" H 7018 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6990 4390 50  0001 C CNN
F 3 "~" H 6950 4400 50  0001 C CNN
	1    6950 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6950 4550 6950 4650
Wire Wire Line
	6950 4950 6950 5050
$Comp
L Device:C C?
U 1 1 5E060D59
P 7350 4800
AR Path="/5D2C0761/5E060D59" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E060D59" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E060D59" Ref="C64"  Part="1" 
F 0 "C64" H 7465 4846 50  0000 L CNN
F 1 "100pF" H 7465 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 7388 4650 50  0001 C CNN
F 3 "~" H 7350 4800 50  0001 C CNN
	1    7350 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E060D5F
P 7350 4400
AR Path="/5D2C0720/5E060D5F" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E060D5F" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E060D5F" Ref="R15"  Part="1" 
F 0 "R15" H 7418 4446 50  0000 L CNN
F 1 "51Ω" H 7418 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7390 4390 50  0001 C CNN
F 3 "~" H 7350 4400 50  0001 C CNN
	1    7350 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7350 4550 7350 4650
Wire Wire Line
	7350 4950 7350 5050
$Comp
L Device:C C?
U 1 1 5E060D6D
P 7750 4800
AR Path="/5D2C0761/5E060D6D" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E060D6D" Ref="C?"  Part="1" 
AR Path="/5D2C12A5/5E060D6D" Ref="C65"  Part="1" 
F 0 "C65" H 7865 4846 50  0000 L CNN
F 1 "100pF" H 7865 4755 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 7788 4650 50  0001 C CNN
F 3 "~" H 7750 4800 50  0001 C CNN
	1    7750 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5E060D73
P 7750 4400
AR Path="/5D2C0720/5E060D73" Ref="R?"  Part="1" 
AR Path="/5D2C0761/5E060D73" Ref="R?"  Part="1" 
AR Path="/5D2C12A5/5E060D73" Ref="R16"  Part="1" 
F 0 "R16" H 7818 4446 50  0000 L CNN
F 1 "51Ω" H 7818 4355 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7790 4390 50  0001 C CNN
F 3 "~" H 7750 4400 50  0001 C CNN
	1    7750 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 4550 7750 4650
Wire Wire Line
	7750 4950 7750 5050
Wire Wire Line
	7750 3800 7750 4250
Wire Wire Line
	7350 3800 7350 4250
Wire Wire Line
	6950 3800 6950 4250
Wire Wire Line
	6550 3800 6550 4250
Wire Wire Line
	6150 3800 6150 4250
Wire Wire Line
	5750 3800 5750 4250
Wire Wire Line
	5350 3800 5350 4250
Wire Wire Line
	4950 5050 5350 5050
Connection ~ 4950 5050
Wire Wire Line
	4950 5050 4950 5150
Connection ~ 5350 5050
Wire Wire Line
	5350 5050 5750 5050
Connection ~ 5750 5050
Wire Wire Line
	5750 5050 6150 5050
Connection ~ 6150 5050
Wire Wire Line
	6150 5050 6550 5050
Connection ~ 6550 5050
Wire Wire Line
	6550 5050 6950 5050
Connection ~ 6950 5050
Wire Wire Line
	6950 5050 7350 5050
Connection ~ 7350 5050
Wire Wire Line
	7350 5050 7750 5050
Wire Bus Line
	8200 2200 8200 3700
Text Notes 5500 5300 0    50   ~ 0
AC termination of the data bus.
Wire Bus Line
	5050 3700 8200 3700
Wire Bus Line
	3700 2200 8200 2200
$EndSCHEMATC
