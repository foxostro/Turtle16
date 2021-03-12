EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 35
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 "Resume execution when the button is pressed."
Comment4 "Pulls the RDY shared line low when the HLT control signal is active."
$EndDescr
Text Notes 1950 2500 0    50   ~ 0
Generate a 22ns positive pulse when the\nResume button is pressed. The debounce\non the button prevents this pulse from\noccurring more frequently than every\n10ms.
$Comp
L power:VCC #PWR?
U 1 1 611BE4DB
P 3700 2450
AR Path="/5D2C07CD/611BE4DB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611BE4DB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4DB" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 3700 2300 50  0001 C CNN
F 1 "VCC" H 3717 2623 50  0000 C CNN
F 2 "" H 3700 2450 50  0001 C CNN
F 3 "" H 3700 2450 50  0001 C CNN
	1    3700 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 611BE4E1
P 3700 3900
AR Path="/5D2C0761/611BE4E1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611BE4E1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4E1" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 3700 3650 50  0001 C CNN
F 1 "GND" H 3705 3727 50  0000 C CNN
F 2 "" H 3700 3900 50  0001 C CNN
F 3 "" H 3700 3900 50  0001 C CNN
	1    3700 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4200 3200 4300 3200
Wire Wire Line
	4300 3200 4300 3300
Wire Wire Line
	4300 3400 4200 3400
$Comp
L power:VCC #PWR?
U 1 1 611BE4EA
P 3150 3400
AR Path="/5D2C0720/611BE4EA" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4EA" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 3150 3250 50  0001 C CNN
F 1 "VCC" V 3168 3527 50  0000 L CNN
F 2 "" H 3150 3400 50  0001 C CNN
F 3 "" H 3150 3400 50  0001 C CNN
	1    3150 3400
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3150 3400 3200 3400
Wire Wire Line
	3700 3600 3700 3850
Wire Wire Line
	3700 2450 3700 2500
$Comp
L Device:R_Small R?
U 1 1 611BE4FB
P 2400 2700
AR Path="/5D2C0720/611BE4FB" Ref="R?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4FB" Ref="R?"  Part="1" 
F 0 "R?" H 2459 2746 50  0000 L CNN
F 1 "10kΩ" H 2459 2655 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 2400 2700 50  0001 C CNN
F 3 "~" H 2400 2700 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1002ELF" H 2400 2700 50  0001 C CNN "Mouser"
	1    2400 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	2400 2600 2400 2500
Connection ~ 3700 2500
Wire Wire Line
	3700 2500 3700 2800
Wire Wire Line
	1950 3850 2400 3850
Connection ~ 3700 3850
Wire Wire Line
	3700 3850 3700 3900
Wire Wire Line
	3200 3000 2400 3000
Wire Wire Line
	2400 2800 2400 3000
$Comp
L Device:C C?
U 1 1 611BE50A
P 2600 3500
AR Path="/5D2C0761/611BE50A" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611BE50A" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE50A" Ref="C?"  Part="1" 
F 0 "C?" H 2715 3546 50  0000 L CNN
F 1 "0.01uF" H 2715 3455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 2638 3350 50  0001 C CNN
F 3 "~" H 2600 3500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 2600 3500 50  0001 C CNN "Mouser"
	1    2600 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 3350 2600 3200
Wire Wire Line
	2600 3200 3200 3200
Wire Wire Line
	2600 3650 2600 3850
Connection ~ 2600 3850
Wire Wire Line
	2600 3850 3700 3850
$Comp
L Device:R_Small R?
U 1 1 611BE516
P 4550 2700
AR Path="/5D2C0720/611BE516" Ref="R?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE516" Ref="R?"  Part="1" 
F 0 "R?" H 4609 2746 50  0000 L CNN
F 1 "1kΩ" H 4609 2655 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 4550 2700 50  0001 C CNN
F 3 "~" H 4550 2700 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1001ELF" H 4550 2700 50  0001 C CNN "Mouser"
	1    4550 2700
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 611BE51F
P 4550 3500
AR Path="/5D2C0761/611BE51F" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611BE51F" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE51F" Ref="C?"  Part="1" 
F 0 "C?" H 4665 3546 50  0000 L CNN
F 1 "22pF" H 4665 3455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 4588 3350 50  0001 C CNN
F 3 "~" H 4550 3500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Walsin/0603N220F500CT?qs=ZrPdAQfJ6DPO1aiYBnCCBw%3D%3D" H 4550 3500 50  0001 C CNN "Mouser"
	1    4550 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 2500 4550 2500
