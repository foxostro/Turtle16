EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 7 33
Title "Instruction Decoder"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Decodes an instruction opcode into an array of control signals."
$EndDescr
Text HLabel 2400 2550 0    50   Input ~ 0
Carry
Text HLabel 2400 2650 0    50   Input ~ 0
Z
Text HLabel 1050 1300 0    50   Input ~ 0
Ins[11..15]
Text HLabel 2400 2750 0    50   Input ~ 0
OVF
$Comp
L Device:C C?
U 1 1 5FF024F0
P 750 7650
AR Path="/5D8005AF/5D800742/5FF024F0" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FF024F0" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FF024F0" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF024F0" Ref="C16"  Part="1" 
F 0 "C16" H 865 7696 50  0000 L CNN
F 1 "100nF" H 865 7605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 788 7500 50  0001 C CNN
F 3 "~" H 750 7650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 750 7650 50  0001 C CNN "Mouser"
	1    750  7650
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FF024F6
P 1250 7650
AR Path="/5D8005AF/5D800742/5FF024F6" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FF024F6" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FF024F6" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF024F6" Ref="C17"  Part="1" 
F 0 "C17" H 1365 7696 50  0000 L CNN
F 1 "100nF" H 1365 7605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1288 7500 50  0001 C CNN
F 3 "~" H 1250 7650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1250 7650 50  0001 C CNN "Mouser"
	1    1250 7650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF024FC
P 750 7800
AR Path="/5D8005AF/5D800742/5FF024FC" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FF024FC" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF024FC" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF024FC" Ref="#PWR0113"  Part="1" 
F 0 "#PWR0113" H 750 7550 50  0001 C CNN
F 1 "GND" H 755 7627 50  0000 C CNN
F 2 "" H 750 7800 50  0001 C CNN
F 3 "" H 750 7800 50  0001 C CNN
	1    750  7800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FF02502
P 750 7500
AR Path="/5D8005AF/5D800742/5FF02502" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FF02502" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02502" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02502" Ref="#PWR0112"  Part="1" 
F 0 "#PWR0112" H 750 7350 50  0001 C CNN
F 1 "VCC" H 767 7673 50  0000 C CNN
F 2 "" H 750 7500 50  0001 C CNN
F 3 "" H 750 7500 50  0001 C CNN
	1    750  7500
	1    0    0    -1  
$EndComp
Wire Wire Line
	750  7500 1250 7500
Connection ~ 750  7500
Wire Wire Line
	1250 7800 750  7800
Connection ~ 750  7800
Text Label 4000 2450 2    50   ~ 0
Ctl4
Text Label 4000 2550 2    50   ~ 0
Ctl5
Text Label 4000 2650 2    50   ~ 0
Ctl6
Text Label 4000 2750 2    50   ~ 0
Ctl7
Text Label 4000 2250 2    50   ~ 0
Ctl2
Text Label 4000 2150 2    50   ~ 0
Ctl1
Text Label 4000 2050 2    50   ~ 0
Ctl0
Entry Wire Line
	4100 2850 4000 2750
Entry Wire Line
	4100 2250 4000 2150
Entry Wire Line
	4100 2350 4000 2250
Entry Wire Line
	4100 2450 4000 2350
Entry Wire Line
	4100 2550 4000 2450
Entry Wire Line
	4100 2650 4000 2550
Entry Wire Line
	4100 2750 4000 2650
$Comp
L power:VCC #PWR?
U 1 1 5FF02531
P 3150 1900
AR Path="/5FE35007/5FF02531" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02531" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02531" Ref="#PWR0125"  Part="1" 
F 0 "#PWR0125" H 3150 1750 50  0001 C CNN
F 1 "VCC" H 3165 2073 50  0000 C CNN
F 2 "" H 3150 1900 50  0001 C CNN
F 3 "" H 3150 1900 50  0001 C CNN
	1    3150 1900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF02537
P 3150 4500
AR Path="/5FE35007/5FF02537" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02537" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02537" Ref="#PWR0126"  Part="1" 
F 0 "#PWR0126" H 3150 4250 50  0001 C CNN
F 1 "GND" H 3155 4327 50  0000 C CNN
F 2 "" H 3150 4500 50  0001 C CNN
F 3 "" H 3150 4500 50  0001 C CNN
	1    3150 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF0253D
