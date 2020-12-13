EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 12 35
Title "System Bus Connector"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Peripheral devices on separate boards connect to the system bus here."
$EndDescr
Entry Wire Line
	4850 4450 4750 4550
Text Label 5100 4450 2    50   ~ 0
Addr4
Entry Wire Line
	4850 4550 4750 4650
Text Label 5100 4550 2    50   ~ 0
Addr6
Entry Wire Line
	4850 4750 4750 4850
Text Label 5100 4750 2    50   ~ 0
Addr8
Entry Wire Line
	4850 4850 4750 4950
Text Label 5150 4850 2    50   ~ 0
Addr10
Entry Wire Line
	4850 5050 4750 5150
Text Label 5150 5050 2    50   ~ 0
Addr12
Entry Wire Line
	4850 5150 4750 5250
Text Label 5150 5150 2    50   ~ 0
Addr14
Entry Wire Line
	6750 5250 6650 5150
Text Label 6600 5150 2    50   ~ 0
Addr15
Entry Wire Line
	6750 5150 6650 5050
Entry Wire Line
	6750 4950 6650 4850
Entry Wire Line
	6750 4850 6650 4750
Entry Wire Line
	6750 4650 6650 4550
Entry Wire Line
	6750 4550 6650 4450
Entry Wire Line
	6750 4350 6650 4250
Entry Wire Line
	6750 4250 6650 4150
$Comp
L power:GND #PWR?
U 1 1 5FAF792A
P 6050 5250
AR Path="/60AF64DE/5FAF792A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF792A" Ref="#PWR0218"  Part="1" 
F 0 "#PWR0218" H 6050 5000 50  0001 C CNN
F 1 "GND" V 6055 5122 50  0000 R CNN
F 2 "" H 6050 5250 50  0001 C CNN
F 3 "" H 6050 5250 50  0001 C CNN
	1    6050 5250
	0    -1   1    0   
$EndComp
Entry Wire Line
	4850 2950 4750 3050
Entry Wire Line
	4850 3050 4750 3150
Entry Wire Line
	4850 3250 4750 3350
Entry Wire Line
	4850 3350 4750 3450
Entry Wire Line
	6650 3250 6750 3350
Entry Wire Line
	6650 3350 6750 3450
$Comp
L power:GND #PWR?
U 1 1 5FAF794C
P 5450 2650
AR Path="/60AF64DE/5FAF794C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FAF794C" Ref="#PWR0197"  Part="1" 
F 0 "#PWR0197" H 5450 2400 50  0001 C CNN
F 1 "GND" V 5455 2522 50  0000 R CNN
F 2 "" H 5450 2650 50  0001 C CNN
F 3 "" H 5450 2650 50  0001 C CNN
	1    5450 2650
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 2650 5500 2650
Wire Wire Line
	4850 4550 5500 4550
Wire Wire Line
	4850 5050 5500 5050
Wire Wire Line
	6650 5150 6000 5150
Wire Wire Line
	5500 5150 4850 5150
Wire Wire Line
	4850 4850 5500 4850
Wire Wire Line
	5500 4750 4850 4750
Wire Wire Line
	4850 4450 5500 4450
Wire Wire Line
	4850 2950 5500 2950
Wire Wire Line
	4850 3050 5500 3050
Wire Wire Line
	4850 3250 5500 3250
Wire Wire Line
	6800 2450 6000 2450
Wire Wire Line
	4700 2450 5500 2450
