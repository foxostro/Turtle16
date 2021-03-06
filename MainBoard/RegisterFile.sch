EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 4 35
Title "Register File"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Triple Port Register File build from dual port SRAM"
$EndDescr
Text HLabel 2000 2800 0    50   Input ~ 0
~WRH
Text HLabel 2000 2700 0    50   Input ~ 0
~WRL
Text HLabel 1850 2900 0    50   Input ~ 0
SelC_WB[0..2]
Entry Wire Line
	2150 5000 2250 5100
Entry Wire Line
	2150 5100 2250 5200
Wire Wire Line
	2250 5200 2550 5200
Entry Wire Line
	2150 5200 2250 5300
Wire Wire Line
	2250 5300 2550 5300
Entry Wire Line
	2150 5300 2250 5400
Wire Wire Line
	2250 5400 2550 5400
Entry Wire Line
	2150 5400 2250 5500
Wire Wire Line
	2250 5500 2550 5500
Entry Wire Line
	2150 5500 2250 5600
Wire Wire Line
	2250 5600 2550 5600
Entry Wire Line
	2150 5600 2250 5700
Wire Wire Line
	2250 5700 2550 5700
Entry Wire Line
	2150 5700 2250 5800
Wire Wire Line
	2250 5800 2550 5800
Wire Wire Line
	2550 2700 2000 2700
Wire Wire Line
	2550 2800 2000 2800
Entry Wire Line
	2000 2900 2100 3000
Text Label 2100 3000 0    50   ~ 0
SelC_WB0
Entry Wire Line
	2000 3000 2100 3100
Text Label 2100 3100 0    50   ~ 0
SelC_WB1
Wire Bus Line
	1850 2900 2000 2900
Entry Wire Line
	2000 3100 2100 3200
Text Label 2100 3200 0    50   ~ 0
SelC_WB2
Text HLabel 4900 4200 2    50   Output ~ 0
A[0..15]
Entry Wire Line
	4750 5000 4650 5100
Wire Wire Line
	4650 5100 4350 5100
Text Label 4650 5100 2    50   ~ 0
A8
Entry Wire Line
	4750 5100 4650 5200
Wire Wire Line
	4650 5200 4350 5200
Text Label 4650 5200 2    50   ~ 0
A9
Entry Wire Line
	4750 5200 4650 5300
Text Label 4650 5300 2    50   ~ 0
A10
Entry Wire Line
	4750 5300 4650 5400
Wire Wire Line
	4650 5400 4350 5400
Text Label 4650 5400 2    50   ~ 0
A11
Entry Wire Line
	4750 5400 4650 5500
Wire Wire Line
	4650 5500 4350 5500
Text Label 4650 5500 2    50   ~ 0
A12
Entry Wire Line
	4750 5500 4650 5600
Wire Wire Line
	4650 5600 4350 5600
Text Label 4650 5600 2    50   ~ 0
A13
Entry Wire Line
	4750 5600 4650 5700
Wire Wire Line
	4650 5700 4350 5700
Text Label 4650 5700 2    50   ~ 0
A14
Entry Wire Line
	4750 5700 4650 5800
Wire Wire Line
	4650 5800 4350 5800
Text Label 4650 5800 2    50   ~ 0
A15
Wire Bus Line
	4900 4200 4750 4200
Entry Wire Line
	4750 4200 4650 4300
Wire Wire Line
	4650 4300 4350 4300
Text Label 4650 4300 2    50   ~ 0
A0
Entry Wire Line
	4750 4300 4650 4400
Wire Wire Line
	4650 4400 4350 4400
Text Label 4650 4400 2    50   ~ 0
A1
Entry Wire Line
	4750 4400 4650 4500
Wire Wire Line
	4650 4500 4350 4500
Text Label 4650 4500 2    50   ~ 0
A2
Entry Wire Line
	4750 4500 4650 4600
Wire Wire Line
	4650 4600 4350 4600
Text Label 4650 4600 2    50   ~ 0
A3
Entry Wire Line
	4750 4600 4650 4700
Wire Wire Line
	4650 4700 4350 4700
Text Label 4650 4700 2    50   ~ 0
A4
Entry Wire Line
	4750 4700 4650 4800
Wire Wire Line
	4650 4800 4350 4800
Text Label 4650 4800 2    50   ~ 0
A5
Entry Wire Line
	4750 4800 4650 4900
Wire Wire Line
	4650 4900 4350 4900
Text Label 4650 4900 2    50   ~ 0
A6
Entry Wire Line
	4750 4900 4650 5000
Wire Wire Line
	4650 5000 4350 5000
Text Label 4650 5000 2    50   ~ 0
A7
Text HLabel 4900 2750 2    50   Input ~ 0
SelA[0..2]
Entry Wire Line
	4750 2900 4650 3000
Wire Wire Line
	4650 3000 4350 3000
Text Label 4650 3000 2    50   ~ 0
SelA0
Entry Wire Line
	4750 3000 4650 3100
Text Label 4650 3100 2    50   ~ 0
SelA1
Wire Bus Line
	4900 2750 4750 2750
Entry Wire Line
	4750 3100 4650 3200
Wire Wire Line
	4350 3100 4650 3100
Wire Wire Line
	4650 3200 4350 3200
Text Label 4650 3200 2    50   ~ 0
SelA2
Wire Wire Line
	1250 7600 1000 7600
