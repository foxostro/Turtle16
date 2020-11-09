EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 19 21
Title "Clock"
Date ""
Rev ""
Comp ""
Comment1 "On reset, pulse the control clock quickly to clear the pipeline."
Comment2 "The enable pin permits us to use a control signal to halt the clock."
Comment3 "Create the inverted clock with a 74x138 decoder."
Comment4 "Use a simple crystal oscillator for the clock."
$EndDescr
$Comp
L power:GND #PWR?
U 1 1 5E153BD2
P 1950 6150
AR Path="/5D2C0CA7/5E153BD2" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5E153BD2" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BD2" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BD2" Ref="#PWR0283"  Part="1" 
F 0 "#PWR0283" H 1950 5900 50  0001 C CNN
F 1 "GND" V 1950 5950 50  0000 C CNN
F 2 "" H 1950 6150 50  0001 C CNN
F 3 "" H 1950 6150 50  0001 C CNN
	1    1950 6150
	0    1    1    0   
$EndComp
Wire Wire Line
	1950 6150 2000 6150
Wire Wire Line
	2000 6100 2000 6150
Connection ~ 2000 6150
Wire Wire Line
	2000 6150 2000 6200
Wire Wire Line
	1150 5800 1150 5850
$Comp
L power:GND #PWR0286
U 1 1 5D888695
P 1150 5850
F 0 "#PWR0286" H 1150 5600 50  0001 C CNN
F 1 "GND" H 1155 5677 50  0000 C CNN
F 2 "" H 1150 5850 50  0001 C CNN
F 3 "" H 1150 5850 50  0001 C CNN
	1    1150 5850
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0287
U 1 1 5E0F85C8
P 1150 5150
F 0 "#PWR0287" H 1150 5000 50  0001 C CNN
F 1 "VCC" H 1167 5323 50  0000 C CNN
F 2 "" H 1150 5150 50  0001 C CNN
F 3 "" H 1150 5150 50  0001 C CNN
	1    1150 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1150 5150 1150 5200
$Comp
L Oscillator:ACO-xxxMHz OSC1
U 1 1 5D387BCA
P 1150 5500
F 0 "OSC1" H 807 5546 50  0000 R CNN
F 1 "16MHz" H 807 5455 50  0000 R CNN
F 2 "Oscillator:Oscillator_DIP-14" H 1600 5150 50  0001 C CNN
F 3 "http://www.conwin.com/datasheets/cx/cx030.pdf" H 1050 5500 50  0001 C CNN
	1    1150 5500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E153BDF
P 1950 5650
AR Path="/5D2C0CA7/5E153BDF" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5E153BDF" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BDF" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BDF" Ref="#PWR0288"  Part="1" 
F 0 "#PWR0288" H 1950 5400 50  0001 C CNN
F 1 "GND" V 1950 5450 50  0000 C CNN
F 2 "" H 1950 5650 50  0001 C CNN
F 3 "" H 1950 5650 50  0001 C CNN
	1    1950 5650
	0    1    1    0   
$EndComp
Wire Wire Line
	1950 5650 2000 5650
Wire Wire Line
	2000 5600 2000 5650
Connection ~ 2000 5650
Wire Wire Line
	2000 5650 2000 5700
Wire Wire Line
	3050 5500 3150 5500
Wire Wire Line
	2550 5150 2550 5200
NoConn ~ 3050 6200
NoConn ~ 3050 6100
NoConn ~ 3050 6000
NoConn ~ 3050 5900
NoConn ~ 3050 5800
NoConn ~ 3050 5700
Wire Wire Line
	2050 5600 2000 5600
Wire Wire Line
	2000 5700 2050 5700
Wire Wire Line
	2550 6500 2550 6600
$Comp
L 74xx:74LS138 U?
U 1 1 5E153BCA
P 2550 5800
AR Path="/5D29E36D/5E153BCA" Ref="U?"  Part="1" 
AR Path="/5DAA13E6/5E153BCA" Ref="U?"  Part="1" 
AR Path="/5D2C0720/5E153BCA" Ref="U41"  Part="1" 
F 0 "U41" H 2250 6400 50  0000 C CNN
F 1 "74AHCT138" H 2250 6300 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 2550 5800 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct138.pdf" H 2550 5800 50  0001 C CNN
	1    2550 5800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E153BC4
