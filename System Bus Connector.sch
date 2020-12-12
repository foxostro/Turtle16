EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 12 34
Title "System Bus Connector"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Peripheral devices on separate boards connect to the system bus here."
$EndDescr
$Comp
L Connector_Generic:Conn_02x32_Odd_Even J?
U 1 1 5FAF78E6
P 5900 3100
AR Path="/60AF64DE/5FAF78E6" Ref="J?"  Part="1" 
AR Path="/5FAED671/5FAF78E6" Ref="J3"  Part="1" 
F 0 "J3" H 5950 4850 50  0000 R CNN
F 1 "71922-264LF" H 6150 4750 50  0000 R CNN
F 2 "Connector_IDC:IDC-Header_2x32_P2.54mm_Horizontal" H 5900 3100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/18/71922-1363266.pdf" H 5900 3100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Amphenol-FCI/71922-264LF?qs=yJYkLTYh576qGOVYzS69eQ%3D%3D" H 5900 3100 50  0001 C CNN "Mouser"
	1    5900 3100
	1    0    0    -1  
$EndComp
Entry Wire Line
	5050 3300 4950 3400
Text Label 5300 3300 2    50   ~ 0
Addr4
Entry Wire Line
	5050 3400 4950 3500
Text Label 5300 3400 2    50   ~ 0
Addr6
Entry Wire Line
	5050 3600 4950 3700
Text Label 5300 3600 2    50   ~ 0
Addr8
Entry Wire Line
	5050 3700 4950 3800
Text Label 5350 3700 2    50   ~ 0
Addr10
Entry Wire Line
	5050 3900 4950 4000
Text Label 5350 3900 2    50   ~ 0
Addr12
Entry Wire Line
	5050 4000 4950 4100
Text Label 5350 4000 2    50   ~ 0
Addr14
Entry Wire Line
	6950 4100 6850 4000
Text Label 6800 4000 2    50   ~ 0
Addr15
Entry Wire Line
	6950 4000 6850 3900
Entry Wire Line
	6950 3800 6850 3700
Entry Wire Line
	6950 3700 6850 3600
Entry Wire Line
	6950 3500 6850 3400
Entry Wire Line
	6950 3400 6850 3300
Entry Wire Line
	6950 3200 6850 3100
Entry Wire Line
	6950 3100 6850 3000
$Comp
L power:GND #PWR?
U 1 1 5FAF792A
P 6250 2900
AR Path="/60AF64DE/5FAF792A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF792A" Ref="#PWR0223"  Part="1" 
F 0 "#PWR0223" H 6250 2650 50  0001 C CNN
F 1 "GND" V 6255 2772 50  0000 R CNN
F 2 "" H 6250 2900 50  0001 C CNN
F 3 "" H 6250 2900 50  0001 C CNN
	1    6250 2900
	0    -1   1    0   
$EndComp
Entry Wire Line
	5050 2400 4950 2500
Entry Wire Line
	5050 2500 4950 2600
Entry Wire Line
	5050 2700 4950 2800
Entry Wire Line
	5050 2800 4950 2900
Entry Wire Line
	6850 2700 6950 2800
Entry Wire Line
	6850 2800 6950 2900
$Comp
L power:GND #PWR?
U 1 1 5FAF794C
P 5650 2100
AR Path="/60AF64DE/5FAF794C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF794C" Ref="#PWR0207"  Part="1" 
F 0 "#PWR0207" H 5650 1850 50  0001 C CNN
F 1 "GND" V 5655 1972 50  0000 R CNN
F 2 "" H 5650 2100 50  0001 C CNN
F 3 "" H 5650 2100 50  0001 C CNN
	1    5650 2100
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2100 5700 2100
Wire Wire Line
	5650 4700 5700 4700
$Comp
L power:GND #PWR?
U 1 1 5FAF796F
P 5650 4700
AR Path="/60AF64DE/5FAF796F" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF796F" Ref="#PWR0216"  Part="1" 
F 0 "#PWR0216" H 5650 4450 50  0001 C CNN
F 1 "GND" V 5655 4572 50  0000 R CNN
F 2 "" H 5650 4700 50  0001 C CNN
F 3 "" H 5650 4700 50  0001 C CNN
	1    5650 4700
	0    1    1    0   