$Comp
L power:GND #PWR?
U 1 1 5FB3291A
P 1000 7700
AR Path="/5D2C0761/5FB3291A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0B92/5FB3291A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FB3291A" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FAA7AE7/5FB3291A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC16AA6/5FB3291A" Ref="#PWR0306"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF028A0/5FB3291A" Ref="#PWR?"  Part="1" 
F 0 "#PWR0306" H 1000 7450 50  0001 C CNN
F 1 "GND" H 1005 7527 50  0000 C CNN
F 2 "" H 1000 7700 50  0001 C CNN
F 3 "" H 1000 7700 50  0001 C CNN
	1    1000 7700
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FB3292C
P 1250 7450
AR Path="/5D2C0761/5FB3292C" Ref="C?"  Part="1" 
AR Path="/5D2C0B92/5FB3292C" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FB3292C" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FAA7AE7/5FB3292C" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FC16AA6/5FB3292C" Ref="C61"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF028A0/5FB3292C" Ref="C?"  Part="1" 
F 0 "C61" H 1365 7496 50  0000 L CNN
F 1 "100nF" H 1365 7405 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1288 7300 50  0001 C CNN
F 3 "~" H 1250 7450 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1250 7450 50  0001 C CNN "Mouser"
	1    1250 7450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FB32932
P 750 7450
AR Path="/5D2C0761/5FB32932" Ref="C?"  Part="1" 
AR Path="/5D2C0B92/5FB32932" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FB32932" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FAA7AE7/5FB32932" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FC16AA6/5FB32932" Ref="C60"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF028A0/5FB32932" Ref="C?"  Part="1" 
F 0 "C60" H 865 7496 50  0000 L CNN
F 1 "100nF" H 865 7405 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 788 7300 50  0001 C CNN
F 3 "~" H 750 7450 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 750 7450 50  0001 C CNN "Mouser"
	1    750  7450
	1    0    0    -1  
$EndComp
Wire Wire Line
	750  7300 1000 7300
$Comp
L power:VCC #PWR?
U 1 1 5FB32939
P 1000 7200
AR Path="/5D2C0761/5FB32939" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0B92/5FB32939" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FB32939" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FAA7AE7/5FB32939" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FC16AA6/5FB32939" Ref="#PWR0305"  Part="1" 
AR Path="/5FED3839/5FE73F43/5FF028A0/5FB32939" Ref="#PWR?"  Part="1" 
F 0 "#PWR0305" H 1000 7050 50  0001 C CNN
F 1 "VCC" H 1017 7373 50  0000 C CNN
F 2 "" H 1000 7200 50  0001 C CNN
F 3 "" H 1000 7200 50  0001 C CNN
	1    1000 7200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1000 7200 1000 7300
Connection ~ 1000 7300
Wire Wire Line
	1000 7300 1250 7300
Wire Wire Line
	1000 7700 1000 7600
Connection ~ 1000 7600
Wire Wire Line
	1000 7600 750  7600
Wire Wire Line
	4350 5300 4650 5300
Wire Wire Line
	2250 5100 2550 5100
Entry Wire Line
	2150 4200 2250 4300
Entry Wire Line
	2150 4300 2250 4400
Wire Wire Line
	2250 4400 2550 4400
Entry Wire Line
	2150 4400 2250 4500
Wire Wire Line
	2250 4500 2550 4500
Entry Wire Line
	2150 4500 2250 4600
Wire Wire Line
	2250 4600 2550 4600
Entry Wire Line
	2150 4600 2250 4700
Wire Wire Line
	2250 4700 2550 4700
Entry Wire Line
	2150 4700 2250 4800
Wire Wire Line
	2250 4800 2550 4800
Entry Wire Line
	2150 4800 2250 4900
Wire Wire Line
	2250 4900 2550 4900
Entry Wire Line
	2150 4900 2250 5000
Wire Wire Line
	2250 5000 2550 5000
Wire Bus Line
	2000 4200 2150 4200
Wire Wire Line
	2250 4300 2550 4300
Text HLabel 2000 4200 0    50   Input ~ 0
C[0..15]
Text Label 2250 4300 0    50   ~ 0
C0
Text Label 2250 4400 0    50   ~ 0
C1
Text Label 2250 4500 0    50   ~ 0
C2
Text Label 2250 4600 0    50   ~ 0
C3
Text Label 2250 4700 0    50   ~ 0
C4
Text Label 2250 4800 0    50   ~ 0
C5
Text Label 2250 4900 0    50   ~ 0
C6
Text Label 2250 5000 0    50   ~ 0
C7
Text Label 2250 5100 0    50   ~ 0
C8
Text Label 2250 5200 0    50   ~ 0
C9
Text Label 2250 5300 0    50   ~ 0
C10
Text Label 2250 5400 0    50   ~ 0
C11
Text Label 2250 5500 0    50   ~ 0
C12
Text Label 2250 5600 0    50   ~ 0
C13
Text Label 2250 5700 0    50   ~ 0
C14
Text Label 2250 5800 0    50   ~ 0
C15
$Comp
L Memory_RAM:IDT7024L15PFG U53
U 1 1 5FCA86A1
P 3450 3650
F 0 "U53" H 3450 3700 50  0000 C CNN
F 1 "IDT7024L15PFG" H 3450 3600 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" V 3050 2100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/698/IDT_7024_DST_20200220-1711288.pdf" H 3500 3650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Renesas-IDT/7024L15PFG?qs=GVScuG1d83hVIavOlaKO6w%3D%3D" V 3150 3300 50  0001 C CNN "Mouser"
	1    3450 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3350 1600 3450 1600
Wire Wire Line
	3550 1600 3550 1650
$Comp
L power:VCC #PWR0322
U 1 1 5FD322E0
P 3450 1550
F 0 "#PWR0322" H 3450 1400 50  0001 C CNN
F 1 "VCC" H 3465 1723 50  0000 C CNN
F 2 "" H 3450 1550 50  0001 C CNN
F 3 "" H 3450 1550 50  0001 C CNN
	1    3450 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 6050 3200 6100
