EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 7 39
Title "MEM"
Date "2021-06-18"
Rev "B (2a1292a9)"
Comp ""
Comment1 "place bus lines into tristate and halt the Phi1 clock."
Comment2 "Devices on the bus may take the open-collector ~RDY~ signal high to force the CPU to"
Comment3 "These devices connect to the main board via a connector described in another sheet."
Comment4 "The MEM stage interfaces with memory and memory-mapped peripherals."
$EndDescr
Text HLabel 1950 3900 0    50   Input ~ 0
StoreOp_MEM[0..15]
Text HLabel 1950 2300 0    50   Input ~ 0
Ctl_MEM[14..20]
Entry Wire Line
	2400 2300 2500 2400
Entry Wire Line
	2500 2300 2600 2400
Entry Bus Bus
	5900 2300 6000 2400
Wire Bus Line
	6000 2400 7200 2400
Text Label 6100 2400 0    50   ~ 0
Ctl_MEM[17..20]
Text Label 2600 2400 3    50   ~ 0
Ctl_MEM14
Text Label 2500 2400 3    50   ~ 0
Ctl_MEM15
Wire Bus Line
	1950 3900 3600 3900
Text HLabel 9250 3250 2    50   3State ~ 0
~MemStore
Text HLabel 9250 3150 2    50   3State ~ 0
~MemLoad
Connection ~ 6600 3900
Wire Bus Line
	6600 3900 7350 3900
Text HLabel 9250 3450 2    50   3State ~ 0
SystemBus[0..15]
$Sheet
S 7350 4400 1150 200 
U 5FAF68C1
F0 "System Bus Pull-down" 50
F1 "SystemBusPulldown.sch" 50
F2 "SystemBus[0..15]" I L 7350 4500 50 
$EndSheet
Wire Bus Line
	6600 3900 6600 4500
Wire Bus Line
	6600 4500 7350 4500
Text HLabel 1950 4900 0    50   Input ~ 0
Y_MEM[0..15]
Wire Bus Line
	5400 3900 6600 3900
$Sheet
S 3600 4700 1250 300 
U 5FB92C55
F0 "Buffer Addr" 50
F1 "BufferALUResultAsAddr.sch" 50
F2 "~RDY" I L 3600 4800 50 
F3 "Addr[0..15]" T R 4850 4900 50 
F4 "Y_MEM[0..15]" I L 3600 4900 50 
$EndSheet
Wire Bus Line
	4850 4900 9250 4900
Text HLabel 9250 4900 2    50   3State ~ 0
Addr[0..15]
Wire Bus Line
	1950 4900 3600 4900
$Sheet
S 3600 2950 1250 400 
U 5FB90806
F0 "Buffer Memory Control Signals" 50
F1 "BufferMemoryControlSignals.sch" 50
F2 "~MemLoadIn" I L 3600 3150 50 
F3 "~MemStoreIn" I L 3600 3250 50 
F4 "~MemLoad" T R 4850 3150 50 
F5 "~MemStore" T R 4850 3250 50 
F6 "~RDY" I L 3600 3050 50 
$EndSheet
Wire Wire Line
	2600 2400 2600 3150
Wire Wire Line
	4850 3150 9250 3150
Wire Wire Line
	9250 3250 4850 3250
Wire Wire Line
	2500 2400 2500 3250
Wire Wire Line
	3300 3050 3600 3050
Text HLabel 2800 1200 0    50   Input ~ 0
RDY
Text Notes 5250 1550 0    50   ~ 0
The RDY signal is an open-collector signal shared between all bus devices.\nWhen a bus device takes this signal high, the CPU releases the system bus\nI/O lines, address lines, and control signals, putting them into a high-Z state.\nThis allows peripheral devices to drive the bus when needed.\n\nThe Reset cycle also forces the CPU to release the bus. This prevents\nerroneous I/O operations on reset as a result of interstage registers being\ninitialized to arbitrary values on power-on.
Wire Wire Line
	2600 3150 3600 3150
Wire Wire Line
	2500 3250 3600 3250
Entry Wire Line
	2300 2300 2400 2400
Text Label 2400 2400 3    50   ~ 0
Ctl_MEM16
Wire Wire Line
	2400 2400 2400 3800
Wire Wire Line
	2400 3800 2800 3800
$Sheet
S 7350 3700 1600 400 
U 5FD56BFA
F0 "sheet5FD56BF4" 50
F1 "StoreOperandRegister3.sch" 50
F2 "SystemBus[0..15]" I L 7350 3900 50 
F3 "StoreOp_WB[0..15]" O R 8950 3900 50 
$EndSheet
Text HLabel 9250 3900 2    50   Output ~ 0
StoreOp_WB[0..15]
Wire Bus Line
	9250 3900 8950 3900