$EndComp
Wire Wire Line
	5050 3400 5700 3400
Wire Wire Line
	5050 3900 5700 3900
Wire Wire Line
	6850 4000 6200 4000
Wire Wire Line
	5700 4000 5050 4000
Wire Wire Line
	5050 3700 5700 3700
Wire Wire Line
	5700 3600 5050 3600
Wire Wire Line
	5050 3300 5700 3300
Wire Wire Line
	5050 2400 5700 2400
Wire Wire Line
	5050 2500 5700 2500
Wire Wire Line
	5050 2700 5700 2700
Wire Wire Line
	7000 1800 6200 1800
Wire Wire Line
	4900 1800 5700 1800
Text HLabel 7000 1800 2    50   3State ~ 0
~MemLoad
Text HLabel 4900 1800 0    50   3State ~ 0
~MemStore
Text HLabel 4700 2500 0    50   3State ~ 0
IO[0..7]
Text Label 5100 2400 0    50   ~ 0
IO0
Text Label 5100 2500 0    50   ~ 0
IO2
Text Label 5100 2700 0    50   ~ 0
IO4
Text Label 5100 2800 0    50   ~ 0
IO6
Text Label 6800 2800 2    50   ~ 0
IO7
Text Label 6800 2700 2    50   ~ 0
IO5
$Comp
L power:GND #PWR?
U 1 1 5FD376AD
P 5650 3500
AR Path="/60AF64DE/5FD376AD" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD376AD" Ref="#PWR0212"  Part="1" 
F 0 "#PWR0212" H 5650 3250 50  0001 C CNN
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
AR Path="/5FAED671/5FD395C1" Ref="#PWR0210"  Part="1" 
F 0 "#PWR0210" H 5650 2650 50  0001 C CNN
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
AR Path="/5FAED671/5FD3CC03" Ref="#PWR0211"  Part="1" 
F 0 "#PWR0211" H 5650 2950 50  0001 C CNN
F 1 "GND" V 5655 3072 50  0000 R CNN
F 2 "" H 5650 3200 50  0001 C CNN
F 3 "" H 5650 3200 50  0001 C CNN
	1    5650 3200
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 3200 5700 3200
Text Label 6800 2400 2    50   ~ 0
IO1
Text Label 6800 2500 2    50   ~ 0
IO3
Wire Wire Line
	6850 2500 6200 2500
Wire Wire Line
	6850 2400 6200 2400
Entry Wire Line
	6850 2500 6950 2600
Entry Wire Line
	6850 2400 6950 2500
Wire Wire Line
	6200 2700 6850 2700
Wire Wire Line
	6200 2800 6850 2800
Wire Wire Line
	6200 3700 6850 3700
Wire Wire Line
	6850 3600 6200 3600
Wire Wire Line
	6200 3300 6850 3300
Wire Wire Line
	6850 3100 6200 3100
Wire Wire Line
	6850 3000 6200 3000
Wire Wire Line
	6850 3400 6200 3400
Wire Wire Line
	6850 3900 6200 3900
Text Label 6800 3000 2    50   ~ 0
Addr1
Text Label 6800 3100 2    50   ~ 0
Addr3
Text Label 6800 3300 2    50   ~ 0
Addr5
Text Label 6800 3400 2    50   ~ 0
Addr7
Text Label 6800 3600 2    50   ~ 0
Addr9
Text Label 6800 3700 2    50   ~ 0
Addr11
Text Label 6800 3900 2    50   ~ 0
Addr13
$Comp
L power:GND #PWR?
U 1 1 5FD9B74C
P 5650 3800
AR Path="/60AF64DE/5FD9B74C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD9B74C" Ref="#PWR0213"  Part="1" 
F 0 "#PWR0213" H 5650 3550 50  0001 C CNN
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
AR Path="/5FAED671/5FD9C7A1" Ref="#PWR0214"  Part="1" 
F 0 "#PWR0214" H 5650 3850 50  0001 C CNN
F 1 "GND" V 5655 3972 50  0000 R CNN
F 2 "" H 5650 4100 50  0001 C CNN
F 3 "" H 5650 4100 50  0001 C CNN
	1    5650 4100
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 4100 5700 4100
Wire Wire Line
	5650 1600 5700 1600
