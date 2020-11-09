EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 20 21
Title "Registers U and V"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "The UV register pair supplies the address for Data RAM."
$EndDescr
$Comp
L Device:C C?
U 1 1 5E5A44F8
P 900 7450
AR Path="/5D2C07CD/5E5A44F8" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5E5A44F8" Ref="C?"  Part="1" 
AR Path="/5E586E0B/5E5A44F8" Ref="C?"  Part="1" 
AR Path="/5E0B0BBA/5E5A44F8" Ref="C36"  Part="1" 
F 0 "C36" H 1015 7496 50  0000 L CNN
F 1 "100nF" H 1015 7405 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 938 7300 50  0001 C CNN
F 3 "~" H 900 7450 50  0001 C CNN
	1    900  7450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E5A44FE
P 1400 7450
AR Path="/5D2C07CD/5E5A44FE" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5E5A44FE" Ref="C?"  Part="1" 
AR Path="/5E586E0B/5E5A44FE" Ref="C?"  Part="1" 
AR Path="/5E0B0BBA/5E5A44FE" Ref="C39"  Part="1" 
F 0 "C39" H 1515 7496 50  0000 L CNN
F 1 "100nF" H 1515 7405 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 1438 7300 50  0001 C CNN
F 3 "~" H 1400 7450 50  0001 C CNN
	1    1400 7450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E5A4504
P 1900 7450
AR Path="/5D2C07CD/5E5A4504" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4504" Ref="C?"  Part="1" 
AR Path="/5E586E0B/5E5A4504" Ref="C?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4504" Ref="C40"  Part="1" 
F 0 "C40" H 2015 7496 50  0000 L CNN
F 1 "100nF" H 2015 7405 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 1938 7300 50  0001 C CNN
F 3 "~" H 1900 7450 50  0001 C CNN
	1    1900 7450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E5A450A
P 2400 7450
AR Path="/5D2C07CD/5E5A450A" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5E5A450A" Ref="C?"  Part="1" 
AR Path="/5E586E0B/5E5A450A" Ref="C?"  Part="1" 
AR Path="/5E0B0BBA/5E5A450A" Ref="C41"  Part="1" 
F 0 "C41" H 2515 7496 50  0000 L CNN
F 1 "100nF" H 2515 7405 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 2438 7300 50  0001 C CNN
F 3 "~" H 2400 7450 50  0001 C CNN
	1    2400 7450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E5A4510
P 900 7600
AR Path="/5D2C07CD/5E5A4510" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4510" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A4510" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4510" Ref="#PWR0252"  Part="1" 
F 0 "#PWR0252" H 900 7350 50  0001 C CNN
F 1 "GND" H 905 7427 50  0000 C CNN
F 2 "" H 900 7600 50  0001 C CNN
F 3 "" H 900 7600 50  0001 C CNN
	1    900  7600
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A4516
P 900 7300
AR Path="/5D2C07CD/5E5A4516" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4516" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A4516" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4516" Ref="#PWR0256"  Part="1" 
F 0 "#PWR0256" H 900 7150 50  0001 C CNN
F 1 "VCC" H 917 7473 50  0000 C CNN
F 2 "" H 900 7300 50  0001 C CNN
F 3 "" H 900 7300 50  0001 C CNN
	1    900  7300
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  7300 1400 7300
Connection ~ 900  7300
Wire Wire Line
	1400 7300 1900 7300
Connection ~ 1400 7300
Wire Wire Line
	1900 7300 2400 7300
Connection ~ 1900 7300
Wire Wire Line
	2400 7600 1900 7600
Wire Wire Line
	1900 7600 1400 7600
Connection ~ 1900 7600
Wire Wire Line
	1400 7600 900  7600
Connection ~ 1400 7600
Connection ~ 900  7600
Text GLabel 1300 3450 0    50   Input ~ 0
~VI
$Comp
L 74xx:74LS161 U?
U 1 1 5E5A4529
P 2600 1950
AR Path="/5D2C07CD/5E5A4529" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4529" Ref="U?"  Part="1" 
AR Path="/5E586E0B/5E5A4529" Ref="U?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4529" Ref="U34"  Part="1" 
F 0 "U34" H 2350 2750 50  0000 C CNN
F 1 "74F161" H 2350 2650 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 2600 1950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS161" H 2600 1950 50  0001 C CNN
	1    2600 1950
	1    0    0    -1  
$EndComp
Text GLabel 1300 3150 0    50   Input ~ 0
RegisterClock4
Wire Wire Line
	2100 2250 1700 2250
Wire Wire Line
	1700 2250 1700 3150
Wire Wire Line
	1700 3150 1300 3150
