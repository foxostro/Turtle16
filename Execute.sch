EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 19 21
Title "Execute"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 "a constant value."
Comment4 "The lower eight bits of the instruction register can be expressed onto the data bus as"
$EndDescr
Text GLabel 1500 4550 0    50   Input ~ 0
ControlWord[0..31]
$Comp
L 74xx:74LS245 U?
U 1 1 5D9156B5
P 6750 2200
AR Path="/5D2C0CA7/5D9156B5" Ref="U?"  Part="1" 
AR Path="/5D7BD0EA/5D9156B5" Ref="U?"  Part="1" 
AR Path="/5D2C0B92/5D9156B5" Ref="U?"  Part="1" 
AR Path="/5D2C13FD/5D9156B5" Ref="U48"  Part="1" 
F 0 "U48" H 6450 3000 50  0000 C CNN
F 1 "74AHCT245" H 6450 2900 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 6750 2200 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn54ahct245.pdf" H 6750 2200 50  0001 C CNN
	1    6750 2200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5D9156C1
P 6750 3000
AR Path="/5D2C0B92/5D9156C1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C13FD/5D9156C1" Ref="#PWR0138"  Part="1" 
F 0 "#PWR0138" H 6750 2750 50  0001 C CNN
F 1 "GND" H 6755 2827 50  0000 C CNN
F 2 "" H 6750 3000 50  0001 C CNN
F 3 "" H 6750 3000 50  0001 C CNN
	1    6750 3000
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5D9156CD
P 6750 1400
AR Path="/5D2C0B92/5D9156CD" Ref="#PWR?"  Part="1" 
AR Path="/5D2C13FD/5D9156CD" Ref="#PWR0137"  Part="1" 
F 0 "#PWR0137" H 6750 1250 50  0001 C CNN
F 1 "VCC" H 6767 1573 50  0000 C CNN
F 2 "" H 6750 1400 50  0001 C CNN
F 3 "" H 6750 1400 50  0001 C CNN
	1    6750 1400
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5D9156D3
P 6250 2600
AR Path="/5D2C0B92/5D9156D3" Ref="#PWR?"  Part="1" 
AR Path="/5D2C13FD/5D9156D3" Ref="#PWR0136"  Part="1" 
F 0 "#PWR0136" H 6250 2450 50  0001 C CNN
F 1 "VCC" V 6268 2727 50  0000 L CNN
F 2 "" H 6250 2600 50  0001 C CNN
F 3 "" H 6250 2600 50  0001 C CNN
	1    6250 2600
	0    -1   -1   0   
$EndComp
Entry Wire Line
	7650 1700 7750 1800
Entry Wire Line
	7650 1800 7750 1900
Entry Wire Line
	7650 1900 7750 2000
Entry Wire Line
	7650 2000 7750 2100
Entry Wire Line
	7650 2100 7750 2200
Entry Wire Line
	7650 2200 7750 2300
Entry Wire Line
	7650 2300 7750 2400
Entry Wire Line
	7650 2400 7750 2500
Wire Wire Line
	7250 1700 7650 1700
Wire Wire Line
	7650 1800 7250 1800
Wire Wire Line
	7250 1900 7650 1900
Wire Wire Line
	7650 2000 7250 2000
Wire Wire Line
	7250 2100 7650 2100
Wire Wire Line
	7650 2200 7250 2200
Wire Wire Line
	7250 2300 7650 2300
Wire Wire Line
	7650 2400 7250 2400
Text GLabel 9900 2800 2    50   Output ~ 0
DataBus[0..7]
Wire Bus Line
	9900 2800 7750 2800