P 2550 4350
AR Path="/5FE35007/5FF0253D" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF0253D" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF0253D" Ref="#PWR0124"  Part="1" 
F 0 "#PWR0124" H 2550 4100 50  0001 C CNN
F 1 "GND" V 2555 4222 50  0000 R CNN
F 2 "" H 2550 4350 50  0001 C CNN
F 3 "" H 2550 4350 50  0001 C CNN
	1    2550 4350
	0    1    1    0   
$EndComp
Entry Wire Line
	1800 2050 1700 1950
Entry Wire Line
	1800 2150 1700 2050
Entry Wire Line
	1800 2250 1700 2150
Entry Wire Line
	1800 2350 1700 2250
Entry Wire Line
	1800 2450 1700 2350
Text Label 1800 2050 0    50   ~ 0
Ins11
Text Label 1800 2150 0    50   ~ 0
Ins12
Text Label 1800 2250 0    50   ~ 0
Ins13
Text Label 1800 2350 0    50   ~ 0
Ins14
Text Label 1800 2450 0    50   ~ 0
Ins15
Wire Wire Line
	2550 2450 1800 2450
Wire Wire Line
	2550 2350 1800 2350
Wire Wire Line
	2550 2250 1800 2250
Wire Wire Line
	2550 2150 1800 2150
Wire Wire Line
	2550 2050 1800 2050
$Comp
L power:VCC #PWR?
U 1 1 5FF02552
P 2550 4050
AR Path="/5FE35007/5FF02552" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02552" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02552" Ref="#PWR0122"  Part="1" 
F 0 "#PWR0122" H 2550 3900 50  0001 C CNN
F 1 "VCC" V 2565 4177 50  0000 L CNN
F 2 "" H 2550 4050 50  0001 C CNN
F 3 "" H 2550 4050 50  0001 C CNN
	1    2550 4050
	0    -1   -1   0   
$EndComp
$Comp
L Device:C C?
U 1 1 5FF025D3
P 1750 7650
AR Path="/5D8005AF/5D800742/5FF025D3" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FF025D3" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FF025D3" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF025D3" Ref="C18"  Part="1" 
F 0 "C18" H 1865 7696 50  0000 L CNN
F 1 "100nF" H 1865 7605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1788 7500 50  0001 C CNN
F 3 "~" H 1750 7650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1750 7650 50  0001 C CNN "Mouser"
	1    1750 7650
	1    0    0    -1  
$EndComp
Wire Wire Line
	1250 7500 1750 7500
Wire Wire Line
	1750 7800 1250 7800
Wire Wire Line
	2400 2550 2550 2550
Wire Wire Line
	2550 2650 2400 2650
Wire Wire Line
	2400 2750 2550 2750
$Comp
L power:GND #PWR?
U 1 1 5FF0263A
P 2550 2950
AR Path="/5FE35007/5FF0263A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF0263A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF0263A" Ref="#PWR0114"  Part="1" 
F 0 "#PWR0114" H 2550 2700 50  0001 C CNN
F 1 "GND" V 2555 2822 50  0000 R CNN
F 2 "" H 2550 2950 50  0001 C CNN
F 3 "" H 2550 2950 50  0001 C CNN
	1    2550 2950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF02640
P 2550 3050
AR Path="/5FE35007/5FF02640" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02640" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02640" Ref="#PWR0115"  Part="1" 
F 0 "#PWR0115" H 2550 2800 50  0001 C CNN
F 1 "GND" V 2555 2922 50  0000 R CNN
F 2 "" H 2550 3050 50  0001 C CNN
F 3 "" H 2550 3050 50  0001 C CNN
	1    2550 3050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF02646
P 2550 3150
AR Path="/5FE35007/5FF02646" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02646" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02646" Ref="#PWR0116"  Part="1" 
F 0 "#PWR0116" H 2550 2900 50  0001 C CNN
F 1 "GND" V 2555 3022 50  0000 R CNN
F 2 "" H 2550 3150 50  0001 C CNN
F 3 "" H 2550 3150 50  0001 C CNN
	1    2550 3150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF0264C
