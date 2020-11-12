EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 36 41
Title "System Bus Connector"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Peripheral devices on separate boards connect to the system bus here."
$EndDescr
Text HLabel 3500 2200 0    50   Input ~ 0
Phi2
Text HLabel 2700 2750 0    50   Input ~ 0
~RST
$Comp
L Connector:Conn_01x40_Male J?
U 1 1 5FAF78E6
P 5900 3900
AR Path="/60AF64DE/5FAF78E6" Ref="J?"  Part="1" 
AR Path="/5FAED671/5FAF78E6" Ref="J3"  Part="1" 
F 0 "J3" H 5872 3874 50  0000 R CNN
F 1 "Conn_01x40_Male" H 5872 3783 50  0000 R CNN
F 2 "Connector_IDC:IDC-Header_2x20_P2.54mm_Horizontal" H 5900 3900 50  0001 C CNN
F 3 "~" H 5900 3900 50  0001 C CNN
	1    5900 3900
	-1   0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FAF78EC
P 4950 2000
AR Path="/60AF64DE/5FAF78EC" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF78EC" Ref="#PWR0524"  Part="1" 
F 0 "#PWR0524" H 4950 1850 50  0001 C CNN
F 1 "VCC" V 4968 2127 50  0000 L CNN
F 2 "" H 4950 2000 50  0001 C CNN
F 3 "" H 4950 2000 50  0001 C CNN
	1    4950 2000
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4950 2000 5700 2000
$Comp
L power:GND #PWR?
U 1 1 5FAF78F3
P 5650 2100
AR Path="/60AF64DE/5FAF78F3" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF78F3" Ref="#PWR0527"  Part="1" 
F 0 "#PWR0527" H 5650 1850 50  0001 C CNN
F 1 "GND" V 5655 1972 50  0000 R CNN
F 2 "" H 5650 2100 50  0001 C CNN
F 3 "" H 5650 2100 50  0001 C CNN
	1    5650 2100
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2100 5700 2100
$Comp
L power:GND #PWR?
U 1 1 5FAF78FB
P 5650 2300
AR Path="/60AF64DE/5FAF78FB" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF78FB" Ref="#PWR0528"  Part="1" 
F 0 "#PWR0528" H 5650 2050 50  0001 C CNN
F 1 "GND" V 5655 2172 50  0000 R CNN
F 2 "" H 5650 2300 50  0001 C CNN
F 3 "" H 5650 2300 50  0001 C CNN
	1    5650 2300
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2300 5700 2300
$Comp
L power:GND #PWR?
U 1 1 5FAF7903
P 5650 2500
AR Path="/60AF64DE/5FAF7903" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF7903" Ref="#PWR0529"  Part="1" 
F 0 "#PWR0529" H 5650 2250 50  0001 C CNN
F 1 "GND" V 5655 2372 50  0000 R CNN
F 2 "" H 5650 2500 50  0001 C CNN
F 3 "" H 5650 2500 50  0001 C CNN
	1    5650 2500
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2500 5700 2500
Entry Wire Line
	4950 3000 4850 3100
Text Label 5200 3000 2    50   ~ 0
Addr0
Entry Wire Line
	4950 3100 4850 3200
Text Label 5200 3100 2    50   ~ 0
Addr1
Entry Wire Line
	4950 3200 4850 3300
Text Label 5200 3200 2    50   ~ 0
Addr2
Entry Wire Line
	4950 3300 4850 3400
Text Label 5200 3300 2    50   ~ 0
Addr3
Entry Wire Line
	4950 3400 4850 3500
Text Label 5200 3400 2    50   ~ 0
Addr4
Entry Wire Line
	4950 3500 4850 3600
Text Label 5200 3500 2    50   ~ 0
Addr5
Entry Wire Line
	4950 3600 4850 3700
Text Label 5200 3600 2    50   ~ 0
Addr6
Entry Wire Line
	4950 3700 4850 3800
Text Label 5200 3700 2    50   ~ 0
Addr7
Entry Wire Line
	4950 3800 4850 3900
Text Label 5200 3800 2    50   ~ 0
Addr8
Entry Wire Line
	4950 3900 4850 4000
Text Label 5200 3900 2    50   ~ 0
Addr9
Entry Wire Line
	4950 4000 4850 4100