$Comp
L power:GND #PWR?
U 1 1 5FDAC894
P 5650 4400
AR Path="/60AF64DE/5FDAC894" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDAC894" Ref="#PWR0215"  Part="1" 
F 0 "#PWR0215" H 5650 4150 50  0001 C CNN
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
AR Path="/5FAED671/5FDB1D21" Ref="#PWR0229"  Part="1" 
F 0 "#PWR0229" H 6250 4450 50  0001 C CNN
F 1 "GND" V 6255 4572 50  0000 R CNN
F 2 "" H 6250 4700 50  0001 C CNN
F 3 "" H 6250 4700 50  0001 C CNN
	1    6250 4700
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDB4B0A
P 6250 2100
AR Path="/60AF64DE/5FDB4B0A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDB4B0A" Ref="#PWR0220"  Part="1" 
F 0 "#PWR0220" H 6250 1850 50  0001 C CNN
F 1 "GND" V 6255 1972 50  0000 R CNN
F 2 "" H 6250 2100 50  0001 C CNN
F 3 "" H 6250 2100 50  0001 C CNN
	1    6250 2100
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDB4B18
P 6250 4400
AR Path="/60AF64DE/5FDB4B18" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDB4B18" Ref="#PWR0228"  Part="1" 
F 0 "#PWR0228" H 6250 4150 50  0001 C CNN
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
AR Path="/5FAED671/5FDBA759" Ref="#PWR0224"  Part="1" 
F 0 "#PWR0224" H 6250 2950 50  0001 C CNN
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
AR Path="/5FAED671/5FDBF023" Ref="#PWR0226"  Part="1" 
F 0 "#PWR0226" H 6250 3550 50  0001 C CNN
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
AR Path="/5FAED671/5FDC14FF" Ref="#PWR0227"  Part="1" 
F 0 "#PWR0227" H 6250 3850 50  0001 C CNN
F 1 "GND" V 6255 3972 50  0000 R CNN
F 2 "" H 6250 4100 50  0001 C CNN
F 3 "" H 6250 4100 50  0001 C CNN
	1    6250 4100
	0    -1   1    0   
$EndComp
Text HLabel 4700 3100 0    50   3State ~ 0
Addr[0..15]
Entry Wire Line
	5050 3000 4950 3100
Text Label 5300 3000 2    50   ~ 0
Addr0
Wire Wire Line
	5050 3000 5700 3000
Wire Wire Line
	5700 3100 5050 3100
Text Label 5300 3100 2    50   ~ 0
Addr2
Entry Wire Line
	5050 3100 4950 3200
Wire Wire Line
	5050 2800 5700 2800
Wire Wire Line
	4950 2000 5700 2000
Wire Wire Line
	6200 1600 6250 1600
Wire Wire Line
	6250 2100 6200 2100
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
Wire Wire Line
	6250 3500 6200 3500
$Comp
L power:GND #PWR?
U 1 1 5FDBCB4E
P 6250 3500
AR Path="/60AF64DE/5FDBCB4E" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBCB4E" Ref="#PWR0225"  Part="1" 
F 0 "#PWR0225" H 6250 3250 50  0001 C CNN
F 1 "GND" V 6255 3372 50  0000 R CNN
F 2 "" H 6250 3500 50  0001 C CNN
F 3 "" H 6250 3500 50  0001 C CNN
	1    6250 3500
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR0217
U 1 1 5FBF62F4
P 6250 1600
F 0 "#PWR0217" H 6250 1450 50  0001 C CNN
F 1 "VCC" V 6265 1728 50  0000 L CNN
F 2 "" H 6250 1600 50  0001 C CNN
F 3 "" H 6250 1600 50  0001 C CNN
	1    6250 1600
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0204
U 1 1 5FBF6D31
P 5650 1600
F 0 "#PWR0204" H 5650 1450 50  0001 C CNN
F 1 "VCC" V 5665 1727 50  0000 L CNN
F 2 "" H 5650 1600 50  0001 C CNN
F 3 "" H 5650 1600 50  0001 C CNN
	1    5650 1600
	0    -1   1    0   