$Comp
L power:GND #PWR?
U 1 1 5E5A4533
P 2600 2750
AR Path="/5D2C07CD/5E5A4533" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4533" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A4533" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4533" Ref="#PWR0267"  Part="1" 
F 0 "#PWR0267" H 2600 2500 50  0001 C CNN
F 1 "GND" H 2605 2577 50  0000 C CNN
F 2 "" H 2600 2750 50  0001 C CNN
F 3 "" H 2600 2750 50  0001 C CNN
	1    2600 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 1950 1500 1950
Wire Wire Line
	1500 3450 1300 3450
Entry Wire Line
	1500 1350 1600 1450
Entry Wire Line
	1500 1450 1600 1550
Entry Wire Line
	1500 1550 1600 1650
Entry Wire Line
	1500 1650 1600 1750
Entry Wire Line
	3550 1350 3650 1450
Entry Wire Line
	3550 1450 3650 1550
Entry Wire Line
	3550 1550 3650 1650
Entry Wire Line
	3550 1650 3650 1750
Wire Wire Line
	1600 1450 2100 1450
Wire Wire Line
	2100 1550 1600 1550
Wire Wire Line
	1600 1650 2100 1650
Wire Wire Line
	2100 1750 1600 1750
Entry Wire Line
	5650 1350 5750 1450
Entry Wire Line
	5650 1450 5750 1550
Entry Wire Line
	5650 1550 5750 1650
Entry Wire Line
	5650 1650 5750 1750
Entry Wire Line
	7750 1450 7850 1550
Entry Wire Line
	7750 1550 7850 1650
Entry Wire Line
	7750 1650 7850 1750
Text Label 1600 1450 0    50   ~ 0
DataBus0
Text Label 1600 1550 0    50   ~ 0
DataBus1
Text Label 1600 1650 0    50   ~ 0
DataBus2
Text Label 1600 1750 0    50   ~ 0
DataBus3
Text Label 3650 1650 0    50   ~ 0
DataBus6
Text Label 3650 1750 0    50   ~ 0
DataBus7
Text Label 5750 1450 0    50   ~ 0
DataBus0
Text Label 5750 1550 0    50   ~ 0
DataBus1
Text Label 5750 1650 0    50   ~ 0
DataBus2
Text Label 5750 1750 0    50   ~ 0
DataBus3
Entry Wire Line
	7750 1350 7850 1450
Text Label 7850 1450 0    50   ~ 0
DataBus4
Text Label 7850 1550 0    50   ~ 0
DataBus5
Text Label 7850 1650 0    50   ~ 0
DataBus6
Text Label 7850 1750 0    50   ~ 0
DataBus7
Entry Wire Line
	3300 1450 3400 1350
Entry Wire Line
	3300 1550 3400 1450
Entry Wire Line
	3300 1650 3400 1550
Entry Wire Line
	3300 1750 3400 1650
Wire Wire Line
	1500 3450 3750 3450
Connection ~ 1500 3450
Wire Wire Line
	1700 3150 3850 3150
Connection ~ 1700 3150
Entry Wire Line
	5400 1450 5500 1350
Entry Wire Line
	5400 1550 5500 1450
Entry Wire Line
	5400 1650 5500 1550
Entry Wire Line
	5400 1750 5500 1650
Entry Wire Line
	7500 1450 7600 1350
Entry Wire Line
	7500 1550 7600 1450
Entry Wire Line
	7500 1650 7600 1550
Entry Wire Line
	7500 1750 7600 1650
Entry Wire Line
	9650 1450 9750 1350
Entry Wire Line
	9650 1550 9750 1450
Entry Wire Line
	9650 1650 9750 1550
Entry Wire Line
	9650 1750 9750 1650
Wire Bus Line
	1300 950  1500 950 
Connection ~ 1500 950 
Wire Bus Line
	1500 950  3550 950 
Connection ~ 3550 950 
Wire Bus Line
	3550 950  5650 950 
Connection ~ 5650 950 
Wire Bus Line
	5650 950  7750 950 
Wire Bus Line
	3400 1050 5500 1050
Connection ~ 7600 1050
Connection ~ 5500 1050
Wire Bus Line
	5500 1050 7600 1050
Connection ~ 2600 2750
Text GLabel 10250 1050 2    50   Output ~ 0
UV[0..15]
Wire Wire Line
	8400 1750 7850 1750
Wire Wire Line
	7850 1650 8400 1650
Wire Wire Line
	8400 1550 7850 1550
Wire Wire Line
	7850 1450 8400 1450