P 2550 5150
AR Path="/5D29E36D/5E153BC4" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BC4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BC4" Ref="#PWR0149"  Part="1" 
F 0 "#PWR0149" H 2550 5000 50  0001 C CNN
F 1 "VCC" H 2567 5323 50  0000 C CNN
F 2 "" H 2550 5150 50  0001 C CNN
F 3 "" H 2550 5150 50  0001 C CNN
	1    2550 5150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E153BBE
P 2550 6600
AR Path="/5D2C0CA7/5E153BBE" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5E153BBE" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BBE" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BBE" Ref="#PWR0148"  Part="1" 
F 0 "#PWR0148" H 2550 6350 50  0001 C CNN
F 1 "GND" H 2555 6427 50  0000 C CNN
F 2 "" H 2550 6600 50  0001 C CNN
F 3 "" H 2550 6600 50  0001 C CNN
	1    2550 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2050 6100 2000 6100
Wire Wire Line
	2000 6200 2050 6200
Wire Wire Line
	1700 6000 2050 6000
Text GLabel 1700 6000 0    50   Input ~ 0
~HLT
$Comp
L Power_Supervisor:MCP100-450D U?
U 1 1 5DEC3D1A
P 2600 1950
AR Path="/5D2C0761/5DEC3D1A" Ref="U?"  Part="1" 
AR Path="/5D2C0720/5DEC3D1A" Ref="U51"  Part="1" 
F 0 "U51" H 2371 1996 50  0000 R CNN
F 1 "MCP100-450D" H 2371 1905 50  0000 R CNN
F 2 "Package_TO_SOT_THT:TO-92" H 2200 2100 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/11187f.pdf" H 2300 2200 50  0001 C CNN
	1    2600 1950
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5DEC3D20
P 1450 800
AR Path="/5D2C0761/5DEC3D20" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3D20" Ref="#PWR0155"  Part="1" 
F 0 "#PWR0155" H 1450 650 50  0001 C CNN
F 1 "VCC" H 1467 973 50  0000 C CNN
F 2 "" H 1450 800 50  0001 C CNN
F 3 "" H 1450 800 50  0001 C CNN
	1    1450 800 
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R1
U 1 1 5DEC3D32
P 1450 1050
AR Path="/5D2C0720/5DEC3D32" Ref="R1"  Part="1" 
AR Path="/5D2C0761/5DEC3D32" Ref="R?"  Part="1" 
F 0 "R1" H 1518 1096 50  0000 L CNN
F 1 "1kΩ" H 1518 1005 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 1450 1050 50  0001 C CNN
F 3 "~" H 1450 1050 50  0001 C CNN
	1    1450 1050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 1 1 5DEC3D6C
P 3850 5850
AR Path="/5D2C0761/5DEC3D6C" Ref="U?"  Part="1" 
AR Path="/5D2C0720/5DEC3D6C" Ref="U29"  Part="1" 
F 0 "U29" H 3850 6167 50  0000 C CNN
F 1 "74AHCT04" H 3850 6076 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 3850 5850 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 3850 5850 50  0001 C CNN
	1    3850 5850
	1    0    0    -1  
$EndComp
$Comp
L Device:R R6
U 1 1 5DEC3D7D
P 3750 2850
AR Path="/5D2C0720/5DEC3D7D" Ref="R6"  Part="1" 
AR Path="/5D2C0761/5DEC3D7D" Ref="R?"  Part="1" 
F 0 "R6" H 3818 2896 50  0000 L CNN
F 1 "220Ω" H 3818 2805 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3790 2840 50  0001 C CNN
F 3 "~" H 3750 2850 50  0001 C CNN
	1    3750 2850
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D2
U 1 1 5DEC3D83
P 3750 2500
AR Path="/5D2C0720/5DEC3D83" Ref="D2"  Part="1" 
AR Path="/5D2C0761/5DEC3D83" Ref="D?"  Part="1" 
F 0 "D2" V 3789 2383 50  0000 R CNN
F 1 "Reset" V 3698 2383 50  0000 R CNN
F 2 "LED_THT:LED_D5.0mm" H 3750 2500 50  0001 C CNN
F 3 "~" H 3750 2500 50  0001 C CNN
	1    3750 2500
	0    -1   -1   0   
