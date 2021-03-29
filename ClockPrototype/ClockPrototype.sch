EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 1 3
Title "Turtle16: Clock Prototype"
Date "2021-03-29"
Rev "A (d3581256)"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "A prototype of the clock for the Turtle16 computer."
$EndDescr
$Comp
L Mechanical:MountingHole_Pad H1
U 1 1 5D9D8517
P 1100 6950
F 0 "H1" H 1200 6999 50  0000 L CNN
F 1 "MountingHole_Pad" H 1200 6908 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 1100 6950 50  0001 C CNN
F 3 "~" H 1100 6950 50  0001 C CNN
	1    1100 6950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 5D9D8FA4
P 1100 7050
F 0 "#PWR03" H 1100 6800 50  0001 C CNN
F 1 "GND" H 1105 6877 50  0000 C CNN
F 2 "" H 1100 7050 50  0001 C CNN
F 3 "" H 1100 7050 50  0001 C CNN
	1    1100 7050
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H2
U 1 1 5D9DB4ED
P 1100 7450
F 0 "H2" H 1200 7499 50  0000 L CNN
F 1 "MountingHole_Pad" H 1200 7408 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 1100 7450 50  0001 C CNN
F 3 "~" H 1100 7450 50  0001 C CNN
	1    1100 7450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 5D9DB4F9
P 1100 7550
F 0 "#PWR04" H 1100 7300 50  0001 C CNN
F 1 "GND" H 1105 7377 50  0000 C CNN
F 2 "" H 1100 7550 50  0001 C CNN
F 3 "" H 1100 7550 50  0001 C CNN
	1    1100 7550
	1    0    0    -1  
$EndComp
$Sheet
S 6200 3400 550  450 
U 5D2C0720
F0 "Clock" 50
F1 "Clock.sch" 50
F2 "~HLT" I R 6750 3500 50 
F3 "RDY" B L 6200 3500 50 
$EndSheet
$Comp
L power:VCC #PWR?
U 1 1 608FD908
P 4300 3250
AR Path="/5D2C0761/608FD908" Ref="#PWR?"  Part="1" 
AR Path="/608FD908" Ref="#PWR01"  Part="1" 
AR Path="/5DCFC665/608FD908" Ref="#PWR?"  Part="1" 
F 0 "#PWR01" H 4300 3100 50  0001 C CNN
F 1 "VCC" V 4317 3378 50  0000 L CNN
F 2 "" H 4300 3250 50  0001 C CNN
F 3 "" H 4300 3250 50  0001 C CNN
	1    4300 3250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 608FD90E
P 4300 3550
AR Path="/5D2C0761/608FD90E" Ref="#PWR?"  Part="1" 
AR Path="/608FD90E" Ref="#PWR02"  Part="1" 
AR Path="/5DCFC665/608FD90E" Ref="#PWR?"  Part="1" 
F 0 "#PWR02" H 4300 3300 50  0001 C CNN
F 1 "GND" V 4305 3422 50  0000 R CNN
F 2 "" H 4300 3550 50  0001 C CNN
F 3 "" H 4300 3550 50  0001 C CNN
	1    4300 3550
	0    -1   -1   0   
$EndComp
$Comp
L Device:CP1 C?
U 1 1 608FD914
P 3750 3400
AR Path="/5D2C0720/608FD914" Ref="C?"  Part="1" 
AR Path="/5D2C0761/608FD914" Ref="C?"  Part="1" 
AR Path="/608FD914" Ref="C1"  Part="1" 
AR Path="/5DCFC665/608FD914" Ref="C?"  Part="1" 
F 0 "C1" H 3842 3446 50  0000 L CNN
F 1 "100µF" H 3842 3355 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.33x1.80mm_HandSolder" H 3750 3400 50  0001 C CNN
F 3 "~" H 3750 3400 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-AMK316ABJ107ML-T" H 3750 3400 50  0001 C CNN "Mouser"
	1    3750 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4300 3250 4150 3250
Wire Wire Line
	3750 3550 4150 3550
Wire Wire Line
	3400 3450 3500 3450
Wire Wire Line
	3400 3350 3500 3350
$Comp
L power:PWR_FLAG #FLG?
U 1 1 608FD924
P 4150 3750
AR Path="/5DCFC665/608FD924" Ref="#FLG?"  Part="1" 
AR Path="/608FD924" Ref="#FLG02"  Part="1" 
F 0 "#FLG02" H 4150 3825 50  0001 C CNN
F 1 "PWR_FLAG" H 4150 3923 50  0000 C CNN
F 2 "" H 4150 3750 50  0001 C CNN
F 3 "~" H 4150 3750 50  0001 C CNN
	1    4150 3750
	-1   0    0    1   
$EndComp
Wire Wire Line
	4150 3750 4150 3550
Connection ~ 4150 3550
Wire Wire Line
	4150 3550 4300 3550