Wire Wire Line
	3200 6100 3300 6100
Wire Wire Line
	3700 6100 3700 6050
Wire Wire Line
	3300 6050 3300 6100
Connection ~ 3300 6100
Wire Wire Line
	3300 6100 3400 6100
Wire Wire Line
	3400 6050 3400 6100
Connection ~ 3400 6100
Wire Wire Line
	3400 6100 3500 6100
Wire Wire Line
	3500 6050 3500 6100
Connection ~ 3500 6100
Wire Wire Line
	3500 6100 3600 6100
Wire Wire Line
	3600 6050 3600 6100
Connection ~ 3600 6100
Wire Wire Line
	3600 6100 3700 6100
Wire Wire Line
	3400 6100 3400 6200
$Comp
L power:GND #PWR0321
U 1 1 5FD44FB4
P 3400 6200
F 0 "#PWR0321" H 3400 5950 50  0001 C CNN
F 1 "GND" H 3405 6027 50  0000 C CNN
F 2 "" H 3400 6200 50  0001 C CNN
F 3 "" H 3400 6200 50  0001 C CNN
	1    3400 6200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0307
U 1 1 5FD454DC
P 2550 1900
F 0 "#PWR0307" H 2550 1650 50  0001 C CNN
F 1 "GND" V 2555 1772 50  0000 R CNN
F 2 "" H 2550 1900 50  0001 C CNN
F 3 "" H 2550 1900 50  0001 C CNN
	1    2550 1900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0308
U 1 1 5FD458D6
P 2550 2100
F 0 "#PWR0308" H 2550 1850 50  0001 C CNN
F 1 "GND" V 2555 1972 50  0000 R CNN
F 2 "" H 2550 2100 50  0001 C CNN
F 3 "" H 2550 2100 50  0001 C CNN
	1    2550 2100
	0    1    1    0   
$EndComp
NoConn ~ 2550 2200
NoConn ~ 4350 2200
$Comp
L power:GND #PWR0309
U 1 1 5FD4C172
P 2550 2300
F 0 "#PWR0309" H 2550 2050 50  0001 C CNN
F 1 "GND" V 2555 2172 50  0000 R CNN
F 2 "" H 2550 2300 50  0001 C CNN
F 3 "" H 2550 2300 50  0001 C CNN
	1    2550 2300
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0310
U 1 1 5FD4C5E8
P 2550 2400
F 0 "#PWR0310" H 2550 2150 50  0001 C CNN
F 1 "GND" V 2555 2272 50  0000 R CNN
F 2 "" H 2550 2400 50  0001 C CNN
F 3 "" H 2550 2400 50  0001 C CNN
	1    2550 2400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0311
U 1 1 5FD4C82D
P 2550 2600
F 0 "#PWR0311" H 2550 2350 50  0001 C CNN
F 1 "GND" V 2555 2472 50  0000 R CNN
F 2 "" H 2550 2600 50  0001 C CNN
F 3 "" H 2550 2600 50  0001 C CNN
	1    2550 2600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0323