Text Label 5250 4000 2    50   ~ 0
Addr10
Entry Wire Line
	4950 4100 4850 4200
Text Label 5250 4100 2    50   ~ 0
Addr11
Entry Wire Line
	4950 4200 4850 4300
Text Label 5250 4200 2    50   ~ 0
Addr12
Entry Wire Line
	4950 4300 4850 4400
Text Label 5250 4300 2    50   ~ 0
Addr13
Entry Wire Line
	4950 4400 4850 4500
Text Label 5250 4400 2    50   ~ 0
Addr14
Entry Wire Line
	4950 4500 4850 4600
Text Label 5250 4500 2    50   ~ 0
Addr15
$Comp
L power:GND #PWR?
U 1 1 5FAF792A
P 5650 4600
AR Path="/60AF64DE/5FAF792A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF792A" Ref="#PWR0532"  Part="1" 
F 0 "#PWR0532" H 5650 4350 50  0001 C CNN
F 1 "GND" V 5655 4472 50  0000 R CNN
F 2 "" H 5650 4600 50  0001 C CNN
F 3 "" H 5650 4600 50  0001 C CNN
	1    5650 4600
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 4600 5700 4600
Entry Wire Line
	5050 4700 4950 4800
Entry Wire Line
	5050 4800 4950 4900
Entry Wire Line
	5050 4900 4950 5000
Entry Wire Line
	5050 5000 4950 5100
Entry Wire Line
	5050 5100 4950 5200
Entry Wire Line
	5050 5200 4950 5300
Entry Wire Line
	5050 5300 4950 5400
Entry Wire Line
	5050 5400 4950 5500
$Comp
L power:GND #PWR?
U 1 1 5FAF7941
P 5650 5500
AR Path="/60AF64DE/5FAF7941" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF7941" Ref="#PWR0533"  Part="1" 
F 0 "#PWR0533" H 5650 5250 50  0001 C CNN
F 1 "GND" V 5655 5372 50  0000 R CNN
F 2 "" H 5650 5500 50  0001 C CNN
F 3 "" H 5650 5500 50  0001 C CNN
	1    5650 5500
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 5500 5700 5500
Wire Wire Line
	5300 5600 5700 5600
Wire Wire Line
	5650 5700 5700 5700
Wire Wire Line
	5300 5800 5700 5800
Wire Wire Line
	5650 5900 5700 5900
$Comp
L power:GND #PWR?
U 1 1 5FAF794C
P 5650 2700
AR Path="/60AF64DE/5FAF794C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF794C" Ref="#PWR0530"  Part="1" 
F 0 "#PWR0530" H 5650 2450 50  0001 C CNN
F 1 "GND" V 5655 2572 50  0000 R CNN
F 2 "" H 5650 2700 50  0001 C CNN
F 3 "" H 5650 2700 50  0001 C CNN
	1    5650 2700
	0    1    1    0   
$EndComp
Wire Wire Line
	5650 2700 5700 2700
Wire Bus Line
	4600 5800 4850 5800
$Comp
L power:GND #PWR?
U 1 1 5FAF7956
P 5650 5700
AR Path="/60AF64DE/5FAF7956" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF7956" Ref="#PWR0534"  Part="1" 
F 0 "#PWR0534" H 5650 5450 50  0001 C CNN
F 1 "GND" V 5655 5572 50  0000 R CNN
F 2 "" H 5650 5700 50  0001 C CNN
F 3 "" H 5650 5700 50  0001 C CNN
	1    5650 5700
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FAF795C
P 5650 5900
AR Path="/60AF64DE/5FAF795C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF795C" Ref="#PWR0535"  Part="1" 
F 0 "#PWR0535" H 5650 5650 50  0001 C CNN
F 1 "GND" V 5655 5772 50  0000 R CNN
F 2 "" H 5650 5900 50  0001 C CNN
F 3 "" H 5650 5900 50  0001 C CNN
	1    5650 5900
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FAF7962
P 5300 5800
AR Path="/60AF64DE/5FAF7962" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF7962" Ref="#PWR0526"  Part="1" 
F 0 "#PWR0526" H 5300 5650 50  0001 C CNN
F 1 "VCC" V 5318 5927 50  0000 L CNN
F 2 "" H 5300 5800 50  0001 C CNN
F 3 "" H 5300 5800 50  0001 C CNN
	1    5300 5800
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FAF7968
P 5300 5600
AR Path="/60AF64DE/5FAF7968" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF7968" Ref="#PWR0525"  Part="1" 
F 0 "#PWR0525" H 5300 5450 50  0001 C CNN
F 1 "VCC" V 5318 5727 50  0000 L CNN
F 2 "" H 5300 5600 50  0001 C CNN
F 3 "" H 5300 5600 50  0001 C CNN
	1    5300 5600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5650 2900 5700 2900