$Comp
L 74xx:74LS161 U?
U 1 1 5E5A459A
P 8900 1950
AR Path="/5D2C07CD/5E5A459A" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5E5A459A" Ref="U?"  Part="1" 
AR Path="/5E586E0B/5E5A459A" Ref="U?"  Part="1" 
AR Path="/5E0B0BBA/5E5A459A" Ref="U40"  Part="1" 
F 0 "U40" H 8650 2750 50  0000 C CNN
F 1 "74F161" H 8650 2650 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 8900 1950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS161" H 8900 1950 50  0001 C CNN
	1    8900 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 2750 8900 2750
Connection ~ 6800 2750
Wire Wire Line
	6300 1750 5750 1750
Wire Wire Line
	5750 1650 6300 1650
Wire Wire Line
	6300 1550 5750 1550
$Comp
L 74xx:74LS161 U?
U 1 1 5E5A45A9
P 6800 1950
AR Path="/5D2C07CD/5E5A45A9" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45A9" Ref="U?"  Part="1" 
AR Path="/5E586E0B/5E5A45A9" Ref="U?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45A9" Ref="U38"  Part="1" 
F 0 "U38" H 6550 2750 50  0000 C CNN
F 1 "74F161" H 6550 2650 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 6800 1950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS161" H 6800 1950 50  0001 C CNN
	1    6800 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 2750 4700 2750
Connection ~ 4700 2750
Wire Wire Line
	4700 2750 6800 2750
Wire Wire Line
	3650 1750 4200 1750
Wire Wire Line
	4200 1650 3650 1650
Wire Wire Line
	3650 1550 4200 1550
Wire Wire Line
	4200 1450 3650 1450
$Comp
L 74xx:74LS161 U?
U 1 1 5E5A45BA
P 4700 1950
AR Path="/5D2C07CD/5E5A45BA" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45BA" Ref="U?"  Part="1" 
AR Path="/5E586E0B/5E5A45BA" Ref="U?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45BA" Ref="U36"  Part="1" 
F 0 "U36" H 4450 2750 50  0000 C CNN
F 1 "74F161" H 4450 2650 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 4700 1950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS161" H 4700 1950 50  0001 C CNN
	1    4700 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	7700 2150 7700 1950
Wire Wire Line
	7700 1950 7300 1950
Wire Wire Line
	7700 2150 8400 2150
Wire Wire Line
	5200 1950 5600 1950
Wire Wire Line
	5600 1950 5600 2150
Wire Wire Line
	5600 2150 6300 2150
Wire Wire Line
	3100 1950 3500 1950
Wire Wire Line
	3500 1950 3500 2150
Wire Wire Line
	3500 2150 4200 2150
Wire Wire Line
	6300 1450 5750 1450
Wire Wire Line
	1500 1950 1500 3450
$Comp
L power:VCC #PWR?
U 1 1 5E5A45CD
P 8400 2050
AR Path="/5D2C07CD/5E5A45CD" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45CD" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A45CD" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45CD" Ref="#PWR0268"  Part="1" 
F 0 "#PWR0268" H 8400 1900 50  0001 C CNN
F 1 "VCC" V 8418 2177 50  0000 L CNN
F 2 "" H 8400 2050 50  0001 C CNN
F 3 "" H 8400 2050 50  0001 C CNN
	1    8400 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A45D3
P 6300 2050
AR Path="/5D2C07CD/5E5A45D3" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45D3" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A45D3" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45D3" Ref="#PWR0269"  Part="1" 
F 0 "#PWR0269" H 6300 1900 50  0001 C CNN
F 1 "VCC" V 6318 2177 50  0000 L CNN
F 2 "" H 6300 2050 50  0001 C CNN
F 3 "" H 6300 2050 50  0001 C CNN
	1    6300 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A45D9
P 4200 2050
AR Path="/5D2C07CD/5E5A45D9" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45D9" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A45D9" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45D9" Ref="#PWR0270"  Part="1" 
F 0 "#PWR0270" H 4200 1900 50  0001 C CNN
F 1 "VCC" V 4218 2177 50  0000 L CNN
F 2 "" H 4200 2050 50  0001 C CNN
F 3 "" H 4200 2050 50  0001 C CNN
	1    4200 2050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2100 2050 2000 2050
Wire Wire Line
	2000 2050 2000 2100
Wire Wire Line
	2000 2150 2100 2150
Connection ~ 2000 2100
Wire Wire Line
	2000 2100 2000 2150
Wire Bus Line
	7600 1050 9750 1050
Connection ~ 9750 1050
Text GLabel 1300 950  0    50   Input ~ 0
DataBus[0..7]
Wire Wire Line
	4700 1150 4700 850 