$EndComp
Text GLabel 10250 1950 2    50   Output ~ 0
~RST
$Comp
L power:VCC #PWR?
U 1 1 5DEC3D90
P 6350 2450
AR Path="/5D2C0761/5DEC3D90" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3D90" Ref="#PWR0159"  Part="1" 
F 0 "#PWR0159" H 6350 2300 50  0001 C CNN
F 1 "VCC" H 6367 2623 50  0000 C CNN
F 2 "" H 6350 2450 50  0001 C CNN
F 3 "" H 6350 2450 50  0001 C CNN
	1    6350 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 2450 6350 2500
$Comp
L power:GND #PWR0160
U 1 1 5DEC3D97
P 6350 4500
AR Path="/5D2C0720/5DEC3D97" Ref="#PWR0160"  Part="1" 
AR Path="/5D2C0761/5DEC3D97" Ref="#PWR?"  Part="1" 
F 0 "#PWR0160" H 6350 4250 50  0001 C CNN
F 1 "GND" H 6355 4327 50  0000 C CNN
F 2 "" H 6350 4500 50  0001 C CNN
F 3 "" H 6350 4500 50  0001 C CNN
	1    6350 4500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 4400 6350 4450
Wire Wire Line
	5850 4100 5750 4100
Wire Wire Line
	5750 4100 5750 4450
Wire Wire Line
	5750 4450 6350 4450
Connection ~ 6350 4450
Wire Wire Line
	6350 4450 6350 4500
Wire Wire Line
	5100 2800 5850 2800
Wire Wire Line
	5850 2900 5150 2900
Wire Wire Line
	6850 2800 7650 2800
Wire Wire Line
	3750 3150 3750 3250
$Comp
L power:GND #PWR?
U 1 1 5DEC3DB4
P 3750 3250
AR Path="/5D2C0761/5DEC3DB4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3DB4" Ref="#PWR0161"  Part="1" 
F 0 "#PWR0161" H 3750 3000 50  0001 C CNN
F 1 "GND" H 3755 3077 50  0000 C CNN
F 2 "" H 3750 3250 50  0001 C CNN
F 3 "" H 3750 3250 50  0001 C CNN
	1    3750 3250
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DBA
P 5300 1000
AR Path="/5D2C0761/5DEC3DBA" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DBA" Ref="C28"  Part="1" 
F 0 "C28" H 5415 1046 50  0000 L CNN
F 1 "100nF" H 5415 955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 5338 850 50  0001 C CNN
F 3 "~" H 5300 1000 50  0001 C CNN
	1    5300 1000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DC0
P 5800 1000
AR Path="/5D2C0761/5DEC3DC0" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DC0" Ref="C32"  Part="1" 
F 0 "C32" H 5915 1046 50  0000 L CNN
F 1 "100nF" H 5915 955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 5838 850 50  0001 C CNN
F 3 "~" H 5800 1000 50  0001 C CNN
	1    5800 1000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DC6
P 6300 1000
AR Path="/5D2C0761/5DEC3DC6" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DC6" Ref="C52"  Part="1" 
F 0 "C52" H 6415 1046 50  0000 L CNN
F 1 "100nF" H 6415 955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 6338 850 50  0001 C CNN
F 3 "~" H 6300 1000 50  0001 C CNN
	1    6300 1000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DCC
P 6800 1000
AR Path="/5D2C0761/5DEC3DCC" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DCC" Ref="C53"  Part="1" 
F 0 "C53" H 6915 1046 50  0000 L CNN
F 1 "100nF" H 6915 955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 6838 850 50  0001 C CNN
F 3 "~" H 6800 1000 50  0001 C CNN
	1    6800 1000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5DEC3DD2
P 5300 1150
AR Path="/5D2C0761/5DEC3DD2" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3DD2" Ref="#PWR0162"  Part="1" 
F 0 "#PWR0162" H 5300 900 50  0001 C CNN
F 1 "GND" H 5305 977 50  0000 C CNN
F 2 "" H 5300 1150 50  0001 C CNN
F 3 "" H 5300 1150 50  0001 C CNN
	1    5300 1150
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5DEC3DD8
P 5300 850
AR Path="/5D2C0761/5DEC3DD8" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3DD8" Ref="#PWR0179"  Part="1" 
F 0 "#PWR0179" H 5300 700 50  0001 C CNN
F 1 "VCC" H 5317 1023 50  0000 C CNN
F 2 "" H 5300 850 50  0001 C CNN
F 3 "" H 5300 850 50  0001 C CNN
	1    5300 850 
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 850  5800 850 
Connection ~ 5300 850 
Wire Wire Line
	5800 850  6300 850 