$EndComp
Text HLabel 7000 1050 2    50   Output ~ 0
~RDY
$Comp
L power:VCC #PWR?
U 1 1 5FBB7C05
P 4100 750
AR Path="/60AF64DE/600805C3/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D2600/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D275E/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FF1115C/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FB90806/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBB7C05" Ref="#PWR0201"  Part="1" 
F 0 "#PWR0201" H 4100 600 50  0001 C CNN
F 1 "VCC" H 4117 923 50  0000 C CNN
F 2 "" H 4100 750 50  0001 C CNN
F 3 "" H 4100 750 50  0001 C CNN
	1    4100 750 
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FBB7C0B
P 4100 900
AR Path="/5D2C0720/5FBB7C0B" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FBB7C0B" Ref="R15"  Part="1" 
F 0 "R15" H 4159 946 50  0000 L CNN
F 1 "10kΩ" H 4159 855 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 4100 900 50  0001 C CNN
F 3 "~" H 4100 900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 4100 900 50  0001 C CNN "Mouser"
	1    4100 900 
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
AR Path="/5FAED671/5FBBFEC5" Ref="U24"  Part="7" 
F 0 "U24" H -1250 6250 50  0000 C CNN
F 1 "74AHCT04" H -1250 6150 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1250 6200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 6200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -1250 6200 50  0001 C CNN "Mouser"
	7    -1250 6200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FBBFECB
P -950 5400
AR Path="/5D8005AF/5D800744/5FBBFECB" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFECB" Ref="U?"  Part="6" 
AR Path="/5FAED671/5FBBFECB" Ref="U24"  Part="6" 
F 0 "U24" H -950 5717 50  0000 C CNN
F 1 "74AHCT04" H -950 5626 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 5400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 5400 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -950 5400 50  0001 C CNN "Mouser"
	6    -950 5400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FBBFED1
P -950 4900
AR Path="/5D8005AF/5D800744/5FBBFED1" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFED1" Ref="U?"  Part="5" 
AR Path="/5FAED671/5FBBFED1" Ref="U24"  Part="5" 
F 0 "U24" H -950 5217 50  0000 C CNN
F 1 "74AHCT04" H -950 5126 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 4900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 4900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -950 4900 50  0001 C CNN "Mouser"
	5    -950 4900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FBBFED7
P -950 4400
AR Path="/5D8005AF/5D800744/5FBBFED7" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFED7" Ref="U?"  Part="4" 
AR Path="/5FAED671/5FBBFED7" Ref="U24"  Part="4" 
F 0 "U24" H -950 4717 50  0000 C CNN
F 1 "74AHCT04" H -950 4626 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 4400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 4400 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -950 4400 50  0001 C CNN "Mouser"
	4    -950 4400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FBBFEDD
P -950 3900
AR Path="/5D8005AF/5D800744/5FBBFEDD" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBBFEDD" Ref="U?"  Part="3" 
AR Path="/5FAED671/5FBBFEDD" Ref="U24"  Part="3" 
F 0 "U24" H -950 4217 50  0000 C CNN
F 1 "74AHCT04" H -950 4126 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 3900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -950 3900 50  0001 C CNN "Mouser"
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
AR Path="/5FAED671/5FBBFEE5" Ref="#PWR0191"  Part="1" 
F 0 "#PWR0191" H -1250 2700 50  0001 C CNN
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
AR Path="/5FAED671/5FBBFEF1" Ref="#PWR0192"  Part="1" 
F 0 "#PWR0192" H -1250 6600 50  0001 C CNN
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
AR Path="/5FAED671/5FBBFEFD" Ref="U24"  Part="2" 
F 0 "U24" H -950 3717 50  0000 C CNN
F 1 "74AHCT04" H -950 3626 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -950 3400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -950 3400 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -950 3400 50  0001 C CNN "Mouser"
	2    -950 3400
	1    0    0    -1  