Wire Wire Line
	4550 2500 4550 2600
Wire Wire Line
	4550 3650 4550 3850
Wire Wire Line
	4550 3850 3700 3850
Wire Wire Line
	4550 2800 4550 3300
Wire Wire Line
	4300 3300 4550 3300
Connection ~ 4300 3300
Wire Wire Line
	4300 3300 4300 3400
Connection ~ 4550 3300
Wire Wire Line
	4550 3300 4550 3350
Wire Wire Line
	2400 2500 3700 2500
Connection ~ 2400 3000
$Comp
L Device:C C?
U 1 1 611BE533
P 2400 3500
AR Path="/5D2C0761/611BE533" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611BE533" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE533" Ref="C?"  Part="1" 
F 0 "C?" H 2515 3546 50  0000 L CNN
F 1 "10uF" H 2515 3455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 2438 3350 50  0001 C CNN
F 3 "~" H 2400 3500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Walsin/0603X106K100CT?qs=ZrPdAQfJ6DPmkZ8840O9Sg%3D%3D" H 2400 3500 50  0001 C CNN "Mouser"
	1    2400 3500
	-1   0    0    -1  
$EndComp
Wire Wire Line
	2400 3000 2400 3350
Wire Wire Line
	2400 3650 2400 3850
Connection ~ 2400 3850
Wire Wire Line
	2400 3850 2600 3850
Wire Wire Line
	2250 3000 2400 3000
Wire Wire Line
	1950 3000 2050 3000
$Comp
L Device:R_Small R?
U 1 1 611BE540
P 2150 3000
AR Path="/5D2C0720/611BE540" Ref="R?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE540" Ref="R?"  Part="1" 
F 0 "R?" V 1954 3000 50  0000 C CNN
F 1 "1kΩ" V 2045 3000 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 2150 3000 50  0001 C CNN
F 3 "~" H 2150 3000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1001ELF" V 2150 3000 50  0001 C CNN "Mouser"
	1    2150 3000
	0    1    1    0   
$EndComp
Wire Wire Line
	1950 3000 1950 3300
Wire Wire Line
	1950 3700 1950 3850
$Comp
L Switch:SW_Push SW?
U 1 1 611BE548
P 1950 3500
AR Path="/5D2C0761/611BE548" Ref="SW?"  Part="1" 
AR Path="/5D2C0720/611BE548" Ref="SW?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE548" Ref="SW?"  Part="1" 
F 0 "SW?" V 2000 3800 50  0000 R CNN
F 1 "Resume" V 1900 3850 50  0000 R CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm_H5mm" H 1950 3700 50  0001 C CNN
F 3 "~" H 1950 3700 50  0001 C CNN
	1    1950 3500
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1800 4400 5800 4400
Text HLabel 1800 4400 0    50   Input ~ 0
~RST
Text HLabel 10050 3900 2    50   BiDi ~ 0
RDY
Wire Wire Line
	9950 3900 10050 3900
NoConn ~ -950 5300
$Comp
L power:VCC #PWR?
U 1 1 611D0296
P -1550 4850
AR Path="/5D2C0761/611D0296" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611D0296" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611D0296" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -1550 4700 50  0001 C CNN
F 1 "VCC" H -1533 5023 50  0000 C CNN
F 2 "" H -1550 4850 50  0001 C CNN
F 3 "" H -1550 4850 50  0001 C CNN
	1    -1550 4850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 611D029C
P -1550 6650
AR Path="/5D2C0720/611D029C" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/611D029C" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611D029C" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -1550 6400 50  0001 C CNN
F 1 "GND" H -1545 6477 50  0000 C CNN
F 2 "" H -1550 6650 50  0001 C CNN
F 3 "" H -1550 6650 50  0001 C CNN
	1    -1550 6650
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1550 6500 -1550 6650
Wire Wire Line
	5800 4600 5700 4600
Wire Wire Line
	6650 3450 6550 3450
Wire Wire Line
	6550 3450 6550 4000
Wire Wire Line
	6550 4500 6400 4500
Wire Wire Line
	7600 3200 7450 3200
Wire Wire Line
	7450 3200 7450 3450
Wire Wire Line
	7450 3450 7250 3450
Wire Wire Line
	4200 3000 7600 3000
Wire Wire Line
	5700 4600 5700 5300
Wire Wire Line
	2150 5200 2200 5200
Connection ~ 2150 5200
Wire Wire Line
	2150 5400 2150 5200
Wire Wire Line
	4300 5400 2150 5400
Wire Wire Line
	4100 5200 4300 5200
Wire Wire Line
	5700 5300 5600 5300