P 2550 3250
AR Path="/5FE35007/5FF0264C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF0264C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF0264C" Ref="#PWR0117"  Part="1" 
F 0 "#PWR0117" H 2550 3000 50  0001 C CNN
F 1 "GND" V 2555 3122 50  0000 R CNN
F 2 "" H 2550 3250 50  0001 C CNN
F 3 "" H 2550 3250 50  0001 C CNN
	1    2550 3250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF02652
P 2550 3350
AR Path="/5FE35007/5FF02652" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02652" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02652" Ref="#PWR0118"  Part="1" 
F 0 "#PWR0118" H 2550 3100 50  0001 C CNN
F 1 "GND" V 2555 3222 50  0000 R CNN
F 2 "" H 2550 3350 50  0001 C CNN
F 3 "" H 2550 3350 50  0001 C CNN
	1    2550 3350
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF02658
P 2550 3450
AR Path="/5FE35007/5FF02658" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF02658" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF02658" Ref="#PWR0119"  Part="1" 
F 0 "#PWR0119" H 2550 3200 50  0001 C CNN
F 1 "GND" V 2555 3322 50  0000 R CNN
F 2 "" H 2550 3450 50  0001 C CNN
F 3 "" H 2550 3450 50  0001 C CNN
	1    2550 3450
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF0265E
P 2550 3550
AR Path="/5FE35007/5FF0265E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF0265E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF0265E" Ref="#PWR0120"  Part="1" 
F 0 "#PWR0120" H 2550 3300 50  0001 C CNN
F 1 "GND" V 2555 3422 50  0000 R CNN
F 2 "" H 2550 3550 50  0001 C CNN
F 3 "" H 2550 3550 50  0001 C CNN
	1    2550 3550
	0    1    1    0   
$EndComp
Connection ~ 1250 7500
Connection ~ 1250 7800
Text Label 4000 2350 2    50   ~ 0
Ctl3
Text HLabel 2400 2850 0    50   Input ~ 0
~RST
Wire Wire Line
	2400 2850 2550 2850
$Comp
L Memory_Flash:SST39SF010 U?
U 1 1 5FF028BF
P 3150 3250
AR Path="/5FED3839/5FF028BF" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF028BF" Ref="U11"  Part="1" 
F 0 "U11" H 2500 4650 50  0000 C CNN
F 1 "SST39SF010A-45-4I-NHE" H 2550 4550 50  0000 C CNN
F 2 "Package_LCC:PLCC-32_SMD-Socket" H 3150 3550 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 3150 3550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology/SST39SF010A-45-4I-NHE?qs=tIuBKjZQlcn4x3o3EE%252B3qw%3D%3D" H 3150 3250 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/517-8432-21B1-RK-TP" H 3150 3250 50  0001 C CNN "Mouser2"
	1    3150 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FF028C5
P 2550 4250
AR Path="/5FE35007/5FF028C5" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FF028C5" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF028C5" Ref="#PWR0123"  Part="1" 
F 0 "#PWR0123" H 2550 4000 50  0001 C CNN
F 1 "GND" V 2555 4122 50  0000 R CNN
F 2 "" H 2550 4250 50  0001 C CNN
F 3 "" H 2550 4250 50  0001 C CNN
	1    2550 4250
	0    1    1    0   
$EndComp
Wire Wire Line
	4000 2650 3750 2650
Wire Wire Line
	4000 2450 3750 2450
Wire Wire Line
	4000 2250 3750 2250
Wire Wire Line
	4000 2050 3750 2050
Entry Wire Line
	4100 2150 4000 2050
Wire Wire Line
	4000 2150 3750 2150
Wire Wire Line
	4000 2350 3750 2350
Wire Wire Line
	4000 2550 3750 2550
Wire Wire Line
	4000 2750 3750 2750
