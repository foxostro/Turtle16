EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 2 21
Title "Register D"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Register D controls the device select lines for peripherals and memory."
$EndDescr
Text Label 5650 2800 2    50   ~ 0
D2
Text Label 5650 2700 2    50   ~ 0
D1
Text Label 5650 2600 2    50   ~ 0
D0
Wire Wire Line
	5550 2800 5750 2800
Wire Wire Line
	5750 2700 5550 2700
Wire Wire Line
	5550 2600 5750 2600
Wire Bus Line
	5250 2400 5450 2400
Entry Wire Line
	5550 2600 5450 2500
Entry Wire Line
	5450 2700 5550 2800
Entry Wire Line
	5450 2600 5550 2700
Text Label 5150 3300 2    50   ~ 0
D7
Text Label 5150 3200 2    50   ~ 0
D6
Text Label 5150 3100 2    50   ~ 0
D5
Text Label 5150 3000 2    50   ~ 0
D4
Text Label 5150 2900 2    50   ~ 0
D3
Text Label 5150 2800 2    50   ~ 0
D2
Text Label 5150 2700 2    50   ~ 0
D1
Text Label 5150 2600 2    50   ~ 0
D0
Text GLabel 9450 1750 2    50   Output ~ 0
D[0..7]
Wire Wire Line
	4950 3300 5150 3300
Wire Wire Line
	5150 3200 4950 3200
Wire Wire Line
	4950 3100 5150 3100
Wire Wire Line
	5150 3000 4950 3000
Wire Wire Line
	4950 2900 5150 2900
Wire Wire Line
	5150 2800 4950 2800
Wire Wire Line
	4950 2700 5150 2700
Wire Wire Line
	5150 2600 4950 2600
Entry Wire Line
	5150 3300 5250 3400
Entry Wire Line
	5150 3200 5250 3300
Entry Wire Line
	5150 3100 5250 3200
Entry Wire Line
	5150 3000 5250 3100
Entry Wire Line
	5150 2900 5250 3000
Entry Wire Line
	5150 2800 5250 2900
Entry Wire Line
	5150 2700 5250 2800
Entry Wire Line
	5150 2600 5250 2700
Text Label 7300 3300 2    50   ~ 0
~PI7
Text Label 7300 3200 2    50   ~ 0
~PI6
Text Label 7300 3100 2    50   ~ 0
~PI5
Text Label 7300 3000 2    50   ~ 0
~PI4
Text Label 7300 2900 2    50   ~ 0
~PI3
Text Label 7300 2800 2    50   ~ 0
~PI2
Text Label 7300 2700 2    50   ~ 0
~PI1
Text Label 7300 2600 2    50   ~ 0
~PI0
Wire Bus Line
	9450 4100 7400 4100
Text GLabel 9450 4100 2    50   Output ~ 0
~PI[0..7]
Wire Wire Line
	6750 3300 7300 3300
Wire Wire Line
	7300 3200 6750 3200
Wire Wire Line
	6750 3100 7300 3100
Wire Wire Line
	7300 3000 6750 3000
Wire Wire Line
	6750 2900 7300 2900
Wire Wire Line
	7300 2800 6750 2800
Wire Wire Line
	6750 2700 7300 2700
Wire Wire Line
	7300 2600 6750 2600
Entry Wire Line
	7300 3300 7400 3400
Entry Wire Line
	7300 3200 7400 3300
Entry Wire Line
	7300 3100 7400 3200
Entry Wire Line
	7300 3000 7400 3100
Entry Wire Line
	7300 2900 7400 3000
Entry Wire Line
	7300 2800 7400 2900
Entry Wire Line
	7300 2700 7400 2800
Entry Wire Line
	7300 2600 7400 2700
Wire Wire Line
	5750 3100 5700 3100
Wire Wire Line
	5700 3300 5750 3300
Wire Wire Line
	5750 3200 5700 3200