Connection ~ 5800 850 
Wire Wire Line
	6300 850  6800 850 
Connection ~ 6300 850 
Wire Wire Line
	6800 1150 6300 1150
Wire Wire Line
	6300 1150 5800 1150
Connection ~ 6300 1150
Wire Wire Line
	5800 1150 5300 1150
Connection ~ 5800 1150
Connection ~ 5300 1150
$Comp
L 74xx:74LS157 U?
U 1 1 5DEC3DF0
P 6350 3400
AR Path="/5D2C0761/5DEC3DF0" Ref="U?"  Part="1" 
AR Path="/5D2C0720/5DEC3DF0" Ref="U52"  Part="1" 
F 0 "U52" H 6550 4300 50  0000 C CNN
F 1 "74AHCT157" H 6550 4200 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 6350 3400 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct157.pdf" H 6350 3400 50  0001 C CNN
	1    6350 3400
	1    0    0    -1  
$EndComp
NoConn ~ 6850 3400
NoConn ~ 6850 3700
Wire Wire Line
	5650 3600 5750 3600
Wire Wire Line
	5850 3800 5750 3800
Wire Wire Line
	5750 3800 5750 3700
Connection ~ 5750 3700
Wire Wire Line
	5850 3700 5750 3700
Wire Wire Line
	5750 3700 5750 3600
Connection ~ 5750 3500
Wire Wire Line
	5850 3500 5750 3500
Wire Wire Line
	5750 3500 5750 3400
Wire Wire Line
	5850 3400 5750 3400
Text GLabel 8900 2800 2    50   Output ~ 0
ControlClock0
Text GLabel 5350 5850 2    50   Output ~ 0
RegisterClock0
Text Notes 5800 700  0    50   ~ 0
Decoupling caps
Wire Wire Line
	1450 5500 1700 5500
Connection ~ 1700 5500
Wire Wire Line
	1700 5500 2050 5500
$Comp
L 74xx:74LS04 U?
U 7 1 5DFDD43F
P -2350 3500
AR Path="/5D2C0761/5DFDD43F" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5DFDD43F" Ref="U29"  Part="7" 
F 0 "U29" H -2750 3850 50  0000 C CNN
F 1 "74AHCT04" H -2750 3750 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -2350 3500 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -2350 3500 50  0001 C CNN
	7    -2350 3500
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5DFDD44B
P -3200 2850
AR Path="/5D2C0761/5DFDD44B" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DFDD44B" Ref="#PWR0284"  Part="1" 
F 0 "#PWR0284" H -3200 2700 50  0001 C CNN
F 1 "VCC" H -3183 3023 50  0000 C CNN
F 2 "" H -3200 2850 50  0001 C CNN
F 3 "" H -3200 2850 50  0001 C CNN
	1    -3200 2850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0285
U 1 1 5DFDD451
P -2350 4150
AR Path="/5D2C0720/5DFDD451" Ref="#PWR0285"  Part="1" 
AR Path="/5D2C0761/5DFDD451" Ref="#PWR?"  Part="1" 
F 0 "#PWR0285" H -2350 3900 50  0001 C CNN
F 1 "GND" H -2345 3977 50  0000 C CNN
F 2 "" H -2350 4150 50  0001 C CNN
F 3 "" H -2350 4150 50  0001 C CNN
	1    -2350 4150
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-2350 4000 -2350 4100
Wire Wire Line
	-2350 4100 -2350 4150
Wire Wire Line
	-3200 2850 -3200 2950
Wire Wire Line
	-2350 2950 -2350 3000
$Comp
L 74xx:74LS04 U?
U 4 1 5DFDD463
P 8050 3300
AR Path="/5D2C0761/5DFDD463" Ref="U?"  Part="4" 
AR Path="/5D2C0720/5DFDD463" Ref="U29"  Part="4" 
F 0 "U29" H 8050 3617 50  0000 C CNN
F 1 "74AHCT04" H 8050 3526 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 8050 3300 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 8050 3300 50  0001 C CNN
	4    8050 3300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5DFDD469