Wire Wire Line
	6800 1150 6800 850 
Wire Wire Line
	8900 850  8900 1150
Wire Wire Line
	6800 850  8900 850 
Connection ~ 6800 850 
Wire Wire Line
	4700 850  6800 850 
Connection ~ 4700 850 
Wire Wire Line
	2600 850  4700 850 
Wire Wire Line
	2600 1150 2600 850 
Connection ~ 2600 850 
Wire Wire Line
	2600 800  2600 850 
$Comp
L power:VCC #PWR?
U 1 1 5E5A45F4
P 2600 800
AR Path="/5D2C07CD/5E5A45F4" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45F4" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A45F4" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45F4" Ref="#PWR0271"  Part="1" 
F 0 "#PWR0271" H 2600 650 50  0001 C CNN
F 1 "VCC" H 2617 973 50  0000 C CNN
F 2 "" H 2600 800 50  0001 C CNN
F 3 "" H 2600 800 50  0001 C CNN
	1    2600 800 
	1    0    0    -1  
$EndComp
Text Label 3650 1550 0    50   ~ 0
DataBus5
Text Label 3650 1450 0    50   ~ 0
DataBus4
$Comp
L power:VCC #PWR?
U 1 1 5E5A45FD
P 2100 2450
AR Path="/5D2C07CD/5E5A45FD" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A45FD" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A45FD" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A45FD" Ref="#PWR0272"  Part="1" 
F 0 "#PWR0272" H 2100 2300 50  0001 C CNN
F 1 "VCC" V 2118 2577 50  0000 L CNN
F 2 "" H 2100 2450 50  0001 C CNN
F 3 "" H 2100 2450 50  0001 C CNN
	1    2100 2450
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A4603
P 4200 2450
AR Path="/5D2C07CD/5E5A4603" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4603" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A4603" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4603" Ref="#PWR0273"  Part="1" 
F 0 "#PWR0273" H 4200 2300 50  0001 C CNN
F 1 "VCC" V 4218 2577 50  0000 L CNN
F 2 "" H 4200 2450 50  0001 C CNN
F 3 "" H 4200 2450 50  0001 C CNN
	1    4200 2450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3850 2250 3850 3150
Connection ~ 3850 3150
Wire Wire Line
	3850 3150 5900 3150
Wire Wire Line
	3850 2250 4200 2250
$Comp
L power:VCC #PWR?
U 1 1 5E5A460D
P 6300 2450
AR Path="/5D2C07CD/5E5A460D" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A460D" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A460D" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A460D" Ref="#PWR0274"  Part="1" 
F 0 "#PWR0274" H 6300 2300 50  0001 C CNN
F 1 "VCC" V 6318 2577 50  0000 L CNN
F 2 "" H 6300 2450 50  0001 C CNN
F 3 "" H 6300 2450 50  0001 C CNN
	1    6300 2450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5900 2250 5900 3150
Connection ~ 5900 3150
Wire Wire Line
	5900 2250 6300 2250
Wire Wire Line
	5900 3150 8050 3150
$Comp
L power:VCC #PWR?
U 1 1 5E5A4617
P 8400 2450
AR Path="/5D2C07CD/5E5A4617" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4617" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A4617" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4617" Ref="#PWR0275"  Part="1" 
F 0 "#PWR0275" H 8400 2300 50  0001 C CNN
F 1 "VCC" V 8418 2577 50  0000 L CNN
F 2 "" H 8400 2450 50  0001 C CNN
F 3 "" H 8400 2450 50  0001 C CNN
	1    8400 2450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8050 2250 8050 3150
Wire Wire Line
	8050 2250 8400 2250
Text GLabel 1300 3600 0    50   Input ~ 0
~UI
Wire Wire Line
	1300 3600 5800 3600
Wire Wire Line
	3750 1950 3750 3450
Wire Wire Line
	3750 1950 4200 1950
Wire Wire Line
	5800 1950 5800 3600
Connection ~ 5800 3600
Wire Wire Line
	5800 1950 6300 1950
Wire Wire Line
	5800 3600 7950 3600
Wire Wire Line
	7950 1950 7950 3600
Wire Wire Line
	7950 1950 8400 1950
Text GLabel 1300 3300 0    50   Input ~ 0
UVInc
Wire Wire Line
	1600 2100 1600 3300
Wire Wire Line
	1600 3300 1300 3300
Wire Wire Line
	1600 2100 2000 2100