Text HLabel 6800 2450 2    50   3State ~ 0
~MemLoad
Text HLabel 4700 2450 0    50   3State ~ 0
~MemStore
Text HLabel 4500 3050 0    50   3State ~ 0
IO[0..15]
Text Label 4900 2950 0    50   ~ 0
IO0
Text Label 4900 3050 0    50   ~ 0
IO2
Text Label 4900 3250 0    50   ~ 0
IO4
Text Label 4900 3350 0    50   ~ 0
IO6
Text Label 6600 3350 2    50   ~ 0
IO7
Text Label 6600 3250 2    50   ~ 0
IO5
$Comp
L power:GND #PWR?
U 1 1 5FD376AD
P 5450 4650
AR Path="/60AF64DE/5FD376AD" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD376AD" Ref="#PWR0204"  Part="1" 
F 0 "#PWR0204" H 5450 4400 50  0001 C CNN
F 1 "GND" V 5455 4522 50  0000 R CNN
F 2 "" H 5450 4650 50  0001 C CNN
F 3 "" H 5450 4650 50  0001 C CNN
	1    5450 4650
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 4650 5500 4650
$Comp
L power:GND #PWR?
U 1 1 5FD395C1
P 5450 5250
AR Path="/60AF64DE/5FD395C1" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD395C1" Ref="#PWR0206"  Part="1" 
F 0 "#PWR0206" H 5450 5000 50  0001 C CNN
F 1 "GND" V 5455 5122 50  0000 R CNN
F 2 "" H 5450 5250 50  0001 C CNN
F 3 "" H 5450 5250 50  0001 C CNN
	1    5450 5250
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 5250 5500 5250
$Comp
L power:GND #PWR?
U 1 1 5FD3CC03
P 5450 4350
AR Path="/60AF64DE/5FD3CC03" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD3CC03" Ref="#PWR0203"  Part="1" 
F 0 "#PWR0203" H 5450 4100 50  0001 C CNN
F 1 "GND" V 5455 4222 50  0000 R CNN
F 2 "" H 5450 4350 50  0001 C CNN
F 3 "" H 5450 4350 50  0001 C CNN
	1    5450 4350
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 4350 5500 4350
Text Label 6600 2950 2    50   ~ 0
IO1
Text Label 6600 3050 2    50   ~ 0
IO3
Wire Wire Line
	6650 3050 6000 3050
Wire Wire Line
	6650 2950 6000 2950
Entry Wire Line
	6650 3050 6750 3150
Entry Wire Line
	6650 2950 6750 3050
Wire Wire Line
	6000 3250 6650 3250
Wire Wire Line
	6000 3350 6650 3350
Wire Wire Line
	6000 4850 6650 4850
Wire Wire Line
	6650 4750 6000 4750
Wire Wire Line
	6000 4450 6650 4450
Wire Wire Line
	6650 4250 6000 4250
Wire Wire Line
	6650 4150 6000 4150
Wire Wire Line
	6650 4550 6000 4550
Wire Wire Line
	6650 5050 6000 5050
Text Label 6600 4150 2    50   ~ 0
Addr1
Text Label 6600 4250 2    50   ~ 0
Addr3
Text Label 6600 4450 2    50   ~ 0
Addr5
Text Label 6600 4550 2    50   ~ 0
Addr7
Text Label 6600 4750 2    50   ~ 0
Addr9
Text Label 6600 4850 2    50   ~ 0
Addr11
Text Label 6600 5050 2    50   ~ 0
Addr13
$Comp
L power:GND #PWR?
U 1 1 5FD9B74C
P 5450 4950
AR Path="/60AF64DE/5FD9B74C" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD9B74C" Ref="#PWR0205"  Part="1" 
F 0 "#PWR0205" H 5450 4700 50  0001 C CNN
F 1 "GND" V 5455 4822 50  0000 R CNN
F 2 "" H 5450 4950 50  0001 C CNN
F 3 "" H 5450 4950 50  0001 C CNN
	1    5450 4950
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 4950 5500 4950
Wire Wire Line
	5450 2350 5500 2350
$Comp
L power:GND #PWR?
U 1 1 5FDB4B0A
P 6050 2650
AR Path="/60AF64DE/5FDB4B0A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDB4B0A" Ref="#PWR0209"  Part="1" 
F 0 "#PWR0209" H 6050 2400 50  0001 C CNN
F 1 "GND" V 6055 2522 50  0000 R CNN
F 2 "" H 6050 2650 50  0001 C CNN
F 3 "" H 6050 2650 50  0001 C CNN
	1    6050 2650
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDBA759
P 6050 4350
AR Path="/60AF64DE/5FDBA759" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBA759" Ref="#PWR0215"  Part="1" 
F 0 "#PWR0215" H 6050 4100 50  0001 C CNN
F 1 "GND" V 6055 4222 50  0000 R CNN
F 2 "" H 6050 4350 50  0001 C CNN
F 3 "" H 6050 4350 50  0001 C CNN
	1    6050 4350
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDBF023
P 6050 4950
AR Path="/60AF64DE/5FDBF023" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBF023" Ref="#PWR0217"  Part="1" 
F 0 "#PWR0217" H 6050 4700 50  0001 C CNN
F 1 "GND" V 6055 4822 50  0000 R CNN
F 2 "" H 6050 4950 50  0001 C CNN
F 3 "" H 6050 4950 50  0001 C CNN
	1    6050 4950
	0    -1   1    0   