P -1250 4850
AR Path="/5D2C0761/5DFDD469" Ref="U?"  Part="5" 
AR Path="/5D2C0720/5DFDD469" Ref="U29"  Part="5" 
F 0 "U29" H -1250 5167 50  0000 C CNN
F 1 "74AHCT04" H -1250 5076 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -1250 4850 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -1250 4850 50  0001 C CNN
	5    -1250 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 3300 7650 3300
Wire Wire Line
	7650 3300 7650 2800
Connection ~ 7650 2800
Wire Wire Line
	7650 2800 7750 2800
Wire Wire Line
	7750 3800 7650 3800
Wire Wire Line
	7650 3800 7650 3300
Text GLabel 8900 3300 2    50   Output ~ 0
ControlClock1
Wire Wire Line
	8900 3300 8350 3300
Wire Wire Line
	8350 2800 8900 2800
Wire Wire Line
	5350 5850 4150 5850
Text GLabel 8900 3800 2    50   Output ~ 0
ControlClock2
Wire Wire Line
	8900 3800 8350 3800
Connection ~ 7650 3300
$Comp
L 74xx:74LS04 U?
U 2 1 5E278D12
P 8050 4300
AR Path="/5D8005AF/5D800744/5E278D12" Ref="U?"  Part="2" 
AR Path="/5D2C0720/5E278D12" Ref="U4"  Part="2" 
F 0 "U4" H 8050 4617 50  0000 C CNN
F 1 "74AHCT04" H 8050 4526 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 8050 4300 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 8050 4300 50  0001 C CNN
	2    8050 4300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5E278D18
P 8050 4850
AR Path="/5D8005AF/5D800744/5E278D18" Ref="U?"  Part="3" 
AR Path="/5D2C0720/5E278D18" Ref="U4"  Part="3" 
F 0 "U4" H 8050 5167 50  0000 C CNN
F 1 "74AHCT04" H 8050 5076 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 8050 4850 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 8050 4850 50  0001 C CNN
	3    8050 4850
	1    0    0    -1  
$EndComp
Text GLabel 8900 4300 2    50   Output ~ 0
ControlClock3
Wire Wire Line
	8900 4300 8350 4300
Text GLabel 8900 4850 2    50   Output ~ 0
ControlClock4
Wire Wire Line
	8900 4850 8350 4850
Wire Wire Line
	7650 3800 7650 4300
Wire Wire Line
	7650 4300 7750 4300
Connection ~ 7650 3800
Wire Wire Line
	7650 4300 7650 4850
Wire Wire Line
	7650 4850 7750 4850
Connection ~ 7650 4300
$Comp
L 74xx:74LS04 U?
U 4 1 5E2C3DD8
P -1250 5350
AR Path="/5D8005AF/5D800744/5E2C3DD8" Ref="U?"  Part="4" 
AR Path="/5D2C0720/5E2C3DD8" Ref="U4"  Part="4" 
F 0 "U4" H -1250 5667 50  0000 C CNN
F 1 "74AHCT04" H -1250 5576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -1250 5350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -1250 5350 50  0001 C CNN
	4    -1250 5350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5E2C3DDE
P 3850 6350
AR Path="/5D8005AF/5D800744/5E2C3DDE" Ref="U?"  Part="5" 
AR Path="/5D2C0720/5E2C3DDE" Ref="U4"  Part="5" 
F 0 "U4" H 3850 6667 50  0000 C CNN
F 1 "74AHCT04" H 3850 6576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 3850 6350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 3850 6350 50  0001 C CNN
	5    3850 6350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5E2C3DE4
P 3850 6850
AR Path="/5D8005AF/5D800744/5E2C3DE4" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E2C3DE4" Ref="U4"  Part="6" 
F 0 "U4" H 3850 7167 50  0000 C CNN
F 1 "74AHCT04" H 3850 7076 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 3850 6850 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 3850 6850 50  0001 C CNN
	6    3850 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1550 5350 -1650 5350
Wire Wire Line
	3550 6350 3450 6350
Wire Wire Line
	3550 6850 3450 6850
Wire Wire Line
	3450 6850 3450 6350