Wire Wire Line
	5000 5300 4900 5300
Wire Wire Line
	3500 5200 3450 5200
Wire Wire Line
	2850 5200 2800 5200
Text HLabel 1800 5200 0    50   Input ~ 0
~HLT
Wire Wire Line
	1800 5200 2150 5200
Wire Wire Line
	8500 3100 8200 3100
Wire Wire Line
	8500 4000 6550 4000
Connection ~ 6550 4000
Wire Wire Line
	6550 4000 6550 4500
Wire Wire Line
	9100 3200 9200 3200
Wire Wire Line
	9200 3200 9200 3450
Wire Wire Line
	9200 3450 8400 3450
Wire Wire Line
	8400 3450 8400 3800
Wire Wire Line
	8400 3800 8500 3800
Wire Wire Line
	8500 3300 8500 3500
Wire Wire Line
	8500 3500 9200 3500
Wire Wire Line
	9200 3500 9200 3900
Wire Wire Line
	9200 3900 9100 3900
Text Notes 8400 3050 0    50   ~ 0
R
Text Notes 8400 4150 0    50   ~ 0
S
Wire Wire Line
	-1550 4850 -1550 5300
Connection ~ -1550 5300
Wire Wire Line
	-1550 5300 -1550 5500
$Comp
L power:VCC #PWR?
U 1 1 60508FA4
P -2650 4300
AR Path="/5D2C0761/60508FA4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/60508FA4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/60508FA4" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -2650 4150 50  0001 C CNN
F 1 "VCC" H -2633 4473 50  0000 C CNN
F 2 "" H -2650 4300 50  0001 C CNN
F 3 "" H -2650 4300 50  0001 C CNN
	1    -2650 4300
	1    0    0    -1  
$EndComp
Connection ~ -2650 4650
Wire Wire Line
	-2650 4650 -2650 4850
Connection ~ -2650 4850
Wire Wire Line
	-2650 4850 -2650 5200
Connection ~ -2650 5200
Wire Wire Line
	-2650 5200 -2650 5400
Connection ~ -2650 5400
Wire Wire Line
	-2650 5400 -2650 5500
$Comp
L power:GND #PWR?
U 1 1 6050FB91
P -2650 6650
AR Path="/5D2C0720/6050FB91" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/6050FB91" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/6050FB91" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -2650 6400 50  0001 C CNN
F 1 "GND" H -2645 6477 50  0000 C CNN
F 2 "" H -2650 6650 50  0001 C CNN
F 3 "" H -2650 6650 50  0001 C CNN
	1    -2650 6650
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-2650 6500 -2650 6650
NoConn ~ -2050 5300
NoConn ~ -2050 4750
Wire Wire Line
	-2650 4300 -2650 4650
$Comp
L power:VCC #PWR?
U 1 1 60561054
P -3750 4850
AR Path="/5D2C0761/60561054" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/60561054" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/60561054" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -3750 4700 50  0001 C CNN
F 1 "VCC" H -3733 5023 50  0000 C CNN
F 2 "" H -3750 4850 50  0001 C CNN
F 3 "" H -3750 4850 50  0001 C CNN
	1    -3750 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3750 4850 -3750 5200
Connection ~ -3750 5200
Wire Wire Line
	-3750 5200 -3750 5400
Connection ~ -3750 5400
Wire Wire Line
	-3750 5400 -3750 5500
NoConn ~ -3150 5300
Wire Wire Line
	-3750 6500 -3750 6650
$Comp
L power:GND #PWR?
U 1 1 6056106B
P -3750 6650
AR Path="/5D2C0720/6056106B" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/6056106B" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/6056106B" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -3750 6400 50  0001 C CNN
F 1 "GND" H -3745 6477 50  0000 C CNN
F 2 "" H -3750 6650 50  0001 C CNN
F 3 "" H -3750 6650 50  0001 C CNN
	1    -3750 6650
	-1   0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U?
U 1 1 60561032
P 4600 5300
F 0 "U?" H 4600 5625 50  0000 C CNN
F 1 "74AHCT08" H 4600 5534 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4600 5300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT08-1388970.pdf" H 4600 5300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT08PW118?qs=P62ublwmbi%252BmFuvuMynCYg%3D%3D" H 4600 5300 50  0001 C CNN "Mouser"
	1    4600 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 1 1 612E659B
P 2500 5200
F 0 "U?" H 2500 5517 50  0000 C CNN
F 1 "74AHCT04" H 2500 5426 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 2500 5200 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 2500 5200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 2500 5200 50  0001 C CNN "Mouser"
	1    2500 5200
	1    0    0    -1  