$EndComp
NoConn ~ -650 3400
$Comp
L 74xx:74LS04 U?
U 1 1 5FBCC32D
P 4750 1050
AR Path="/5D8005AF/5D800744/5FBCC32D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBCC32D" Ref="U?"  Part="2" 
AR Path="/5FAED671/5FBCC32D" Ref="U24"  Part="1" 
F 0 "U24" H 4750 1367 50  0000 C CNN
F 1 "74AHCT04" H 4750 1276 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4750 1050 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4750 1050 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 4750 1050 50  0001 C CNN "Mouser"
	1    4750 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 1050 5050 1050
Wire Wire Line
	4100 750  4100 800 
Wire Wire Line
	4100 1000 4100 1050
Wire Wire Line
	4100 1050 4450 1050
Connection ~ 4100 1050
Text Notes 1300 2300 0    50   ~ 0
The bus connector has a shared open-drain active-high RDY signal.\nIf all bus devices are ready then they allow the line to remain high.\nIf any bus device is not ready then it drives the line low.\nWhen RDY is driven low, the CPU Phi1 clock stops and the CPU\ndisconnects from the bus, placing the lines in a high-Z mode.\n\nIf no bus devices are connected then the CPU is always ready.
Text Label 5200 2200 2    50   ~ 0
RDY
Wire Wire Line
	6200 4500 6800 4500
Wire Wire Line
	6800 4300 6200 4300
Wire Wire Line
	6800 4200 6200 4200
Wire Wire Line
	6800 4600 6200 4600
Text Label 6800 4200 2    50   ~ 0
Bank1
Text Label 6800 4300 2    50   ~ 0
Bank3
Text Label 6800 4500 2    50   ~ 0
Bank5
Text Label 6800 4600 2    50   ~ 0
Bank7
Wire Wire Line
	6200 2000 7000 2000
Wire Wire Line
	5700 4500 5100 4500
Wire Wire Line
	5100 4300 5700 4300
Wire Wire Line
	5100 4200 5700 4200
Wire Wire Line
	5100 4600 5700 4600
Text Label 5100 4200 0    50   ~ 0
Bank0
Text Label 5100 4300 0    50   ~ 0
Bank2
Text Label 5100 4500 0    50   ~ 0
Bank4
Text Label 5100 4600 0    50   ~ 0
Bank6
$Comp
L power:GND #PWR?
U 1 1 5FBEF786
P 6250 2600
AR Path="/60AF64DE/5FBEF786" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBEF786" Ref="#PWR0222"  Part="1" 
F 0 "#PWR0222" H 6250 2350 50  0001 C CNN
F 1 "GND" V 6255 2472 50  0000 R CNN
F 2 "" H 6250 2600 50  0001 C CNN
F 3 "" H 6250 2600 50  0001 C CNN
	1    6250 2600
	0    -1   1    0   
$EndComp
Wire Wire Line
	6250 2600 6200 2600
$Comp
L power:GND #PWR?
U 1 1 5FBF251B
P 6250 1900
AR Path="/60AF64DE/5FBF251B" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBF251B" Ref="#PWR0219"  Part="1" 
F 0 "#PWR0219" H 6250 1650 50  0001 C CNN
F 1 "GND" V 6255 1772 50  0000 R CNN
F 2 "" H 6250 1900 50  0001 C CNN
F 3 "" H 6250 1900 50  0001 C CNN
	1    6250 1900
	0    -1   1    0   
$EndComp
Wire Wire Line
	6250 1900 6200 1900
$Comp
L power:GND #PWR?
U 1 1 5FBF51C5
P 5650 2600
AR Path="/60AF64DE/5FBF51C5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBF51C5" Ref="#PWR0209"  Part="1" 
F 0 "#PWR0209" H 5650 2350 50  0001 C CNN
F 1 "GND" V 5655 2472 50  0000 R CNN
F 2 "" H 5650 2600 50  0001 C CNN
F 3 "" H 5650 2600 50  0001 C CNN
	1    5650 2600
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2600 5700 2600
$Comp
L power:GND #PWR?
U 1 1 5FBF815A
P 5650 1900
AR Path="/60AF64DE/5FBF815A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBF815A" Ref="#PWR0206"  Part="1" 
F 0 "#PWR0206" H 5650 1650 50  0001 C CNN
F 1 "GND" V 5655 1772 50  0000 R CNN
F 2 "" H 5650 1900 50  0001 C CNN
F 3 "" H 5650 1900 50  0001 C CNN
	1    5650 1900
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 1900 5700 1900
$Comp
L power:GND #PWR?
U 1 1 5FC39243
P 5650 2300
AR Path="/60AF64DE/5FC39243" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FC39243" Ref="#PWR0208"  Part="1" 
F 0 "#PWR0208" H 5650 2050 50  0001 C CNN
F 1 "GND" V 5655 2172 50  0000 R CNN
F 2 "" H 5650 2300 50  0001 C CNN
F 3 "" H 5650 2300 50  0001 C CNN
	1    5650 2300
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2300 5700 2300
Wire Wire Line
	5700 2200 4100 2200