$Comp
L power:VCC #PWR029
U 1 1 5DD4525E
P 5700 3100
F 0 "#PWR029" H 5700 2950 50  0001 C CNN
F 1 "VCC" V 5718 3227 50  0000 L CNN
F 2 "" H 5700 3100 50  0001 C CNN
F 3 "" H 5700 3100 50  0001 C CNN
	1    5700 3100
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5DD42551
P 6250 3750
AR Path="/5D2C0CA7/5DD42551" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5DD42551" Ref="#PWR032"  Part="1" 
F 0 "#PWR032" H 6250 3500 50  0001 C CNN
F 1 "GND" H 6255 3577 50  0000 C CNN
F 2 "" H 6250 3750 50  0001 C CNN
F 3 "" H 6250 3750 50  0001 C CNN
	1    6250 3750
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR031
U 1 1 5DD42017
P 6250 2300
F 0 "#PWR031" H 6250 2150 50  0001 C CNN
F 1 "VCC" H 6267 2473 50  0000 C CNN
F 2 "" H 6250 2300 50  0001 C CNN
F 3 "" H 6250 2300 50  0001 C CNN
	1    6250 2300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS138 U13
U 1 1 5DD40EA8
P 6250 2900
F 0 "U13" H 5950 3500 50  0000 C CNN
F 1 "74AHCT138" H 5950 3400 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 6250 2900 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct138.pdf" H 6250 2900 50  0001 C CNN
	1    6250 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	3150 3600 3950 3600
Wire Wire Line
	3150 2700 3150 3600
Wire Wire Line
	1650 2700 3150 2700
Wire Wire Line
	3250 2550 1650 2550
Wire Wire Line
	3250 3500 3250 2550
Wire Wire Line
	3950 3500 3250 3500
Text Label 3500 3300 0    50   ~ 0
DataBus7
Text Label 3500 3200 0    50   ~ 0
DataBus6
Text Label 3500 3100 0    50   ~ 0
DataBus5
Text Label 3500 3000 0    50   ~ 0
DataBus4
Text Label 3500 2900 0    50   ~ 0
DataBus3
Text Label 3500 2800 0    50   ~ 0
DataBus2
Text Label 3500 2700 0    50   ~ 0
DataBus1
Text Label 3500 2600 0    50   ~ 0
DataBus0
Wire Bus Line
	3350 2400 1650 2400
Text GLabel 1650 2400 0    50   Input ~ 0
DataBus[0..7]
Entry Wire Line
	3450 2600 3350 2500
Wire Wire Line
	3950 2600 3450 2600
Wire Wire Line
	3450 2700 3950 2700
Wire Wire Line
	3950 2800 3450 2800
Wire Wire Line
	3450 2900 3950 2900
Wire Wire Line
	3950 3000 3450 3000
Wire Wire Line
	3450 3100 3950 3100
Wire Wire Line
	3950 3200 3450 3200
Wire Wire Line
	3450 3300 3950 3300
Entry Wire Line
	3450 3100 3350 3000
Entry Wire Line
	3450 3000 3350 2900
Entry Wire Line
	3450 2900 3350 2800
Entry Wire Line
	3450 2800 3350 2700
Entry Wire Line
	3450 2700 3350 2600
Entry Wire Line
	3450 3200 3350 3100
Entry Wire Line
	3450 3300 3350 3200
Text GLabel 1650 2700 0    50   Input ~ 0
~DI
Text GLabel 1650 2550 0    50   Input ~ 0
RegisterClock0
$Comp
L 74xx:74LS377 U?
U 1 1 5D2A25F1
P 4450 3100
AR Path="/5D2C0CA7/5D2A25F1" Ref="U?"  Part="1" 
AR Path="/5D29E36D/5D2A25F1" Ref="U12"  Part="1" 
F 0 "U12" H 4150 3900 50  0000 C CNN
F 1 "74F377" H 4150 3800 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 4450 3100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 4450 3100 50  0001 C CNN
	1    4450 3100
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR027
U 1 1 5DD39690
P 4450 2300
F 0 "#PWR027" H 4450 2150 50  0001 C CNN
F 1 "VCC" H 4467 2473 50  0000 C CNN
F 2 "" H 4450 2300 50  0001 C CNN
F 3 "" H 4450 2300 50  0001 C CNN
	1    4450 2300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5D2A25FE