$EndComp
$Comp
L Timer:LM555xMM U?
U 1 1 611BE4F4
P 3700 3200
AR Path="/5D2C0720/611BE4F4" Ref="U?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4F4" Ref="U?"  Part="1" 
F 0 "U?" H 3400 3700 50  0000 C CNN
F 1 "74AHCT04" H 3400 3600 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4350 2800 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 4550 2800 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/LM555CMMX-NOPB?qs=QbsRYf82W3FVBYo9S%2FC8bw%3D%3D" H 3700 3200 50  0001 C CNN "Mouser"
	1    3700 3200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U?
U 1 1 60506B82
P 8800 3200
F 0 "U?" H 8800 3525 50  0000 C CNN
F 1 "74AHCT02" H 8800 3434 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 8800 3200 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H 8800 3200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H 8800 3200 50  0001 C CNN "Mouser"
	1    8800 3200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U?
U 5 1 6056104E
P -3750 6000
F 0 "U?" H -3520 6046 50  0000 L CNN
F 1 "74AHCT08" H -3520 5955 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -3750 6000 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT08-1388970.pdf" H -3750 6000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT08PW118?qs=P62ublwmbi%252BmFuvuMynCYg%3D%3D" H -3750 6000 50  0001 C CNN "Mouser"
	5    -3750 6000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U?
U 4 1 60561047
P -3450 5300
F 0 "U?" H -3450 5625 50  0000 C CNN
F 1 "74AHCT08" H -3450 5534 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -3450 5300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT08-1388970.pdf" H -3450 5300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT08PW118?qs=P62ublwmbi%252BmFuvuMynCYg%3D%3D" H -3450 5300 50  0001 C CNN "Mouser"
	4    -3450 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U?
U 3 1 60561040
P 7900 3100
F 0 "U?" H 7900 3425 50  0000 C CNN
F 1 "74AHCT08" H 7900 3334 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 7900 3100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT08-1388970.pdf" H 7900 3100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT08PW118?qs=P62ublwmbi%252BmFuvuMynCYg%3D%3D" H 7900 3100 50  0001 C CNN "Mouser"
	3    7900 3100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U?
U 2 1 60561039
P 6100 4500
F 0 "U?" H 6100 4825 50  0000 C CNN
F 1 "74AHCT08" H 6100 4734 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 6100 4500 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT08-1388970.pdf" H 6100 4500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT08PW118?qs=P62ublwmbi%252BmFuvuMynCYg%3D%3D" H 6100 4500 50  0001 C CNN "Mouser"
	2    6100 4500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 612E52B1
P 6950 3450
F 0 "U?" H 6950 3767 50  0000 C CNN
F 1 "74AHCT04" H 6950 3676 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 6950 3450 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 6950 3450 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 6950 3450 50  0001 C CNN "Mouser"
	5    6950 3450
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 612E5866
P 5300 5300
F 0 "U?" H 5300 5617 50  0000 C CNN
F 1 "74AHCT04" H 5300 5526 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 5300 5300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 5300 5300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 5300 5300 50  0001 C CNN "Mouser"
	4    5300 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 612E5D5B
P 3800 5200
F 0 "U?" H 3800 5517 50  0000 C CNN
F 1 "74AHCT04" H 3800 5426 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 3800 5200 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 3800 5200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 3800 5200 50  0001 C CNN "Mouser"
	3    3800 5200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 612E6178
P 3150 5200
F 0 "U?" H 3150 5517 50  0000 C CNN
F 1 "74AHCT04" H 3150 5426 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 3150 5200 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 3150 5200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 3150 5200 50  0001 C CNN "Mouser"
	2    3150 5200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 7 1 612E0CF5
P -1550 6000
F 0 "U?" H -1320 6046 50  0000 L CNN
F 1 "74AHCT04" H -1320 5955 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1550 6000 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H -1550 6000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -1550 6000 50  0001 C CNN "Mouser"
	7    -1550 6000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 612DD2AD
P -1250 5300
F 0 "U?" H -1250 5617 50  0000 C CNN
F 1 "74AHCT04" H -1250 5526 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1250 5300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H -1250 5300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -1250 5300 50  0001 C CNN "Mouser"
	6    -1250 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U?
U 2 1 60506B89
P 8800 3900
F 0 "U?" H 8800 4225 50  0000 C CNN
F 1 "74AHCT02" H 8800 4134 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 8800 3900 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H 8800 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H 8800 3900 50  0001 C CNN "Mouser"
	2    8800 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U?