$Comp
L 74xx:74LS245 U?
U 1 1 5E5A462D
P 3400 4800
AR Path="/5D2C0CA7/5E5A462D" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5E5A462D" Ref="U?"  Part="1" 
AR Path="/5E586E0B/5E5A462D" Ref="U?"  Part="1" 
AR Path="/5E0B0BBA/5E5A462D" Ref="U35"  Part="1" 
F 0 "U35" H 3150 5600 50  0000 C CNN
F 1 "74AHCT245" H 3150 5500 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 3400 4800 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn54ahct245.pdf" H 3400 4800 50  0001 C CNN
	1    3400 4800
	0    1    1    0   
$EndComp
$Comp
L 74xx:74LS245 U?
U 1 1 5E5A4633
P 5650 4800
AR Path="/5D2C0CA7/5E5A4633" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5E5A4633" Ref="U?"  Part="1" 
AR Path="/5E586E0B/5E5A4633" Ref="U?"  Part="1" 
AR Path="/5E0B0BBA/5E5A4633" Ref="U37"  Part="1" 
F 0 "U37" H 5400 5600 50  0000 C CNN
F 1 "74AHCT245" H 5400 5500 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 5650 4800 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn54ahct245.pdf" H 5650 4800 50  0001 C CNN
	1    5650 4800
	0    1    1    0   
$EndComp
Entry Wire Line
	3900 4100 3800 4000
Entry Wire Line
	3800 4100 3700 4000
Entry Wire Line
	3700 4100 3600 4000
Entry Wire Line
	3600 4100 3500 4000
Entry Wire Line
	3200 4100 3100 4000
Entry Wire Line
	3300 4100 3200 4000
Entry Wire Line
	3400 4100 3300 4000
Entry Wire Line
	3500 4100 3400 4000
Entry Wire Line
	6150 4100 6050 4000
Entry Wire Line
	6050 4100 5950 4000
Entry Wire Line
	5950 4100 5850 4000
Entry Wire Line
	5850 4100 5750 4000
Entry Wire Line
	5450 4100 5350 4000
Entry Wire Line
	5550 4100 5450 4000
Entry Wire Line
	5650 4100 5550 4000
Entry Wire Line
	5750 4100 5650 4000
Entry Wire Line
	6150 6350 6050 6250
Entry Wire Line
	6050 6350 5950 6250
Entry Wire Line
	5950 6350 5850 6250
Entry Wire Line
	5850 6350 5750 6250
Entry Wire Line
	5750 6350 5650 6250
Entry Wire Line
	5650 6350 5550 6250
Entry Wire Line
	5550 6350 5450 6250
Text GLabel 10050 6350 2    50   Output ~ 0
DataBus[0..7]
Entry Wire Line
	6250 6350 6150 6250
Text Label 6050 5850 3    50   ~ 0
DataBus1
Text Label 5950 5850 3    50   ~ 0
DataBus2
Text Label 5850 5850 3    50   ~ 0
DataBus3
Text Label 5750 5850 3    50   ~ 0
DataBus4
Text Label 5650 5850 3    50   ~ 0
DataBus5
Text Label 5550 5850 3    50   ~ 0
DataBus6
Text Label 5450 5850 3    50   ~ 0
DataBus7
Text Label 6150 5850 3    50   ~ 0
DataBus0
Wire Wire Line
	5450 6250 5450 5300
Wire Wire Line
	5550 6250 5550 5300
Wire Wire Line
	5650 6250 5650 5300
Wire Wire Line
	5750 6250 5750 5300
Wire Wire Line
	5850 6250 5850 5300
Wire Wire Line
	5950 6250 5950 5300
Wire Wire Line
	6050 6250 6050 5300
Wire Wire Line
	6150 6250 6150 5300
Entry Wire Line
	3900 6350 3800 6250
Entry Wire Line
	3800 6350 3700 6250
Entry Wire Line
	3700 6350 3600 6250
Entry Wire Line
	3600 6350 3500 6250
Entry Wire Line
	3500 6350 3400 6250
Entry Wire Line
	3400 6350 3300 6250
Entry Wire Line
	3300 6350 3200 6250
Entry Wire Line
	4000 6350 3900 6250
Text Label 3800 5850 3    50   ~ 0
DataBus1
Text Label 3700 5850 3    50   ~ 0
DataBus2
Text Label 3600 5850 3    50   ~ 0
DataBus3
Text Label 3500 5850 3    50   ~ 0
DataBus4
Text Label 3400 5850 3    50   ~ 0
DataBus5
Text Label 3300 5850 3    50   ~ 0
DataBus6
Text Label 3200 5850 3    50   ~ 0
DataBus7
Text Label 3900 5850 3    50   ~ 0
DataBus0
Wire Wire Line
	3200 6250 3200 5300
Wire Wire Line
	3300 6250 3300 5300
