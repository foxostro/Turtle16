EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 16 33
Title "System Bus Connector"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Peripheral devices on separate boards connect to the system bus here."
$EndDescr
Text HLabel 7000 2500 2    50   Input ~ 0
~RST
$Comp
L Connector_Generic:Conn_02x25_Odd_Even J?
U 1 1 5FAF78E6
P 5900 3500
AR Path="/60AF64DE/5FAF78E6" Ref="J?"  Part="1" 
AR Path="/5FAED671/5FAF78E6" Ref="J3"  Part="1" 
F 0 "J3" H 5950 4950 50  0000 R CNN
F 1 "Conn_01x50_Male" H 6250 4850 50  0000 R CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 5900 3500 50  0001 C CNN
F 3 "~" H 5900 3500 50  0001 C CNN
	1    5900 3500
	1    0    0    -1  
$EndComp
Entry Wire Line
	4950 3300 4850 3400
Text Label 5200 3300 2    50   ~ 0
Addr4
Entry Wire Line
	4950 3400 4850 3500
Text Label 5200 3400 2    50   ~ 0
Addr5
Entry Wire Line
	4950 3600 4850 3700
Text Label 5200 3600 2    50   ~ 0
Addr8
Entry Wire Line
	4950 3700 4850 3800
Text Label 5200 3700 2    50   ~ 0
Addr9
Entry Wire Line
	4950 3900 4850 4000
Text Label 5250 3900 2    50   ~ 0
Addr12
Entry Wire Line
	4950 4000 4850 4100
Text Label 5250 4000 2    50   ~ 0
Addr13
Entry Wire Line
	7050 4100 6950 4000
Text Label 6650 4000 0    50   ~ 0
Addr15
Entry Wire Line
	7050 4000 6950 3900
Entry Wire Line
	7050 3800 6950 3700
Entry Wire Line
	7050 3700 6950 3600
Entry Wire Line
	7050 3500 6950 3400
Entry Wire Line
	7050 3400 6950 3300
Entry Wire Line
	7050 3200 6950 3100
Entry Wire Line
	7050 3100 6950 3000
$Comp
L power:GND #PWR?
U 1 1 5FAF792A
P 6250 2900
AR Path="/60AF64DE/5FAF792A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF792A" Ref="#PWR0188"  Part="1" 
F 0 "#PWR0188" H 6250 2650 50  0001 C CNN
F 1 "GND" V 6255 2772 50  0000 R CNN
F 2 "" H 6250 2900 50  0001 C CNN
F 3 "" H 6250 2900 50  0001 C CNN
	1    6250 2900
	0    -1   1    0   
$EndComp
Entry Wire Line
	5050 4200 4950 4300
Entry Wire Line
	5050 4300 4950 4400
Entry Wire Line
	5050 4500 4950 4600
Entry Wire Line
	5050 4600 4950 4700
Entry Wire Line
	6850 4500 6950 4600
Entry Wire Line
	6850 4600 6950 4700
$Comp
L power:GND #PWR?
U 1 1 5FAF794C
P 5650 2600
AR Path="/60AF64DE/5FAF794C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF794C" Ref="#PWR0178"  Part="1" 
F 0 "#PWR0178" H 5650 2350 50  0001 C CNN
F 1 "GND" V 5655 2472 50  0000 R CNN
F 2 "" H 5650 2600 50  0001 C CNN
F 3 "" H 5650 2600 50  0001 C CNN
	1    5650 2600
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2600 5700 2600
Wire Wire Line
	5650 4700 5700 4700
$Comp
L power:GND #PWR?
U 1 1 5FAF796F
P 5650 4700
AR Path="/60AF64DE/5FAF796F" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF796F" Ref="#PWR0185"  Part="1" 
F 0 "#PWR0185" H 5650 4450 50  0001 C CNN
F 1 "GND" V 5655 4572 50  0000 R CNN
F 2 "" H 5650 4700 50  0001 C CNN
F 3 "" H 5650 4700 50  0001 C CNN
	1    5650 4700
	0    1    1    0   
$EndComp
Wire Wire Line
	4950 3400 5700 3400
Wire Wire Line
	4950 3900 5700 3900
Wire Wire Line
	6950 4000 6200 4000
Wire Wire Line
	5700 4000 4950 4000
Wire Wire Line
	4950 3700 5700 3700
Wire Wire Line
	5700 3600 4950 3600
Wire Wire Line
	4950 3300 5700 3300
Wire Wire Line
	5050 4200 5700 4200