U 1 1 5FD4CDD8
P 4350 2100
F 0 "#PWR0323" H 4350 1850 50  0001 C CNN
F 1 "GND" V 4355 1972 50  0000 R CNN
F 2 "" H 4350 2100 50  0001 C CNN
F 3 "" H 4350 2100 50  0001 C CNN
	1    4350 2100
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0324
U 1 1 5FD4D61C
P 4350 2300
F 0 "#PWR0324" H 4350 2050 50  0001 C CNN
F 1 "GND" V 4355 2172 50  0000 R CNN
F 2 "" H 4350 2300 50  0001 C CNN
F 3 "" H 4350 2300 50  0001 C CNN
	1    4350 2300
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0325
U 1 1 5FD4D993
P 4350 2400
F 0 "#PWR0325" H 4350 2150 50  0001 C CNN
F 1 "GND" V 4355 2272 50  0000 R CNN
F 2 "" H 4350 2400 50  0001 C CNN
F 3 "" H 4350 2400 50  0001 C CNN
	1    4350 2400
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0327
U 1 1 5FD4DF71
P 4350 2600
F 0 "#PWR0327" H 4350 2350 50  0001 C CNN
F 1 "GND" V 4355 2472 50  0000 R CNN
F 2 "" H 4350 2600 50  0001 C CNN
F 3 "" H 4350 2600 50  0001 C CNN
	1    4350 2600
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0330
U 1 1 5FD6A629
P 4350 3300
F 0 "#PWR0330" H 4350 3050 50  0001 C CNN
F 1 "GND" V 4355 3172 50  0000 R CNN
F 2 "" H 4350 3300 50  0001 C CNN
F 3 "" H 4350 3300 50  0001 C CNN
	1    4350 3300
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0331
U 1 1 5FD6AD03
P 4350 3400
F 0 "#PWR0331" H 4350 3150 50  0001 C CNN
F 1 "GND" V 4355 3272 50  0000 R CNN
F 2 "" H 4350 3400 50  0001 C CNN
F 3 "" H 4350 3400 50  0001 C CNN
	1    4350 3400
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0332
U 1 1 5FD6AF7B
P 4350 3500
F 0 "#PWR0332" H 4350 3250 50  0001 C CNN
F 1 "GND" V 4355 3372 50  0000 R CNN
F 2 "" H 4350 3500 50  0001 C CNN
F 3 "" H 4350 3500 50  0001 C CNN
	1    4350 3500
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0333
U 1 1 5FD6B26A
P 4350 3600
F 0 "#PWR0333" H 4350 3350 50  0001 C CNN
F 1 "GND" V 4355 3472 50  0000 R CNN
F 2 "" H 4350 3600 50  0001 C CNN
F 3 "" H 4350 3600 50  0001 C CNN
	1    4350 3600
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0334
U 1 1 5FD6B57B
P 4350 3700
F 0 "#PWR0334" H 4350 3450 50  0001 C CNN
F 1 "GND" V 4355 3572 50  0000 R CNN
F 2 "" H 4350 3700 50  0001 C CNN
F 3 "" H 4350 3700 50  0001 C CNN
	1    4350 3700
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0335
U 1 1 5FD6B8BF
P 4350 3800
F 0 "#PWR0335" H 4350 3550 50  0001 C CNN
F 1 "GND" V 4355 3672 50  0000 R CNN
F 2 "" H 4350 3800 50  0001 C CNN
F 3 "" H 4350 3800 50  0001 C CNN
	1    4350 3800
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0336
U 1 1 5FD6BB7B
P 4350 3900
F 0 "#PWR0336" H 4350 3650 50  0001 C CNN
F 1 "GND" V 4355 3772 50  0000 R CNN
F 2 "" H 4350 3900 50  0001 C CNN
F 3 "" H 4350 3900 50  0001 C CNN
	1    4350 3900
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0337
U 1 1 5FD6BE6A
P 4350 4000
F 0 "#PWR0337" H 4350 3750 50  0001 C CNN
F 1 "GND" V 4355 3872 50  0000 R CNN
F 2 "" H 4350 4000 50  0001 C CNN
F 3 "" H 4350 4000 50  0001 C CNN
	1    4350 4000
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0338
U 1 1 5FD6C104
P 4350 4100
F 0 "#PWR0338" H 4350 3850 50  0001 C CNN
F 1 "GND" V 4355 3972 50  0000 R CNN
F 2 "" H 4350 4100 50  0001 C CNN
F 3 "" H 4350 4100 50  0001 C CNN
	1    4350 4100
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0320
U 1 1 5FD6C3E2
P 2550 4100
F 0 "#PWR0320" H 2550 3850 50  0001 C CNN
F 1 "GND" V 2555 3972 50  0000 R CNN
F 2 "" H 2550 4100 50  0001 C CNN
F 3 "" H 2550 4100 50  0001 C CNN
	1    2550 4100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0319
U 1 1 5FD6C8AD
P 2550 4000
F 0 "#PWR0319" H 2550 3750 50  0001 C CNN
F 1 "GND" V 2555 3872 50  0000 R CNN
F 2 "" H 2550 4000 50  0001 C CNN
F 3 "" H 2550 4000 50  0001 C CNN
	1    2550 4000
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0318
U 1 1 5FD6CABF
P 2550 3900
F 0 "#PWR0318" H 2550 3650 50  0001 C CNN
F 1 "GND" V 2555 3772 50  0000 R CNN
F 2 "" H 2550 3900 50  0001 C CNN
F 3 "" H 2550 3900 50  0001 C CNN
	1    2550 3900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0317
U 1 1 5FD6CE25
P 2550 3800
F 0 "#PWR0317" H 2550 3550 50  0001 C CNN
F 1 "GND" V 2555 3672 50  0000 R CNN
F 2 "" H 2550 3800 50  0001 C CNN
F 3 "" H 2550 3800 50  0001 C CNN
	1    2550 3800
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0316
U 1 1 5FD6D103
P 2550 3700
F 0 "#PWR0316" H 2550 3450 50  0001 C CNN
F 1 "GND" V 2555 3572 50  0000 R CNN
F 2 "" H 2550 3700 50  0001 C CNN
F 3 "" H 2550 3700 50  0001 C CNN
	1    2550 3700
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0315
U 1 1 5FD6D3AE
P 2550 3600
F 0 "#PWR0315" H 2550 3350 50  0001 C CNN
F 1 "GND" V 2555 3472 50  0000 R CNN
F 2 "" H 2550 3600 50  0001 C CNN
F 3 "" H 2550 3600 50  0001 C CNN
	1    2550 3600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0314
U 1 1 5FD6D68C
P 2550 3500
F 0 "#PWR0314" H 2550 3250 50  0001 C CNN
F 1 "GND" V 2555 3372 50  0000 R CNN
F 2 "" H 2550 3500 50  0001 C CNN
F 3 "" H 2550 3500 50  0001 C CNN
	1    2550 3500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0313
U 1 1 5FD6D8E2
P 2550 3400
F 0 "#PWR0313" H 2550 3150 50  0001 C CNN
F 1 "GND" V 2555 3272 50  0000 R CNN
F 2 "" H 2550 3400 50  0001 C CNN
F 3 "" H 2550 3400 50  0001 C CNN
	1    2550 3400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0312
U 1 1 5FD6DB49
P 2550 3300
F 0 "#PWR0312" H 2550 3050 50  0001 C CNN
F 1 "GND" V 2555 3172 50  0000 R CNN
F 2 "" H 2550 3300 50  0001 C CNN
F 3 "" H 2550 3300 50  0001 C CNN
	1    2550 3300
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0326
U 1 1 5FDD012C
P 4350 2500
F 0 "#PWR0326" H 4350 2350 50  0001 C CNN
F 1 "VCC" V 4365 2628 50  0000 L CNN
F 2 "" H 4350 2500 50  0001 C CNN
F 3 "" H 4350 2500 50  0001 C CNN
	1    4350 2500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0328