Text GLabel 5350 6350 2    50   Output ~ 0
RegisterClock2
Wire Wire Line
	5350 6350 4150 6350
Text GLabel 5350 6850 2    50   Output ~ 0
RegisterClock3
Wire Wire Line
	-3200 3050 -3200 2950
Wire Wire Line
	-3200 2950 -2350 2950
Wire Wire Line
	-3200 4050 -3200 4100
Wire Wire Line
	-3200 4100 -2350 4100
Connection ~ -2350 4100
Connection ~ 3450 6350
Wire Wire Line
	3550 5850 3450 5850
Wire Wire Line
	3450 6850 3450 7350
Connection ~ 3450 6850
Wire Wire Line
	3450 5350 3550 5350
Text GLabel 5350 7350 2    50   Output ~ 0
RegisterClock4
Wire Wire Line
	4150 6850 5350 6850
Wire Wire Line
	4150 7350 5350 7350
Text GLabel 5350 5350 2    50   Output ~ 0
RegisterClock1
Wire Wire Line
	4150 5350 5350 5350
$Comp
L 74xx:74LS04 U?
U 3 1 5E3CE71E
P 8050 3800
AR Path="/5D8005AF/5D800744/5E3CE71E" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CE71E" Ref="U29"  Part="3" 
F 0 "U29" H 8050 4117 50  0000 C CNN
F 1 "74AHCT04" H 8050 4026 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 8050 3800 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 8050 3800 50  0001 C CNN
	3    8050 3800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E3D6D91
P -1650 2300
AR Path="/5D2C0761/5E3D6D91" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E3D6D91" Ref="#PWR01"  Part="1" 
F 0 "#PWR01" H -1650 2150 50  0001 C CNN
F 1 "VCC" H -1633 2473 50  0000 C CNN
F 2 "" H -1650 2300 50  0001 C CNN
F 3 "" H -1650 2300 50  0001 C CNN
	1    -1650 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1650 4350 -1550 4350
Wire Wire Line
	-1650 2300 -1650 2850
Wire Wire Line
	-1550 3850 -1650 3850
Connection ~ -1650 3850
Wire Wire Line
	-1650 3850 -1650 4350
Wire Wire Line
	-1550 3350 -1650 3350
Connection ~ -1650 3350
Wire Wire Line
	-1650 3350 -1650 3850
Wire Wire Line
	-1550 2850 -1650 2850
Connection ~ -1650 2850
Wire Wire Line
	-1650 2850 -1650 3350
NoConn ~ -950 3350
NoConn ~ -950 3850
NoConn ~ -950 4350
$Comp
L 74xx:74LS04 U?
U 1 1 5DFDD475
P 3350 2350
AR Path="/5D2C0761/5DFDD475" Ref="U?"  Part="3" 
AR Path="/5D2C0720/5DFDD475" Ref="U53"  Part="1" 
F 0 "U53" H 3350 2667 50  0000 C CNN
F 1 "74AHCT04" H 3350 2576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 3350 2350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 3350 2350 50  0001 C CNN
	1    3350 2350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 7 1 5E3187C8
P -3200 3550
AR Path="/5D2C0761/5E3187C8" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5E3187C8" Ref="U53"  Part="7" 
F 0 "U53" H -3600 3900 50  0000 C CNN
F 1 "74AHCT04" H -3600 3800 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -3200 3550 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -3200 3550 50  0001 C CNN
	7    -3200 3550
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5E326F07
P -1250 4350
AR Path="/5D8005AF/5D800744/5E326F07" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E326F07" Ref="U53"  Part="6" 
F 0 "U53" H -1250 4667 50  0000 C CNN
F 1 "74AHCT04" H -1250 4576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -1250 4350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -1250 4350 50  0001 C CNN
	6    -1250 4350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5E338851
P -1250 3350
AR Path="/5D8005AF/5D800744/5E338851" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E338851" Ref="U53"  Part="2" 
F 0 "U53" H -1250 3667 50  0000 C CNN
F 1 "74AHCT04" H -1250 3576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -1250 3350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -1250 3350 50  0001 C CNN
	2    -1250 3350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5E3CB33D
