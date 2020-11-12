EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 3 41
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
L Power_Supervisor:MCP100-450D U?
U 1 1 5DEC3D1A
P 2600 1950
AR Path="/5D2C0761/5DEC3D1A" Ref="U?"  Part="1" 
AR Path="/5D2C0720/5DEC3D1A" Ref="U8"  Part="1" 
F 0 "U8" H 2371 1996 50  0000 R CNN
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
AR Path="/5D2C0720/5DEC3D20" Ref="#PWR027"  Part="1" 
F 0 "#PWR027" H 1450 650 50  0001 C CNN
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
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 1450 1050 50  0001 C CNN
F 3 "~" H 1450 1050 50  0001 C CNN
	1    1450 1050
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 5DEC3D7D
P 3750 2850
AR Path="/5D2C0720/5DEC3D7D" Ref="R2"  Part="1" 
AR Path="/5D2C0761/5DEC3D7D" Ref="R?"  Part="1" 
F 0 "R2" H 3818 2896 50  0000 L CNN
F 1 "220Ω" H 3818 2805 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" V 3790 2840 50  0001 C CNN
F 3 "~" H 3750 2850 50  0001 C CNN
	1    3750 2850
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D1
U 1 1 5DEC3D83
P 3750 2500
AR Path="/5D2C0720/5DEC3D83" Ref="D1"  Part="1" 
AR Path="/5D2C0761/5DEC3D83" Ref="D?"  Part="1" 
F 0 "D1" V 3789 2383 50  0000 R CNN
F 1 "Reset" V 3698 2383 50  0000 R CNN
F 2 "LED_THT:LED_D5.0mm" H 3750 2500 50  0001 C CNN
F 3 "~" H 3750 2500 50  0001 C CNN
	1    3750 2500
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5DEC3D90
P 6350 2450
AR Path="/5D2C0761/5DEC3D90" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3D90" Ref="#PWR037"  Part="1" 
F 0 "#PWR037" H 6350 2300 50  0001 C CNN
F 1 "VCC" H 6367 2623 50  0000 C CNN
F 2 "" H 6350 2450 50  0001 C CNN
F 3 "" H 6350 2450 50  0001 C CNN
	1    6350 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 2450 6350 2500
$Comp
L power:GND #PWR038
U 1 1 5DEC3D97
P 6350 4500
AR Path="/5D2C0720/5DEC3D97" Ref="#PWR038"  Part="1" 
AR Path="/5D2C0761/5DEC3D97" Ref="#PWR?"  Part="1" 
F 0 "#PWR038" H 6350 4250 50  0001 C CNN
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
AR Path="/5D2C0720/5DEC3DB4" Ref="#PWR032"  Part="1" 
F 0 "#PWR032" H 3750 3000 50  0001 C CNN
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
AR Path="/5D2C0720/5DEC3DBA" Ref="C6"  Part="1" 
F 0 "C6" H 5415 1046 50  0000 L CNN
F 1 "100nF" H 5415 955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0201_0603Metric_Pad0.64x0.40mm_HandSolder" H 5338 850 50  0001 C CNN
F 3 "~" H 5300 1000 50  0001 C CNN
	1    5300 1000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DC0
P 5800 1000
AR Path="/5D2C0761/5DEC3DC0" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DC0" Ref="C7"  Part="1" 
F 0 "C7" H 5915 1046 50  0000 L CNN
F 1 "100nF" H 5915 955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0201_0603Metric_Pad0.64x0.40mm_HandSolder" H 5838 850 50  0001 C CNN
F 3 "~" H 5800 1000 50  0001 C CNN
	1    5800 1000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DC6
P 6300 1000
AR Path="/5D2C0761/5DEC3DC6" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DC6" Ref="C8"  Part="1" 
F 0 "C8" H 6415 1046 50  0000 L CNN
F 1 "100nF" H 6415 955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0201_0603Metric_Pad0.64x0.40mm_HandSolder" H 6338 850 50  0001 C CNN
F 3 "~" H 6300 1000 50  0001 C CNN
	1    6300 1000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5DEC3DCC