$Comp
L power:GND #PWR?
U 1 1 5FC40EA5
P 6250 2300
AR Path="/60AF64DE/5FC40EA5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FC40EA5" Ref="#PWR0221"  Part="1" 
F 0 "#PWR0221" H 6250 2050 50  0001 C CNN
F 1 "GND" V 6255 2172 50  0000 R CNN
F 2 "" H 6250 2300 50  0001 C CNN
F 3 "" H 6250 2300 50  0001 C CNN
	1    6250 2300
	0    -1   1    0   
$EndComp
Wire Wire Line
	6250 2300 6200 2300
$Comp
L power:GND #PWR?
U 1 1 5FC4C3D9
P 6250 1700
AR Path="/60AF64DE/5FC4C3D9" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FC4C3D9" Ref="#PWR0218"  Part="1" 
F 0 "#PWR0218" H 6250 1450 50  0001 C CNN
F 1 "GND" V 6255 1572 50  0000 R CNN
F 2 "" H 6250 1700 50  0001 C CNN
F 3 "" H 6250 1700 50  0001 C CNN
	1    6250 1700
	0    -1   1    0   
$EndComp
Wire Wire Line
	6250 1700 6200 1700
$Comp
L power:GND #PWR?
U 1 1 5FC4F660
P 5650 1700
AR Path="/60AF64DE/5FC4F660" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FC4F660" Ref="#PWR0205"  Part="1" 
F 0 "#PWR0205" H 5650 1450 50  0001 C CNN
F 1 "GND" V 5655 1572 50  0000 R CNN
F 2 "" H 5650 1700 50  0001 C CNN
F 3 "" H 5650 1700 50  0001 C CNN
	1    5650 1700
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 1700 5700 1700
NoConn ~ 6200 2200
Wire Wire Line
	4100 1050 4100 2200
Wire Bus Line
	4700 3100 4950 3100
Text HLabel 7200 3100 2    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	7200 3100 6950 3100
Wire Bus Line
	4700 2500 4950 2500
Text HLabel 7200 2500 2    50   3State ~ 0
IO[0..7]
Wire Bus Line
	7200 2500 6950 2500
$Comp
L power:GND #PWR?
U 1 1 5FCEA92B
P 2450 7350
AR Path="/60AF64DE/5FCEA92B" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA92B" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA92B" Ref="#PWR0197"  Part="1" 
F 0 "#PWR0197" H 2450 7100 50  0001 C CNN
F 1 "GND" H 2455 7177 50  0000 C CNN
F 2 "" H 2450 7350 50  0001 C CNN
F 3 "" H 2450 7350 50  0001 C CNN
	1    2450 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA931
P 2750 7350
AR Path="/60AF64DE/5FCEA931" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA931" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA931" Ref="#PWR0198"  Part="1" 
F 0 "#PWR0198" H 2750 7100 50  0001 C CNN
F 1 "GND" H 2755 7177 50  0000 C CNN
F 2 "" H 2750 7350 50  0001 C CNN
F 3 "" H 2750 7350 50  0001 C CNN
	1    2750 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA937
P 3050 7350
AR Path="/60AF64DE/5FCEA937" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA937" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA937" Ref="#PWR0199"  Part="1" 
F 0 "#PWR0199" H 3050 7100 50  0001 C CNN
F 1 "GND" H 3055 7177 50  0000 C CNN
F 2 "" H 3050 7350 50  0001 C CNN
F 3 "" H 3050 7350 50  0001 C CNN
	1    3050 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA93D