$Comp
L power:GND #PWR?
U 1 1 5FAF796F
P 5650 2900
AR Path="/60AF64DE/5FAF796F" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF796F" Ref="#PWR0531"  Part="1" 
F 0 "#PWR0531" H 5650 2650 50  0001 C CNN
F 1 "GND" V 5655 2772 50  0000 R CNN
F 2 "" H 5650 2900 50  0001 C CNN
F 3 "" H 5650 2900 50  0001 C CNN
	1    5650 2900
	0    1    1    0   
$EndComp
Wire Wire Line
	4950 3000 5700 3000
Wire Wire Line
	4950 3300 5700 3300
Wire Wire Line
	4950 3600 5700 3600
Wire Wire Line
	4950 3900 5700 3900
Wire Wire Line
	4950 4200 5700 4200
Wire Wire Line
	4950 4500 5700 4500
Wire Wire Line
	4950 4400 5700 4400
Wire Wire Line
	5700 4300 4950 4300
Wire Wire Line
	4950 4100 5700 4100
Wire Wire Line
	5700 4000 4950 4000
Wire Wire Line
	4950 3800 5700 3800
Wire Wire Line
	5700 3700 4950 3700
Wire Wire Line
	4950 3500 5700 3500
Wire Wire Line
	5700 3400 4950 3400
Wire Wire Line
	4950 3200 5700 3200
Wire Wire Line
	5700 3100 4950 3100
Wire Wire Line
	5050 4700 5700 4700
Wire Wire Line
	5050 4800 5700 4800
Wire Wire Line
	5050 4900 5700 4900
Wire Wire Line
	5050 5000 5700 5000
Wire Wire Line
	5050 5100 5700 5100
Wire Wire Line
	5050 5200 5700 5200
Wire Wire Line
	5050 5300 5700 5300
Wire Wire Line
	5050 5400 5700 5400
Wire Wire Line
	4900 2600 5700 2600
Wire Wire Line
	4900 2800 5700 2800
Text HLabel 4900 2600 0    50   Input ~ 0
~MemLoad
Text HLabel 4900 2800 0    50   Input ~ 0
~MemStore
Text HLabel 4600 5800 0    50   Input ~ 0
Addr[0..15]
Text HLabel 4550 6150 0    50   3State ~ 0
IO[0..7]
Wire Bus Line
	4550 6150 4950 6150
NoConn ~ -500 4400
NoConn ~ -500 4900
$Comp
L 74xx:74LS04 U?
U 7 1 5FC6252F
P -1100 5700
AR Path="/5D2C0761/5FC6252F" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC6252F" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC6252F" Ref="U?"  Part="7" 
AR Path="/5FAED671/5FC6252F" Ref="U99"  Part="7" 
F 0 "U99" H -1100 5750 50  0000 C CNN
F 1 "74AHCT04" H -1100 5650 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1100 5700 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1100 5700 50  0001 C CNN
	7    -1100 5700
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC62535
P -800 4900
AR Path="/5D8005AF/5D800744/5FC62535" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC62535" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC62535" Ref="U?"  Part="6" 
AR Path="/5FAED671/5FC62535" Ref="U99"  Part="6" 
F 0 "U99" H -800 5217 50  0000 C CNN
F 1 "74AHCT04" H -800 5126 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 4900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 4900 50  0001 C CNN
	6    -800 4900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC6253B
P 3200 2750
AR Path="/5D8005AF/5D800744/5FC6253B" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC6253B" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC6253B" Ref="U?"  Part="2" 
AR Path="/5FAED671/5FC6253B" Ref="U99"  Part="2" 
F 0 "U99" H 3200 3067 50  0000 C CNN
F 1 "74AHCT04" H 3200 2976 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 3200 2750 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3200 2750 50  0001 C CNN
	2    3200 2750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC62541
