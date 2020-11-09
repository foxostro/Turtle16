EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 1 21
Title "TurtleTTL: Main Board"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "TTL microcomputer built from 74xx series logic chips."
$EndDescr
$Sheet
S 6650 3100 1500 500 
U 5D29E36D
F0 "Register D" 50
F1 "Register D.sch" 50
$EndSheet
$Sheet
S 3200 2400 1500 500 
U 5D2C07CD
F0 "Program Counter" 50
F1 "Program Counter.sch" 50
$EndSheet
$Sheet
S 3200 3800 1500 500 
U 5D8005AF
F0 "Instruction Fetch" 50
F1 "Instruction Fetch.sch" 50
$EndSheet
$Sheet
S 3200 4500 1500 500 
U 5D2C0B92
F0 "Instruction Decode" 50
F1 "Instruction Decode.sch" 50
$EndSheet
$Sheet
S 4950 1700 1500 500 
U 5D2C0CA7
F0 "Register A" 50
F1 "Register A.sch" 50
$EndSheet
$Sheet
S 4950 2400 1500 500 
U 5D2C0D13
F0 "Register B" 50
F1 "Register B.sch" 50
$EndSheet
$Sheet
S 4950 3100 1500 500 
U 5D2C0CE4
F0 "ALU" 50
F1 "ALU.sch" 50
$EndSheet
$Sheet
S 4950 4500 1500 500 
U 5D2C12A5
F0 "Bus Display" 50
F1 "Bus Display.sch" 50
$EndSheet
$Sheet
S 6650 3800 1500 500 
U 5D9F1D54
F0 "Expansion" 50
F1 "Expansion.sch" 50
$EndSheet
$Comp
L Mechanical:MountingHole_Pad H1
U 1 1 5D9D8517
P 3050 6650
F 0 "H1" H 3150 6699 50  0000 L CNN
F 1 "MountingHole_Pad" H 3150 6608 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3050 6650 50  0001 C CNN
F 3 "~" H 3050 6650 50  0001 C CNN
	1    3050 6650
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H3
U 1 1 5D9D8A27
P 4800 6650
F 0 "H3" H 4900 6699 50  0000 L CNN
F 1 "MountingHole_Pad" H 4900 6608 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 4800 6650 50  0001 C CNN
F 3 "~" H 4800 6650 50  0001 C CNN
	1    4800 6650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0225
U 1 1 5D9D8FA4
P 3050 6750
F 0 "#PWR0225" H 3050 6500 50  0001 C CNN
F 1 "GND" H 3055 6577 50  0000 C CNN
F 2 "" H 3050 6750 50  0001 C CNN
F 3 "" H 3050 6750 50  0001 C CNN
	1    3050 6750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0226
U 1 1 5D9D9546
P 4800 6750
F 0 "#PWR0226" H 4800 6500 50  0001 C CNN
F 1 "GND" H 4805 6577 50  0000 C CNN
F 2 "" H 4800 6750 50  0001 C CNN
F 3 "" H 4800 6750 50  0001 C CNN
	1    4800 6750
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H2
U 1 1 5D9DB4ED
P 3050 7150
F 0 "H2" H 3150 7199 50  0000 L CNN
F 1 "MountingHole_Pad" H 3150 7108 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3050 7150 50  0001 C CNN
F 3 "~" H 3050 7150 50  0001 C CNN
	1    3050 7150
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H4
U 1 1 5D9DB4F3
P 4800 7150
F 0 "H4" H 4900 7199 50  0000 L CNN
F 1 "MountingHole_Pad" H 4900 7108 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 4800 7150 50  0001 C CNN
F 3 "~" H 4800 7150 50  0001 C CNN
	1    4800 7150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0227
U 1 1 5D9DB4F9
P 3050 7250
F 0 "#PWR0227" H 3050 7000 50  0001 C CNN
F 1 "GND" H 3055 7077 50  0000 C CNN
F 2 "" H 3050 7250 50  0001 C CNN
F 3 "" H 3050 7250 50  0001 C CNN
	1    3050 7250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0228
U 1 1 5D9DB4FF
P 4800 7250
F 0 "#PWR0228" H 4800 7000 50  0001 C CNN
F 1 "GND" H 4805 7077 50  0000 C CNN
F 2 "" H 4800 7250 50  0001 C CNN
F 3 "" H 4800 7250 50  0001 C CNN
	1    4800 7250
	1    0    0    -1  