P 8050 2800
AR Path="/5D8005AF/5D800744/5E3CB33D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CB33D" Ref="U53"  Part="3" 
F 0 "U53" H 8050 3117 50  0000 C CNN
F 1 "74AHCT04" H 8050 3026 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 8050 2800 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 8050 2800 50  0001 C CNN
	3    8050 2800
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5E3CC9AE
P 3850 5350
AR Path="/5D8005AF/5D800744/5E3CC9AE" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CC9AE" Ref="U53"  Part="4" 
F 0 "U53" H 3850 5667 50  0000 C CNN
F 1 "74AHCT04" H 3850 5576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 3850 5350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 3850 5350 50  0001 C CNN
	4    3850 5350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5E3CD911
P -1250 3850
AR Path="/5D8005AF/5D800744/5E3CD911" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CD911" Ref="U53"  Part="5" 
F 0 "U53" H -1250 4167 50  0000 C CNN
F 1 "74AHCT04" H -1250 4076 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H -1250 3850 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H -1250 3850 50  0001 C CNN
	5    -1250 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1650 4350 -1650 4850
Wire Wire Line
	-1650 4850 -1550 4850
Connection ~ -1650 4350
NoConn ~ -950 4850
$Comp
L Switch:SW_Push SW?
U 1 1 5DEC3DEA
P 1450 1950
AR Path="/5D2C0761/5DEC3DEA" Ref="SW?"  Part="1" 
AR Path="/5D2C0720/5DEC3DEA" Ref="SW1"  Part="1" 
F 0 "SW1" V 1500 2250 50  0000 R CNN
F 1 "Reset" V 1400 2300 50  0000 R CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm_H5mm" H 1450 2150 50  0001 C CNN
F 3 "~" H 1450 2150 50  0001 C CNN
	1    1450 1950
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1450 800  1450 950 
Wire Wire Line
	1450 1150 1450 1350
Wire Wire Line
	1450 1350 2500 1350
Connection ~ 1450 1350
Wire Wire Line
	1450 1350 1450 1750
Wire Wire Line
	4350 4000 4350 1950
Connection ~ 4350 1950
Wire Wire Line
	4350 4000 5850 4000
Wire Wire Line
	4350 1950 10250 1950
Connection ~ -3200 2950
$Comp
L Device:C C?
U 1 1 5E2B93B8
P 7300 1000
AR Path="/5D2C0761/5E2B93B8" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E2B93B8" Ref="C47"  Part="1" 
F 0 "C47" H 7415 1046 50  0000 L CNN
F 1 "100nF" H 7415 955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 7338 850 50  0001 C CNN
F 3 "~" H 7300 1000 50  0001 C CNN
	1    7300 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 850  7300 850 
Wire Wire Line
	7300 1150 6800 1150
Connection ~ 6800 850 
Connection ~ 6800 1150
Wire Wire Line
	3450 7350 3550 7350
Wire Wire Line
	7650 4850 7650 5500
Wire Wire Line
	7650 5500 8400 5500
Connection ~ 7650 4850
Text Label 7700 5500 0    50   ~ 0
RootControlClock
Text Label 7700 5600 0    50   ~ 0
RootRegisterClock
Wire Wire Line
	5150 2900 5150 4250
Wire Wire Line
	5150 4250 3150 4250
Wire Wire Line
	3150 4250 3150 5500
Wire Wire Line
	5100 2800 5100 4900
Wire Wire Line
	1700 4900 5100 4900
Wire Wire Line
	8400 5400 6850 5400
Wire Wire Line
	6850 5400 6850 4900
Wire Wire Line
	6850 4900 5100 4900
Connection ~ 5100 4900
Wire Wire Line
	1700 4900 1700 5500
Text Label 7700 5400 0    50   ~ 0
RawClockSignal
$Comp
L power:GND #PWR0238
U 1 1 5E07A6CE
P 8250 5950
F 0 "#PWR0238" H 8250 5700 50  0001 C CNN
F 1 "GND" H 8255 5777 50  0000 C CNN
F 2 "" H 8250 5950 50  0001 C CNN
F 3 "" H 8250 5950 50  0001 C CNN
	1    8250 5950
	1    0    0    -1  
$EndComp
Wire Wire Line
	8400 5800 8250 5800
Wire Wire Line
	8250 5800 8250 5950