P 4450 3900
AR Path="/5D2C0CA7/5D2A25FE" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5D2A25FE" Ref="#PWR028"  Part="1" 
F 0 "#PWR028" H 4450 3650 50  0001 C CNN
F 1 "GND" H 4455 3727 50  0000 C CNN
F 2 "" H 4450 3900 50  0001 C CNN
F 3 "" H 4450 3900 50  0001 C CNN
	1    4450 3900
	1    0    0    -1  
$EndComp
Text GLabel 2450 4750 0    50   Input ~ 0
D[0..7]
Wire Wire Line
	3100 4850 3100 5450
Wire Wire Line
	3000 5450 3000 4850
Wire Wire Line
	2900 4850 2900 5450
Wire Wire Line
	2800 5450 2800 4850
Wire Wire Line
	2700 4850 2700 5450
Wire Wire Line
	3500 5300 3500 5450
Wire Wire Line
	3200 4850 3200 5450
$Comp
L Connector:Conn_01x09_Female J2
U 1 1 5D83DE8F
P 3100 5650
F 0 "J2" V 3250 5600 50  0000 C CNN
F 1 "D Register LED Connector" V 3350 5600 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x09_P2.54mm_Vertical" H 3100 5650 50  0001 C CNN
F 3 "~" H 3100 5650 50  0001 C CNN
	1    3100 5650
	0    1    1    0   
$EndComp
Wire Wire Line
	3400 4850 3400 5450
Wire Wire Line
	3300 4850 3300 5450
Text Label 3400 4950 1    50   ~ 0
D0
Text Label 3300 4950 1    50   ~ 0
D1
Text Label 3200 4950 1    50   ~ 0
D2
Text Label 3100 4950 1    50   ~ 0
D3
Text Label 3000 4950 1    50   ~ 0
D4
Text Label 2900 4950 1    50   ~ 0
D5
Text Label 2800 4950 1    50   ~ 0
D6
Text Label 2700 4950 1    50   ~ 0
D7
Entry Wire Line
	3400 4850 3300 4750
Entry Wire Line
	3300 4850 3200 4750
Entry Wire Line
	3200 4850 3100 4750
Entry Wire Line
	3100 4850 3000 4750
Entry Wire Line
	3000 4850 2900 4750
Entry Wire Line
	2900 4850 2800 4750
Entry Wire Line
	2800 4850 2700 4750
Entry Wire Line
	2700 4850 2600 4750
$Comp
L power:GND #PWR?
U 1 1 5DCE36CD
P 3500 5300
AR Path="/5D2C07CD/5DCE36CD" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CA7/5DCE36CD" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5DCE36CD" Ref="#PWR?"  Part="1" 
AR Path="/5D2C12A5/5DCE36CD" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5DCE36CD" Ref="#PWR026"  Part="1" 
F 0 "#PWR026" H 3500 5050 50  0001 C CNN
F 1 "GND" H 3505 5127 50  0000 C CNN
F 2 "" H 3500 5300 50  0001 C CNN
F 3 "" H 3500 5300 50  0001 C CNN
	1    3500 5300
	1    0    0    1   
$EndComp
Connection ~ 4300 7450
Wire Wire Line
	4800 7450 4300 7450
Connection ~ 4300 7150
Wire Wire Line
	4300 7150 4800 7150
$Comp
L power:VCC #PWR?
U 1 1 5DCE5DF5
P 4300 7150
AR Path="/5D2C07CD/5DCE5DF5" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5DCE5DF5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CA7/5DCE5DF5" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5DCE5DF5" Ref="#PWR033"  Part="1" 
F 0 "#PWR033" H 4300 7000 50  0001 C CNN
F 1 "VCC" H 4317 7323 50  0000 C CNN
F 2 "" H 4300 7150 50  0001 C CNN
F 3 "" H 4300 7150 50  0001 C CNN
	1    4300 7150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5DCE5DEF