$Comp
L power:PWR_FLAG #FLG?
U 1 1 608FD92D
P 4150 3050
AR Path="/5DCFC665/608FD92D" Ref="#FLG?"  Part="1" 
AR Path="/608FD92D" Ref="#FLG01"  Part="1" 
F 0 "#FLG01" H 4150 3125 50  0001 C CNN
F 1 "PWR_FLAG" H 4150 3223 50  0000 C CNN
F 2 "" H 4150 3050 50  0001 C CNN
F 3 "~" H 4150 3050 50  0001 C CNN
	1    4150 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 3050 4150 3250
Connection ~ 4150 3250
Wire Wire Line
	4150 3250 3750 3250
Wire Wire Line
	3500 3250 3500 3350
Wire Wire Line
	3500 3450 3500 3550
Wire Wire Line
	3750 3250 3500 3250
Connection ~ 3750 3250
Wire Wire Line
	3500 3550 3750 3550
Connection ~ 3750 3550
Wire Wire Line
	6200 3500 5900 3500
$Comp
L power:GND #PWR06
U 1 1 5D9DB4FF
P 2100 7550
F 0 "#PWR06" H 2100 7300 50  0001 C CNN
F 1 "GND" H 2105 7377 50  0000 C CNN
F 2 "" H 2100 7550 50  0001 C CNN
F 3 "" H 2100 7550 50  0001 C CNN
	1    2100 7550
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H4
U 1 1 5D9DB4F3
P 2100 7450
F 0 "H4" H 2200 7499 50  0000 L CNN
F 1 "MountingHole_Pad" H 2200 7408 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2100 7450 50  0001 C CNN
F 3 "~" H 2100 7450 50  0001 C CNN
	1    2100 7450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR05
U 1 1 5D9D9546
P 2100 7050
F 0 "#PWR05" H 2100 6800 50  0001 C CNN
F 1 "GND" H 2105 6877 50  0000 C CNN
F 2 "" H 2100 7050 50  0001 C CNN
F 3 "" H 2100 7050 50  0001 C CNN
	1    2100 7050
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H3
U 1 1 5D9D8A27
P 2100 6950
F 0 "H3" H 2200 6999 50  0000 L CNN
F 1 "MountingHole_Pad" H 2200 6908 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2100 6950 50  0001 C CNN
F 3 "~" H 2100 6950 50  0001 C CNN
	1    2100 6950
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J1
U 1 1 60501CA1
P 3200 3450
F 0 "J1" H 3118 3125 50  0000 C CNN
F 1 "Screw_Terminal_01x02" H 3118 3216 50  0000 C CNN
F 2 "TerminalBlock_MetzConnect:TerminalBlock_MetzConnect_Type055_RT01502HDWU_1x02_P5.00mm_Horizontal" H 3200 3450 50  0001 C CNN
F 3 "~" H 3200 3450 50  0001 C CNN
	1    3200 3450
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x01_Female J?
U 1 1 6063BE68
P 7200 3500
AR Path="/5D2C0720/6063BE68" Ref="J?"  Part="1" 
AR Path="/6063BE68" Ref="J3"  Part="1" 
F 0 "J3" H 7100 3250 50  0000 C CNN
F 1 "~HLT" H 7100 3350 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x01_P2.54mm_Vertical" H 7200 3500 50  0001 C CNN
F 3 "~" H 7200 3500 50  0001 C CNN
	1    7200 3500
	1    0    0    1   
$EndComp
Wire Wire Line
	6750 3500 7000 3500
$Comp
L power:VCC #PWR?
U 1 1 6064C5C5
P 5900 2950
AR Path="/60AF64DE/600805C3/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D2600/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/600D275E/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FF1115C/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/60AF64DE/5FB90806/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/5FAED671/6064C5C5" Ref="#PWR?"  Part="1" 
AR Path="/6064C5C5" Ref="#PWR0101"  Part="1" 
F 0 "#PWR0101" H 5900 2800 50  0001 C CNN
F 1 "VCC" H 5917 3123 50  0000 C CNN
F 2 "" H 5900 2950 50  0001 C CNN
F 3 "" H 5900 2950 50  0001 C CNN
	1    5900 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 6064C5CC
P 5900 3150
AR Path="/5D2C0720/6064C5CC" Ref="R?"  Part="1" 
AR Path="/5FAED671/6064C5CC" Ref="R?"  Part="1" 
AR Path="/6064C5CC" Ref="R10"  Part="1" 
F 0 "R10" H 5959 3196 50  0000 L CNN
F 1 "10kΩ" H 5959 3105 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 5900 3150 50  0001 C CNN
F 3 "~" H 5900 3150 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 5900 3150 50  0001 C CNN "Mouser"
	1    5900 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 2950 5900 3050
Wire Wire Line
	5900 3250 5900 3500
$EndSCHEMATC