Wire Wire Line
	3400 6250 3400 5300
Wire Wire Line
	3500 6250 3500 5300
Wire Wire Line
	3600 6250 3600 5300
Wire Wire Line
	3700 6250 3700 5300
Wire Wire Line
	3800 6250 3800 5300
Wire Wire Line
	3900 6250 3900 5300
$Comp
L power:VCC #PWR?
U 1 1 5E5A469B
P 5250 4300
AR Path="/5D2C0CA7/5E5A469B" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A469B" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A469B" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A469B" Ref="#PWR0276"  Part="1" 
F 0 "#PWR0276" H 5250 4150 50  0001 C CNN
F 1 "VCC" H 5267 4473 50  0000 C CNN
F 2 "" H 5250 4300 50  0001 C CNN
F 3 "" H 5250 4300 50  0001 C CNN
	1    5250 4300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A46A1
P 3000 4300
AR Path="/5D2C0CA7/5E5A46A1" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A46A1" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A46A1" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46A1" Ref="#PWR0277"  Part="1" 
F 0 "#PWR0277" H 3000 4150 50  0001 C CNN
F 1 "VCC" H 3017 4473 50  0000 C CNN
F 2 "" H 3000 4300 50  0001 C CNN
F 3 "" H 3000 4300 50  0001 C CNN
	1    3000 4300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A46A7
P 6450 4800
AR Path="/5D2C07CD/5E5A46A7" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A46A7" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A46A7" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46A7" Ref="#PWR0278"  Part="1" 
F 0 "#PWR0278" H 6450 4650 50  0001 C CNN
F 1 "VCC" V 6468 4927 50  0000 L CNN
F 2 "" H 6450 4800 50  0001 C CNN
F 3 "" H 6450 4800 50  0001 C CNN
	1    6450 4800
	0    1    -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E5A46AD
P 4200 4800
AR Path="/5D2C07CD/5E5A46AD" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5A46AD" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A46AD" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46AD" Ref="#PWR0279"  Part="1" 
F 0 "#PWR0279" H 4200 4650 50  0001 C CNN
F 1 "VCC" V 4218 4927 50  0000 L CNN
F 2 "" H 4200 4800 50  0001 C CNN
F 3 "" H 4200 4800 50  0001 C CNN
	1    4200 4800
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E5A46B3
P 4850 4800
AR Path="/5D7BD0EA/5E5A46B3" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A46B3" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46B3" Ref="#PWR0280"  Part="1" 
F 0 "#PWR0280" H 4850 4550 50  0001 C CNN
F 1 "GND" V 4855 4672 50  0000 R CNN
F 2 "" H 4850 4800 50  0001 C CNN
F 3 "" H 4850 4800 50  0001 C CNN
	1    4850 4800
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E5A46B9
P 2600 4800
AR Path="/5D7BD0EA/5E5A46B9" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5A46B9" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46B9" Ref="#PWR0281"  Part="1" 
F 0 "#PWR0281" H 2600 4550 50  0001 C CNN
F 1 "GND" V 2605 4672 50  0000 R CNN
F 2 "" H 2600 4800 50  0001 C CNN
F 3 "" H 2600 4800 50  0001 C CNN
	1    2600 4800
	0    1    1    0   
$EndComp
Text GLabel 1300 3750 0    50   Input ~ 0
~VO
Text GLabel 1300 3900 0    50   Input ~ 0
~UO
Wire Wire Line
	1300 3900 2900 3900
Wire Wire Line
	2900 3900 2900 4300
Wire Wire Line
	1300 3750 5150 3750
Wire Wire Line
	5150 3750 5150 4300
$Comp
L Device:C C?
U 1 1 5E5A46C5
P 2900 7450
AR Path="/5D2C07CD/5E5A46C5" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5E5A46C5" Ref="C?"  Part="1" 
AR Path="/5E586E0B/5E5A46C5" Ref="C?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46C5" Ref="C42"  Part="1" 
F 0 "C42" H 3015 7496 50  0000 L CNN
F 1 "100nF" H 3015 7405 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 2938 7300 50  0001 C CNN
F 3 "~" H 2900 7450 50  0001 C CNN
	1    2900 7450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E5A46CB
P 3400 7450
AR Path="/5D2C07CD/5E5A46CB" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5E5A46CB" Ref="C?"  Part="1" 
AR Path="/5E586E0B/5E5A46CB" Ref="C?"  Part="1" 
AR Path="/5E0B0BBA/5E5A46CB" Ref="C44"  Part="1" 
F 0 "C44" H 3515 7496 50  0000 L CNN
F 1 "100nF" H 3515 7405 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 3438 7300 50  0001 C CNN
F 3 "~" H 3400 7450 50  0001 C CNN
	1    3400 7450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2400 7300 2900 7300