Text HLabel 10050 5250 2    50   Output ~ 0
Ctl[0..23]
Text HLabel 5200 2550 0    50   Input ~ 0
Carry
Text HLabel 5200 2650 0    50   Input ~ 0
Z
Text HLabel 5200 2750 0    50   Input ~ 0
OVF
Text Label 6800 2450 2    50   ~ 0
Ctl12
Text Label 6800 2550 2    50   ~ 0
Ctl13
Text Label 6800 2650 2    50   ~ 0
Ctl14
Text Label 6800 2750 2    50   ~ 0
Ctl15
Text Label 6800 2250 2    50   ~ 0
Ctl10
Text Label 6800 2150 2    50   ~ 0
Ctl9
Text Label 6800 2050 2    50   ~ 0
Ctl8
Entry Wire Line
	6900 2850 6800 2750
Entry Wire Line
	6900 2250 6800 2150
Entry Wire Line
	6900 2350 6800 2250
Entry Wire Line
	6900 2450 6800 2350
Entry Wire Line
	6900 2550 6800 2450
Entry Wire Line
	6900 2650 6800 2550
Entry Wire Line
	6900 2750 6800 2650
$Comp
L power:VCC #PWR?
U 1 1 60132D26
P 5950 1900
AR Path="/5FE35007/60132D26" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D26" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D26" Ref="#PWR0138"  Part="1" 
F 0 "#PWR0138" H 5950 1750 50  0001 C CNN
F 1 "VCC" H 5965 2073 50  0000 C CNN
F 2 "" H 5950 1900 50  0001 C CNN
F 3 "" H 5950 1900 50  0001 C CNN
	1    5950 1900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D2C
P 5950 4500
AR Path="/5FE35007/60132D2C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D2C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D2C" Ref="#PWR0139"  Part="1" 
F 0 "#PWR0139" H 5950 4250 50  0001 C CNN
F 1 "GND" H 5955 4327 50  0000 C CNN
F 2 "" H 5950 4500 50  0001 C CNN
F 3 "" H 5950 4500 50  0001 C CNN
	1    5950 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D32
P 5350 4350
AR Path="/5FE35007/60132D32" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D32" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D32" Ref="#PWR0137"  Part="1" 
F 0 "#PWR0137" H 5350 4100 50  0001 C CNN
F 1 "GND" V 5355 4222 50  0000 R CNN
F 2 "" H 5350 4350 50  0001 C CNN
F 3 "" H 5350 4350 50  0001 C CNN
	1    5350 4350
	0    1    1    0   
$EndComp
Entry Wire Line
	4600 2050 4500 1950
Entry Wire Line
	4600 2150 4500 2050
Entry Wire Line
	4600 2250 4500 2150
Entry Wire Line
	4600 2350 4500 2250
Entry Wire Line
	4600 2450 4500 2350
Text Label 4600 2050 0    50   ~ 0
Ins11
Text Label 4600 2150 0    50   ~ 0
Ins12
Text Label 4600 2250 0    50   ~ 0
Ins13
Text Label 4600 2350 0    50   ~ 0
Ins14
Text Label 4600 2450 0    50   ~ 0
Ins15
Wire Wire Line
	5350 2450 4600 2450
Wire Wire Line
	5350 2350 4600 2350
Wire Wire Line
	5350 2250 4600 2250
Wire Wire Line
	5350 2150 4600 2150
Wire Wire Line
	5350 2050 4600 2050
$Comp
L power:VCC #PWR?
U 1 1 60132D47
P 5350 4050
AR Path="/5FE35007/60132D47" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D47" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D47" Ref="#PWR0135"  Part="1" 
F 0 "#PWR0135" H 5350 3900 50  0001 C CNN
F 1 "VCC" V 5365 4177 50  0000 L CNN
F 2 "" H 5350 4050 50  0001 C CNN
F 3 "" H 5350 4050 50  0001 C CNN
	1    5350 4050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5200 2550 5350 2550
Wire Wire Line
	5350 2650 5200 2650
Wire Wire Line
	5200 2750 5350 2750