U 1 1 5FDD583B
P 4350 2700
F 0 "#PWR0328" H 4350 2450 50  0001 C CNN
F 1 "GND" V 4355 2572 50  0000 R CNN
F 2 "" H 4350 2700 50  0001 C CNN
F 3 "" H 4350 2700 50  0001 C CNN
	1    4350 2700
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0329
U 1 1 5FDD6081
P 4350 2800
F 0 "#PWR0329" H 4350 2550 50  0001 C CNN
F 1 "GND" V 4355 2672 50  0000 R CNN
F 2 "" H 4350 2800 50  0001 C CNN
F 3 "" H 4350 2800 50  0001 C CNN
	1    4350 2800
	0    -1   1    0   
$EndComp
Text HLabel 6050 2800 0    50   Input ~ 0
~WRH
Text HLabel 6050 2700 0    50   Input ~ 0
~WRL
Entry Wire Line
	6200 5000 6300 5100
Entry Wire Line
	6200 5100 6300 5200
Wire Wire Line
	6300 5200 6600 5200
Entry Wire Line
	6200 5200 6300 5300
Wire Wire Line
	6300 5300 6600 5300
Entry Wire Line
	6200 5300 6300 5400
Wire Wire Line
	6300 5400 6600 5400
Entry Wire Line
	6200 5400 6300 5500
Wire Wire Line
	6300 5500 6600 5500
Entry Wire Line
	6200 5500 6300 5600
Wire Wire Line
	6300 5600 6600 5600
Entry Wire Line
	6200 5600 6300 5700
Wire Wire Line
	6300 5700 6600 5700
Entry Wire Line
	6200 5700 6300 5800
Wire Wire Line
	6300 5800 6600 5800
Wire Wire Line
	6600 2700 6050 2700
Wire Wire Line
	6600 2800 6050 2800
Text HLabel 8950 4200 2    50   Output ~ 0
B[0..15]
Entry Wire Line
	8800 5000 8700 5100
Wire Wire Line
	8700 5100 8400 5100
Text Label 8700 5100 2    50   ~ 0
B8
Entry Wire Line
	8800 5100 8700 5200
Wire Wire Line
	8700 5200 8400 5200
Text Label 8700 5200 2    50   ~ 0
B9
Entry Wire Line
	8800 5200 8700 5300
Text Label 8700 5300 2    50   ~ 0
B10
Entry Wire Line
	8800 5300 8700 5400
Wire Wire Line
	8700 5400 8400 5400
Text Label 8700 5400 2    50   ~ 0
B11
Entry Wire Line
	8800 5400 8700 5500
Wire Wire Line
	8700 5500 8400 5500
Text Label 8700 5500 2    50   ~ 0
B12
Entry Wire Line
	8800 5500 8700 5600
Wire Wire Line
	8700 5600 8400 5600
Text Label 8700 5600 2    50   ~ 0
B13
Entry Wire Line
	8800 5600 8700 5700
Wire Wire Line
	8700 5700 8400 5700
Text Label 8700 5700 2    50   ~ 0
B14
Entry Wire Line
	8800 5700 8700 5800
Wire Wire Line
	8700 5800 8400 5800
Text Label 8700 5800 2    50   ~ 0
B15
Wire Bus Line
	8950 4200 8800 4200
Entry Wire Line
	8800 4200 8700 4300
Wire Wire Line
	8700 4300 8400 4300
Text Label 8700 4300 2    50   ~ 0
B0
Entry Wire Line
	8800 4300 8700 4400
Wire Wire Line
	8700 4400 8400 4400
Text Label 8700 4400 2    50   ~ 0
B1
Entry Wire Line
	8800 4400 8700 4500
Wire Wire Line
	8700 4500 8400 4500
Text Label 8700 4500 2    50   ~ 0
B2
Entry Wire Line
	8800 4500 8700 4600
Wire Wire Line
	8700 4600 8400 4600
Text Label 8700 4600 2    50   ~ 0
B3
Entry Wire Line
	8800 4600 8700 4700
Wire Wire Line
	8700 4700 8400 4700
Text Label 8700 4700 2    50   ~ 0
B4
Entry Wire Line
	8800 4700 8700 4800
Wire Wire Line
	8700 4800 8400 4800
Text Label 8700 4800 2    50   ~ 0
B5
Entry Wire Line
	8800 4800 8700 4900
Wire Wire Line
	8700 4900 8400 4900
Text Label 8700 4900 2    50   ~ 0
B6
Entry Wire Line
	8800 4900 8700 5000
Wire Wire Line
	8700 5000 8400 5000
Text Label 8700 5000 2    50   ~ 0
B7
Text HLabel 8950 2900 2    50   Input ~ 0
SelB[0..2]
Entry Wire Line
	8800 2900 8700 3000
Wire Wire Line
	8700 3000 8400 3000
Text Label 8700 3000 2    50   ~ 0
SelB0
Entry Wire Line
	8800 3000 8700 3100
Text Label 8700 3100 2    50   ~ 0
SelB1
Wire Bus Line
	8950 2900 8800 2900
Entry Wire Line
	8800 3100 8700 3200
Wire Wire Line
	8400 3100 8700 3100
Wire Wire Line
	8700 3200 8400 3200
Text Label 8700 3200 2    50   ~ 0
SelB2
Wire Wire Line
	8400 5300 8700 5300
Wire Wire Line
	6300 5100 6600 5100
Entry Wire Line
	6200 4200 6300 4300
Entry Wire Line
	6200 4300 6300 4400
Wire Wire Line
	6300 4400 6600 4400
Entry Wire Line
	6200 4400 6300 4500