Text HLabel 9250 2500 2    50   Output ~ 0
SelC_WB[0..2]
Wire Bus Line
	8950 2500 9250 2500
$Sheet
S 7200 2200 1750 400 
U 5FD643E5
F0 "sheet5FD643DA" 50
F1 "Ctl_15_23_Register.sch" 50
F2 "SelC_MEM[0..2]" I L 7200 2500 50 
F3 "SelC_WB[0..2]" O R 8950 2500 50 
F4 "Ctl_WB[17..20]" O R 8950 2400 50 
F5 "Ctl_MEM[17..20]" I L 7200 2400 50 
$EndSheet
Text HLabel 6750 2500 0    50   Input ~ 0
SelC_MEM[0..2]
Wire Bus Line
	7200 2500 6750 2500
Text HLabel 9250 2400 2    50   Output ~ 0
Ctl_WB[17..20]
Wire Bus Line
	8950 2400 9250 2400
Text HLabel 9250 5600 2    50   Output ~ 0
Y_WB[0..15]
$Sheet
S 7350 5300 1350 400 
U 5FD9EFDB
F0 "Sheet5FD9EFDA" 50
F1 "ALUResultRegister_MEM_WB.sch" 50
F2 "Y_MEM[0..15]" I L 7350 5600 50 
F3 "Y_WB[0..15]" O R 8700 5600 50 
$EndSheet
Text HLabel 6750 5600 0    50   Input ~ 0
Y_MEM[0..15]
Wire Bus Line
	6750 5600 7350 5600
Wire Bus Line
	9250 5600 8700 5600
Wire Bus Line
	6600 3450 9250 3450
Wire Bus Line
	6600 3450 6600 3900
$Comp
L 74xx:74LS04 U?
U 1 1 605061C0
P 3450 1200
AR Path="/5D8005AF/5D800744/605061C0" Ref="U?"  Part="6" 
AR Path="/5D2C0720/605061C0" Ref="U?"  Part="2" 
AR Path="/5FAED671/605061C0" Ref="U?"  Part="1" 
AR Path="/60AF64DE/605061C0" Ref="U12"  Part="1" 
F 0 "U12" H 3450 1517 50  0000 C CNN
F 1 "74AHCT04" H 3450 1426 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 3450 1200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3450 1200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 3450 1200 50  0001 C CNN "Mouser"
	1    3450 1200
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 1200 3150 1200
NoConn ~ -250 5250
NoConn ~ -250 5750
$Comp
L 74xx:74LS04 U?
U 7 1 605153B1
P -850 6550
AR Path="/5D2C0761/605153B1" Ref="U?"  Part="7" 
AR Path="/5D2C0720/605153B1" Ref="U?"  Part="7" 
AR Path="/5FAED671/605153B1" Ref="U?"  Part="7" 
AR Path="/60AF64DE/605153B1" Ref="U12"  Part="7" 
F 0 "U12" H -850 6600 50  0000 C CNN
F 1 "74AHCT04" H -850 6500 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -850 6550 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 6550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -850 6550 50  0001 C CNN "Mouser"
	7    -850 6550
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 605153B8
P -550 5750
AR Path="/5D8005AF/5D800744/605153B8" Ref="U?"  Part="6" 
AR Path="/5D2C0720/605153B8" Ref="U?"  Part="6" 
AR Path="/5FAED671/605153B8" Ref="U?"  Part="6" 
AR Path="/60AF64DE/605153B8" Ref="U12"  Part="6" 
F 0 "U12" H -550 6067 50  0000 C CNN
F 1 "74AHCT04" H -550 5976 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -550 5750 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 5750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -550 5750 50  0001 C CNN "Mouser"
	6    -550 5750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 605153BF
P -550 5250
AR Path="/5D8005AF/5D800744/605153BF" Ref="U?"  Part="6" 
AR Path="/5D2C0720/605153BF" Ref="U?"  Part="5" 
AR Path="/5FAED671/605153BF" Ref="U?"  Part="5" 
AR Path="/60AF64DE/605153BF" Ref="U12"  Part="5" 
F 0 "U12" H -550 5567 50  0000 C CNN
F 1 "74AHCT04" H -550 5476 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -550 5250 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 5250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -550 5250 50  0001 C CNN "Mouser"
	5    -550 5250
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 605153C6
P -550 4750
AR Path="/5D8005AF/5D800744/605153C6" Ref="U?"  Part="6" 
AR Path="/5D2C0720/605153C6" Ref="U?"  Part="4" 
AR Path="/5FAED671/605153C6" Ref="U?"  Part="4" 
AR Path="/60AF64DE/605153C6" Ref="U12"  Part="4" 
F 0 "U12" H -550 5067 50  0000 C CNN
F 1 "74AHCT04" H -550 4976 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -550 4750 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 4750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -550 4750 50  0001 C CNN "Mouser"
	4    -550 4750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 605153CD