P 6800 1000
AR Path="/5D2C0761/5DEC3DCC" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5DEC3DCC" Ref="C9"  Part="1" 
F 0 "C9" H 6915 1046 50  0000 L CNN
F 1 "100nF" H 6915 955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0201_0603Metric_Pad0.64x0.40mm_HandSolder" H 6838 850 50  0001 C CNN
F 3 "~" H 6800 1000 50  0001 C CNN
	1    6800 1000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5DEC3DD2
P 5300 1150
AR Path="/5D2C0761/5DEC3DD2" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3DD2" Ref="#PWR034"  Part="1" 
F 0 "#PWR034" H 5300 900 50  0001 C CNN
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
AR Path="/5D2C0720/5DEC3DD8" Ref="#PWR033"  Part="1" 
F 0 "#PWR033" H 5300 700 50  0001 C CNN
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
AR Path="/5D2C0720/5DEC3DF0" Ref="U9"  Part="1" 
F 0 "U9" H 6550 4300 50  0000 C CNN
F 1 "74AHCT157" H 6550 4200 50  0000 C CNN
F 2 "Package_SO:SOP-16_4.4x10.4mm_P1.27mm" H 6350 3400 50  0001 C CNN
F 3 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT157DR?qs=UGVLDq%2F29ui8OtPpHyHWiQ%3D%3D" H 6350 3400 50  0001 C CNN
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
Connection ~ 7650 2800
NoConn ~ -500 2500
NoConn ~ -500 4000
NoConn ~ -500 4500
$Comp
L 74xx:74LS04 U?
U 1 1 5DFDD475
P 3350 2350
AR Path="/5D2C0761/5DFDD475" Ref="U?"  Part="3" 
AR Path="/5D2C0720/5DFDD475" Ref="U6"  Part="1" 
F 0 "U6" H 3350 2667 50  0000 C CNN
F 1 "74AHCT04" H 3350 2576 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 3350 2350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3350 2350 50  0001 C CNN
	1    3350 2350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 7 1 5E3187C8
P -1100 5300
AR Path="/5D2C0761/5E3187C8" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5E3187C8" Ref="U6"  Part="7" 
F 0 "U6" H -1100 5350 50  0000 C CNN
F 1 "74AHCT04" H -1100 5250 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1100 5300 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1100 5300 50  0001 C CNN
	7    -1100 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5E326F07
P -800 4500
AR Path="/5D8005AF/5D800744/5E326F07" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E326F07" Ref="U6"  Part="6" 
F 0 "U6" H -800 4817 50  0000 C CNN
F 1 "74AHCT04" H -800 4726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 4500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 4500 50  0001 C CNN
	6    -800 4500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5E338851
P -800 2500
AR Path="/5D8005AF/5D800744/5E338851" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E338851" Ref="U6"  Part="2" 
F 0 "U6" H -800 2817 50  0000 C CNN
F 1 "74AHCT04" H -800 2726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 2500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 2500 50  0001 C CNN
	2    -800 2500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5E3CD911
P -800 4000
AR Path="/5D8005AF/5D800744/5E3CD911" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CD911" Ref="U6"  Part="5" 
F 0 "U6" H -800 4317 50  0000 C CNN
F 1 "74AHCT04" H -800 4226 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 4000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 4000 50  0001 C CNN
	5    -800 4000
	1    0    0    -1  
$EndComp
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
	1450 1350 2200 1350
Connection ~ 1450 1350
Wire Wire Line
	1450 1350 1450 1750
Wire Wire Line
	4350 4000 4350 1950
Connection ~ 4350 1950
Wire Wire Line
	4350 4000 5850 4000