Wire Wire Line
	6300 4500 6600 4500
Entry Wire Line
	6200 4500 6300 4600
Wire Wire Line
	6300 4600 6600 4600
Entry Wire Line
	6200 4600 6300 4700
Wire Wire Line
	6300 4700 6600 4700
Entry Wire Line
	6200 4700 6300 4800
Wire Wire Line
	6300 4800 6600 4800
Entry Wire Line
	6200 4800 6300 4900
Wire Wire Line
	6300 4900 6600 4900
Entry Wire Line
	6200 4900 6300 5000
Wire Wire Line
	6300 5000 6600 5000
Wire Bus Line
	6050 4200 6200 4200
Wire Wire Line
	6300 4300 6600 4300
Text HLabel 6050 4200 0    50   Input ~ 0
C[0..15]
Text Label 6300 4300 0    50   ~ 0
C0
Text Label 6300 4400 0    50   ~ 0
C1
Text Label 6300 4500 0    50   ~ 0
C2
Text Label 6300 4600 0    50   ~ 0
C3
Text Label 6300 4700 0    50   ~ 0
C4
Text Label 6300 4800 0    50   ~ 0
C5
Text Label 6300 4900 0    50   ~ 0
C6
Text Label 6300 5000 0    50   ~ 0
C7
Text Label 6300 5100 0    50   ~ 0
C8
Text Label 6300 5200 0    50   ~ 0
C9
Text Label 6300 5300 0    50   ~ 0
C10
Text Label 6300 5400 0    50   ~ 0
C11
Text Label 6300 5500 0    50   ~ 0
C12
Text Label 6300 5600 0    50   ~ 0
C13
Text Label 6300 5700 0    50   ~ 0
C14
Text Label 6300 5800 0    50   ~ 0
C15
$Comp
L Memory_RAM:IDT7024L15PFG U54
U 1 1 5FDF3541
P 7500 3650
F 0 "U54" H 7500 3700 50  0000 C CNN
F 1 "IDT7024L15PFG" H 7500 3600 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" V 7100 2100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/698/IDT_7024_DST_20200220-1711288.pdf" H 7550 3650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Renesas-IDT/7024L15PFG?qs=GVScuG1d83hVIavOlaKO6w%3D%3D" V 7200 3300 50  0001 C CNN "Mouser"
	1    7500 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	7400 1600 7500 1600
Wire Wire Line
	7600 1600 7600 1650
$Comp
L power:VCC #PWR0354
U 1 1 5FDF354B
P 7500 1550
F 0 "#PWR0354" H 7500 1400 50  0001 C CNN
F 1 "VCC" H 7515 1723 50  0000 C CNN
F 2 "" H 7500 1550 50  0001 C CNN
F 3 "" H 7500 1550 50  0001 C CNN
	1    7500 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7250 6050 7250 6100
Wire Wire Line
	7250 6100 7350 6100
Wire Wire Line
	7750 6100 7750 6050
Wire Wire Line
	7350 6050 7350 6100
Connection ~ 7350 6100
Wire Wire Line
	7350 6100 7450 6100
Wire Wire Line
	7450 6050 7450 6100
Connection ~ 7450 6100
Wire Wire Line
	7450 6100 7550 6100
Wire Wire Line
	7550 6050 7550 6100
Connection ~ 7550 6100
Wire Wire Line
	7550 6100 7650 6100
Wire Wire Line
	7650 6050 7650 6100
Connection ~ 7650 6100
Wire Wire Line
	7650 6100 7750 6100
Wire Wire Line
	7450 6100 7450 6200
$Comp
L power:GND #PWR0353
U 1 1 5FDF3561
P 7450 6200
F 0 "#PWR0353" H 7450 5950 50  0001 C CNN
F 1 "GND" H 7455 6027 50  0000 C CNN
F 2 "" H 7450 6200 50  0001 C CNN
F 3 "" H 7450 6200 50  0001 C CNN
	1    7450 6200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0339
U 1 1 5FDF3567
P 6600 1900
F 0 "#PWR0339" H 6600 1650 50  0001 C CNN
F 1 "GND" V 6605 1772 50  0000 R CNN
F 2 "" H 6600 1900 50  0001 C CNN
F 3 "" H 6600 1900 50  0001 C CNN
	1    6600 1900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0340
U 1 1 5FDF356D
P 6600 2100
F 0 "#PWR0340" H 6600 1850 50  0001 C CNN
F 1 "GND" V 6605 1972 50  0000 R CNN
F 2 "" H 6600 2100 50  0001 C CNN
F 3 "" H 6600 2100 50  0001 C CNN
	1    6600 2100
	0    1    1    0   
$EndComp
NoConn ~ 6600 2200
NoConn ~ 8400 2200
$Comp
L power:GND #PWR0341
U 1 1 5FDF3575
P 6600 2300
F 0 "#PWR0341" H 6600 2050 50  0001 C CNN
F 1 "GND" V 6605 2172 50  0000 R CNN
F 2 "" H 6600 2300 50  0001 C CNN
F 3 "" H 6600 2300 50  0001 C CNN
	1    6600 2300
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0342
U 1 1 5FDF357B
P 6600 2400
F 0 "#PWR0342" H 6600 2150 50  0001 C CNN
F 1 "GND" V 6605 2272 50  0000 R CNN
F 2 "" H 6600 2400 50  0001 C CNN
F 3 "" H 6600 2400 50  0001 C CNN
	1    6600 2400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0343
U 1 1 5FDF3581
P 6600 2600
F 0 "#PWR0343" H 6600 2350 50  0001 C CNN
F 1 "GND" V 6605 2472 50  0000 R CNN
F 2 "" H 6600 2600 50  0001 C CNN
F 3 "" H 6600 2600 50  0001 C CNN
	1    6600 2600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0355