$Comp
L power:GND #PWR?
U 1 1 60132D50
P 5350 2950
AR Path="/5FE35007/60132D50" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D50" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D50" Ref="#PWR0127"  Part="1" 
F 0 "#PWR0127" H 5350 2700 50  0001 C CNN
F 1 "GND" V 5355 2822 50  0000 R CNN
F 2 "" H 5350 2950 50  0001 C CNN
F 3 "" H 5350 2950 50  0001 C CNN
	1    5350 2950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D56
P 5350 3050
AR Path="/5FE35007/60132D56" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D56" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D56" Ref="#PWR0128"  Part="1" 
F 0 "#PWR0128" H 5350 2800 50  0001 C CNN
F 1 "GND" V 5355 2922 50  0000 R CNN
F 2 "" H 5350 3050 50  0001 C CNN
F 3 "" H 5350 3050 50  0001 C CNN
	1    5350 3050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D5C
P 5350 3150
AR Path="/5FE35007/60132D5C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D5C" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D5C" Ref="#PWR0129"  Part="1" 
F 0 "#PWR0129" H 5350 2900 50  0001 C CNN
F 1 "GND" V 5355 3022 50  0000 R CNN
F 2 "" H 5350 3150 50  0001 C CNN
F 3 "" H 5350 3150 50  0001 C CNN
	1    5350 3150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D62
P 5350 3250
AR Path="/5FE35007/60132D62" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D62" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D62" Ref="#PWR0130"  Part="1" 
F 0 "#PWR0130" H 5350 3000 50  0001 C CNN
F 1 "GND" V 5355 3122 50  0000 R CNN
F 2 "" H 5350 3250 50  0001 C CNN
F 3 "" H 5350 3250 50  0001 C CNN
	1    5350 3250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D68
P 5350 3350
AR Path="/5FE35007/60132D68" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D68" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D68" Ref="#PWR0131"  Part="1" 
F 0 "#PWR0131" H 5350 3100 50  0001 C CNN
F 1 "GND" V 5355 3222 50  0000 R CNN
F 2 "" H 5350 3350 50  0001 C CNN
F 3 "" H 5350 3350 50  0001 C CNN
	1    5350 3350
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D6E
P 5350 3450
AR Path="/5FE35007/60132D6E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D6E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D6E" Ref="#PWR0132"  Part="1" 
F 0 "#PWR0132" H 5350 3200 50  0001 C CNN
F 1 "GND" V 5355 3322 50  0000 R CNN
F 2 "" H 5350 3450 50  0001 C CNN
F 3 "" H 5350 3450 50  0001 C CNN
	1    5350 3450
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D74
P 5350 3550
AR Path="/5FE35007/60132D74" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D74" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D74" Ref="#PWR0133"  Part="1" 
F 0 "#PWR0133" H 5350 3300 50  0001 C CNN
F 1 "GND" V 5355 3422 50  0000 R CNN
F 2 "" H 5350 3550 50  0001 C CNN
F 3 "" H 5350 3550 50  0001 C CNN
	1    5350 3550
	0    1    1    0   
$EndComp
Text Label 6800 2350 2    50   ~ 0
Ctl11
Text HLabel 5200 2850 0    50   Input ~ 0
~RST
Wire Wire Line
	5200 2850 5350 2850
$Comp
L Memory_Flash:SST39SF010 U?
U 1 1 60132D7F
P 5950 3250
AR Path="/5FED3839/60132D7F" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D7F" Ref="U12"  Part="1" 
F 0 "U12" H 5300 4650 50  0000 C CNN
F 1 "SST39SF010A-45-4I-NHE" H 5350 4550 50  0000 C CNN
F 2 "Package_LCC:PLCC-32_SMD-Socket" H 5950 3550 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 5950 3550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology/SST39SF010A-45-4I-NHE?qs=tIuBKjZQlcn4x3o3EE%252B3qw%3D%3D" H 5950 3250 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/517-8432-21B1-RK-TP" H 5950 3250 50  0001 C CNN "Mouser2"
	1    5950 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60132D85
P 5350 4250
AR Path="/5FE35007/60132D85" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/60132D85" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/60132D85" Ref="#PWR0136"  Part="1" 
F 0 "#PWR0136" H 5350 4000 50  0001 C CNN
F 1 "GND" V 5355 4122 50  0000 R CNN
F 2 "" H 5350 4250 50  0001 C CNN
F 3 "" H 5350 4250 50  0001 C CNN
	1    5350 4250
	0    1    1    0   