$Comp
L Device:C C?
U 1 1 5E2B93B8
P 7300 1000
AR Path="/5D2C0761/5E2B93B8" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5E2B93B8" Ref="C10"  Part="1" 
F 0 "C10" H 7415 1046 50  0000 L CNN
F 1 "100nF" H 7415 955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0201_0603Metric_Pad0.64x0.40mm_HandSolder" H 7338 850 50  0001 C CNN
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
	7650 5500 8400 5500
Wire Wire Line
	5150 2900 5150 4250
Wire Wire Line
	5150 4250 3150 4250
Text Label 7700 5400 0    50   ~ 0
RawClockSignal
$Comp
L power:GND #PWR040
U 1 1 5E07A6CE
P 8250 5950
F 0 "#PWR040" H 8250 5700 50  0001 C CNN
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
L power:VCC #PWR039
U 1 1 5E080807
P 8150 5700
F 0 "#PWR039" H 8150 5550 50  0001 C CNN
F 1 "VCC" V 8168 5827 50  0000 L CNN
F 2 "" H 8150 5700 50  0001 C CNN
F 3 "" H 8150 5700 50  0001 C CNN
	1    8150 5700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8150 5700 8400 5700
$Comp
L Connector:Conn_01x05_Female J2
U 1 1 5E00A594
P 8600 5600
F 0 "J2" H 8492 5175 50  0000 C CNN
F 1 "External Clock" H 8492 5266 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x05_P2.54mm_Vertical" H 8600 5600 50  0001 C CNN
F 3 "~" H 8600 5600 50  0001 C CNN
	1    8600 5600
	1    0    0    1   
$EndComp
Connection ~ 5750 3600
Wire Wire Line
	5750 3600 5750 3500
$Comp
L power:VCC #PWR?
U 1 1 5DEC3E01
P 5650 3600
AR Path="/5D2C0761/5DEC3E01" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5DEC3E01" Ref="#PWR035"  Part="1" 
F 0 "#PWR035" H 5650 3450 50  0001 C CNN
F 1 "VCC" V 5650 3800 50  0000 C CNN
F 2 "" H 5650 3600 50  0001 C CNN
F 3 "" H 5650 3600 50  0001 C CNN
	1    5650 3600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5850 3100 5750 3100
Wire Wire Line
	3200 4300 5200 4300
Wire Wire Line
	5200 4300 5200 3200
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
L power:GND #PWR036
U 1 1 5F533C17
P 5750 3100
F 0 "#PWR036" H 5750 2850 50  0001 C CNN
F 1 "GND" V 5755 2972 50  0000 R CNN
F 2 "" H 5750 3100 50  0001 C CNN
F 3 "" H 5750 3100 50  0001 C CNN
	1    5750 3100
	0    1    1    0   
$EndComp
Wire Wire Line
	4350 1950 10250 1950
Wire Wire Line
	7550 5600 8400 5600
Wire Wire Line
	6850 3100 7550 3100
$Comp
L 74xx:74LS04 U?
U 4 1 5E3CC9AE
P -800 3500
AR Path="/5D8005AF/5D800744/5E3CC9AE" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CC9AE" Ref="U6"  Part="4" 
F 0 "U6" H -800 3817 50  0000 C CNN
F 1 "74AHCT04" H -800 3726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 3500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 3500 50  0001 C CNN
	4    -800 3500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5E3CB33D
P -800 3000
AR Path="/5D8005AF/5D800744/5E3CB33D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5E3CB33D" Ref="U6"  Part="3" 
F 0 "U6" H -800 3317 50  0000 C CNN
F 1 "74AHCT04" H -800 3226 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 3000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 3000 50  0001 C CNN
	3    -800 3000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 3100 7550 5600
Wire Wire Line
	7550 3100 8900 3100
Connection ~ 7550 3100
Wire Wire Line
	7650 2800 8900 2800
Wire Wire Line
	7650 2800 7650 5500
Wire Wire Line
	5100 5400 8400 5400
Wire Wire Line
	5100 5400 5100 4900