P -550 4250
AR Path="/5D8005AF/5D800744/605153CD" Ref="U?"  Part="6" 
AR Path="/5D2C0720/605153CD" Ref="U?"  Part="3" 
AR Path="/5FAED671/605153CD" Ref="U?"  Part="3" 
AR Path="/60AF64DE/605153CD" Ref="U12"  Part="3" 
F 0 "U12" H -550 4567 50  0000 C CNN
F 1 "74AHCT04" H -550 4476 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -550 4250 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 4250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -550 4250 50  0001 C CNN "Mouser"
	3    -550 4250
	1    0    0    -1  
$EndComp
NoConn ~ -250 4250
NoConn ~ -250 4750
$Comp
L power:VCC #PWR?
U 1 1 605153D5
P -850 3850
AR Path="/5D2C0761/605153D5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/605153D5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/605153D5" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/605153D5" Ref="#PWR085"  Part="1" 
F 0 "#PWR085" H -850 3700 50  0001 C CNN
F 1 "VCC" H -833 4023 50  0000 C CNN
F 2 "" H -850 3850 50  0001 C CNN
F 3 "" H -850 3850 50  0001 C CNN
	1    -850 3850
	1    0    0    -1  
$EndComp
Connection ~ -850 4250
Wire Wire Line
	-850 4250 -850 4750
Connection ~ -850 4750
Wire Wire Line
	-850 4750 -850 5250
Connection ~ -850 5250
Wire Wire Line
	-850 5250 -850 5750
$Comp
L power:GND #PWR?
U 1 1 605153E1
P -850 7200
AR Path="/5D2C0720/605153E1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/605153E1" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/605153E1" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/605153E1" Ref="#PWR086"  Part="1" 
F 0 "#PWR086" H -850 6950 50  0001 C CNN
F 1 "GND" H -845 7027 50  0000 C CNN
F 2 "" H -850 7200 50  0001 C CNN
F 3 "" H -850 7200 50  0001 C CNN
	1    -850 7200
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-850 7050 -850 7200
Wire Wire Line
	-850 5750 -850 6050
Connection ~ -850 5750
$Comp
L 74xx:74LS04 U?
U 2 1 605153EE
P 3450 1750
AR Path="/5D8005AF/5D800744/605153EE" Ref="U?"  Part="6" 
AR Path="/5D2C0720/605153EE" Ref="U?"  Part="2" 
AR Path="/5FAED671/605153EE" Ref="U?"  Part="2" 
AR Path="/60AF64DE/605153EE" Ref="U12"  Part="2" 
F 0 "U12" H 3450 2067 50  0000 C CNN
F 1 "74AHCT04" H 3450 1976 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 3450 1750 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3450 1750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 3450 1750 50  0001 C CNN "Mouser"
	2    3450 1750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 605153F5
P 1100 7500
AR Path="/5D2C0761/605153F5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/605153F5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/605153F5" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/605153F5" Ref="#PWR088"  Part="1" 
F 0 "#PWR088" H 1100 7250 50  0001 C CNN
F 1 "GND" H 1105 7327 50  0000 C CNN
F 2 "" H 1100 7500 50  0001 C CNN
F 3 "" H 1100 7500 50  0001 C CNN
	1    1100 7500
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 605153FB
P 1100 7200
AR Path="/5D2C0761/605153FB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/605153FB" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/605153FB" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/605153FB" Ref="#PWR087"  Part="1" 
F 0 "#PWR087" H 1100 7050 50  0001 C CNN
F 1 "VCC" H 1117 7373 50  0000 C CNN
F 2 "" H 1100 7200 50  0001 C CNN
F 3 "" H 1100 7200 50  0001 C CNN
	1    1100 7200
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 60515402
P 900 7350
AR Path="/5D2C0761/60515402" Ref="C?"  Part="1" 
AR Path="/5D2C0720/60515402" Ref="C?"  Part="1" 
AR Path="/5FAED671/60515402" Ref="C?"  Part="1" 
AR Path="/60AF64DE/60515402" Ref="C15"  Part="1" 
F 0 "C15" H 1015 7396 50  0000 L CNN
F 1 "100nF" H 1015 7305 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 938 7200 50  0001 C CNN
F 3 "~" H 900 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 900 7350 50  0001 C CNN "Mouser"
	1    900  7350
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 60CA967D
P -1750 4800
AR Path="/60906BCD/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F531/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD38/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/600609C2/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FBEE9DC/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FC18C0A/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC5F3B1/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC5F3B1/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FC6A49F/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FC6A49F/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC6FC04/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC6FC04/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC806D1/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC806D1/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCD7CF6/5FBF0C1B/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCD7CF6/5FBF1996/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCD86F6/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC6FC04/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC806D1/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC5F3B1/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCD7CF6/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FCE2082/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DB91/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4714C/60CA967D" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/60CA967D" Ref="#PWR089"  Part="1" 
F 0 "#PWR089" H -1750 4650 50  0001 C CNN
F 1 "VCC" H -1733 4973 50  0000 C CNN
F 2 "" H -1750 4800 50  0001 C CNN
F 3 "" H -1750 4800 50  0001 C CNN
	1    -1750 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1650 4950 -1750 4950