P -800 4400
AR Path="/5D8005AF/5D800744/5FC62541" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC62541" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC62541" Ref="U?"  Part="5" 
AR Path="/5FAED671/5FC62541" Ref="U99"  Part="5" 
F 0 "U99" H -800 4717 50  0000 C CNN
F 1 "74AHCT04" H -800 4626 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 4400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 4400 50  0001 C CNN
	5    -800 4400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC62547
P -800 3900
AR Path="/5D8005AF/5D800744/5FC62547" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC62547" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC62547" Ref="U?"  Part="4" 
AR Path="/5FAED671/5FC62547" Ref="U99"  Part="4" 
F 0 "U99" H -800 4217 50  0000 C CNN
F 1 "74AHCT04" H -800 4126 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -800 3900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -800 3900 50  0001 C CNN
	4    -800 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC6254D
P 3900 2750
AR Path="/5D8005AF/5D800744/5FC6254D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC6254D" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC6254D" Ref="U?"  Part="3" 
AR Path="/5FAED671/5FC6254D" Ref="U99"  Part="3" 
F 0 "U99" H 3900 3067 50  0000 C CNN
F 1 "74AHCT04" H 3900 2976 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 3900 2750 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3900 2750 50  0001 C CNN
	3    3900 2750
	1    0    0    -1  
$EndComp
NoConn ~ -500 3900
$Comp
L power:VCC #PWR?
U 1 1 5FC62555
P -1100 3600
AR Path="/5D2C0761/5FC62555" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC62555" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC62555" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FC62555" Ref="#PWR0522"  Part="1" 
F 0 "#PWR0522" H -1100 3450 50  0001 C CNN
F 1 "VCC" H -1083 3773 50  0000 C CNN
F 2 "" H -1100 3600 50  0001 C CNN
F 3 "" H -1100 3600 50  0001 C CNN
	1    -1100 3600
	1    0    0    -1  
$EndComp
Connection ~ -1100 3900
Wire Wire Line
	-1100 3900 -1100 4400
Connection ~ -1100 4400
Wire Wire Line
	-1100 4400 -1100 4900
$Comp
L power:GND #PWR?
U 1 1 5FC62563
P -1100 6350
AR Path="/5D2C0720/5FC62563" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC62563" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC62563" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FC62563" Ref="#PWR0523"  Part="1" 
F 0 "#PWR0523" H -1100 6100 50  0001 C CNN
F 1 "GND" H -1095 6177 50  0000 C CNN
F 2 "" H -1100 6350 50  0001 C CNN
F 3 "" H -1100 6350 50  0001 C CNN
	1    -1100 6350
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1100 6200 -1100 6350
Wire Wire Line
	-1100 4900 -1100 5200
Connection ~ -1100 4900
$Comp
L 74xx:74LS04 U?
U 1 1 5FC6256D
P 3900 2200
AR Path="/5D8005AF/5D800744/5FC6256D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC6256D" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC6256D" Ref="U?"  Part="1" 
AR Path="/5FAED671/5FC6256D" Ref="U99"  Part="1" 
F 0 "U99" H 3900 2517 50  0000 C CNN
F 1 "74AHCT04" H 3900 2426 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 3900 2200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3900 2200 50  0001 C CNN
	1    3900 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 2200 3600 2200
Wire Wire Line
	4200 2200 5700 2200
Wire Wire Line
	-1100 3600 -1100 3900
Wire Wire Line
	3500 2750 3600 2750
Wire Wire Line
	2700 2750 2900 2750
Wire Wire Line
	4200 2750 4250 2750
Wire Wire Line
	4250 2750 4250 2400
Wire Wire Line
	4250 2400 5700 2400
Text Notes 3650 3050 2    50   ~ 0
Buffer the RST signal before it leaves the board.
Text Label 5100 4700 0    50   ~ 0
IO0
Text Label 5100 4800 0    50   ~ 0
IO1
Text Label 5100 4900 0    50   ~ 0
IO2
Text Label 5100 5000 0    50   ~ 0
IO3
Text Label 5100 5100 0    50   ~ 0
IO4
Text Label 5100 5200 0    50   ~ 0
IO5
Text Label 5100 5300 0    50   ~ 0
IO6
Text Label 5100 5400 0    50   ~ 0
IO7
Wire Bus Line
	4950 4800 4950 6150
Wire Bus Line
	4850 3100 4850 5800
$EndSCHEMATC