$EndComp
Text HLabel 4500 4250 0    50   3State ~ 0
Addr[0..15]
Entry Wire Line
	4850 4150 4750 4250
Text Label 5100 4150 2    50   ~ 0
Addr0
Wire Wire Line
	4850 4150 5500 4150
Wire Wire Line
	5500 4250 4850 4250
Text Label 5100 4250 2    50   ~ 0
Addr2
Entry Wire Line
	4850 4250 4750 4350
Wire Wire Line
	4850 3350 5500 3350
Wire Wire Line
	4750 2750 5500 2750
Wire Wire Line
	6000 2350 6050 2350
Wire Wire Line
	6050 2650 6000 2650
Wire Wire Line
	6050 5250 6000 5250
Wire Wire Line
	6050 4350 6000 4350
Wire Wire Line
	6050 4950 6000 4950
Wire Wire Line
	6050 4650 6000 4650
$Comp
L power:GND #PWR?
U 1 1 5FDBCB4E
P 6050 4650
AR Path="/60AF64DE/5FDBCB4E" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDBCB4E" Ref="#PWR0216"  Part="1" 
F 0 "#PWR0216" H 6050 4400 50  0001 C CNN
F 1 "GND" V 6055 4522 50  0000 R CNN
F 2 "" H 6050 4650 50  0001 C CNN
F 3 "" H 6050 4650 50  0001 C CNN
	1    6050 4650
	0    -1   1    0   
$EndComp
$Comp
L power:VCC #PWR0208
U 1 1 5FBF62F4
P 6050 2350
F 0 "#PWR0208" H 6050 2200 50  0001 C CNN
F 1 "VCC" V 6065 2478 50  0000 L CNN
F 2 "" H 6050 2350 50  0001 C CNN
F 3 "" H 6050 2350 50  0001 C CNN
	1    6050 2350
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0196
U 1 1 5FBF6D31
P 5450 2350
F 0 "#PWR0196" H 5450 2200 50  0001 C CNN
F 1 "VCC" V 5465 2477 50  0000 L CNN
F 2 "" H 5450 2350 50  0001 C CNN
F 3 "" H 5450 2350 50  0001 C CNN
	1    5450 2350
	0    -1   1    0   
$EndComp
Text HLabel 6800 1800 2    50   Output ~ 0
~RDY
$Comp
L power:VCC #PWR?
U 1 1 5FBB7C05
P 3900 1500
AR Path="/60AF64DE/600805C3/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D2600/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D275E/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FF1115C/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FB90806/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FBB7C05" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBB7C05" Ref="#PWR0193"  Part="1" 
F 0 "#PWR0193" H 3900 1350 50  0001 C CNN
F 1 "VCC" H 3917 1673 50  0000 C CNN
F 2 "" H 3900 1500 50  0001 C CNN
F 3 "" H 3900 1500 50  0001 C CNN
	1    3900 1500
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5FBB7C0B
P 3900 1650
AR Path="/5D2C0720/5FBB7C0B" Ref="R?"  Part="1" 
AR Path="/5FAED671/5FBB7C0B" Ref="R10"  Part="1" 
F 0 "R10" H 3959 1696 50  0000 L CNN
F 1 "10kΩ" H 3959 1605 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 3900 1650 50  0001 C CNN
F 3 "~" H 3900 1650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 3900 1650 50  0001 C CNN "Mouser"
	1    3900 1650
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
AR Path="/5FAED671/5FBBFEE5" Ref="#PWR0188"  Part="1" 
F 0 "#PWR0188" H -1250 2700 50  0001 C CNN
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
AR Path="/5FAED671/5FBBFEF1" Ref="#PWR0189"  Part="1" 
F 0 "#PWR0189" H -1250 6600 50  0001 C CNN
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
P 4550 1800
AR Path="/5D8005AF/5D800744/5FBCC32D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FBCC32D" Ref="U?"  Part="2" 
AR Path="/5FAED671/5FBCC32D" Ref="U24"  Part="1" 
F 0 "U24" H 4550 2117 50  0000 C CNN
F 1 "74AHCT04" H 4550 2026 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4550 1800 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4550 1800 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 4550 1800 50  0001 C CNN "Mouser"
	1    4550 1800
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 1800 4850 1800
Wire Wire Line
	3900 1500 3900 1550