$EndComp
Wire Wire Line
	6800 2650 6550 2650
Wire Wire Line
	6800 2450 6550 2450
Wire Wire Line
	6800 2250 6550 2250
Wire Wire Line
	6800 2050 6550 2050
Entry Wire Line
	6900 2150 6800 2050
Wire Wire Line
	6800 2150 6550 2150
Wire Wire Line
	6800 2350 6550 2350
Wire Wire Line
	6800 2550 6550 2550
Wire Wire Line
	6800 2750 6550 2750
Text HLabel 8000 2550 0    50   Input ~ 0
Carry
Text HLabel 8000 2650 0    50   Input ~ 0
Z
Text HLabel 8000 2750 0    50   Input ~ 0
OVF
Text Label 9600 2450 2    50   ~ 0
Ctl20
Text Label 9600 2550 2    50   ~ 0
Ctl21
Text Label 9600 2650 2    50   ~ 0
Ctl22
Text Label 9600 2750 2    50   ~ 0
Ctl23
Text Label 9600 2250 2    50   ~ 0
Ctl18
Text Label 9600 2150 2    50   ~ 0
Ctl17
Text Label 9600 2050 2    50   ~ 0
Ctl16
Entry Wire Line
	9700 2850 9600 2750
Entry Wire Line
	9700 2250 9600 2150
Entry Wire Line
	9700 2350 9600 2250
Entry Wire Line
	9700 2450 9600 2350
Entry Wire Line
	9700 2550 9600 2450
Entry Wire Line
	9700 2650 9600 2550
Entry Wire Line
	9700 2750 9600 2650
$Comp
L power:VCC #PWR?
U 1 1 6013D36A
P 8750 1900
AR Path="/5FE35007/6013D36A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D36A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D36A" Ref="#PWR0151"  Part="1" 
F 0 "#PWR0151" H 8750 1750 50  0001 C CNN
F 1 "VCC" H 8765 2073 50  0000 C CNN
F 2 "" H 8750 1900 50  0001 C CNN
F 3 "" H 8750 1900 50  0001 C CNN
	1    8750 1900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D370
P 8750 4500
AR Path="/5FE35007/6013D370" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D370" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D370" Ref="#PWR0152"  Part="1" 
F 0 "#PWR0152" H 8750 4250 50  0001 C CNN
F 1 "GND" H 8755 4327 50  0000 C CNN
F 2 "" H 8750 4500 50  0001 C CNN
F 3 "" H 8750 4500 50  0001 C CNN
	1    8750 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D376
P 8150 4350
AR Path="/5FE35007/6013D376" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D376" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D376" Ref="#PWR0150"  Part="1" 
F 0 "#PWR0150" H 8150 4100 50  0001 C CNN
F 1 "GND" V 8155 4222 50  0000 R CNN
F 2 "" H 8150 4350 50  0001 C CNN
F 3 "" H 8150 4350 50  0001 C CNN
	1    8150 4350
	0    1    1    0   
$EndComp
Entry Wire Line
	7400 2050 7300 1950
Entry Wire Line
	7400 2150 7300 2050
Entry Wire Line
	7400 2250 7300 2150
Entry Wire Line
	7400 2350 7300 2250
Entry Wire Line
	7400 2450 7300 2350
Text Label 7400 2050 0    50   ~ 0
Ins11
Text Label 7400 2150 0    50   ~ 0
Ins12
Text Label 7400 2250 0    50   ~ 0
Ins13
Text Label 7400 2350 0    50   ~ 0
Ins14
Text Label 7400 2450 0    50   ~ 0
Ins15
Wire Wire Line
	8150 2450 7400 2450
Wire Wire Line
	8150 2350 7400 2350
Wire Wire Line
	8150 2250 7400 2250
Wire Wire Line
	8150 2150 7400 2150
Wire Wire Line
	8150 2050 7400 2050