U 1 1 5FDF358D
P 8400 2100
F 0 "#PWR0355" H 8400 1850 50  0001 C CNN
F 1 "GND" V 8405 1972 50  0000 R CNN
F 2 "" H 8400 2100 50  0001 C CNN
F 3 "" H 8400 2100 50  0001 C CNN
	1    8400 2100
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0356
U 1 1 5FDF3593
P 8400 2300
F 0 "#PWR0356" H 8400 2050 50  0001 C CNN
F 1 "GND" V 8405 2172 50  0000 R CNN
F 2 "" H 8400 2300 50  0001 C CNN
F 3 "" H 8400 2300 50  0001 C CNN
	1    8400 2300
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0357
U 1 1 5FDF3599
P 8400 2400
F 0 "#PWR0357" H 8400 2150 50  0001 C CNN
F 1 "GND" V 8405 2272 50  0000 R CNN
F 2 "" H 8400 2400 50  0001 C CNN
F 3 "" H 8400 2400 50  0001 C CNN
	1    8400 2400
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0359
U 1 1 5FDF359F
P 8400 2600
F 0 "#PWR0359" H 8400 2350 50  0001 C CNN
F 1 "GND" V 8405 2472 50  0000 R CNN
F 2 "" H 8400 2600 50  0001 C CNN
F 3 "" H 8400 2600 50  0001 C CNN
	1    8400 2600
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0362
U 1 1 5FDF35A5
P 8400 3300
F 0 "#PWR0362" H 8400 3050 50  0001 C CNN
F 1 "GND" V 8405 3172 50  0000 R CNN
F 2 "" H 8400 3300 50  0001 C CNN
F 3 "" H 8400 3300 50  0001 C CNN
	1    8400 3300
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0363
U 1 1 5FDF35AB
P 8400 3400
F 0 "#PWR0363" H 8400 3150 50  0001 C CNN
F 1 "GND" V 8405 3272 50  0000 R CNN
F 2 "" H 8400 3400 50  0001 C CNN
F 3 "" H 8400 3400 50  0001 C CNN
	1    8400 3400
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0364
U 1 1 5FDF35B1
P 8400 3500
F 0 "#PWR0364" H 8400 3250 50  0001 C CNN
F 1 "GND" V 8405 3372 50  0000 R CNN
F 2 "" H 8400 3500 50  0001 C CNN
F 3 "" H 8400 3500 50  0001 C CNN
	1    8400 3500
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0365
U 1 1 5FDF35B7
P 8400 3600
F 0 "#PWR0365" H 8400 3350 50  0001 C CNN
F 1 "GND" V 8405 3472 50  0000 R CNN
F 2 "" H 8400 3600 50  0001 C CNN
F 3 "" H 8400 3600 50  0001 C CNN
	1    8400 3600
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0366
U 1 1 5FDF35BD
P 8400 3700
F 0 "#PWR0366" H 8400 3450 50  0001 C CNN
F 1 "GND" V 8405 3572 50  0000 R CNN
F 2 "" H 8400 3700 50  0001 C CNN
F 3 "" H 8400 3700 50  0001 C CNN
	1    8400 3700
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0367
U 1 1 5FDF35C3
P 8400 3800
F 0 "#PWR0367" H 8400 3550 50  0001 C CNN
F 1 "GND" V 8405 3672 50  0000 R CNN
F 2 "" H 8400 3800 50  0001 C CNN
F 3 "" H 8400 3800 50  0001 C CNN
	1    8400 3800
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0368
U 1 1 5FDF35C9
P 8400 3900
F 0 "#PWR0368" H 8400 3650 50  0001 C CNN
F 1 "GND" V 8405 3772 50  0000 R CNN
F 2 "" H 8400 3900 50  0001 C CNN
F 3 "" H 8400 3900 50  0001 C CNN
	1    8400 3900
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0369
U 1 1 5FDF35CF
P 8400 4000
F 0 "#PWR0369" H 8400 3750 50  0001 C CNN
F 1 "GND" V 8405 3872 50  0000 R CNN
F 2 "" H 8400 4000 50  0001 C CNN
F 3 "" H 8400 4000 50  0001 C CNN
	1    8400 4000
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0370
U 1 1 5FDF35D5
P 8400 4100
F 0 "#PWR0370" H 8400 3850 50  0001 C CNN
F 1 "GND" V 8405 3972 50  0000 R CNN
F 2 "" H 8400 4100 50  0001 C CNN
F 3 "" H 8400 4100 50  0001 C CNN
	1    8400 4100
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0352
U 1 1 5FDF35DB
P 6600 4100
F 0 "#PWR0352" H 6600 3850 50  0001 C CNN
F 1 "GND" V 6605 3972 50  0000 R CNN
F 2 "" H 6600 4100 50  0001 C CNN
F 3 "" H 6600 4100 50  0001 C CNN
	1    6600 4100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0351
U 1 1 5FDF35E1
P 6600 4000
F 0 "#PWR0351" H 6600 3750 50  0001 C CNN
F 1 "GND" V 6605 3872 50  0000 R CNN
F 2 "" H 6600 4000 50  0001 C CNN
F 3 "" H 6600 4000 50  0001 C CNN
	1    6600 4000
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0350
U 1 1 5FDF35E7
P 6600 3900
F 0 "#PWR0350" H 6600 3650 50  0001 C CNN
F 1 "GND" V 6605 3772 50  0000 R CNN
F 2 "" H 6600 3900 50  0001 C CNN
F 3 "" H 6600 3900 50  0001 C CNN
	1    6600 3900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0349