Wire Wire Line
	3900 1750 3900 1800
Wire Wire Line
	3900 1800 4250 1800
Connection ~ 3900 1800
Text Notes 1100 3050 0    50   ~ 0
The bus connector has a shared open-drain active-high RDY signal.\nIf all bus devices are ready then they allow the line to remain high.\nIf any bus device is not ready then it drives the line low.\nWhen RDY is driven low, the CPU Phi1 clock stops and the CPU\ndisconnects from the bus, placing the lines in a high-Z mode.\n\nIf no bus devices are connected then the CPU is always ready.
Text Label 5000 2550 2    50   ~ 0
RDY
Wire Wire Line
	4900 5350 5500 5350
Text Label 4900 5350 0    50   ~ 0
Bank1
Wire Wire Line
	6000 2550 6800 2550
Wire Wire Line
	6600 5350 6000 5350
Wire Wire Line
	6600 2750 6000 2750
Text Label 6600 2750 2    50   ~ 0
Bank0
Text Label 6600 5350 2    50   ~ 0
Bank2
$Comp
L power:GND #PWR?
U 1 1 5FBEF786
P 6050 3150
AR Path="/60AF64DE/5FBEF786" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBEF786" Ref="#PWR0211"  Part="1" 
F 0 "#PWR0211" H 6050 2900 50  0001 C CNN
F 1 "GND" V 6055 3022 50  0000 R CNN
F 2 "" H 6050 3150 50  0001 C CNN
F 3 "" H 6050 3150 50  0001 C CNN
	1    6050 3150
	0    -1   1    0   
$EndComp
Wire Wire Line
	6050 3150 6000 3150
$Comp
L power:GND #PWR?
U 1 1 5FBF51C5
P 5450 3150
AR Path="/60AF64DE/5FBF51C5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FBF51C5" Ref="#PWR0199"  Part="1" 
F 0 "#PWR0199" H 5450 2900 50  0001 C CNN
F 1 "GND" V 5455 3022 50  0000 R CNN
F 2 "" H 5450 3150 50  0001 C CNN
F 3 "" H 5450 3150 50  0001 C CNN
	1    5450 3150
	0    1    1    0   
$EndComp
Wire Wire Line
	5500 2550 3900 2550
Wire Bus Line
	4500 4250 4750 4250
Text HLabel 7000 4250 2    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	7000 4250 6750 4250
Wire Bus Line
	4500 3050 4750 3050
Text HLabel 7000 3050 2    50   3State ~ 0
IO[0..15]
Wire Bus Line
	7000 3050 6750 3050
$Comp
L power:GND #PWR?
U 1 1 5FCEA943
P 1250 7350
AR Path="/60AF64DE/5FCEA943" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FAF68C1/5FCEA943" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCEA943" Ref="#PWR0190"  Part="1" 
F 0 "#PWR0190" H 1250 7100 50  0001 C CNN
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
AR Path="/5FAED671/5FCEA949" Ref="#PWR0191"  Part="1" 
F 0 "#PWR0191" H 1550 7100 50  0001 C CNN
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
AR Path="/5FAED671/5FCEA94F" Ref="#PWR0192"  Part="1" 
F 0 "#PWR0192" H 1850 7100 50  0001 C CNN
F 1 "GND" H 1855 7177 50  0000 C CNN
F 2 "" H 1850 7350 50  0001 C CNN
F 3 "" H 1850 7350 50  0001 C CNN
	1    1850 7350
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
L power:GND #PWR?
U 1 1 5FCF2A74
P 4600 7300
AR Path="/5D2C0761/5FCF2A74" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FCF2A74" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FCF2A74" Ref="#PWR0195"  Part="1" 
F 0 "#PWR0195" H 4600 7050 50  0001 C CNN
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
AR Path="/5FAED671/5FCF2A7A" Ref="#PWR0194"  Part="1" 
F 0 "#PWR0194" H 4600 6850 50  0001 C CNN
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
Text GLabel 4750 2750 0    50   Input ~ 0
Phi2
Text GLabel 6800 2550 2    50   Input ~ 0
~RST
Wire Wire Line
	5450 3150 5500 3150