Text Label 7250 1700 0    50   ~ 0
DataBus0
Text Label 7250 1800 0    50   ~ 0
DataBus1
Text Label 7250 1900 0    50   ~ 0
DataBus2
Text Label 7250 2000 0    50   ~ 0
DataBus3
Text Label 7250 2100 0    50   ~ 0
DataBus4
Text Label 7250 2200 0    50   ~ 0
DataBus5
Text Label 7250 2300 0    50   ~ 0
DataBus6
Text Label 7250 2400 0    50   ~ 0
DataBus7
Text GLabel 1150 2700 0    50   Input ~ 0
~CO
$Comp
L power:GND #PWR?
U 1 1 5D91585D
P 1700 7700
AR Path="/5D2C0761/5D91585D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0B92/5D91585D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C13FD/5D91585D" Ref="#PWR0133"  Part="1" 
F 0 "#PWR0133" H 1700 7450 50  0001 C CNN
F 1 "GND" H 1705 7527 50  0000 C CNN
F 2 "" H 1700 7700 50  0001 C CNN
F 3 "" H 1700 7700 50  0001 C CNN
	1    1700 7700
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5D91587B
P 1700 7550
AR Path="/5D2C0761/5D91587B" Ref="C?"  Part="1" 
AR Path="/5D2C0B92/5D91587B" Ref="C?"  Part="1" 
AR Path="/5D2C13FD/5D91587B" Ref="C48"  Part="1" 
F 0 "C48" H 1815 7596 50  0000 L CNN
F 1 "100nF" H 1815 7505 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.3mm_W1.9mm_P5.00mm" H 1738 7400 50  0001 C CNN
F 3 "~" H 1700 7550 50  0001 C CNN
	1    1700 7550
	1    0    0    -1  
$EndComp
Entry Wire Line
	5850 2300 5950 2400
Entry Wire Line
	5850 2200 5950 2300
Entry Wire Line
	5850 2100 5950 2200
Entry Wire Line
	5850 2000 5950 2100
Entry Wire Line
	5850 1900 5950 2000
Entry Wire Line
	5850 1800 5950 1900
Entry Wire Line
	5850 1700 5950 1800
Entry Wire Line
	5850 1600 5950 1700
Text GLabel 1100 1050 0    50   Input ~ 0
C[0..7]
Text Label 6050 1700 2    50   ~ 0
C0
Text Label 6050 1800 2    50   ~ 0
C1
Text Label 6050 1900 2    50   ~ 0
C2
Text Label 6050 2000 2    50   ~ 0
C3
Text Label 6050 2100 2    50   ~ 0
C4
Text Label 6050 2200 2    50   ~ 0
C5
Text Label 6050 2300 2    50   ~ 0
C6
Text Label 6050 2400 2    50   ~ 0
C7
Wire Wire Line
	5950 1700 6250 1700
Wire Wire Line
	6250 1800 5950 1800
Wire Wire Line
	5950 1900 6250 1900
Wire Wire Line
	6250 2000 5950 2000
Wire Wire Line
	5950 2100 6250 2100
Wire Wire Line
	6250 2200 5950 2200
Wire Wire Line
	5950 2300 6250 2300
Wire Wire Line
	6250 2400 5950 2400
Wire Wire Line
	1150 2700 6250 2700
Entry Wire Line
	6100 4550 6200 4450
Entry Wire Line
	6250 4550 6350 4450
Entry Wire Line
	6400 4550 6500 4450
Entry Wire Line
	6550 4550 6650 4450
Entry Wire Line
	6700 4550 6800 4450
Entry Wire Line
	6850 4550 6950 4450
Entry Wire Line
	7150 4550 7250 4450
Entry Wire Line
	7300 4550 7400 4450
Entry Wire Line
	7450 4550 7550 4450
Entry Wire Line
	7600 4550 7700 4450
Entry Wire Line
	7750 4550 7850 4450
Entry Wire Line
	7900 4550 8000 4450
Entry Wire Line
	8050 4550 8150 4450
Entry Wire Line
	8200 4550 8300 4450
Entry Wire Line
	8350 4550 8450 4450
Text Label 8450 4400 1    50   ~ 0
ControlWord0
Text Label 8300 4400 1    50   ~ 0
ControlWord1
Wire Wire Line
	8450 3800 8450 4450
Wire Wire Line
	8300 3800 8300 4450
Wire Wire Line
	8150 3800 8150 4450
Wire Wire Line
	8000 3800 8000 4450
Wire Wire Line
	7850 3800 7850 4450
Wire Wire Line
	7700 3800 7700 4450
Wire Wire Line
	7550 3800 7550 4450
Wire Wire Line
	7400 3800 7400 4450
Wire Wire Line
	7250 3800 7250 4450
Wire Wire Line
	6950 3800 6950 4450
Wire Wire Line
	6800 3800 6800 4450
Wire Wire Line
	6650 3800 6650 4450
Wire Wire Line
	6500 3800 6500 4450
Wire Wire Line
	6350 3800 6350 4450
Wire Wire Line
	6200 3800 6200 4450