U 1 1 5FDF35ED
P 6600 3800
F 0 "#PWR0349" H 6600 3550 50  0001 C CNN
F 1 "GND" V 6605 3672 50  0000 R CNN
F 2 "" H 6600 3800 50  0001 C CNN
F 3 "" H 6600 3800 50  0001 C CNN
	1    6600 3800
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0348
U 1 1 5FDF35F3
P 6600 3700
F 0 "#PWR0348" H 6600 3450 50  0001 C CNN
F 1 "GND" V 6605 3572 50  0000 R CNN
F 2 "" H 6600 3700 50  0001 C CNN
F 3 "" H 6600 3700 50  0001 C CNN
	1    6600 3700
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0347
U 1 1 5FDF35F9
P 6600 3600
F 0 "#PWR0347" H 6600 3350 50  0001 C CNN
F 1 "GND" V 6605 3472 50  0000 R CNN
F 2 "" H 6600 3600 50  0001 C CNN
F 3 "" H 6600 3600 50  0001 C CNN
	1    6600 3600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0346
U 1 1 5FDF35FF
P 6600 3500
F 0 "#PWR0346" H 6600 3250 50  0001 C CNN
F 1 "GND" V 6605 3372 50  0000 R CNN
F 2 "" H 6600 3500 50  0001 C CNN
F 3 "" H 6600 3500 50  0001 C CNN
	1    6600 3500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0345
U 1 1 5FDF3605
P 6600 3400
F 0 "#PWR0345" H 6600 3150 50  0001 C CNN
F 1 "GND" V 6605 3272 50  0000 R CNN
F 2 "" H 6600 3400 50  0001 C CNN
F 3 "" H 6600 3400 50  0001 C CNN
	1    6600 3400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0344
U 1 1 5FDF360B
P 6600 3300
F 0 "#PWR0344" H 6600 3050 50  0001 C CNN
F 1 "GND" V 6605 3172 50  0000 R CNN
F 2 "" H 6600 3300 50  0001 C CNN
F 3 "" H 6600 3300 50  0001 C CNN
	1    6600 3300
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0358
U 1 1 5FDF3611
P 8400 2500
F 0 "#PWR0358" H 8400 2350 50  0001 C CNN
F 1 "VCC" V 8415 2628 50  0000 L CNN
F 2 "" H 8400 2500 50  0001 C CNN
F 3 "" H 8400 2500 50  0001 C CNN
	1    8400 2500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0360
U 1 1 5FDF361B
P 8400 2700
F 0 "#PWR0360" H 8400 2450 50  0001 C CNN
F 1 "GND" V 8405 2572 50  0000 R CNN
F 2 "" H 8400 2700 50  0001 C CNN
F 3 "" H 8400 2700 50  0001 C CNN
	1    8400 2700
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0361
U 1 1 5FDF3621
P 8400 2800
F 0 "#PWR0361" H 8400 2550 50  0001 C CNN
F 1 "GND" V 8405 2672 50  0000 R CNN
F 2 "" H 8400 2800 50  0001 C CNN
F 3 "" H 8400 2800 50  0001 C CNN
	1    8400 2800
	0    -1   1    0   
$EndComp
Text Notes 2550 7250 0    50   ~ 0
Both dual port SRAMs are configured in Slave mode. This disables the\non board contention arbitration logic. Per application note, AN-91, a\nsimultaneous read and write to the same cell will flow through from one\nport to another after a short delay.
Wire Wire Line
	3350 1650 3350 1600
Wire Wire Line
	7400 1650 7400 1600
Wire Wire Line
	7500 1550 7500 1600
Connection ~ 7500 1600
Wire Wire Line
	7500 1600 7600 1600
Wire Wire Line
	7500 1600 7500 1650
Wire Wire Line
	3450 1550 3450 1600
Connection ~ 3450 1600
Wire Wire Line
	3450 1600 3550 1600
Wire Wire Line
	3450 1600 3450 1650
Text HLabel 2000 2500 0    50   Input ~ 0
~WBEN
Wire Wire Line
	2550 2500 2000 2500
Text HLabel 6050 2500 0    50   Input ~ 0
~WBEN
Wire Wire Line
	6600 2500 6050 2500
Wire Wire Line
	2100 3000 2550 3000
Wire Wire Line
	2100 3100 2550 3100
Wire Wire Line
	2100 3200 2550 3200
Text HLabel 5900 2900 0    50   Input ~ 0
SelC_WB[0..2]
Entry Wire Line
	6050 2900 6150 3000
Text Label 6150 3000 0    50   ~ 0
SelC_WB0
Entry Wire Line
	6050 3000 6150 3100
Text Label 6150 3100 0    50   ~ 0
SelC_WB1
Wire Bus Line
	5900 2900 6050 2900
Entry Wire Line
	6050 3100 6150 3200
Text Label 6150 3200 0    50   ~ 0
SelC_WB2
Wire Wire Line
	6150 3000 6600 3000
Wire Wire Line
	6150 3100 6600 3100
Wire Wire Line
	6150 3200 6600 3200
Wire Bus Line
	2000 2900 2000 3100
Wire Bus Line
	8800 2900 8800 3100
Wire Bus Line
	6050 2900 6050 3100
Wire Bus Line
	4750 2750 4750 3100
Wire Bus Line
	2150 4200 2150 5700
Wire Bus Line
	4750 4200 4750 5700
Wire Bus Line
	6200 4200 6200 5700
Wire Bus Line
	8800 4200 8800 5700
$EndSCHEMATC