P 4300 7450
AR Path="/5D2C07CD/5DCE5DEF" Ref="#PWR?"  Part="1" 
AR Path="/5D7BD0EA/5DCE5DEF" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CA7/5DCE5DEF" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5DCE5DEF" Ref="#PWR034"  Part="1" 
F 0 "#PWR034" H 4300 7200 50  0001 C CNN
F 1 "GND" H 4305 7277 50  0000 C CNN
F 2 "" H 4300 7450 50  0001 C CNN
F 3 "" H 4300 7450 50  0001 C CNN
	1    4300 7450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DCE5DE9
P 4800 7300
AR Path="/5D2C07CD/5DCE5DE9" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5DCE5DE9" Ref="C?"  Part="1" 
AR Path="/5D2C0CA7/5DCE5DE9" Ref="C?"  Part="1" 
AR Path="/5D29E36D/5DCE5DE9" Ref="C13"  Part="1" 
F 0 "C13" H 4915 7346 50  0000 L CNN
F 1 "100nF" H 4915 7255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 4838 7150 50  0001 C CNN
F 3 "~" H 4800 7300 50  0001 C CNN
	1    4800 7300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DCE5DE3
P 4300 7300
AR Path="/5D2C07CD/5DCE5DE3" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5DCE5DE3" Ref="C?"  Part="1" 
AR Path="/5D2C0CA7/5DCE5DE3" Ref="C?"  Part="1" 
AR Path="/5D29E36D/5DCE5DE3" Ref="C12"  Part="1" 
F 0 "C12" H 4415 7346 50  0000 L CNN
F 1 "100nF" H 4415 7255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 4338 7150 50  0001 C CNN
F 3 "~" H 4300 7300 50  0001 C CNN
	1    4300 7300
	1    0    0    -1  
$EndComp
Text GLabel 1650 2850 0    50   Input ~ 0
~PI
Text GLabel 1650 3000 0    50   Input ~ 0
~PO
Text Label 5650 4800 2    50   ~ 0
D2
Text Label 5650 4700 2    50   ~ 0
D1
Text Label 5650 4600 2    50   ~ 0
D0
Wire Wire Line
	5550 4800 5750 4800
Wire Wire Line
	5750 4700 5550 4700
Wire Wire Line
	5550 4600 5750 4600
Entry Wire Line
	5550 4600 5450 4500
Entry Wire Line
	5450 4700 5550 4800
Entry Wire Line
	5450 4600 5550 4700
Text Label 7300 5300 2    50   ~ 0
~PO7
Text Label 7300 5200 2    50   ~ 0
~PO6
Text Label 7300 5100 2    50   ~ 0
~PO5
Text Label 7300 5000 2    50   ~ 0
~PO4
Text Label 7300 4900 2    50   ~ 0
~PO3
Text Label 7300 4800 2    50   ~ 0
~PO2
Text Label 7300 4700 2    50   ~ 0
~PO1
Text Label 7300 4600 2    50   ~ 0
~PO0
Wire Wire Line
	6750 5300 7300 5300
Wire Wire Line
	7300 5200 6750 5200
Wire Wire Line
	6750 5100 7300 5100
Wire Wire Line
	7300 5000 6750 5000
Wire Wire Line
	6750 4900 7300 4900
Wire Wire Line
	7300 4800 6750 4800
Wire Wire Line
	6750 4700 7300 4700
Wire Wire Line
	7300 4600 6750 4600
Wire Wire Line
	5750 5100 5700 5100
Wire Wire Line
	5700 5300 5750 5300
Wire Wire Line
	5750 5200 5700 5200
$Comp
L 74xx:74LS138 U1
U 1 1 5D9BABA2
P 6250 4900
F 0 "U1" H 5950 5500 50  0000 C CNN
F 1 "74AHCT138" H 5950 5400 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 6250 4900 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ahct138.pdf" H 6250 4900 50  0001 C CNN
	1    6250 4900
	1    0    0    -1  