Wire Wire Line
	5050 4300 5700 4300
Wire Wire Line
	5050 4500 5700 4500
Wire Wire Line
	7000 2400 6200 2400
Wire Wire Line
	4900 2400 5700 2400
Text HLabel 7000 2400 2    50   3State ~ 0
~MemLoad
Text HLabel 4900 2400 0    50   3State ~ 0
~MemStore
Text HLabel 2750 5700 0    50   3State ~ 0
IO[0..7]
Text Label 5100 4200 0    50   ~ 0
IO0
Text Label 5100 4300 0    50   ~ 0
IO1
Text Label 5100 4500 0    50   ~ 0
IO4
Text Label 5100 4600 0    50   ~ 0
IO5
Text Label 6800 4600 2    50   ~ 0
IO7
Text Label 6800 4500 2    50   ~ 0
IO6
$Comp
L power:GND #PWR?
U 1 1 5FD376AD
P 5650 3500
AR Path="/60AF64DE/5FD376AD" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD376AD" Ref="#PWR0181"  Part="1" 
F 0 "#PWR0181" H 5650 3250 50  0001 C CNN
F 1 "GND" V 5655 3372 50  0000 R CNN
F 2 "" H 5650 3500 50  0001 C CNN
F 3 "" H 5650 3500 50  0001 C CNN
	1    5650 3500
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 3500 5700 3500
$Comp
L power:GND #PWR?
U 1 1 5FD395C1
P 5650 2900
AR Path="/60AF64DE/5FD395C1" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD395C1" Ref="#PWR0179"  Part="1" 
F 0 "#PWR0179" H 5650 2650 50  0001 C CNN
F 1 "GND" V 5655 2772 50  0000 R CNN
F 2 "" H 5650 2900 50  0001 C CNN
F 3 "" H 5650 2900 50  0001 C CNN
	1    5650 2900
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2900 5700 2900
$Comp
L power:GND #PWR?
U 1 1 5FD3CC03
P 5650 3200
AR Path="/60AF64DE/5FD3CC03" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD3CC03" Ref="#PWR0180"  Part="1" 
F 0 "#PWR0180" H 5650 2950 50  0001 C CNN
F 1 "GND" V 5655 3072 50  0000 R CNN
F 2 "" H 5650 3200 50  0001 C CNN
F 3 "" H 5650 3200 50  0001 C CNN
	1    5650 3200
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 3200 5700 3200
Text Label 6800 4200 2    50   ~ 0
IO2
Text Label 6800 4300 2    50   ~ 0
IO3
Wire Wire Line
	6850 4300 6200 4300
Wire Wire Line
	6850 4200 6200 4200
Entry Wire Line
	6850 4300 6950 4400
Entry Wire Line
	6850 4200 6950 4300
Wire Wire Line
	6200 4500 6850 4500
Wire Wire Line
	6200 4600 6850 4600
Text HLabel 4950 2500 0    50   Input ~ 0
Phi2
Wire Wire Line
	6200 3700 6950 3700
Wire Wire Line
	6950 3600 6200 3600
Wire Wire Line
	6200 3300 6950 3300
Wire Wire Line
	6950 3100 6200 3100
Wire Wire Line
	6950 3000 6200 3000
Wire Wire Line
	6950 3400 6200 3400
Wire Wire Line
	6950 3900 6200 3900
Text Label 6650 3000 0    50   ~ 0
Addr2
Text Label 6650 3100 0    50   ~ 0
Addr3
Text Label 6650 3300 0    50   ~ 0
Addr6
Text Label 6650 3400 0    50   ~ 0
Addr7
Text Label 6650 3600 0    50   ~ 0
Addr10
Text Label 6650 3700 0    50   ~ 0
Addr11
Text Label 6650 3900 0    50   ~ 0
Addr14
$Comp
L power:GND #PWR?
U 1 1 5FD9B74C
P 5650 3800
AR Path="/60AF64DE/5FD9B74C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD9B74C" Ref="#PWR0182"  Part="1" 
F 0 "#PWR0182" H 5650 3550 50  0001 C CNN
F 1 "GND" V 5655 3672 50  0000 R CNN
F 2 "" H 5650 3800 50  0001 C CNN
F 3 "" H 5650 3800 50  0001 C CNN
	1    5650 3800
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 3800 5700 3800
$Comp
L power:GND #PWR?
U 1 1 5FD9C7A1
P 5650 4100
AR Path="/60AF64DE/5FD9C7A1" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD9C7A1" Ref="#PWR0183"  Part="1" 
F 0 "#PWR0183" H 5650 3850 50  0001 C CNN
F 1 "GND" V 5655 3972 50  0000 R CNN
F 2 "" H 5650 4100 50  0001 C CNN
F 3 "" H 5650 4100 50  0001 C CNN
	1    5650 4100
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 4100 5700 4100
Wire Wire Line
	5650 2300 5700 2300