Wire Wire Line
	5100 2800 5100 4900
Connection ~ 5100 4900
Wire Wire Line
	1700 4900 5100 4900
Wire Wire Line
	3200 5600 3200 4300
Wire Wire Line
	3050 5600 3200 5600
Wire Wire Line
	1700 4900 1700 5500
Wire Wire Line
	3150 4250 3150 5500
Wire Wire Line
	1700 5500 2050 5500
Connection ~ 1700 5500
Wire Wire Line
	1450 5500 1700 5500
Wire Wire Line
	1700 6000 2050 6000
Wire Wire Line
	2000 6200 2050 6200
Wire Wire Line
	2050 6100 2000 6100
$Comp
L power:GND #PWR?
U 1 1 5E153BBE
P 2550 6600
AR Path="/5D2C0CA7/5E153BBE" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5E153BBE" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BBE" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BBE" Ref="#PWR031"  Part="1" 
F 0 "#PWR031" H 2550 6350 50  0001 C CNN
F 1 "GND" H 2555 6427 50  0000 C CNN
F 2 "" H 2550 6600 50  0001 C CNN
F 3 "" H 2550 6600 50  0001 C CNN
	1    2550 6600
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5E153BC4
P 2550 5150
AR Path="/5D29E36D/5E153BC4" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BC4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BC4" Ref="#PWR030"  Part="1" 
F 0 "#PWR030" H 2550 5000 50  0001 C CNN
F 1 "VCC" H 2567 5323 50  0000 C CNN
F 2 "" H 2550 5150 50  0001 C CNN
F 3 "" H 2550 5150 50  0001 C CNN
	1    2550 5150
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS138 U?
U 1 1 5E153BCA
P 2550 5800
AR Path="/5D29E36D/5E153BCA" Ref="U?"  Part="1" 
AR Path="/5DAA13E6/5E153BCA" Ref="U?"  Part="1" 
AR Path="/5D2C0720/5E153BCA" Ref="U7"  Part="1" 
F 0 "U7" H 2250 6400 50  0000 C CNN
F 1 "74AHCT138" H 2250 6300 50  0000 C CNN
F 2 "Package_SO:SOP-16_4.4x10.4mm_P1.27mm" H 2550 5800 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct138" H 2550 5800 50  0001 C CNN
	1    2550 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	2550 6500 2550 6600
Wire Wire Line
	2000 5700 2050 5700
Wire Wire Line
	2050 5600 2000 5600
NoConn ~ 3050 5700
NoConn ~ 3050 5800
NoConn ~ 3050 5900
NoConn ~ 3050 6000
NoConn ~ 3050 6100
NoConn ~ 3050 6200
Wire Wire Line
	2550 5150 2550 5200
Wire Wire Line
	3050 5500 3150 5500
Wire Wire Line
	2000 5650 2000 5700
Connection ~ 2000 5650
Wire Wire Line
	2000 5600 2000 5650
Wire Wire Line
	1950 5650 2000 5650
$Comp
L power:GND #PWR?
U 1 1 5E153BDF
P 1950 5650
AR Path="/5D2C0CA7/5E153BDF" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5E153BDF" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BDF" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BDF" Ref="#PWR028"  Part="1" 
F 0 "#PWR028" H 1950 5400 50  0001 C CNN
F 1 "GND" V 1950 5450 50  0000 C CNN
F 2 "" H 1950 5650 50  0001 C CNN
F 3 "" H 1950 5650 50  0001 C CNN
	1    1950 5650
	0    1    1    0   
$EndComp
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
Wire Wire Line
	1150 5150 1150 5200
$Comp
L power:VCC #PWR025
U 1 1 5E0F85C8
P 1150 5150
F 0 "#PWR025" H 1150 5000 50  0001 C CNN
F 1 "VCC" H 1167 5323 50  0000 C CNN
F 2 "" H 1150 5150 50  0001 C CNN
F 3 "" H 1150 5150 50  0001 C CNN
	1    1150 5150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR026