$Comp
L power:GND #PWR?
U 1 1 5FD8DC65
P 6050 3450
AR Path="/60AF64DE/5FD8DC65" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD8DC65" Ref="#PWR0212"  Part="1" 
F 0 "#PWR0212" H 6050 3200 50  0001 C CNN
F 1 "GND" V 6055 3322 50  0000 R CNN
F 2 "" H 6050 3450 50  0001 C CNN
F 3 "" H 6050 3450 50  0001 C CNN
	1    6050 3450
	0    -1   1    0   
$EndComp
Wire Wire Line
	6050 3450 6000 3450
$Comp
L power:GND #PWR?
U 1 1 5FD936B5
P 5450 3450
AR Path="/60AF64DE/5FD936B5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FD936B5" Ref="#PWR0200"  Part="1" 
F 0 "#PWR0200" H 5450 3200 50  0001 C CNN
F 1 "GND" V 5455 3322 50  0000 R CNN
F 2 "" H 5450 3450 50  0001 C CNN
F 3 "" H 5450 3450 50  0001 C CNN
	1    5450 3450
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 3450 5500 3450
Entry Wire Line
	6650 3550 6750 3650
Entry Wire Line
	6650 3650 6750 3750
Text Label 6600 3650 2    50   ~ 0
IO11
Text Label 6600 3550 2    50   ~ 0
IO9
Entry Wire Line
	6650 3350 6750 3450
Wire Wire Line
	6000 3550 6650 3550
Wire Wire Line
	6000 3650 6650 3650
Wire Wire Line
	4850 3550 5500 3550
Text Label 4900 3550 0    50   ~ 0
IO8
Text Label 4900 3650 0    50   ~ 0
IO10
Wire Wire Line
	4850 3650 5500 3650
Entry Wire Line
	4850 3550 4750 3650
Entry Wire Line
	4850 3650 4750 3750
Wire Wire Line
	3900 1800 3900 2550
$Comp
L Connector_Generic:Conn_02x32_Odd_Even J?
U 1 1 5FAF78E6
P 5700 3850
AR Path="/60AF64DE/5FAF78E6" Ref="J?"  Part="1" 
AR Path="/5FAED671/5FAF78E6" Ref="J3"  Part="1" 
F 0 "J3" H 5750 5600 50  0000 R CNN
F 1 "71922-264LF" H 5950 5500 50  0000 R CNN
F 2 "Connector_IDC:IDC-Header_2x32_P2.54mm_Horizontal" H 5700 3850 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/18/71922-1363266.pdf" H 5700 3850 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Amphenol-FCI/71922-264LF?qs=yJYkLTYh576qGOVYzS69eQ%3D%3D" H 5700 3850 50  0001 C CNN "Mouser"
	1    5700 3850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDD5426
P 5450 2850
AR Path="/60AF64DE/5FDD5426" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDD5426" Ref="#PWR0198"  Part="1" 
F 0 "#PWR0198" H 5450 2600 50  0001 C CNN
F 1 "GND" V 5455 2722 50  0000 R CNN
F 2 "" H 5450 2850 50  0001 C CNN
F 3 "" H 5450 2850 50  0001 C CNN
	1    5450 2850
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 2850 5500 2850
$Comp
L power:GND #PWR?
U 1 1 5FDD86C9
P 6050 2850
AR Path="/60AF64DE/5FDD86C9" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FDD86C9" Ref="#PWR0210"  Part="1" 
F 0 "#PWR0210" H 6050 2600 50  0001 C CNN
F 1 "GND" V 6055 2722 50  0000 R CNN
F 2 "" H 6050 2850 50  0001 C CNN
F 3 "" H 6050 2850 50  0001 C CNN
	1    6050 2850
	0    -1   1    0   
$EndComp
Wire Wire Line
	6050 2850 6000 2850