$Comp
L power:GND #PWR?
U 1 1 5FDAC894
P 5650 4400
AR Path="/60AF64DE/5FDAC894" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDAC894" Ref="#PWR0184"  Part="1" 
F 0 "#PWR0184" H 5650 4150 50  0001 C CNN
F 1 "GND" V 5655 4272 50  0000 R CNN
F 2 "" H 5650 4400 50  0001 C CNN
F 3 "" H 5650 4400 50  0001 C CNN
	1    5650 4400
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 4400 5700 4400
$Comp
L power:GND #PWR?
U 1 1 5FDB1D21
P 6250 4700
AR Path="/60AF64DE/5FDB1D21" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDB1D21" Ref="#PWR0194"  Part="1" 
F 0 "#PWR0194" H 6250 4450 50  0001 C CNN
F 1 "GND" V 6255 4572 50  0000 R CNN
F 2 "" H 6250 4700 50  0001 C CNN
F 3 "" H 6250 4700 50  0001 C CNN
	1    6250 4700
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDB4B0A
P 6250 2600
AR Path="/60AF64DE/5FDB4B0A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDB4B0A" Ref="#PWR0187"  Part="1" 
F 0 "#PWR0187" H 6250 2350 50  0001 C CNN
F 1 "GND" V 6255 2472 50  0000 R CNN
F 2 "" H 6250 2600 50  0001 C CNN
F 3 "" H 6250 2600 50  0001 C CNN
	1    6250 2600
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDB4B18
P 6250 4400
AR Path="/60AF64DE/5FDB4B18" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDB4B18" Ref="#PWR0193"  Part="1" 
F 0 "#PWR0193" H 6250 4150 50  0001 C CNN
F 1 "GND" V 6255 4272 50  0000 R CNN
F 2 "" H 6250 4400 50  0001 C CNN
F 3 "" H 6250 4400 50  0001 C CNN
	1    6250 4400
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDBA759
P 6250 3200
AR Path="/60AF64DE/5FDBA759" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBA759" Ref="#PWR0189"  Part="1" 
F 0 "#PWR0189" H 6250 2950 50  0001 C CNN
F 1 "GND" V 6255 3072 50  0000 R CNN
F 2 "" H 6250 3200 50  0001 C CNN
F 3 "" H 6250 3200 50  0001 C CNN
	1    6250 3200
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDBF023
P 6250 3800
AR Path="/60AF64DE/5FDBF023" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBF023" Ref="#PWR0191"  Part="1" 
F 0 "#PWR0191" H 6250 3550 50  0001 C CNN
F 1 "GND" V 6255 3672 50  0000 R CNN
F 2 "" H 6250 3800 50  0001 C CNN
F 3 "" H 6250 3800 50  0001 C CNN
	1    6250 3800
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDC14FF
P 6250 4100
AR Path="/60AF64DE/5FDC14FF" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDC14FF" Ref="#PWR0192"  Part="1" 
F 0 "#PWR0192" H 6250 3850 50  0001 C CNN
F 1 "GND" V 6255 3972 50  0000 R CNN
F 2 "" H 6250 4100 50  0001 C CNN
F 3 "" H 6250 4100 50  0001 C CNN
	1    6250 4100
	0    -1   1    0   
$EndComp
Text HLabel 2750 6050 0    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	2750 5700 4950 5700
Wire Wire Line
	6200 2500 7000 2500
Entry Wire Line
	4950 3000 4850 3100
Text Label 5200 3000 2    50   ~ 0
Addr0
Wire Wire Line
	4950 3000 5700 3000
Wire Wire Line
	5700 3100 4950 3100
Text Label 5200 3100 2    50   ~ 0
Addr1
Entry Wire Line
	4950 3100 4850 3200
Wire Wire Line
	5050 4600 5700 4600
Wire Wire Line
	4950 2500 5700 2500
Wire Wire Line
	6200 2300 6250 2300
Wire Wire Line
	6250 2600 6200 2600
Wire Wire Line
	6250 2900 6200 2900
Wire Wire Line
	6250 3200 6200 3200
Wire Wire Line
	6250 3800 6200 3800
Wire Wire Line
	6250 4100 6200 4100