Wire Wire Line
	2900 7300 3400 7300
Connection ~ 2900 7300
Wire Wire Line
	3400 7600 2900 7600
Wire Wire Line
	2900 7600 2400 7600
Connection ~ 2900 7600
Connection ~ 2400 7300
Connection ~ 2400 7600
Wire Bus Line
	9750 1050 10250 1050
$Comp
L power:GND #PWR?
U 1 1 5E5B4E3A
P 9450 4600
AR Path="/5D2C07CD/5E5B4E3A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CA7/5E5B4E3A" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5E5B4E3A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C12A5/5E5B4E3A" Ref="#PWR?"  Part="1" 
AR Path="/5E586E0B/5E5B4E3A" Ref="#PWR?"  Part="1" 
AR Path="/5E0B0BBA/5E5B4E3A" Ref="#PWR0282"  Part="1" 
F 0 "#PWR0282" H 9450 4350 50  0001 C CNN
F 1 "GND" H 9455 4427 50  0000 C CNN
F 2 "" H 9450 4600 50  0001 C CNN
F 3 "" H 9450 4600 50  0001 C CNN
	1    9450 4600
	-1   0    0    1   
$EndComp
Entry Wire Line
	7850 4100 7750 4000
Entry Wire Line
	8050 4100 7950 4000
Entry Wire Line
	8150 4100 8050 4000
Entry Wire Line
	8250 4100 8150 4000
Entry Wire Line
	8350 4100 8250 4000
Entry Wire Line
	8450 4100 8350 4000
Entry Wire Line
	8550 4100 8450 4000
Entry Wire Line
	8650 4100 8550 4000
Entry Wire Line
	8750 4100 8650 4000
Entry Wire Line
	8850 4100 8750 4000
Entry Wire Line
	8950 4100 8850 4000
Entry Wire Line
	9050 4100 8950 4000
Entry Wire Line
	9150 4100 9050 4000
Entry Wire Line
	9250 4100 9150 4000
Entry Wire Line
	9350 4100 9250 4000
Text Label 7850 4650 1    50   ~ 0
UV15
Text Label 8050 4650 1    50   ~ 0
UV13
Text Label 8150 4650 1    50   ~ 0
UV12
Text Label 8250 4650 1    50   ~ 0
UV11
Text Label 8350 4650 1    50   ~ 0
UV10
Text Label 8450 4650 1    50   ~ 0
UV9
Text Label 8550 4650 1    50   ~ 0
UV8
Text Label 8650 4650 1    50   ~ 0
UV7
Text Label 8750 4650 1    50   ~ 0
UV6
Text Label 8850 4650 1    50   ~ 0
UV5
Text Label 8950 4650 1    50   ~ 0
UV4
Text Label 9050 4650 1    50   ~ 0
UV3
Text Label 9150 4650 1    50   ~ 0
UV2
Text Label 9250 4650 1    50   ~ 0
UV1
Text Label 9350 4650 1    50   ~ 0
UV0
Wire Wire Line
	7850 4100 7850 4700
Wire Wire Line
	8050 4100 8050 4700
Wire Wire Line
	8150 4100 8150 4700
Wire Wire Line
	8250 4100 8250 4700
Wire Wire Line
	8350 4100 8350 4700
Wire Wire Line
	8450 4100 8450 4700
Wire Wire Line
	8550 4100 8550 4700
Wire Wire Line
	8650 4100 8650 4700
Wire Wire Line
	8750 4100 8750 4700
Wire Wire Line
	8850 4100 8850 4700
Wire Wire Line
	8950 4100 8950 4700
Wire Wire Line
	9050 4100 9050 4700
Wire Wire Line
	9150 4100 9150 4700
Wire Wire Line
	9250 4100 9250 4700
Wire Wire Line
	9350 4100 9350 4700
Wire Wire Line
	9450 4700 9450 4600
Wire Wire Line
	7950 4100 7950 4700
Text Label 7950 4650 1    50   ~ 0
UV14
Entry Wire Line
	7950 4100 7850 4000
$Comp
L Connector:Conn_01x17_Female J?
U 1 1 5E5B4E72
P 8650 4900
AR Path="/5D2C12A5/5E5B4E72" Ref="J?"  Part="1" 
AR Path="/5E586E0B/5E5B4E72" Ref="J?"  Part="1" 
AR Path="/5E0B0BBA/5E5B4E72" Ref="J23"  Part="1" 
F 0 "J23" V 8723 4880 50  0000 C CNN
F 1 "UV LED Connector" V 8814 4880 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x17_P2.54mm_Vertical" H 8650 4900 50  0001 C CNN
F 3 "~" H 8650 4900 50  0001 C CNN
	1    8650 4900
	0    1    1    0   