$EndComp
$Sheet
S 6650 5200 1500 500 
U 5DAA13E6
F0 "Data RAM" 50
F1 "Data RAM.sch" 50
$EndSheet
$Sheet
S 3200 3100 1500 500 
U 5DA6B866
F0 "Link Register" 50
F1 "Link Register.sch" 50
$EndSheet
$Comp
L Mechanical:MountingHole_Pad H5
U 1 1 661EA07C
P 3050 7600
F 0 "H5" H 3150 7649 50  0000 L CNN
F 1 "MountingHole_Pad" H 3150 7558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3050 7600 50  0001 C CNN
F 3 "~" H 3050 7600 50  0001 C CNN
	1    3050 7600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0154
U 1 1 661EA082
P 3050 7700
F 0 "#PWR0154" H 3050 7450 50  0001 C CNN
F 1 "GND" H 3055 7527 50  0000 C CNN
F 2 "" H 3050 7700 50  0001 C CNN
F 3 "" H 3050 7700 50  0001 C CNN
	1    3050 7700
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H6
U 1 1 661EC32F
P 4800 7600
F 0 "H6" H 4900 7649 50  0000 L CNN
F 1 "MountingHole_Pad" H 4900 7558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 4800 7600 50  0001 C CNN
F 3 "~" H 4800 7600 50  0001 C CNN
	1    4800 7600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0157
U 1 1 661EC335
P 4800 7700
F 0 "#PWR0157" H 4800 7450 50  0001 C CNN
F 1 "GND" H 4805 7527 50  0000 C CNN
F 2 "" H 4800 7700 50  0001 C CNN
F 3 "" H 4800 7700 50  0001 C CNN
	1    4800 7700
	1    0    0    -1  
$EndComp
$Sheet
S 4950 5200 1500 500 
U 5DCFC665
F0 "Power Supply" 50
F1 "PowerSupply.sch" 50
$EndSheet
$Comp
L Mechanical:MountingHole_Pad H7
U 1 1 5DED8C63
P 3950 7150
F 0 "H7" H 4050 7199 50  0000 L CNN
F 1 "MountingHole_Pad" H 4050 7108 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3950 7150 50  0001 C CNN
F 3 "~" H 3950 7150 50  0001 C CNN
	1    3950 7150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0217
U 1 1 5DED8C69
P 3950 7250
F 0 "#PWR0217" H 3950 7000 50  0001 C CNN
F 1 "GND" H 3955 7077 50  0000 C CNN
F 2 "" H 3950 7250 50  0001 C CNN
F 3 "" H 3950 7250 50  0001 C CNN
	1    3950 7250
	1    0    0    -1  
$EndComp
$Sheet
S 3200 5200 1500 500 
U 5D2C13FD
F0 "Execute" 50
F1 "Execute.sch" 50
$EndSheet
$Comp
L Mechanical:MountingHole_Pad H8
U 1 1 5E0E2F6B
P 3950 6650
F 0 "H8" H 4050 6699 50  0000 L CNN
F 1 "MountingHole_Pad" H 4050 6608 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3950 6650 50  0001 C CNN
F 3 "~" H 3950 6650 50  0001 C CNN
	1    3950 6650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0236
U 1 1 5E0E2F71
P 3950 6750
F 0 "#PWR0236" H 3950 6500 50  0001 C CNN
F 1 "GND" H 3955 6577 50  0000 C CNN
F 2 "" H 3950 6750 50  0001 C CNN
F 3 "" H 3950 6750 50  0001 C CNN
	1    3950 6750
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H9
U 1 1 5E0E37C1
P 3950 7600
F 0 "H9" H 4050 7649 50  0000 L CNN
F 1 "MountingHole_Pad" H 4050 7558 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3950 7600 50  0001 C CNN
F 3 "~" H 3950 7600 50  0001 C CNN
	1    3950 7600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0237
U 1 1 5E0E37C7
P 3950 7700
F 0 "#PWR0237" H 3950 7450 50  0001 C CNN
F 1 "GND" H 3955 7527 50  0000 C CNN
F 2 "" H 3950 7700 50  0001 C CNN
F 3 "" H 3950 7700 50  0001 C CNN
	1    3950 7700
	1    0    0    -1  
$EndComp
$Sheet
S 4950 3800 1500 500 
U 5D2C0720
F0 "Clock" 50
F1 "Clock.sch" 50
$EndSheet
$Sheet
S 6650 4500 1500 500 
U 5E0B0BBA
F0 "Register UV" 50
F1 "Register UV.sch" 50
$EndSheet
$Sheet
S 3200 1700 1500 500 
U 5D7BD0EA
F0 "Register XY" 50
F1 "Register XY.sch" 50
$EndSheet
$EndSCHEMATC