Wire Wire Line
	6250 4400 6200 4400
Wire Wire Line
	6250 4700 6200 4700
Wire Bus Line
	2750 6050 4850 6050
Wire Wire Line
	6250 3500 6200 3500
$Comp
L power:GND #PWR?
U 1 1 5FDBCB4E
P 6250 3500
AR Path="/60AF64DE/5FDBCB4E" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBCB4E" Ref="#PWR0190"  Part="1" 
F 0 "#PWR0190" H 6250 3250 50  0001 C CNN
F 1 "GND" V 6255 3372 50  0000 R CNN
F 2 "" H 6250 3500 50  0001 C CNN
F 3 "" H 6250 3500 50  0001 C CNN
	1    6250 3500
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR0186
U 1 1 5FBF62F4
P 6250 2300
F 0 "#PWR0186" H 6250 2150 50  0001 C CNN
F 1 "VCC" V 6265 2428 50  0000 L CNN
F 2 "" H 6250 2300 50  0001 C CNN
F 3 "" H 6250 2300 50  0001 C CNN
	1    6250 2300
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0177
U 1 1 5FBF6D31
P 5650 2300
F 0 "#PWR0177" H 5650 2150 50  0001 C CNN
F 1 "VCC" V 5665 2427 50  0000 L CNN
F 2 "" H 5650 2300 50  0001 C CNN
F 3 "" H 5650 2300 50  0001 C CNN
	1    5650 2300
	0    -1   1    0   
$EndComp
Connection ~ 4850 6050
Wire Bus Line
	4850 6050 7050 6050
Connection ~ 4950 5700
Wire Bus Line
	4950 5700 6950 5700
Text HLabel 7000 1350 2    50   Output ~ 0
~RDY
NoConn ~ 6200 2700
NoConn ~ 6200 2800
NoConn ~ 5700 2800
$Comp
L power:VCC #PWR?
U 1 1 5FBB7C05
P 4100 1050
AR Path="/60AF64DE/600805C3/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D2600/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D275E/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FF1115C/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FB90806/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBB7C05" Ref="#PWR0176"  Part="1" 
F 0 "#PWR0176" H 4100 900 50  0001 C CNN
F 1 "VCC" H 4117 1223 50  0000 C CNN
F 2 "" H 4100 1050 50  0001 C CNN
F 3 "" H 4100 1050 50  0001 C CNN
	1    4100 1050
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FBB7C0B
P 4100 1200
AR Path="/5D2C0720/5FBB7C0B" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FBB7C0B" Ref="R21"  Part="1" 
F 0 "R21" H 4159 1246 50  0000 L CNN
F 1 "10kΩ" H 4159 1155 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 4100 1200 50  0001 C CNN
F 3 "~" H 4100 1200 50  0001 C CNN
	1    4100 1200
	1    0    0    -1  
$EndComp
NoConn ~ -650 4900
NoConn ~ -650 5400
$Comp
L 74xx:74LS04 U?
U 7 1 5FBBFEC5
P -1250 6200
AR Path="/5D2C0761/5FBBFEC5" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FBBFEC5" Ref="U?"  Part="7" 
AR Path="/5FAED671/5FBBFEC5" Ref="U35"  Part="7" 
F 0 "U35" H -1250 6250 50  0000 C CNN
F 1 "74AHCT04" H -1250 6150 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1250 6200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 6200 50  0001 C CNN
	7    -1250 6200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FBBFECB
P -950 5400
AR Path="/5D8005AF/5D800744/5FBBFECB" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFECB" Ref="U?"  Part="6" 
AR Path="/5FAED671/5FBBFECB" Ref="U35"  Part="6" 
F 0 "U35" H -950 5717 50  0000 C CNN
F 1 "74AHCT04" H -950 5626 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 5400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 5400 50  0001 C CNN
	6    -950 5400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FBBFED1
P -950 4900
AR Path="/5D8005AF/5D800744/5FBBFED1" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFED1" Ref="U?"  Part="5" 
AR Path="/5FAED671/5FBBFED1" Ref="U35"  Part="5" 
F 0 "U35" H -950 5217 50  0000 C CNN
F 1 "74AHCT04" H -950 5126 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 4900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 4900 50  0001 C CNN
	5    -950 4900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FBBFED7
P -950 4400
AR Path="/5D8005AF/5D800744/5FBBFED7" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFED7" Ref="U?"  Part="4" 
AR Path="/5FAED671/5FBBFED7" Ref="U35"  Part="4" 
F 0 "U35" H -950 4717 50  0000 C CNN
F 1 "74AHCT04" H -950 4626 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 4400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 4400 50  0001 C CNN
	4    -950 4400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FBBFEDD