$Comp
L power:VCC #PWR?
U 1 1 6013D38B
P 8150 4050
AR Path="/5FE35007/6013D38B" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D38B" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D38B" Ref="#PWR0148"  Part="1" 
F 0 "#PWR0148" H 8150 3900 50  0001 C CNN
F 1 "VCC" V 8165 4177 50  0000 L CNN
F 2 "" H 8150 4050 50  0001 C CNN
F 3 "" H 8150 4050 50  0001 C CNN
	1    8150 4050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8000 2550 8150 2550
Wire Wire Line
	8150 2650 8000 2650
Wire Wire Line
	8000 2750 8150 2750
$Comp
L power:GND #PWR?
U 1 1 6013D394
P 8150 2950
AR Path="/5FE35007/6013D394" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D394" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D394" Ref="#PWR0140"  Part="1" 
F 0 "#PWR0140" H 8150 2700 50  0001 C CNN
F 1 "GND" V 8155 2822 50  0000 R CNN
F 2 "" H 8150 2950 50  0001 C CNN
F 3 "" H 8150 2950 50  0001 C CNN
	1    8150 2950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D39A
P 8150 3050
AR Path="/5FE35007/6013D39A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D39A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D39A" Ref="#PWR0141"  Part="1" 
F 0 "#PWR0141" H 8150 2800 50  0001 C CNN
F 1 "GND" V 8155 2922 50  0000 R CNN
F 2 "" H 8150 3050 50  0001 C CNN
F 3 "" H 8150 3050 50  0001 C CNN
	1    8150 3050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D3A0
P 8150 3150
AR Path="/5FE35007/6013D3A0" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D3A0" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3A0" Ref="#PWR0142"  Part="1" 
F 0 "#PWR0142" H 8150 2900 50  0001 C CNN
F 1 "GND" V 8155 3022 50  0000 R CNN
F 2 "" H 8150 3150 50  0001 C CNN
F 3 "" H 8150 3150 50  0001 C CNN
	1    8150 3150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D3A6
P 8150 3250
AR Path="/5FE35007/6013D3A6" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D3A6" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3A6" Ref="#PWR0143"  Part="1" 
F 0 "#PWR0143" H 8150 3000 50  0001 C CNN
F 1 "GND" V 8155 3122 50  0000 R CNN
F 2 "" H 8150 3250 50  0001 C CNN
F 3 "" H 8150 3250 50  0001 C CNN
	1    8150 3250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D3AC
P 8150 3350
AR Path="/5FE35007/6013D3AC" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D3AC" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3AC" Ref="#PWR0144"  Part="1" 
F 0 "#PWR0144" H 8150 3100 50  0001 C CNN
F 1 "GND" V 8155 3222 50  0000 R CNN
F 2 "" H 8150 3350 50  0001 C CNN
F 3 "" H 8150 3350 50  0001 C CNN
	1    8150 3350
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D3B2
P 8150 3450
AR Path="/5FE35007/6013D3B2" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D3B2" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3B2" Ref="#PWR0145"  Part="1" 
F 0 "#PWR0145" H 8150 3200 50  0001 C CNN
F 1 "GND" V 8155 3322 50  0000 R CNN
F 2 "" H 8150 3450 50  0001 C CNN
F 3 "" H 8150 3450 50  0001 C CNN
	1    8150 3450
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D3B8
P 8150 3550
AR Path="/5FE35007/6013D3B8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D3B8" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3B8" Ref="#PWR0146"  Part="1" 
F 0 "#PWR0146" H 8150 3300 50  0001 C CNN
F 1 "GND" V 8155 3422 50  0000 R CNN
F 2 "" H 8150 3550 50  0001 C CNN
F 3 "" H 8150 3550 50  0001 C CNN
	1    8150 3550
	0    1    1    0   
$EndComp
Text Label 9600 2350 2    50   ~ 0
Ctl19
Text HLabel 8000 2850 0    50   Input ~ 0
~RST
Wire Wire Line
	8000 2850 8150 2850