U 1 1 5D888695
P 1150 5850
F 0 "#PWR026" H 1150 5600 50  0001 C CNN
F 1 "GND" H 1155 5677 50  0000 C CNN
F 2 "" H 1150 5850 50  0001 C CNN
F 3 "" H 1150 5850 50  0001 C CNN
	1    1150 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	1150 5800 1150 5850
Wire Wire Line
	2000 6150 2000 6200
Connection ~ 2000 6150
Wire Wire Line
	2000 6100 2000 6150
Wire Wire Line
	1950 6150 2000 6150
$Comp
L power:GND #PWR?
U 1 1 5E153BD2
P 1950 6150
AR Path="/5D2C0CA7/5E153BD2" Ref="#PWR?"  Part="1" 
AR Path="/5D29E36D/5E153BD2" Ref="#PWR?"  Part="1" 
AR Path="/5DAA13E6/5E153BD2" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5E153BD2" Ref="#PWR029"  Part="1" 
F 0 "#PWR029" H 1950 5900 50  0001 C CNN
F 1 "GND" V 1950 5950 50  0000 C CNN
F 2 "" H 1950 6150 50  0001 C CNN
F 3 "" H 1950 6150 50  0001 C CNN
	1    1950 6150
	0    1    1    0   
$EndComp
NoConn ~ -500 3000
NoConn ~ -500 3500
$Comp
L power:VCC #PWR?
U 1 1 5FCD1869
P -1100 1950
AR Path="/5D2C0761/5FCD1869" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FCD1869" Ref="#PWR023"  Part="1" 
F 0 "#PWR023" H -1100 1800 50  0001 C CNN
F 1 "VCC" H -1083 2123 50  0000 C CNN
F 2 "" H -1100 1950 50  0001 C CNN
F 3 "" H -1100 1950 50  0001 C CNN
	1    -1100 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1100 1950 -1100 2500
Wire Wire Line
	-1100 2500 -1100 3000
Connection ~ -1100 2500
Connection ~ -1100 3000
Wire Wire Line
	-1100 3000 -1100 3500
Connection ~ -1100 3500
Wire Wire Line
	-1100 3500 -1100 4000
Connection ~ -1100 4000
Wire Wire Line
	-1100 4000 -1100 4500
$Comp
L power:GND #PWR024
U 1 1 5FD35768
P -1100 5950
AR Path="/5D2C0720/5FD35768" Ref="#PWR024"  Part="1" 
AR Path="/5D2C0761/5FD35768" Ref="#PWR?"  Part="1" 
F 0 "#PWR024" H -1100 5700 50  0001 C CNN
F 1 "GND" H -1095 5777 50  0000 C CNN
F 2 "" H -1100 5950 50  0001 C CNN
F 3 "" H -1100 5950 50  0001 C CNN
	1    -1100 5950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1100 5800 -1100 5950
Wire Wire Line
	-1100 4500 -1100 4800
Connection ~ -1100 4500
Text HLabel 10250 1950 2    50   Output ~ 0
~RST
Text HLabel 8900 3100 2    50   Output ~ 0
Phi2
Text HLabel 1700 6000 0    50   Input ~ 0
~HLT
Text HLabel 8900 2800 2    50   Output ~ 0
Phi1
$Comp
L power:PWR_FLAG #FLG03
U 1 1 5FC2FB0D
P 2200 1350
F 0 "#FLG03" H 2200 1425 50  0001 C CNN
F 1 "PWR_FLAG" H 2200 1523 50  0000 C CNN
F 2 "" H 2200 1350 50  0001 C CNN
F 3 "~" H 2200 1350 50  0001 C CNN
	1    2200 1350
	1    0    0    -1  
$EndComp
Connection ~ 2200 1350
Wire Wire Line
	2200 1350 2500 1350
$EndSCHEMATC