P -950 3900
AR Path="/5D8005AF/5D800744/5FBBFEDD" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFEDD" Ref="U?"  Part="3" 
AR Path="/5FAED671/5FBBFEDD" Ref="U35"  Part="3" 
F 0 "U35" H -950 4217 50  0000 C CNN
F 1 "74AHCT04" H -950 4126 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 3900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 3900 50  0001 C CNN
	3    -950 3900
	1    0    0    -1  
$EndComp
NoConn ~ -650 3900
NoConn ~ -650 4400
$Comp
L power:VCC #PWR?
U 1 1 5FBBFEE5
P -1250 2850
AR Path="/5D2C0761/5FBBFEE5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FBBFEE5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBBFEE5" Ref="#PWR0174"  Part="1" 
F 0 "#PWR0174" H -1250 2700 50  0001 C CNN
F 1 "VCC" H -1233 3023 50  0000 C CNN
F 2 "" H -1250 2850 50  0001 C CNN
F 3 "" H -1250 2850 50  0001 C CNN
	1    -1250 2850
	1    0    0    -1  
$EndComp
Connection ~ -1250 3900
Wire Wire Line
	-1250 3900 -1250 4400
Connection ~ -1250 4400
Wire Wire Line
	-1250 4400 -1250 4900
Connection ~ -1250 4900
Wire Wire Line
	-1250 4900 -1250 5400
$Comp
L power:GND #PWR?
U 1 1 5FBBFEF1
P -1250 6850
AR Path="/5D2C0720/5FBBFEF1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FBBFEF1" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBBFEF1" Ref="#PWR0175"  Part="1" 
F 0 "#PWR0175" H -1250 6600 50  0001 C CNN
F 1 "GND" H -1245 6677 50  0000 C CNN
F 2 "" H -1250 6850 50  0001 C CNN
F 3 "" H -1250 6850 50  0001 C CNN
	1    -1250 6850
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1250 6700 -1250 6850
Wire Wire Line
	-1250 5400 -1250 5700
Connection ~ -1250 5400
Connection ~ -1250 3400
Wire Wire Line
	-1250 3400 -1250 3900
Wire Wire Line
	-1250 2850 -1250 3400
$Comp
L 74xx:74LS04 U?
U 2 1 5FBBFEFD
P -950 3400
AR Path="/5D8005AF/5D800744/5FBBFEFD" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFEFD" Ref="U?"  Part="2" 
AR Path="/5FAED671/5FBBFEFD" Ref="U35"  Part="2" 
F 0 "U35" H -950 3717 50  0000 C CNN
F 1 "74AHCT04" H -950 3626 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 3400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 3400 50  0001 C CNN
	2    -950 3400
	1    0    0    -1  
$EndComp
NoConn ~ -650 3400
$Comp
L 74xx:74LS04 U?
U 1 1 5FBCC32D
P 4750 1350
AR Path="/5D8005AF/5D800744/5FBCC32D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBCC32D" Ref="U?"  Part="2" 
AR Path="/5FAED671/5FBCC32D" Ref="U35"  Part="1" 
F 0 "U35" H 4750 1667 50  0000 C CNN
F 1 "74AHCT04" H 4750 1576 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4750 1350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4750 1350 50  0001 C CNN
	1    4750 1350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 1350 5050 1350
Wire Wire Line
	4100 1050 4100 1100
Wire Wire Line
	4100 1300 4100 1350
Wire Wire Line
	4100 1350 4450 1350
Wire Wire Line
	4100 2700 4100 1350
Wire Wire Line
	4100 2700 5700 2700
Connection ~ 4100 1350
Text Notes 1300 2300 0    50   ~ 0
The bus connector has a shared open-drain active-high RDY signal.\nIf all bus devices are ready then they allow the line to remain high.\nIf any bus device is not ready then it drives the line low.\nWhen RDY is driven low, the CPU Phi1 clock stops and the CPU\ndisconnects from the bus, placing the lines in a high-Z mode.\n\nIf no bus devices are connected then the CPU is always ready.
Wire Bus Line
	4950 4300 4950 5700
Wire Bus Line
	6950 4300 6950 5700
Wire Bus Line
	4850 3100 4850 6050
Wire Bus Line
	7050 3100 7050 6050
Text Label 5000 2700 0    50   ~ 0
RDY
$EndSCHEMATC