Text Label 8150 4400 1    50   ~ 0
ControlWord2
Text Label 8000 4400 1    50   ~ 0
ControlWord3
Text Label 7850 4400 1    50   ~ 0
ControlWord4
Text Label 7700 4400 1    50   ~ 0
ControlWord5
Text Label 7550 4400 1    50   ~ 0
ControlWord6
Text Label 7400 4400 1    50   ~ 0
ControlWord7
Text Label 7250 4400 1    50   ~ 0
ControlWord8
Text Label 6950 4400 1    50   ~ 0
ControlWord10
Text Label 6800 4400 1    50   ~ 0
ControlWord11
Text Label 6650 4400 1    50   ~ 0
ControlWord12
Text Label 6500 4400 1    50   ~ 0
ControlWord13
Text Label 6350 4400 1    50   ~ 0
ControlWord14
Text Label 6200 4400 1    50   ~ 0
ControlWord15
Text GLabel 6200 3800 1    50   Output ~ 0
~XI
Text GLabel 6350 3800 1    50   Output ~ 0
~PO
Text GLabel 6500 3800 1    50   Output ~ 0
~PI
Text GLabel 6650 3800 1    50   Output ~ 0
UVInc
Text GLabel 6800 3800 1    50   Output ~ 0
~VO
Text GLabel 6950 3800 1    50   Output ~ 0
~VI
Text GLabel 7250 3800 1    50   Output ~ 0
~UI
Text GLabel 7400 3800 1    50   Output ~ 0
~FI
Text GLabel 7550 3800 1    50   Output ~ 0
~EO
Text GLabel 7700 3800 1    50   Output ~ 0
~DI
Text GLabel 7850 3800 1    50   Output ~ 0
~CO
Text GLabel 8000 3800 1    50   Output ~ 0
~BO
Text GLabel 8150 3800 1    50   Output ~ 0
~BI
Text GLabel 8300 3800 1    50   Output ~ 0
~AO
Text GLabel 8450 3800 1    50   Output ~ 0
~AI
Wire Wire Line
	4400 1300 4400 1600
$Comp
L power:GND #PWR?
U 1 1 5DBAF93D
P 4400 1300
AR Path="/5D2C12A5/5DBAF93D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0CA7/5DBAF93D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C13FD/5DBAF93D" Ref="#PWR0134"  Part="1" 
F 0 "#PWR0134" H 4400 1050 50  0001 C CNN
F 1 "GND" H 4405 1127 50  0000 C CNN
F 2 "" H 4400 1300 50  0001 C CNN
F 3 "" H 4400 1300 50  0001 C CNN
	1    4400 1300
	-1   0    0    1   
$EndComp
Entry Wire Line
	3700 1150 3600 1050
Wire Wire Line
	3700 1150 3700 1600
Text Label 3700 1550 1    50   ~ 0
C6
Wire Wire Line
	3900 1150 3900 1600
Text Label 3900 1550 1    50   ~ 0
C4
$Comp
L Connector:Conn_01x09_Female J?
U 1 1 5DBAF948
P 4000 1800
AR Path="/5D29E36D/5DBAF948" Ref="J?"  Part="1" 
AR Path="/5D2C12A5/5DBAF948" Ref="J?"  Part="1" 
AR Path="/5D2C0CE4/5DBAF948" Ref="J?"  Part="1" 
AR Path="/5D2C0D13/5DBAF948" Ref="J?"  Part="1" 
AR Path="/5D2C0CA7/5DBAF948" Ref="J?"  Part="1" 
AR Path="/5D2C13FD/5DBAF948" Ref="J5"  Part="1" 
F 0 "J5" V 4150 1750 50  0000 C CNN
F 1 "C Register LED Connector" V 4250 1750 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x09_P2.54mm_Vertical" H 4000 1800 50  0001 C CNN
F 3 "~" H 4000 1800 50  0001 C CNN
	1    4000 1800
	0    1    1    0   
$EndComp
Text Label 4300 1550 1    50   ~ 0
C0
Text Label 4200 1550 1    50   ~ 0
C1
Text Label 4100 1550 1    50   ~ 0
C2
Text Label 4000 1550 1    50   ~ 0
C3
Text Label 3800 1550 1    50   ~ 0
C5
Text Label 3600 1550 1    50   ~ 0
C7
Wire Wire Line
	3600 1150 3600 1600
Wire Wire Line
	3800 1150 3800 1600
Wire Wire Line
	4000 1150 4000 1600
Wire Wire Line
	4100 1150 4100 1600
Wire Wire Line
	4200 1150 4200 1600
Wire Wire Line
	4300 1150 4300 1600