Connection ~ -1750 4950
Wire Wire Line
	-1750 4950 -1750 5150
Wire Wire Line
	-1650 5150 -1750 5150
Connection ~ -1750 5150
Wire Wire Line
	-1750 5150 -1750 5550
Wire Wire Line
	-1650 5550 -1750 5550
Connection ~ -1750 5550
Wire Wire Line
	-1750 5550 -1750 5750
Wire Wire Line
	-1650 5750 -1750 5750
Connection ~ -1750 5750
Wire Wire Line
	-1750 5750 -1750 6000
$Comp
L power:GND #PWR?
U 1 1 60CA9695
P -1750 7000
AR Path="/5FE8EB3D/60CA9695" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FCE2082/60CA9695" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC2DB91/60CA9695" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD4714C/60CA9695" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/60CA9695" Ref="#PWR090"  Part="1" 
F 0 "#PWR090" H -1750 6750 50  0001 C CNN
F 1 "GND" H -1745 6827 50  0000 C CNN
F 2 "" H -1750 7000 50  0001 C CNN
F 3 "" H -1750 7000 50  0001 C CNN
	1    -1750 7000
	1    0    0    -1  
$EndComp
NoConn ~ -1050 5050
NoConn ~ -1050 5650
$Comp
L 74xx:74LS32 U?
U 2 2 60CA969F
P 3100 3700
AR Path="/5FE35007/5FCE2082/60CA969F" Ref="U?"  Part="2" 
AR Path="/60AF64DE/60CA969F" Ref="U13"  Part="2" 
F 0 "U13" H 3100 4025 50  0000 C CNN
F 1 "74ABT32" H 3100 3934 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 3100 3700 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74ABT32-1318711.pdf" H 3100 3700 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74ABT32PW118?qs=P62ublwmbi%2FkuIVV181WGQ%3D%3D" H 3100 3700 50  0001 C CNN "Mouser"
	2    3100 3700
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U?
U 3 1 60CA96A6
P -1350 5050
AR Path="/5FE35007/5FCE2082/60CA96A6" Ref="U?"  Part="3" 
AR Path="/60AF64DE/60CA96A6" Ref="U13"  Part="3" 
F 0 "U13" H -1350 5375 50  0000 C CNN
F 1 "74ABT32" H -1350 5284 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1350 5050 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74ABT32-1318711.pdf" H -1350 5050 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74ABT32PW118?qs=P62ublwmbi%2FkuIVV181WGQ%3D%3D" H -1350 5050 50  0001 C CNN "Mouser"
	3    -1350 5050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U?
U 4 1 60CA96AD
P -1350 5650
AR Path="/5FE35007/5FCE2082/60CA96AD" Ref="U?"  Part="4" 
AR Path="/60AF64DE/60CA96AD" Ref="U13"  Part="4" 
F 0 "U13" H -1350 5975 50  0000 C CNN
F 1 "74ABT32" H -1350 5884 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1350 5650 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74ABT32-1318711.pdf" H -1350 5650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74ABT32PW118?qs=P62ublwmbi%2FkuIVV181WGQ%3D%3D" H -1350 5650 50  0001 C CNN "Mouser"
	4    -1350 5650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U?