U 3 1 60506B90
P -2350 4750
F 0 "U?" H -2350 5075 50  0000 C CNN
F 1 "74AHCT02" H -2350 4984 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2350 4750 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H -2350 4750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H -2350 4750 50  0001 C CNN "Mouser"
	3    -2350 4750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U?
U 4 1 60506B97
P -2350 5300
F 0 "U?" H -2350 5625 50  0000 C CNN
F 1 "74AHCT02" H -2350 5534 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2350 5300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H -2350 5300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H -2350 5300 50  0001 C CNN "Mouser"
	4    -2350 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U?
U 5 1 60506B9E
P -2650 6000
F 0 "U?" H -2420 6046 50  0000 L CNN
F 1 "74AHCT02" H -2420 5955 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2650 6000 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H -2650 6000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H -2650 6000 50  0001 C CNN "Mouser"
	5    -2650 6000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 605F9350
P -4800 6650
AR Path="/5D2C0720/605F9350" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/605F9350" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/605F9350" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -4800 6400 50  0001 C CNN
F 1 "GND" H -4795 6477 50  0000 C CNN
F 2 "" H -4800 6650 50  0001 C CNN
F 3 "" H -4800 6650 50  0001 C CNN
	1    -4800 6650
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-4800 6500 -4800 6650
$Comp
L 74xx:74LS05 U?
U 1 1 605F9358
P 9650 3900
F 0 "U?" H 9650 4217 50  0000 C CNN
F 1 "74AHCT05" H 9650 4126 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 9650 3900 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H 9650 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H 9650 3900 50  0001 C CNN "Mouser"
	1    9650 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 1 1 605F935F
P -4500 3250
F 0 "U?" H -4500 3567 50  0000 C CNN
F 1 "74AHCT05" H -4500 3476 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4500 3250 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -4500 3250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -4500 3250 50  0001 C CNN "Mouser"
	1    -4500 3250
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 1 1 605F9366
P -4500 3750
F 0 "U?" H -4500 4067 50  0000 C CNN
F 1 "74AHCT05" H -4500 3976 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4500 3750 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -4500 3750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -4500 3750 50  0001 C CNN "Mouser"
	1    -4500 3750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 1 1 605F936D
P -4500 4250
F 0 "U?" H -4500 4567 50  0000 C CNN
F 1 "74AHCT05" H -4500 4476 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4500 4250 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -4500 4250 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -4500 4250 50  0001 C CNN "Mouser"
	1    -4500 4250
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 1 1 605F9374
P -4500 4800
F 0 "U?" H -4500 5117 50  0000 C CNN
F 1 "74AHCT05" H -4500 5026 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4500 4800 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -4500 4800 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -4500 4800 50  0001 C CNN "Mouser"
	1    -4500 4800
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 1 1 605F937B
P -4500 5300
F 0 "U?" H -4500 5617 50  0000 C CNN
F 1 "74AHCT05" H -4500 5526 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4500 5300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -4500 5300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -4500 5300 50  0001 C CNN "Mouser"
	1    -4500 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 7 1 605F9382
P -4800 6000
F 0 "U?" H -4570 6046 50  0000 L CNN
F 1 "74AHCT05" H -4570 5955 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4800 6000 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -4800 6000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -4800 6000 50  0001 C CNN "Mouser"
	7    -4800 6000
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 605F9388
P -4800 2850
AR Path="/5D2C0761/605F9388" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/605F9388" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/605F9388" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -4800 2700 50  0001 C CNN
F 1 "VCC" H -4783 3023 50  0000 C CNN
F 2 "" H -4800 2850 50  0001 C CNN
F 3 "" H -4800 2850 50  0001 C CNN
	1    -4800 2850
	1    0    0    -1  
$EndComp
Wire Wire Line
	-4800 3250 -4800 3750
Connection ~ -4800 3250
Wire Wire Line
	-4800 3750 -4800 4250
Connection ~ -4800 3750
Wire Wire Line
	-4800 4250 -4800 4800
Connection ~ -4800 4250
Wire Wire Line
	-4800 4800 -4800 5300
Connection ~ -4800 4800
Wire Wire Line
	-4800 5300 -4800 5500
Connection ~ -4800 5300
NoConn ~ -4200 5300
NoConn ~ -4200 4800
NoConn ~ -4200 4250
NoConn ~ -4200 3750
NoConn ~ -4200 3250
Wire Wire Line
	-4800 2850 -4800 3250
Wire Wire Line
	9200 3900 9350 3900
Connection ~ 9200 3900
$EndSCHEMATC