$EndComp
Wire Bus Line
	5250 4400 5450 4400
Connection ~ 5250 2400
Wire Bus Line
	5250 2400 5250 1750
Wire Bus Line
	9450 1750 5250 1750
Wire Bus Line
	9450 6100 7400 6100
Text GLabel 9450 6100 2    50   Output ~ 0
~PO[0..7]
Entry Wire Line
	7300 5300 7400 5400
Entry Wire Line
	7300 5200 7400 5300
Entry Wire Line
	7300 5100 7400 5200
Entry Wire Line
	7300 5000 7400 5100
Entry Wire Line
	7300 4900 7400 5000
Entry Wire Line
	7300 4800 7400 4900
Entry Wire Line
	7300 4700 7400 4800
Entry Wire Line
	7300 4600 7400 4700
Wire Wire Line
	5700 3200 5700 3250
Wire Wire Line
	5700 5200 5700 5250
Wire Wire Line
	5700 3250 5350 3250
Wire Wire Line
	5350 3250 5350 4200
Wire Wire Line
	5350 4200 3050 4200
Wire Wire Line
	3050 4200 3050 2850
Wire Wire Line
	3050 2850 1650 2850
Connection ~ 5700 3250
Wire Wire Line
	5700 3250 5700 3300
Wire Wire Line
	1650 3000 2950 3000
Wire Wire Line
	2950 3000 2950 4300
Wire Wire Line
	2950 4300 5150 4300
Wire Wire Line
	5150 4300 5150 5250
Wire Wire Line
	5150 5250 5700 5250
Connection ~ 5700 5250
Wire Wire Line
	5700 5250 5700 5300
Wire Wire Line
	5300 7450 4800 7450
Wire Wire Line
	4800 7150 5300 7150
$Comp
L Device:C C?
U 1 1 5D9FE1CE
P 5300 7300
AR Path="/5D2C07CD/5D9FE1CE" Ref="C?"  Part="1" 
AR Path="/5D7BD0EA/5D9FE1CE" Ref="C?"  Part="1" 
AR Path="/5D2C0CA7/5D9FE1CE" Ref="C?"  Part="1" 
AR Path="/5D29E36D/5D9FE1CE" Ref="C2"  Part="1" 
F 0 "C2" H 5415 7346 50  0000 L CNN
F 1 "100nF" H 5415 7255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 5338 7150 50  0001 C CNN
F 3 "~" H 5300 7300 50  0001 C CNN
	1    5300 7300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 3600 6250 3650
Wire Wire Line
	6250 3650 6800 3650
Wire Wire Line
	6800 3650 6800 5800
Wire Wire Line
	6800 5800 6250 5800
Wire Wire Line
	6250 5800 6250 5600
Connection ~ 6250 3650
Wire Wire Line
	6250 3650 6250 3750
$Comp
L power:VCC #PWR0218
U 1 1 5DD1728C
P 5700 5100
F 0 "#PWR0218" H 5700 4950 50  0001 C CNN
F 1 "VCC" V 5718 5227 50  0000 L CNN
F 2 "" H 5700 5100 50  0001 C CNN
F 3 "" H 5700 5100 50  0001 C CNN
	1    5700 5100
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR0220
U 1 1 5DD18FC5
P 6250 4300
F 0 "#PWR0220" H 6250 4150 50  0001 C CNN
F 1 "VCC" H 6267 4473 50  0000 C CNN
F 2 "" H 6250 4300 50  0001 C CNN
F 3 "" H 6250 4300 50  0001 C CNN
	1    6250 4300
	1    0    0    -1  
$EndComp
Wire Bus Line
	5450 2400 5450 2700
Wire Bus Line
	5450 4400 5450 4700
Wire Bus Line
	3350 2400 3350 3200
Wire Bus Line
	2450 4750 3300 4750
Wire Bus Line
	7400 2700 7400 4100
Wire Bus Line
	7400 4700 7400 6100
Wire Bus Line
	5250 2400 5250 4400
$EndSCHEMATC