U 5 1 60CA96B4
P -1750 6500
AR Path="/5FE35007/5FCE2082/60CA96B4" Ref="U?"  Part="5" 
AR Path="/60AF64DE/60CA96B4" Ref="U13"  Part="5" 
F 0 "U13" H -1520 6546 50  0000 L CNN
F 1 "74ABT32" H -1520 6455 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1750 6500 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74ABT32-1318711.pdf" H -1750 6500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74ABT32PW118?qs=P62ublwmbi%2FkuIVV181WGQ%3D%3D" H -1750 6500 50  0001 C CNN "Mouser"
	5    -1750 6500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U?
U 1 1 60CAA449
P 4450 1500
AR Path="/5FE35007/5FCE2082/60CAA449" Ref="U?"  Part="2" 
AR Path="/60AF64DE/60CAA449" Ref="U13"  Part="1" 
F 0 "U13" H 4450 1825 50  0000 C CNN
F 1 "74ABT32" H 4450 1734 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4450 1500 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74ABT32-1318711.pdf" H 4450 1500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74ABT32PW118?qs=P62ublwmbi%2FkuIVV181WGQ%3D%3D" H 4450 1500 50  0001 C CNN "Mouser"
	1    4450 1500
	1    0    0    -1  
$EndComp
$Sheet
S 3600 3600 1800 400 
U 5FF1115C
F0 "Buffer StoreOp As Bus I/O" 50
F1 "BufferStoreOpAsBusIO.sch" 50
F2 "SystemBus[0..15]" T R 5400 3900 50 
F3 "StoreOp_MEM[0..15]" I L 3600 3900 50 
F4 "~Assert" I L 3600 3700 50 
$EndSheet
$Comp
L Device:C C?
U 1 1 60CB6995
P 1400 7350
AR Path="/5D8005AF/5D833E4B/60CB6995" Ref="C?"  Part="1" 
AR Path="/5FE21410/60CB6995" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/60CB6995" Ref="C?"  Part="1" 
AR Path="/60153F0B/60CB6995" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/60CB6995" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/60CB6995" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56568/60CB6995" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FCDD090/60CB6995" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD148F1/60CB6995" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD202DF/60CB6995" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD2B946/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD447EB/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD44E3D/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45108/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45557/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45834/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD47CBA/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/600400AF/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040306/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040791/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60044374/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004437C/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004F414/60CB6995" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/60CB6995" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/60CB6995" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/60CB6995" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/60CB6995" Ref="C?"  Part="1" 
AR Path="/60A71BBF/60CB6995" Ref="C?"  Part="1" 
AR Path="/60AF64DE/600805C3/60CB6995" Ref="C?"  Part="1" 
AR Path="/60AF64DE/600D2600/60CB6995" Ref="C?"  Part="1" 
AR Path="/60AF64DE/600D275E/60CB6995" Ref="C?"  Part="1" 
AR Path="/60AF64DE/5FF1115C/60CB6995" Ref="C?"  Part="1" 
AR Path="/60AF64DE/60CB6995" Ref="C17"  Part="1" 
F 0 "C17" H 1515 7396 50  0000 L CNN
F 1 "100nF" H 1515 7305 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1438 7200 50  0001 C CNN
F 3 "~" H 1400 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1400 7350 50  0001 C CNN "Mouser"
	1    1400 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  7200 1100 7200
Wire Wire Line
	1400 7500 1100 7500
Connection ~ 1100 7200
Wire Wire Line
	1100 7200 1400 7200
Connection ~ 1100 7500
Wire Wire Line
	1100 7500 900  7500
Text Label 3300 3050 0    50   ~ 0
~RDY
Wire Wire Line
	3300 4800 3600 4800
Text Label 3300 4800 0    50   ~ 0
~RDY
Text GLabel 2850 1750 0    50   Input ~ 0
~RST
Wire Wire Line
	3150 1750 2850 1750
Wire Wire Line
	-850 3850 -850 4250
Wire Wire Line
	3750 1200 3950 1200
Wire Wire Line
	3950 1200 3950 1400
Wire Wire Line
	3950 1400 4150 1400
Wire Wire Line
	4150 1600 3950 1600
Wire Wire Line
	3950 1600 3950 1750
Wire Wire Line
	3950 1750 3750 1750
Wire Wire Line
	5050 1500 4750 1500
Text Label 5050 1500 2    50   ~ 0
~RDY
Wire Wire Line
	3400 3700 3600 3700
Wire Wire Line
	2500 3600 2800 3600
Text Label 2500 3600 0    50   ~ 0
~RDY
Wire Wire Line
	-1750 4800 -1750 4950
Wire Bus Line
	1950 2300 5900 2300
$EndSCHEMATC