$Comp
L power:VCC #PWR0239
U 1 1 5E080807
P 8150 5700
F 0 "#PWR0239" H 8150 5550 50  0001 C CNN
F 1 "VCC" V 8168 5827 50  0000 L CNN
F 2 "" H 8150 5700 50  0001 C CNN
F 3 "" H 8150 5700 50  0001 C CNN
	1    8150 5700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8150 5700 8400 5700
$Comp
L Connector:Conn_01x05_Female J24
U 1 1 5E00A594
P 8600 5600
F 0 "J24" H 8492 5175 50  0000 C CNN
F 1 "External Clock" H 8492 5266 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x05_P2.54mm_Vertical" H 8600 5600 50  0001 C CNN
F 3 "~" H 8600 5600 50  0001 C CNN
	1    8600 5600
	1    0    0    1   
$EndComp
NoConn ~ -950 5350
Wire Wire Line
	-1650 4850 -1650 5350
Connection ~ -1650 4850
Connection ~ 3450 5850
Wire Wire Line
	3450 5850 3450 6350
Connection ~ 3450 5350
$Comp
L 74xx:74LS04 U?
U 6 1 5DFDD46F
P 3850 7350
AR Path="/5D2C0761/5DFDD46F" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5DFDD46F" Ref="U29"  Part="6" 
F 0 "U29" H 3850 7667 50  0000 C CNN
F 1 "74AHCT04" H 3850 7576 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 3850 7350 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct04.pdf" H 3850 7350 50  0001 C CNN
	6    3850 7350
	1    0    0    -1  
$EndComp
Connection ~ 5750 3600
Wire Wire Line
	5750 3600 5750 3500
$Comp
L power:VCC #PWR?
U 1 1 5DEC3E01
P 5650 3600
AR Path="/5D2C0761/5DEC3E01" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3E01" Ref="#PWR0219"  Part="1" 
F 0 "#PWR0219" H 5650 3450 50  0001 C CNN
F 1 "VCC" V 5650 3800 50  0000 C CNN
F 2 "" H 5650 3600 50  0001 C CNN
F 3 "" H 5650 3600 50  0001 C CNN
	1    5650 3600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5850 3100 5750 3100
Wire Wire Line
	3450 5350 3450 5850
Wire Wire Line
	3050 5600 3200 5600
Wire Wire Line
	3200 5600 3200 4300
Wire Wire Line
	3200 4300 5200 4300
Wire Wire Line
	5200 4300 5200 3200
Wire Wire Line
	6850 3100 7150 3100
Wire Wire Line
	7150 3100 7150 4800
Wire Wire Line
	7150 4800 3450 4800
Wire Wire Line
	7150 4800 7150 5600
Connection ~ 7150 4800
Wire Wire Line
	7150 5600 8400 5600
Wire Wire Line
	3450 4800 3450 5350
Text Notes 4500 2550 0    50   ~ 0
Pass register clock through the 157 too,\nto reduce skew between the two clocks.
Wire Wire Line
	2900 1950 3000 1950
Wire Wire Line
	1450 3150 2500 3150
Connection ~ 2500 3150
Wire Wire Line
	2500 3150 3750 3150
Wire Wire Line
	2500 2350 2500 3150
Wire Wire Line
	1450 2150 1450 3150
Wire Wire Line
	3750 2350 3650 2350
Wire Wire Line
	3750 2650 3750 2700
Connection ~ 3750 3150
Wire Wire Line
	3750 3150 3750 3000
Wire Wire Line
	3050 2350 3000 2350
Wire Wire Line
	3000 2350 3000 1950
Connection ~ 3000 1950
Wire Wire Line
	3000 1950 4350 1950
Text Notes 2950 1900 0    50   ~ 0
An inverter is necessary as a buffer,\nto avoid pulling too much current\nfrom the MCP100.
Wire Wire Line
	2500 1350 2500 1550
Wire Wire Line
	5200 3200 5850 3200
$Comp
L power:GND #PWR?
U 1 1 5F533C17
P 5750 3100
F 0 "#PWR?" H 5750 2850 50  0001 C CNN
F 1 "GND" V 5755 2972 50  0000 R CNN
F 2 "" H 5750 3100 50  0001 C CNN
F 3 "" H 5750 3100 50  0001 C CNN
	1    5750 3100
	0    1    1    0   
$EndComp
$EndSCHEMATC