$Comp
L Memory_Flash:SST39SF010 U?
U 1 1 6013D3C3
P 8750 3250
AR Path="/5FED3839/6013D3C3" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3C3" Ref="U13"  Part="1" 
F 0 "U13" H 8100 4650 50  0000 C CNN
F 1 "SST39SF010A-45-4I-NHE" H 8150 4550 50  0000 C CNN
F 2 "Package_LCC:PLCC-32_SMD-Socket" H 8750 3550 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 8750 3550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology/SST39SF010A-45-4I-NHE?qs=tIuBKjZQlcn4x3o3EE%252B3qw%3D%3D" H 8750 3250 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/517-8432-21B1-RK-TP" H 8750 3250 50  0001 C CNN "Mouser2"
	1    8750 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6013D3C9
P 8150 4250
AR Path="/5FE35007/6013D3C9" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6013D3C9" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6013D3C9" Ref="#PWR0149"  Part="1" 
F 0 "#PWR0149" H 8150 4000 50  0001 C CNN
F 1 "GND" V 8155 4122 50  0000 R CNN
F 2 "" H 8150 4250 50  0001 C CNN
F 3 "" H 8150 4250 50  0001 C CNN
	1    8150 4250
	0    1    1    0   
$EndComp
Wire Wire Line
	9600 2650 9350 2650
Wire Wire Line
	9600 2450 9350 2450
Wire Wire Line
	9600 2250 9350 2250
Wire Wire Line
	9600 2050 9350 2050
Entry Wire Line
	9700 2150 9600 2050
Wire Wire Line
	9600 2150 9350 2150
Wire Wire Line
	9600 2350 9350 2350
Wire Wire Line
	9600 2550 9350 2550
Wire Wire Line
	9600 2750 9350 2750
Wire Bus Line
	4100 5250 6900 5250
Connection ~ 6900 5250
Wire Bus Line
	6900 5250 9700 5250
Wire Bus Line
	10050 5250 9700 5250
Connection ~ 9700 5250
NoConn ~ 8150 3750
NoConn ~ 8150 3850
NoConn ~ 5350 3750
NoConn ~ 5350 3850
NoConn ~ 2550 3750
NoConn ~ 2550 3850
$Comp
L power:GND #PWR?
U 1 1 6015C5DE
P 2550 3650
AR Path="/5FE35007/6015C5DE" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6015C5DE" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6015C5DE" Ref="#PWR0121"  Part="1" 
F 0 "#PWR0121" H 2550 3400 50  0001 C CNN
F 1 "GND" V 2555 3522 50  0000 R CNN
F 2 "" H 2550 3650 50  0001 C CNN
F 3 "" H 2550 3650 50  0001 C CNN
	1    2550 3650
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6015C856
P 5350 3650
AR Path="/5FE35007/6015C856" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6015C856" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6015C856" Ref="#PWR0134"  Part="1" 
F 0 "#PWR0134" H 5350 3400 50  0001 C CNN
F 1 "GND" V 5355 3522 50  0000 R CNN
F 2 "" H 5350 3650 50  0001 C CNN
F 3 "" H 5350 3650 50  0001 C CNN
	1    5350 3650
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6015CC55
P 8150 3650
AR Path="/5FE35007/6015CC55" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6015CC55" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FE73F43/6015CC55" Ref="#PWR0147"  Part="1" 
F 0 "#PWR0147" H 8150 3400 50  0001 C CNN
F 1 "GND" V 8155 3522 50  0000 R CNN
F 2 "" H 8150 3650 50  0001 C CNN
F 3 "" H 8150 3650 50  0001 C CNN
	1    8150 3650
	0    1    1    0   
$EndComp
Wire Bus Line
	1050 1300 1700 1300
Connection ~ 1700 1300
Wire Bus Line
	1700 1300 4500 1300
Connection ~ 4500 1300
Wire Bus Line
	4500 1300 7300 1300
Wire Bus Line
	1700 1300 1700 2350
Wire Bus Line
	4500 1300 4500 2350
Wire Bus Line
	7300 1300 7300 2350
Wire Bus Line
	4100 2150 4100 5250
Wire Bus Line
	9700 2150 9700 5250
Wire Bus Line
	6900 2150 6900 5250
$EndSCHEMATC