P 3350 7350
AR Path="/60AF64DE/5FCEA93D" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA93D" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA93D" Ref="#PWR0200"  Part="1" 
F 0 "#PWR0200" H 3350 7100 50  0001 C CNN
F 1 "GND" H 3355 7177 50  0000 C CNN
F 2 "" H 3350 7350 50  0001 C CNN
F 3 "" H 3350 7350 50  0001 C CNN
	1    3350 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA943
P 1250 7350
AR Path="/60AF64DE/5FCEA943" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA943" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA943" Ref="#PWR0193"  Part="1" 
F 0 "#PWR0193" H 1250 7100 50  0001 C CNN
F 1 "GND" H 1255 7177 50  0000 C CNN
F 2 "" H 1250 7350 50  0001 C CNN
F 3 "" H 1250 7350 50  0001 C CNN
	1    1250 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA949
P 1550 7350
AR Path="/60AF64DE/5FCEA949" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA949" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA949" Ref="#PWR0194"  Part="1" 
F 0 "#PWR0194" H 1550 7100 50  0001 C CNN
F 1 "GND" H 1555 7177 50  0000 C CNN
F 2 "" H 1550 7350 50  0001 C CNN
F 3 "" H 1550 7350 50  0001 C CNN
	1    1550 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA94F
P 1850 7350
AR Path="/60AF64DE/5FCEA94F" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA94F" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA94F" Ref="#PWR0195"  Part="1" 
F 0 "#PWR0195" H 1850 7100 50  0001 C CNN
F 1 "GND" H 1855 7177 50  0000 C CNN
F 2 "" H 1850 7350 50  0001 C CNN
F 3 "" H 1850 7350 50  0001 C CNN
	1    1850 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCEA955
P 2150 7350
AR Path="/60AF64DE/5FCEA955" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA955" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA955" Ref="#PWR0196"  Part="1" 
F 0 "#PWR0196" H 2150 7100 50  0001 C CNN
F 1 "GND" H 2155 7177 50  0000 C CNN
F 2 "" H 2150 7350 50  0001 C CNN
F 3 "" H 2150 7350 50  0001 C CNN
	1    2150 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1250 6650 1250 7150
Text Label 1250 6650 3    50   ~ 0
Bank0
Wire Wire Line
	1550 6650 1550 7150
Text Label 1550 6650 3    50   ~ 0
Bank1
Wire Wire Line
	1850 6650 1850 7150
Text Label 1850 6650 3    50   ~ 0
Bank2
Wire Wire Line
	2150 6650 2150 7150
Text Label 2150 6650 3    50   ~ 0
Bank3
Wire Wire Line
	2450 6650 2450 7150
Text Label 2450 6650 3    50   ~ 0
Bank4
Wire Wire Line
	2750 6650 2750 7150
Text Label 2750 6650 3    50   ~ 0
Bank5
Wire Wire Line
	3050 6650 3050 7150
Text Label 3050 6650 3    50   ~ 0
Bank6
Wire Wire Line
	3350 6650 3350 7150
Text Label 3350 6650 3    50   ~ 0
Bank7
$Comp
L Device:R_Small R?
U 1 1 5FCEA96C
P 1250 7250
AR Path="/60AF64DE/5FCEA96C" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA96C" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA96C" Ref="R7"  Part="1" 
F 0 "R7" H 1309 7296 50  0000 L CNN
F 1 "10kΩ" H 1309 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 1250 7250 50  0001 C CNN
F 3 "~" H 1250 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 1250 7250 50  0001 C CNN "Mouser"
	1    1250 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA973
P 1550 7250
AR Path="/60AF64DE/5FCEA973" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA973" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA973" Ref="R8"  Part="1" 
F 0 "R8" H 1609 7296 50  0000 L CNN
F 1 "10kΩ" H 1609 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 1550 7250 50  0001 C CNN
F 3 "~" H 1550 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 1550 7250 50  0001 C CNN "Mouser"
	1    1550 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA97A
P 1850 7250
AR Path="/60AF64DE/5FCEA97A" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA97A" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA97A" Ref="R9"  Part="1" 
F 0 "R9" H 1909 7296 50  0000 L CNN
F 1 "10kΩ" H 1909 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 1850 7250 50  0001 C CNN
F 3 "~" H 1850 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 1850 7250 50  0001 C CNN "Mouser"
	1    1850 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA981