Entry Wire Line
	3600 1150 3500 1050
Entry Wire Line
	3800 1150 3700 1050
Entry Wire Line
	4300 1150 4200 1050
Entry Wire Line
	4200 1150 4100 1050
Entry Wire Line
	4100 1150 4000 1050
Entry Wire Line
	4000 1150 3900 1050
Entry Wire Line
	3900 1150 3800 1050
Text GLabel 7100 3800 1    50   Output ~ 0
~UO
Text Label 7100 4400 1    50   ~ 0
ControlWord9
Wire Wire Line
	7100 3800 7100 4450
Entry Wire Line
	7000 4550 7100 4450
Entry Wire Line
	4900 4550 5000 4450
Entry Wire Line
	5050 4550 5150 4450
Entry Wire Line
	5200 4550 5300 4450
Entry Wire Line
	5350 4550 5450 4450
Entry Wire Line
	5500 4550 5600 4450
Entry Wire Line
	5650 4550 5750 4450
Entry Wire Line
	5800 4550 5900 4450
Entry Wire Line
	5950 4550 6050 4450
Text Label 6050 4400 1    50   ~ 0
ControlWord16
Text Label 5900 4400 1    50   ~ 0
ControlWord17
Wire Wire Line
	6050 3800 6050 4450
Wire Wire Line
	5900 3800 5900 4450
Wire Wire Line
	5750 3800 5750 4450
Wire Wire Line
	5600 3800 5600 4450
Wire Wire Line
	5450 3800 5450 4450
Wire Wire Line
	5300 3800 5300 4450
Wire Wire Line
	5150 3800 5150 4450
Wire Wire Line
	5000 3800 5000 4450
Text Label 5750 4400 1    50   ~ 0
ControlWord18
Text Label 5600 4400 1    50   ~ 0
ControlWord19
Text Label 5450 4400 1    50   ~ 0
ControlWord20
Text Label 5300 4400 1    50   ~ 0
ControlWord21
Text Label 5150 4400 1    50   ~ 0
ControlWord22
Text Label 5000 4400 1    50   ~ 0
ControlWord23
Text GLabel 5000 3800 1    50   Output ~ 0
~LinkLoOut
Text GLabel 5150 3800 1    50   Output ~ 0
~LinkIn
Text GLabel 5300 3800 1    50   Output ~ 0
~MO
Text GLabel 5450 3800 1    50   Output ~ 0
~MI
Text GLabel 5600 3800 1    50   Output ~ 0
XYInc
Text GLabel 5750 3800 1    50   Output ~ 0
~YO
Text GLabel 5900 3800 1    50   Output ~ 0
~YI
Text GLabel 6050 3800 1    50   Output ~ 0
~XO
Entry Wire Line
	3700 4550 3800 4450
Entry Wire Line
	4450 4550 4550 4450
Entry Wire Line
	4600 4550 4700 4450
Entry Wire Line
	4750 4550 4850 4450
Text Label 4850 4400 1    50   ~ 0
ControlWord24
Text Label 4700 4400 1    50   ~ 0
ControlWord25
Wire Wire Line
	4850 3800 4850 4450
Wire Wire Line
	4700 3800 4700 4450
Wire Wire Line
	4550 3800 4550 4450
Wire Wire Line
	3800 3800 3800 4450
Text Label 4550 4400 1    50   ~ 0
ControlWord26
Text Label 3800 4400 1    50   ~ 0
ControlWord31
Text GLabel 3800 3800 1    50   Output ~ 0
~HLT
Text GLabel 4700 3800 1    50   Output ~ 0
~J
Text GLabel 4850 3800 1    50   Output ~ 0
~LinkHiOut
Text GLabel 4550 3800 1    50   Output ~ 0
~CarryIn
$Comp
L power:VCC #PWR0132
U 1 1 5DD28AFB
P 1700 7400
F 0 "#PWR0132" H 1700 7250 50  0001 C CNN
F 1 "VCC" H 1717 7573 50  0000 C CNN
F 2 "" H 1700 7400 50  0001 C CNN
F 3 "" H 1700 7400 50  0001 C CNN
	1    1700 7400
	1    0    0    -1  
$EndComp
Wire Bus Line
	1100 1050 5850 1050
Wire Bus Line
	5850 1050 5850 2300
Wire Bus Line
	7750 1800 7750 2800
Wire Bus Line
	1500 4550 8350 4550
$EndSCHEMATC