$EndComp
Wire Wire Line
	3100 1450 3300 1450
Wire Wire Line
	3300 1550 3100 1550
Wire Wire Line
	3100 1650 3300 1650
Wire Wire Line
	3300 1750 3100 1750
Wire Wire Line
	5200 1450 5400 1450
Wire Wire Line
	5400 1550 5200 1550
Wire Wire Line
	5200 1650 5400 1650
Wire Wire Line
	5400 1750 5200 1750
Wire Wire Line
	7300 1450 7500 1450
Wire Wire Line
	7500 1550 7300 1550
Wire Wire Line
	7300 1650 7500 1650
Wire Wire Line
	7500 1750 7300 1750
Wire Wire Line
	9400 1450 9650 1450
Wire Wire Line
	9650 1550 9400 1550
Wire Wire Line
	9400 1650 9650 1650
Wire Wire Line
	9400 1750 9650 1750
Wire Wire Line
	5450 4100 5450 4300
Wire Wire Line
	5550 4100 5550 4300
Wire Wire Line
	5650 4100 5650 4300
Wire Wire Line
	5750 4100 5750 4300
Wire Wire Line
	5850 4100 5850 4300
Wire Wire Line
	5950 4100 5950 4300
Wire Wire Line
	6050 4300 6050 4100
Wire Wire Line
	6150 4300 6150 4100
Wire Wire Line
	3900 4300 3900 4100
Wire Wire Line
	3800 4100 3800 4300
Wire Wire Line
	3700 4300 3700 4100
Wire Wire Line
	3600 4100 3600 4300
Wire Wire Line
	3500 4300 3500 4100
Wire Wire Line
	3400 4300 3400 4100
Wire Wire Line
	3300 4100 3300 4300
Wire Wire Line
	3200 4300 3200 4100
Text Label 6150 4300 1    50   ~ 0
UV0
Text Label 6050 4300 1    50   ~ 0
UV1
Text Label 5950 4300 1    50   ~ 0
UV2
Text Label 5850 4300 1    50   ~ 0
UV3
Text Label 5750 4300 1    50   ~ 0
UV4
Text Label 5650 4300 1    50   ~ 0
UV5
Text Label 5550 4300 1    50   ~ 0
UV6
Text Label 5450 4300 1    50   ~ 0
UV7
Text Label 3900 4300 1    50   ~ 0
UV8
Text Label 3800 4300 1    50   ~ 0
UV9
Text Label 3700 4300 1    50   ~ 0
UV10
Text Label 3600 4300 1    50   ~ 0
UV11
Text Label 3500 4300 1    50   ~ 0
UV12
Text Label 3400 4300 1    50   ~ 0
UV13
Text Label 3300 4300 1    50   ~ 0
UV14
Text Label 3200 4300 1    50   ~ 0
UV15
Text Label 3100 1450 0    50   ~ 0
UV0
Text Label 3100 1550 0    50   ~ 0
UV1
Text Label 3100 1650 0    50   ~ 0
UV2
Text Label 3100 1750 0    50   ~ 0
UV3
Text Label 5200 1450 0    50   ~ 0
UV4
Text Label 5200 1550 0    50   ~ 0
UV5
Text Label 5200 1650 0    50   ~ 0
UV6
Text Label 5200 1750 0    50   ~ 0
UV7
Text Label 7300 1450 0    50   ~ 0
UV8
Text Label 7300 1550 0    50   ~ 0
UV9
Text Label 7300 1650 0    50   ~ 0
UV10
Text Label 7300 1750 0    50   ~ 0
UV11
Text Label 9400 1450 0    50   ~ 0
UV12
Text Label 9400 1550 0    50   ~ 0
UV13
Text Label 9400 1650 0    50   ~ 0
UV14
Text Label 9400 1750 0    50   ~ 0
UV15
NoConn ~ 9400 1950
Wire Bus Line
	9750 1050 9750 4000
Wire Bus Line
	7600 1050 7600 1650
Wire Bus Line
	5500 1050 5500 1650
Wire Bus Line
	3400 1050 3400 1650
Wire Bus Line
	7750 950  7750 1650
Wire Bus Line
	5650 950  5650 1650
Wire Bus Line
	3550 950  3550 1650
Wire Bus Line
	1500 950  1500 1650
Wire Bus Line
	3300 6350 10050 6350
Wire Bus Line
	3100 4000 9750 4000
$EndSCHEMATC