P 2150 7250
AR Path="/60AF64DE/5FCEA981" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA981" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA981" Ref="R10"  Part="1" 
F 0 "R10" H 2209 7296 50  0000 L CNN
F 1 "10kΩ" H 2209 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 2150 7250 50  0001 C CNN
F 3 "~" H 2150 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 2150 7250 50  0001 C CNN "Mouser"
	1    2150 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA988
P 2450 7250
AR Path="/60AF64DE/5FCEA988" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA988" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA988" Ref="R11"  Part="1" 
F 0 "R11" H 2509 7296 50  0000 L CNN
F 1 "10kΩ" H 2509 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 2450 7250 50  0001 C CNN
F 3 "~" H 2450 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 2450 7250 50  0001 C CNN "Mouser"
	1    2450 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA98F
P 2750 7250
AR Path="/60AF64DE/5FCEA98F" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA98F" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA98F" Ref="R12"  Part="1" 
F 0 "R12" H 2809 7296 50  0000 L CNN
F 1 "10kΩ" H 2809 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 2750 7250 50  0001 C CNN
F 3 "~" H 2750 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 2750 7250 50  0001 C CNN "Mouser"
	1    2750 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA996
P 3050 7250
AR Path="/60AF64DE/5FCEA996" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA996" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA996" Ref="R13"  Part="1" 
F 0 "R13" H 3109 7296 50  0000 L CNN
F 1 "10kΩ" H 3109 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 3050 7250 50  0001 C CNN
F 3 "~" H 3050 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 3050 7250 50  0001 C CNN "Mouser"
	1    3050 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FCEA99D
P 3350 7250
AR Path="/60AF64DE/5FCEA99D" Ref="R?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA99D" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FCEA99D" Ref="R14"  Part="1" 
F 0 "R14" H 3409 7296 50  0000 L CNN
F 1 "10kΩ" H 3409 7205 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 3350 7250 50  0001 C CNN
F 3 "~" H 3350 7250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 3350 7250 50  0001 C CNN "Mouser"
	1    3350 7250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCF2A74
P 4600 7300
AR Path="/5D2C0761/5FCF2A74" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FCF2A74" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCF2A74" Ref="#PWR0203"  Part="1" 
F 0 "#PWR0203" H 4600 7050 50  0001 C CNN
F 1 "GND" H 4605 7127 50  0000 C CNN
F 2 "" H 4600 7300 50  0001 C CNN
F 3 "" H 4600 7300 50  0001 C CNN
	1    4600 7300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FCF2A7A
P 4600 7000
AR Path="/5D2C0761/5FCF2A7A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FCF2A7A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCF2A7A" Ref="#PWR0202"  Part="1" 
F 0 "#PWR0202" H 4600 6850 50  0001 C CNN
F 1 "VCC" H 4617 7173 50  0000 C CNN
F 2 "" H 4600 7000 50  0001 C CNN
F 3 "" H 4600 7000 50  0001 C CNN
	1    4600 7000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FCF2A81
P 4600 7150
AR Path="/5D2C0761/5FCF2A81" Ref="C?"  Part="1" 
AR Path="/5D2C0720/5FCF2A81" Ref="C?"  Part="1" 
AR Path="/5FAED671/5FCF2A81" Ref="C29"  Part="1" 
F 0 "C29" H 4715 7196 50  0000 L CNN
F 1 "100nF" H 4715 7105 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 4638 7000 50  0001 C CNN
F 3 "~" H 4600 7150 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 4600 7150 50  0001 C CNN "Mouser"
	1    4600 7150
	1    0    0    -1  
$EndComp
Text GLabel 4950 2000 0    50   Input ~ 0
Phi2
Text GLabel 7000 2000 2    50   Input ~ 0
~RST
Wire Bus Line
	4950 2500 4950 2900
Wire Bus Line
	6950 2500 6950 2900
Wire Bus Line
	4950 3100 4950 4100
Wire Bus Line
	6950 3100 6950 4100
$EndSCHEMATC