$Comp
L power:GND #PWR?
U 1 1 5FE04257
P 5450 3750
AR Path="/60AF64DE/5FE04257" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FE04257" Ref="#PWR0201"  Part="1" 
F 0 "#PWR0201" H 5450 3500 50  0001 C CNN
F 1 "GND" V 5455 3622 50  0000 R CNN
F 2 "" H 5450 3750 50  0001 C CNN
F 3 "" H 5450 3750 50  0001 C CNN
	1    5450 3750
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 3750 5500 3750
$Comp
L power:GND #PWR?
U 1 1 5FE0738A
P 5450 4050
AR Path="/60AF64DE/5FE0738A" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FE0738A" Ref="#PWR0202"  Part="1" 
F 0 "#PWR0202" H 5450 3800 50  0001 C CNN
F 1 "GND" V 5455 3922 50  0000 R CNN
F 2 "" H 5450 4050 50  0001 C CNN
F 3 "" H 5450 4050 50  0001 C CNN
	1    5450 4050
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 4050 5500 4050
$Comp
L power:GND #PWR?
U 1 1 5FE0A8C1
P 6050 3750
AR Path="/60AF64DE/5FE0A8C1" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FE0A8C1" Ref="#PWR0213"  Part="1" 
F 0 "#PWR0213" H 6050 3500 50  0001 C CNN
F 1 "GND" V 6055 3622 50  0000 R CNN
F 2 "" H 6050 3750 50  0001 C CNN
F 3 "" H 6050 3750 50  0001 C CNN
	1    6050 3750
	0    -1   1    0   
$EndComp
Wire Wire Line
	6050 3750 6000 3750
$Comp
L power:GND #PWR?
U 1 1 5FE0DCE6
P 6050 4050
AR Path="/60AF64DE/5FE0DCE6" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FE0DCE6" Ref="#PWR0214"  Part="1" 
F 0 "#PWR0214" H 6050 3800 50  0001 C CNN
F 1 "GND" V 6055 3922 50  0000 R CNN
F 2 "" H 6050 4050 50  0001 C CNN
F 3 "" H 6050 4050 50  0001 C CNN
	1    6050 4050
	0    -1   1    0   
$EndComp
Wire Wire Line
	6050 4050 6000 4050
Entry Wire Line
	6650 3850 6750 3950
Entry Wire Line
	6650 3950 6750 4050
Text Label 6600 3950 2    50   ~ 0
IO15
Text Label 6600 3850 2    50   ~ 0
IO13
Wire Wire Line
	6000 3850 6650 3850
Wire Wire Line
	6000 3950 6650 3950
Wire Wire Line
	4850 3850 5500 3850
Text Label 4900 3850 0    50   ~ 0
IO12
Text Label 4900 3950 0    50   ~ 0
IO14
Wire Wire Line
	4850 3950 5500 3950
Entry Wire Line
	4850 3850 4750 3950
Entry Wire Line
	4850 3950 4750 4050
$Comp
L power:GND #PWR?
U 1 1 5FE333A3
P 6050 5450
AR Path="/60AF64DE/5FE333A3" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FE333A3" Ref="#PWR0219"  Part="1" 
F 0 "#PWR0219" H 6050 5200 50  0001 C CNN
F 1 "GND" V 6055 5322 50  0000 R CNN
F 2 "" H 6050 5450 50  0001 C CNN
F 3 "" H 6050 5450 50  0001 C CNN
	1    6050 5450
	0    -1   1    0   
$EndComp
Wire Wire Line
	6050 5450 6000 5450
$Comp
L power:GND #PWR?
U 1 1 5FE37238
P 5450 5450
AR Path="/60AF64DE/5FE37238" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/5FE37238" Ref="#PWR0207"  Part="1" 
F 0 "#PWR0207" H 5450 5200 50  0001 C CNN
F 1 "GND" V 5455 5322 50  0000 R CNN
F 2 "" H 5450 5450 50  0001 C CNN
F 3 "" H 5450 5450 50  0001 C CNN
	1    5450 5450
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 5450 5500 5450
Wire Bus Line
	4750 4250 4750 5250
Wire Bus Line
	6750 4250 6750 5250
Wire Bus Line
	6750 3050 6750 4050
Wire Bus Line
	4750 3050 4750 4050
$EndSCHEMATC
