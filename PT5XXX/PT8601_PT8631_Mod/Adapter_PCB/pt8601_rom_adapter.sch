EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Memory_EPROM:27C512 U1
U 1 1 6472E945
P 1525 2125
F 0 "U1" H 1600 2150 50  0000 C CNN
F 1 "27C512" H 1600 2075 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 1525 2125 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0015.pdf" H 1525 2125 50  0001 C CNN
	1    1525 2125
	1    0    0    -1  
$EndComp
$Comp
L Memory_Flash:SST39SF040 U3
U 1 1 647308C7
P 3700 2350
F 0 "U3" H 3800 2250 50  0000 C CNN
F 1 "SST39SF040" H 3800 2175 50  0000 C CNN
F 2 "PLCC_32_SKT:PLCC_32_SKT" H 3700 2650 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 3700 2650 50  0001 C CNN
	1    3700 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 1150 2875 1150
Wire Wire Line
	3100 1250 2875 1250
Wire Wire Line
	3100 1350 2875 1350
Wire Wire Line
	2875 1450 3100 1450
Wire Wire Line
	3100 1550 2875 1550
Wire Wire Line
	3100 1650 2875 1650
Wire Wire Line
	3100 1750 2875 1750
Wire Wire Line
	2875 1850 3100 1850
Wire Wire Line
	3100 1950 2875 1950
Wire Wire Line
	3100 2050 2875 2050
Wire Wire Line
	3100 2150 2875 2150
Wire Wire Line
	2875 2250 3100 2250
Wire Wire Line
	3100 2350 2875 2350
Wire Wire Line
	3100 2450 2875 2450
Wire Wire Line
	3100 2550 2875 2550
Wire Wire Line
	2875 2650 3100 2650
Wire Wire Line
	3100 2750 2875 2750
Wire Wire Line
	3100 2850 2875 2850
Wire Wire Line
	3100 2950 2875 2950
Wire Wire Line
	3025 3350 3100 3350
Wire Wire Line
	3025 3450 3100 3450
Wire Wire Line
	3700 3550 3700 3650
Wire Wire Line
	3700 3650 3025 3650
$Comp
L power:GND #PWR05
U 1 1 64737070
P 3700 3725
F 0 "#PWR05" H 3700 3475 50  0001 C CNN
F 1 "GND" H 3705 3552 50  0000 C CNN
F 2 "" H 3700 3725 50  0001 C CNN
F 3 "" H 3700 3725 50  0001 C CNN
	1    3700 3725
	1    0    0    -1  
$EndComp
$Comp
L Device:C C1
U 1 1 64738E9A
P 2450 1300
F 0 "C1" H 2565 1346 50  0000 L CNN
F 1 "0.1" H 2565 1255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 2488 1150 50  0001 C CNN
F 3 "~" H 2450 1300 50  0001 C CNN
	1    2450 1300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 647396FE
P 2450 1500
F 0 "#PWR03" H 2450 1250 50  0001 C CNN
F 1 "GND" H 2455 1327 50  0000 C CNN
F 2 "" H 2450 1500 50  0001 C CNN
F 3 "" H 2450 1500 50  0001 C CNN
	1    2450 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2450 1500 2450 1450
Text Label 2900 1150 0    50   ~ 0
AA0
Text Label 2900 1250 0    50   ~ 0
AA1
Text Label 2900 1350 0    50   ~ 0
AA2
Text Label 2900 1450 0    50   ~ 0
AA3
Text Label 2900 1550 0    50   ~ 0
AA4
Text Label 2900 1650 0    50   ~ 0
AA5
Text Label 2900 1750 0    50   ~ 0
AA6
Text Label 2900 1850 0    50   ~ 0
AA7
Text Label 2900 1950 0    50   ~ 0
AA8
Text Label 2900 2050 0    50   ~ 0
AA9
Text Label 2900 2150 0    50   ~ 0
AA10
Text Label 2900 2250 0    50   ~ 0
AA11
Text Label 2900 2350 0    50   ~ 0
AA12
Text Label 2900 2450 0    50   ~ 0
AA13
Text Label 2900 2550 0    50   ~ 0
AA14
Text Label 2900 2650 0    50   ~ 0
AA15
Text Label 2900 2750 0    50   ~ 0
A16
Text Label 2900 2850 0    50   ~ 0
A17
Text Label 2900 2950 0    50   ~ 0
A18
Entry Wire Line
	2775 1050 2875 1150
Entry Wire Line
	2775 1150 2875 1250
Entry Wire Line
	2775 1250 2875 1350
Entry Wire Line
	2775 1350 2875 1450
Entry Wire Line
	2775 1450 2875 1550
Entry Wire Line
	2775 1550 2875 1650
Entry Wire Line
	2775 1650 2875 1750
Entry Wire Line
	2775 1750 2875 1850
Entry Wire Line
	2775 1850 2875 1950
Entry Wire Line
	2775 1950 2875 2050
Entry Wire Line
	2775 2050 2875 2150
Entry Wire Line
	2775 2150 2875 2250
Entry Wire Line
	2775 2250 2875 2350
Entry Wire Line
	2775 2350 2875 2450
Entry Wire Line
	2775 2450 2875 2550
Entry Wire Line
	2775 2550 2875 2650
Entry Wire Line
	2775 2650 2875 2750
Entry Wire Line
	2775 2750 2875 2850
Entry Wire Line
	2775 2850 2875 2950
Wire Wire Line
	1125 1225 900  1225
Wire Wire Line
	1125 1325 900  1325
Wire Wire Line
	1125 1425 900  1425
Wire Wire Line
	900  1525 1125 1525
Wire Wire Line
	1125 1625 900  1625
Wire Wire Line
	1125 1725 900  1725
Wire Wire Line
	1125 1825 900  1825
Wire Wire Line
	900  1925 1125 1925
Wire Wire Line
	1125 2025 900  2025
Wire Wire Line
	1125 2125 900  2125
Wire Wire Line
	1125 2225 900  2225
Wire Wire Line
	900  2325 1125 2325
Wire Wire Line
	1125 2425 900  2425
Wire Wire Line
	1125 2525 900  2525
Wire Wire Line
	1125 2625 900  2625
Wire Wire Line
	900  2725 1125 2725
Text Label 925  1225 0    50   ~ 0
AA0
Text Label 925  1325 0    50   ~ 0
AA1
Text Label 925  1425 0    50   ~ 0
AA2
Text Label 925  1525 0    50   ~ 0
AA3
Text Label 925  1625 0    50   ~ 0
AA4
Text Label 925  1725 0    50   ~ 0
AA5
Text Label 925  1825 0    50   ~ 0
AA6
Text Label 925  1925 0    50   ~ 0
AA7
Text Label 925  2025 0    50   ~ 0
AA8
Text Label 925  2125 0    50   ~ 0
AA9
Text Label 925  2225 0    50   ~ 0
AA10
Text Label 925  2325 0    50   ~ 0
AA11
Text Label 925  2425 0    50   ~ 0
AA12
Text Label 925  2525 0    50   ~ 0
AA13
Text Label 925  2625 0    50   ~ 0
AA14
Text Label 925  2725 0    50   ~ 0
AA15
Entry Wire Line
	800  1125 900  1225
Entry Wire Line
	800  1225 900  1325
Entry Wire Line
	800  1325 900  1425
Entry Wire Line
	800  1425 900  1525
Entry Wire Line
	800  1525 900  1625
Entry Wire Line
	800  1625 900  1725
Entry Wire Line
	800  1725 900  1825
Entry Wire Line
	800  1825 900  1925
Entry Wire Line
	800  1925 900  2025
Entry Wire Line
	800  2025 900  2125
Entry Wire Line
	800  2125 900  2225
Entry Wire Line
	800  2225 900  2325
Entry Wire Line
	800  2325 900  2425
Entry Wire Line
	800  2425 900  2525
Entry Wire Line
	800  2525 900  2625
Entry Wire Line
	800  2625 900  2725
Wire Bus Line
	2775 850  800  850 
Wire Wire Line
	1125 2925 1050 2925
Wire Wire Line
	1050 2925 1050 3025
Wire Wire Line
	1050 3025 1125 3025
Wire Wire Line
	1050 3025 1050 3300
Wire Wire Line
	1050 3300 1525 3300
Wire Wire Line
	1525 3300 1525 3225
Connection ~ 1050 3025
$Comp
L power:GND #PWR01
U 1 1 64745972
P 1525 3375
F 0 "#PWR01" H 1525 3125 50  0001 C CNN
F 1 "GND" H 1530 3202 50  0000 C CNN
F 2 "" H 1525 3375 50  0001 C CNN
F 3 "" H 1525 3375 50  0001 C CNN
	1    1525 3375
	1    0    0    -1  
$EndComp
Wire Wire Line
	1525 3300 1525 3375
Connection ~ 1525 3300
Text Label 4325 1150 0    50   ~ 0
DA0
Text Label 4325 1250 0    50   ~ 0
DA1
Text Label 4325 1350 0    50   ~ 0
DA2
Text Label 4325 1450 0    50   ~ 0
DA3
Text Label 4325 1550 0    50   ~ 0
DA4
Text Label 4325 1650 0    50   ~ 0
DA5
Text Label 4325 1750 0    50   ~ 0
DA6
Text Label 4325 1850 0    50   ~ 0
DA7
Entry Wire Line
	4525 1150 4625 1050
Entry Wire Line
	4525 1250 4625 1150
Entry Wire Line
	4525 1350 4625 1250
Entry Wire Line
	4525 1450 4625 1350
Entry Wire Line
	4525 1550 4625 1450
Entry Wire Line
	4525 1650 4625 1550
Entry Wire Line
	4525 1750 4625 1650
Entry Wire Line
	4525 1850 4625 1750
Wire Wire Line
	4300 1150 4525 1150
Wire Wire Line
	4300 1250 4525 1250
Wire Wire Line
	4300 1350 4525 1350
Wire Wire Line
	4300 1450 4525 1450
Wire Wire Line
	4300 1550 4525 1550
Wire Wire Line
	4300 1650 4525 1650
Wire Wire Line
	4300 1750 4525 1750
Wire Wire Line
	4300 1850 4525 1850
Text Label 1950 1225 0    50   ~ 0
DA0
Text Label 1950 1325 0    50   ~ 0
DA1
Text Label 1950 1425 0    50   ~ 0
DA2
Text Label 1950 1525 0    50   ~ 0
DA3
Text Label 1950 1625 0    50   ~ 0
DA4
Text Label 1950 1725 0    50   ~ 0
DA5
Text Label 1950 1825 0    50   ~ 0
DA6
Text Label 1950 1925 0    50   ~ 0
DA7
Entry Wire Line
	2150 1225 2250 1125
Entry Wire Line
	2150 1325 2250 1225
Entry Wire Line
	2150 1425 2250 1325
Entry Wire Line
	2150 1525 2250 1425
Entry Wire Line
	2150 1625 2250 1525
Entry Wire Line
	2150 1725 2250 1625
Entry Wire Line
	2150 1825 2250 1725
Entry Wire Line
	2150 1925 2250 1825
Wire Wire Line
	1925 1225 2150 1225
Wire Wire Line
	1925 1325 2150 1325
Wire Wire Line
	1925 1425 2150 1425
Wire Wire Line
	1925 1525 2150 1525
Wire Wire Line
	1925 1625 2150 1625
Wire Wire Line
	1925 1725 2150 1725
Wire Wire Line
	1925 1825 2150 1825
Wire Wire Line
	1925 1925 2150 1925
Wire Bus Line
	2250 775  4625 775 
Wire Wire Line
	3700 1050 3700 950 
Wire Wire Line
	2450 950  2450 1150
Wire Wire Line
	1525 950  1525 1025
Connection ~ 2450 950 
Wire Wire Line
	2450 950  1525 950 
Wire Wire Line
	2450 950  3700 950 
Wire Wire Line
	3700 3650 3700 3725
Connection ~ 3700 3650
Wire Wire Line
	3025 3350 3025 3450
Wire Wire Line
	3025 3450 3025 3650
Connection ~ 3025 3450
$Comp
L Memory_EPROM:27C512 U5
U 1 1 64919DCC
P 5550 2125
F 0 "U5" H 5625 2150 50  0000 C CNN
F 1 "27C512" H 5625 2075 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 5550 2125 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0015.pdf" H 5550 2125 50  0001 C CNN
	1    5550 2125
	1    0    0    -1  
$EndComp
$Comp
L Memory_Flash:SST39SF040 U7
U 1 1 64919DD2
P 7725 2350
F 0 "U7" H 7825 2250 50  0000 C CNN
F 1 "SST39SF040" H 7825 2175 50  0000 C CNN
F 2 "PLCC_32_SKT:PLCC_32_SKT" H 7725 2650 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 7725 2650 50  0001 C CNN
	1    7725 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7125 1150 6900 1150
Wire Wire Line
	7125 1250 6900 1250
Wire Wire Line
	7125 1350 6900 1350
Wire Wire Line
	6900 1450 7125 1450
Wire Wire Line
	7125 1550 6900 1550
Wire Wire Line
	7125 1650 6900 1650
Wire Wire Line
	7125 1750 6900 1750
Wire Wire Line
	6900 1850 7125 1850
Wire Wire Line
	7125 1950 6900 1950
Wire Wire Line
	7125 2050 6900 2050
Wire Wire Line
	7125 2150 6900 2150
Wire Wire Line
	6900 2250 7125 2250
Wire Wire Line
	7125 2350 6900 2350
Wire Wire Line
	7125 2450 6900 2450
Wire Wire Line
	7125 2550 6900 2550
Wire Wire Line
	6900 2650 7125 2650
Wire Wire Line
	7125 2750 6900 2750
Wire Wire Line
	7125 2850 6900 2850
Wire Wire Line
	7125 2950 6900 2950
Wire Wire Line
	7050 3350 7125 3350
Wire Wire Line
	7050 3450 7125 3450
Wire Wire Line
	7725 3550 7725 3650
Wire Wire Line
	7725 3650 7050 3650
$Comp
L power:GND #PWR011
U 1 1 64919DF2
P 7725 3725
F 0 "#PWR011" H 7725 3475 50  0001 C CNN
F 1 "GND" H 7730 3552 50  0000 C CNN
F 2 "" H 7725 3725 50  0001 C CNN
F 3 "" H 7725 3725 50  0001 C CNN
	1    7725 3725
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 64919DF8
P 6475 1300
F 0 "C3" H 6590 1346 50  0000 L CNN
F 1 "0.1" H 6590 1255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6513 1150 50  0001 C CNN
F 3 "~" H 6475 1300 50  0001 C CNN
	1    6475 1300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR09
U 1 1 64919DFE
P 6475 1500
F 0 "#PWR09" H 6475 1250 50  0001 C CNN
F 1 "GND" H 6480 1327 50  0000 C CNN
F 2 "" H 6475 1500 50  0001 C CNN
F 3 "" H 6475 1500 50  0001 C CNN
	1    6475 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6475 1500 6475 1450
Text Label 6925 1150 0    50   ~ 0
AB0
Text Label 6925 1250 0    50   ~ 0
AB1
Text Label 6925 1350 0    50   ~ 0
AB2
Text Label 6925 1450 0    50   ~ 0
AB3
Text Label 6925 1550 0    50   ~ 0
AB4
Text Label 6925 1650 0    50   ~ 0
AB5
Text Label 6925 1750 0    50   ~ 0
AB6
Text Label 6925 1850 0    50   ~ 0
AB7
Text Label 6925 1950 0    50   ~ 0
AB8
Text Label 6925 2050 0    50   ~ 0
AB9
Text Label 6925 2150 0    50   ~ 0
AB10
Text Label 6925 2250 0    50   ~ 0
AB11
Text Label 6925 2350 0    50   ~ 0
AB12
Text Label 6925 2450 0    50   ~ 0
AB13
Text Label 6925 2550 0    50   ~ 0
AB14
Text Label 6925 2650 0    50   ~ 0
AB15
Text Label 6925 2750 0    50   ~ 0
A16
Text Label 6925 2850 0    50   ~ 0
A17
Text Label 6925 2950 0    50   ~ 0
A18
Entry Wire Line
	6800 1050 6900 1150
Entry Wire Line
	6800 1150 6900 1250
Entry Wire Line
	6800 1250 6900 1350
Entry Wire Line
	6800 1350 6900 1450
Entry Wire Line
	6800 1450 6900 1550
Entry Wire Line
	6800 1550 6900 1650
Entry Wire Line
	6800 1650 6900 1750
Entry Wire Line
	6800 1750 6900 1850
Entry Wire Line
	6800 1850 6900 1950
Entry Wire Line
	6800 1950 6900 2050
Entry Wire Line
	6800 2050 6900 2150
Entry Wire Line
	6800 2150 6900 2250
Entry Wire Line
	6800 2250 6900 2350
Entry Wire Line
	6800 2350 6900 2450
Entry Wire Line
	6800 2450 6900 2550
Entry Wire Line
	6800 2550 6900 2650
Entry Wire Line
	6800 2650 6900 2750
Entry Wire Line
	6800 2750 6900 2850
Entry Wire Line
	6800 2850 6900 2950
Wire Wire Line
	5150 1225 4925 1225
Wire Wire Line
	5150 1325 4925 1325
Wire Wire Line
	5150 1425 4925 1425
Wire Wire Line
	4925 1525 5150 1525
Wire Wire Line
	5150 1625 4925 1625
Wire Wire Line
	5150 1725 4925 1725
Wire Wire Line
	5150 1825 4925 1825
Wire Wire Line
	4925 1925 5150 1925
Wire Wire Line
	5150 2025 4925 2025
Wire Wire Line
	5150 2125 4925 2125
Wire Wire Line
	5150 2225 4925 2225
Wire Wire Line
	4925 2325 5150 2325
Wire Wire Line
	5150 2425 4925 2425
Wire Wire Line
	5150 2525 4925 2525
Wire Wire Line
	5150 2625 4925 2625
Wire Wire Line
	4925 2725 5150 2725
Text Label 4950 1225 0    50   ~ 0
AB0
Text Label 4950 1325 0    50   ~ 0
AB1
Text Label 4950 1425 0    50   ~ 0
AB2
Text Label 4950 1525 0    50   ~ 0
AB3
Text Label 4950 1625 0    50   ~ 0
AB4
Text Label 4950 1725 0    50   ~ 0
AB5
Text Label 4950 1825 0    50   ~ 0
AB6
Text Label 4950 1925 0    50   ~ 0
AB7
Text Label 4950 2025 0    50   ~ 0
AB8
Text Label 4950 2125 0    50   ~ 0
AB9
Text Label 4950 2225 0    50   ~ 0
AB10
Text Label 4950 2325 0    50   ~ 0
AB11
Text Label 4950 2425 0    50   ~ 0
AB12
Text Label 4950 2525 0    50   ~ 0
AB13
Text Label 4950 2625 0    50   ~ 0
AB14
Text Label 4950 2725 0    50   ~ 0
AB15
Entry Wire Line
	4825 1125 4925 1225
Entry Wire Line
	4825 1225 4925 1325
Entry Wire Line
	4825 1325 4925 1425
Entry Wire Line
	4825 1425 4925 1525
Entry Wire Line
	4825 1525 4925 1625
Entry Wire Line
	4825 1625 4925 1725
Entry Wire Line
	4825 1725 4925 1825
Entry Wire Line
	4825 1825 4925 1925
Entry Wire Line
	4825 1925 4925 2025
Entry Wire Line
	4825 2025 4925 2125
Entry Wire Line
	4825 2125 4925 2225
Entry Wire Line
	4825 2225 4925 2325
Entry Wire Line
	4825 2325 4925 2425
Entry Wire Line
	4825 2425 4925 2525
Entry Wire Line
	4825 2525 4925 2625
Entry Wire Line
	4825 2625 4925 2725
Wire Bus Line
	6800 850  4825 850 
Wire Wire Line
	5150 2925 5075 2925
Wire Wire Line
	5075 2925 5075 3025
Wire Wire Line
	5075 3025 5150 3025
Wire Wire Line
	5075 3025 5075 3300
Wire Wire Line
	5075 3300 5550 3300
Wire Wire Line
	5550 3300 5550 3225
Connection ~ 5075 3025
$Comp
L power:GND #PWR07
U 1 1 64919E63
P 5550 3375
F 0 "#PWR07" H 5550 3125 50  0001 C CNN
F 1 "GND" H 5555 3202 50  0000 C CNN
F 2 "" H 5550 3375 50  0001 C CNN
F 3 "" H 5550 3375 50  0001 C CNN
	1    5550 3375
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 3300 5550 3375
Connection ~ 5550 3300
Text Label 8350 1150 0    50   ~ 0
DB0
Text Label 8350 1250 0    50   ~ 0
DB1
Text Label 8350 1350 0    50   ~ 0
DB2
Text Label 8350 1450 0    50   ~ 0
DB3
Text Label 8350 1550 0    50   ~ 0
DB4
Text Label 8350 1650 0    50   ~ 0
DB5
Text Label 8350 1750 0    50   ~ 0
DB6
Text Label 8350 1850 0    50   ~ 0
DB7
Entry Wire Line
	8550 1150 8650 1050
Entry Wire Line
	8550 1250 8650 1150
Entry Wire Line
	8550 1350 8650 1250
Entry Wire Line
	8550 1450 8650 1350
Entry Wire Line
	8550 1550 8650 1450
Entry Wire Line
	8550 1650 8650 1550
Entry Wire Line
	8550 1750 8650 1650
Entry Wire Line
	8550 1850 8650 1750
Wire Wire Line
	8325 1150 8550 1150
Wire Wire Line
	8325 1250 8550 1250
Wire Wire Line
	8325 1350 8550 1350
Wire Wire Line
	8325 1450 8550 1450
Wire Wire Line
	8325 1550 8550 1550
Wire Wire Line
	8325 1650 8550 1650
Wire Wire Line
	8325 1750 8550 1750
Wire Wire Line
	8325 1850 8550 1850
Text Label 5975 1225 0    50   ~ 0
DB0
Text Label 5975 1325 0    50   ~ 0
DB1
Text Label 5975 1425 0    50   ~ 0
DB2
Text Label 5975 1525 0    50   ~ 0
DB3
Text Label 5975 1625 0    50   ~ 0
DB4
Text Label 5975 1725 0    50   ~ 0
DB5
Text Label 5975 1825 0    50   ~ 0
DB6
Text Label 5975 1925 0    50   ~ 0
DB7
Entry Wire Line
	6175 1225 6275 1125
Entry Wire Line
	6175 1325 6275 1225
Entry Wire Line
	6175 1425 6275 1325
Entry Wire Line
	6175 1525 6275 1425
Entry Wire Line
	6175 1625 6275 1525
Entry Wire Line
	6175 1725 6275 1625
Entry Wire Line
	6175 1825 6275 1725
Entry Wire Line
	6175 1925 6275 1825
Wire Wire Line
	5950 1225 6175 1225
Wire Wire Line
	5950 1325 6175 1325
Wire Wire Line
	5950 1425 6175 1425
Wire Wire Line
	5950 1525 6175 1525
Wire Wire Line
	5950 1625 6175 1625
Wire Wire Line
	5950 1725 6175 1725
Wire Wire Line
	5950 1825 6175 1825
Wire Wire Line
	5950 1925 6175 1925
Wire Bus Line
	6275 775  8650 775 
Wire Wire Line
	7725 1050 7725 950 
Wire Wire Line
	6475 950  6475 1150
Wire Wire Line
	5550 950  5550 1025
Connection ~ 6475 950 
Wire Wire Line
	6475 950  5550 950 
Wire Wire Line
	6475 950  7725 950 
Wire Wire Line
	7725 3650 7725 3725
Connection ~ 7725 3650
Wire Wire Line
	7050 3350 7050 3450
Wire Wire Line
	7050 3450 7050 3650
Connection ~ 7050 3450
$Comp
L Memory_EPROM:27C512 U2
U 1 1 6495B090
P 1525 5525
F 0 "U2" H 1600 5550 50  0000 C CNN
F 1 "27C512" H 1600 5475 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 1525 5525 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0015.pdf" H 1525 5525 50  0001 C CNN
	1    1525 5525
	1    0    0    -1  
$EndComp
$Comp
L Memory_Flash:SST39SF040 U4
U 1 1 6495B096
P 3700 5750
F 0 "U4" H 3800 5650 50  0000 C CNN
F 1 "SST39SF040" H 3800 5575 50  0000 C CNN
F 2 "PLCC_32_SKT:PLCC_32_SKT" H 3700 6050 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 3700 6050 50  0001 C CNN
	1    3700 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 4550 2875 4550
Wire Wire Line
	3100 4650 2875 4650
Wire Wire Line
	3100 4750 2875 4750
Wire Wire Line
	2875 4850 3100 4850
Wire Wire Line
	3100 4950 2875 4950
Wire Wire Line
	3100 5050 2875 5050
Wire Wire Line
	3100 5150 2875 5150
Wire Wire Line
	2875 5250 3100 5250
Wire Wire Line
	3100 5350 2875 5350
Wire Wire Line
	3100 5450 2875 5450
Wire Wire Line
	3100 5550 2875 5550
Wire Wire Line
	2875 5650 3100 5650
Wire Wire Line
	3100 5750 2875 5750
Wire Wire Line
	3100 5850 2875 5850
Wire Wire Line
	3100 5950 2875 5950
Wire Wire Line
	2875 6050 3100 6050
Wire Wire Line
	3100 6150 2875 6150
Wire Wire Line
	3100 6250 2875 6250
Wire Wire Line
	3100 6350 2875 6350
Wire Wire Line
	3025 6750 3100 6750
Wire Wire Line
	3025 6850 3100 6850
Wire Wire Line
	3700 6950 3700 7050
Wire Wire Line
	3700 7050 3025 7050
$Comp
L power:GND #PWR06
U 1 1 6495B0B6
P 3700 7125
F 0 "#PWR06" H 3700 6875 50  0001 C CNN
F 1 "GND" H 3705 6952 50  0000 C CNN
F 2 "" H 3700 7125 50  0001 C CNN
F 3 "" H 3700 7125 50  0001 C CNN
	1    3700 7125
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 6495B0BC
P 2450 4700
F 0 "C2" H 2565 4746 50  0000 L CNN
F 1 "0.1" H 2565 4655 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 2488 4550 50  0001 C CNN
F 3 "~" H 2450 4700 50  0001 C CNN
	1    2450 4700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 6495B0C2
P 2450 4900
F 0 "#PWR04" H 2450 4650 50  0001 C CNN
F 1 "GND" H 2455 4727 50  0000 C CNN
F 2 "" H 2450 4900 50  0001 C CNN
F 3 "" H 2450 4900 50  0001 C CNN
	1    2450 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	2450 4900 2450 4850
Text Label 2900 4550 0    50   ~ 0
AC0
Text Label 2900 4650 0    50   ~ 0
AC1
Text Label 2900 4750 0    50   ~ 0
AC2
Text Label 2900 4850 0    50   ~ 0
AC3
Text Label 2900 4950 0    50   ~ 0
AC4
Text Label 2900 5050 0    50   ~ 0
AC5
Text Label 2900 5150 0    50   ~ 0
AC6
Text Label 2900 5250 0    50   ~ 0
AC7
Text Label 2900 5350 0    50   ~ 0
AC8
Text Label 2900 5450 0    50   ~ 0
AC9
Text Label 2900 5550 0    50   ~ 0
AC10
Text Label 2900 5650 0    50   ~ 0
AC11
Text Label 2900 5750 0    50   ~ 0
AC12
Text Label 2900 5850 0    50   ~ 0
AC13
Text Label 2900 5950 0    50   ~ 0
AC14
Text Label 2900 6050 0    50   ~ 0
AC15
Text Label 2900 6150 0    50   ~ 0
A16
Text Label 2900 6250 0    50   ~ 0
A17
Text Label 2900 6350 0    50   ~ 0
A18
Entry Wire Line
	2775 4450 2875 4550
Entry Wire Line
	2775 4550 2875 4650
Entry Wire Line
	2775 4650 2875 4750
Entry Wire Line
	2775 4750 2875 4850
Entry Wire Line
	2775 4850 2875 4950
Entry Wire Line
	2775 4950 2875 5050
Entry Wire Line
	2775 5050 2875 5150
Entry Wire Line
	2775 5150 2875 5250
Entry Wire Line
	2775 5250 2875 5350
Entry Wire Line
	2775 5350 2875 5450
Entry Wire Line
	2775 5450 2875 5550
Entry Wire Line
	2775 5550 2875 5650
Entry Wire Line
	2775 5650 2875 5750
Entry Wire Line
	2775 5750 2875 5850
Entry Wire Line
	2775 5850 2875 5950
Entry Wire Line
	2775 5950 2875 6050
Entry Wire Line
	2775 6050 2875 6150
Entry Wire Line
	2775 6150 2875 6250
Entry Wire Line
	2775 6250 2875 6350
Wire Wire Line
	1125 4625 900  4625
Wire Wire Line
	1125 4725 900  4725
Wire Wire Line
	1125 4825 900  4825
Wire Wire Line
	900  4925 1125 4925
Wire Wire Line
	1125 5025 900  5025
Wire Wire Line
	1125 5125 900  5125
Wire Wire Line
	1125 5225 900  5225
Wire Wire Line
	900  5325 1125 5325
Wire Wire Line
	1125 5425 900  5425
Wire Wire Line
	1125 5525 900  5525
Wire Wire Line
	1125 5625 900  5625
Wire Wire Line
	900  5725 1125 5725
Wire Wire Line
	1125 5825 900  5825
Wire Wire Line
	1125 5925 900  5925
Wire Wire Line
	1125 6025 900  6025
Wire Wire Line
	900  6125 1125 6125
Text Label 925  4625 0    50   ~ 0
AC0
Text Label 925  4725 0    50   ~ 0
AC1
Text Label 925  4825 0    50   ~ 0
AC2
Text Label 925  4925 0    50   ~ 0
AC3
Text Label 925  5025 0    50   ~ 0
AC4
Text Label 925  5125 0    50   ~ 0
AC5
Text Label 925  5225 0    50   ~ 0
AC6
Text Label 925  5325 0    50   ~ 0
AC7
Text Label 925  5425 0    50   ~ 0
AC8
Text Label 925  5525 0    50   ~ 0
AC9
Text Label 925  5625 0    50   ~ 0
AC10
Text Label 925  5725 0    50   ~ 0
AC11
Text Label 925  5825 0    50   ~ 0
AC12
Text Label 925  5925 0    50   ~ 0
AC13
Text Label 925  6025 0    50   ~ 0
AC14
Text Label 925  6125 0    50   ~ 0
AC15
Entry Wire Line
	800  4525 900  4625
Entry Wire Line
	800  4625 900  4725
Entry Wire Line
	800  4725 900  4825
Entry Wire Line
	800  4825 900  4925
Entry Wire Line
	800  4925 900  5025
Entry Wire Line
	800  5025 900  5125
Entry Wire Line
	800  5125 900  5225
Entry Wire Line
	800  5225 900  5325
Entry Wire Line
	800  5325 900  5425
Entry Wire Line
	800  5425 900  5525
Entry Wire Line
	800  5525 900  5625
Entry Wire Line
	800  5625 900  5725
Entry Wire Line
	800  5725 900  5825
Entry Wire Line
	800  5825 900  5925
Entry Wire Line
	800  5925 900  6025
Entry Wire Line
	800  6025 900  6125
Wire Bus Line
	2775 4250 800  4250
Wire Wire Line
	1125 6325 1050 6325
Wire Wire Line
	1050 6325 1050 6425
Wire Wire Line
	1050 6425 1125 6425
Wire Wire Line
	1050 6425 1050 6700
Wire Wire Line
	1050 6700 1525 6700
Wire Wire Line
	1525 6700 1525 6625
Connection ~ 1050 6425
$Comp
L power:GND #PWR02
U 1 1 6495B127
P 1525 6775
F 0 "#PWR02" H 1525 6525 50  0001 C CNN
F 1 "GND" H 1530 6602 50  0000 C CNN
F 2 "" H 1525 6775 50  0001 C CNN
F 3 "" H 1525 6775 50  0001 C CNN
	1    1525 6775
	1    0    0    -1  
$EndComp
Wire Wire Line
	1525 6700 1525 6775
Connection ~ 1525 6700
Text Label 4325 4550 0    50   ~ 0
DC0
Text Label 4325 4650 0    50   ~ 0
DC1
Text Label 4325 4750 0    50   ~ 0
DC2
Text Label 4325 4850 0    50   ~ 0
DC3
Text Label 4325 4950 0    50   ~ 0
DC4
Text Label 4325 5050 0    50   ~ 0
DC5
Text Label 4325 5150 0    50   ~ 0
DC6
Text Label 4325 5250 0    50   ~ 0
DC7
Entry Wire Line
	4525 4550 4625 4450
Entry Wire Line
	4525 4650 4625 4550
Entry Wire Line
	4525 4750 4625 4650
Entry Wire Line
	4525 4850 4625 4750
Entry Wire Line
	4525 4950 4625 4850
Entry Wire Line
	4525 5050 4625 4950
Entry Wire Line
	4525 5150 4625 5050
Entry Wire Line
	4525 5250 4625 5150
Wire Wire Line
	4300 4550 4525 4550
Wire Wire Line
	4300 4650 4525 4650
Wire Wire Line
	4300 4750 4525 4750
Wire Wire Line
	4300 4850 4525 4850
Wire Wire Line
	4300 4950 4525 4950
Wire Wire Line
	4300 5050 4525 5050
Wire Wire Line
	4300 5150 4525 5150
Wire Wire Line
	4300 5250 4525 5250
Text Label 1950 4625 0    50   ~ 0
DC0
Text Label 1950 4725 0    50   ~ 0
DC1
Text Label 1950 4825 0    50   ~ 0
DC2
Text Label 1950 4925 0    50   ~ 0
DC3
Text Label 1950 5025 0    50   ~ 0
DC4
Text Label 1950 5125 0    50   ~ 0
DC5
Text Label 1950 5225 0    50   ~ 0
DC6
Text Label 1950 5325 0    50   ~ 0
DC7
Entry Wire Line
	2150 4625 2250 4525
Entry Wire Line
	2150 4725 2250 4625
Entry Wire Line
	2150 4825 2250 4725
Entry Wire Line
	2150 4925 2250 4825
Entry Wire Line
	2150 5025 2250 4925
Entry Wire Line
	2150 5125 2250 5025
Entry Wire Line
	2150 5225 2250 5125
Entry Wire Line
	2150 5325 2250 5225
Wire Wire Line
	1925 4625 2150 4625
Wire Wire Line
	1925 4725 2150 4725
Wire Wire Line
	1925 4825 2150 4825
Wire Wire Line
	1925 4925 2150 4925
Wire Wire Line
	1925 5025 2150 5025
Wire Wire Line
	1925 5125 2150 5125
Wire Wire Line
	1925 5225 2150 5225
Wire Wire Line
	1925 5325 2150 5325
Wire Bus Line
	2250 4150 4625 4150
Wire Wire Line
	3700 4450 3700 4350
Wire Wire Line
	2450 4350 2450 4550
Wire Wire Line
	1525 4350 1525 4425
Connection ~ 2450 4350
Wire Wire Line
	2450 4350 1525 4350
Wire Wire Line
	2450 4350 3700 4350
Wire Wire Line
	3700 7050 3700 7125
Connection ~ 3700 7050
Wire Wire Line
	3025 6750 3025 6850
Wire Wire Line
	3025 6850 3025 7050
Connection ~ 3025 6850
$Comp
L Memory_EPROM:27C512 U6
U 1 1 6495B16B
P 5550 5525
F 0 "U6" H 5625 5550 50  0000 C CNN
F 1 "27C512" H 5625 5475 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 5550 5525 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0015.pdf" H 5550 5525 50  0001 C CNN
	1    5550 5525
	1    0    0    -1  
$EndComp
$Comp
L Memory_Flash:SST39SF040 U8
U 1 1 6495B171
P 7725 5750
F 0 "U8" H 7825 5650 50  0000 C CNN
F 1 "SST39SF040" H 7825 5575 50  0000 C CNN
F 2 "PLCC_32_SKT:PLCC_32_SKT" H 7725 6050 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 7725 6050 50  0001 C CNN
	1    7725 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7125 4550 6900 4550
Wire Wire Line
	7125 4650 6900 4650
Wire Wire Line
	7125 4750 6900 4750
Wire Wire Line
	6900 4850 7125 4850
Wire Wire Line
	7125 4950 6900 4950
Wire Wire Line
	7125 5050 6900 5050
Wire Wire Line
	7125 5150 6900 5150
Wire Wire Line
	6900 5250 7125 5250
Wire Wire Line
	7125 5350 6900 5350
Wire Wire Line
	7125 5450 6900 5450
Wire Wire Line
	7125 5550 6900 5550
Wire Wire Line
	6900 5650 7125 5650
Wire Wire Line
	7125 5750 6900 5750
Wire Wire Line
	7125 5850 6900 5850
Wire Wire Line
	7125 5950 6900 5950
Wire Wire Line
	6900 6050 7125 6050
Wire Wire Line
	7125 6150 6900 6150
Wire Wire Line
	7125 6250 6900 6250
Wire Wire Line
	7125 6350 6900 6350
Wire Wire Line
	7050 6750 7125 6750
Wire Wire Line
	7050 6850 7125 6850
Wire Wire Line
	7725 6950 7725 7050
Wire Wire Line
	7725 7050 7050 7050
$Comp
L power:GND #PWR012
U 1 1 6495B191
P 7725 7125
F 0 "#PWR012" H 7725 6875 50  0001 C CNN
F 1 "GND" H 7730 6952 50  0000 C CNN
F 2 "" H 7725 7125 50  0001 C CNN
F 3 "" H 7725 7125 50  0001 C CNN
	1    7725 7125
	1    0    0    -1  
$EndComp
$Comp
L Device:C C4
U 1 1 6495B197
P 6475 4700
F 0 "C4" H 6590 4746 50  0000 L CNN
F 1 "0.1" H 6590 4655 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6513 4550 50  0001 C CNN
F 3 "~" H 6475 4700 50  0001 C CNN
	1    6475 4700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR010
U 1 1 6495B19D
P 6475 4900
F 0 "#PWR010" H 6475 4650 50  0001 C CNN
F 1 "GND" H 6480 4727 50  0000 C CNN
F 2 "" H 6475 4900 50  0001 C CNN
F 3 "" H 6475 4900 50  0001 C CNN
	1    6475 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6475 4900 6475 4850
Text Label 6925 4550 0    50   ~ 0
AD0
Text Label 6925 4650 0    50   ~ 0
AD1
Text Label 6925 4750 0    50   ~ 0
AD2
Text Label 6925 4850 0    50   ~ 0
AD3
Text Label 6925 4950 0    50   ~ 0
AD4
Text Label 6925 5050 0    50   ~ 0
AD5
Text Label 6925 5150 0    50   ~ 0
AD6
Text Label 6925 5250 0    50   ~ 0
AD7
Text Label 6925 5350 0    50   ~ 0
AD8
Text Label 6925 5450 0    50   ~ 0
AD9
Text Label 6925 5550 0    50   ~ 0
AD10
Text Label 6925 5650 0    50   ~ 0
AD11
Text Label 6925 5750 0    50   ~ 0
AD12
Text Label 6925 5850 0    50   ~ 0
AD13
Text Label 6925 5950 0    50   ~ 0
AD14
Text Label 6925 6050 0    50   ~ 0
AD15
Text Label 6925 6150 0    50   ~ 0
A16
Text Label 6925 6250 0    50   ~ 0
A17
Text Label 6925 6350 0    50   ~ 0
A18
Entry Wire Line
	6800 4450 6900 4550
Entry Wire Line
	6800 4550 6900 4650
Entry Wire Line
	6800 4650 6900 4750
Entry Wire Line
	6800 4750 6900 4850
Entry Wire Line
	6800 4850 6900 4950
Entry Wire Line
	6800 4950 6900 5050
Entry Wire Line
	6800 5050 6900 5150
Entry Wire Line
	6800 5150 6900 5250
Entry Wire Line
	6800 5250 6900 5350
Entry Wire Line
	6800 5350 6900 5450
Entry Wire Line
	6800 5450 6900 5550
Entry Wire Line
	6800 5550 6900 5650
Entry Wire Line
	6800 5650 6900 5750
Entry Wire Line
	6800 5750 6900 5850
Entry Wire Line
	6800 5850 6900 5950
Entry Wire Line
	6800 5950 6900 6050
Entry Wire Line
	6800 6050 6900 6150
Entry Wire Line
	6800 6150 6900 6250
Entry Wire Line
	6800 6250 6900 6350
Wire Wire Line
	5150 4625 4925 4625
Wire Wire Line
	5150 4725 4925 4725
Wire Wire Line
	5150 4825 4925 4825
Wire Wire Line
	4925 4925 5150 4925
Wire Wire Line
	5150 5025 4925 5025
Wire Wire Line
	5150 5125 4925 5125
Wire Wire Line
	5150 5225 4925 5225
Wire Wire Line
	4925 5325 5150 5325
Wire Wire Line
	5150 5425 4925 5425
Wire Wire Line
	5150 5525 4925 5525
Wire Wire Line
	5150 5625 4925 5625
Wire Wire Line
	4925 5725 5150 5725
Wire Wire Line
	5150 5825 4925 5825
Wire Wire Line
	5150 5925 4925 5925
Wire Wire Line
	5150 6025 4925 6025
Wire Wire Line
	4925 6125 5150 6125
Text Label 4950 4625 0    50   ~ 0
AD0
Text Label 4950 4725 0    50   ~ 0
AD1
Text Label 4950 4825 0    50   ~ 0
AD2
Text Label 4950 4925 0    50   ~ 0
AD3
Text Label 4950 5025 0    50   ~ 0
AD4
Text Label 4950 5125 0    50   ~ 0
AD5
Text Label 4950 5225 0    50   ~ 0
AD6
Text Label 4950 5325 0    50   ~ 0
AD7
Text Label 4950 5425 0    50   ~ 0
AD8
Text Label 4950 5525 0    50   ~ 0
AD9
Text Label 4950 5625 0    50   ~ 0
AD10
Text Label 4950 5725 0    50   ~ 0
AD11
Text Label 4950 5825 0    50   ~ 0
AD12
Text Label 4950 5925 0    50   ~ 0
AD13
Text Label 4950 6025 0    50   ~ 0
AD14
Text Label 4950 6125 0    50   ~ 0
AD15
Entry Wire Line
	4825 4525 4925 4625
Entry Wire Line
	4825 4625 4925 4725
Entry Wire Line
	4825 4725 4925 4825
Entry Wire Line
	4825 4825 4925 4925
Entry Wire Line
	4825 4925 4925 5025
Entry Wire Line
	4825 5025 4925 5125
Entry Wire Line
	4825 5125 4925 5225
Entry Wire Line
	4825 5225 4925 5325
Entry Wire Line
	4825 5325 4925 5425
Entry Wire Line
	4825 5425 4925 5525
Entry Wire Line
	4825 5525 4925 5625
Entry Wire Line
	4825 5625 4925 5725
Entry Wire Line
	4825 5725 4925 5825
Entry Wire Line
	4825 5825 4925 5925
Entry Wire Line
	4825 5925 4925 6025
Entry Wire Line
	4825 6025 4925 6125
Wire Bus Line
	6800 4250 4825 4250
Wire Wire Line
	5150 6325 5075 6325
Wire Wire Line
	5075 6325 5075 6425
Wire Wire Line
	5075 6425 5150 6425
Wire Wire Line
	5075 6425 5075 6700
Wire Wire Line
	5075 6700 5550 6700
Wire Wire Line
	5550 6700 5550 6625
Connection ~ 5075 6425
$Comp
L power:GND #PWR08
U 1 1 6495B202
P 5550 6775
F 0 "#PWR08" H 5550 6525 50  0001 C CNN
F 1 "GND" H 5555 6602 50  0000 C CNN
F 2 "" H 5550 6775 50  0001 C CNN
F 3 "" H 5550 6775 50  0001 C CNN
	1    5550 6775
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 6700 5550 6775
Connection ~ 5550 6700
Text Label 8350 4550 0    50   ~ 0
DD0
Text Label 8350 4650 0    50   ~ 0
DD1
Text Label 8350 4750 0    50   ~ 0
DD2
Text Label 8350 4850 0    50   ~ 0
DD3
Text Label 8350 4950 0    50   ~ 0
DD4
Text Label 8350 5050 0    50   ~ 0
DD5
Text Label 8350 5150 0    50   ~ 0
DD6
Text Label 8350 5250 0    50   ~ 0
DD7
Entry Wire Line
	8550 4550 8650 4450
Entry Wire Line
	8550 4650 8650 4550
Entry Wire Line
	8550 4750 8650 4650
Entry Wire Line
	8550 4850 8650 4750
Entry Wire Line
	8550 4950 8650 4850
Entry Wire Line
	8550 5050 8650 4950
Entry Wire Line
	8550 5150 8650 5050
Entry Wire Line
	8550 5250 8650 5150
Wire Wire Line
	8325 4550 8550 4550
Wire Wire Line
	8325 4650 8550 4650
Wire Wire Line
	8325 4750 8550 4750
Wire Wire Line
	8325 4850 8550 4850
Wire Wire Line
	8325 4950 8550 4950
Wire Wire Line
	8325 5050 8550 5050
Wire Wire Line
	8325 5150 8550 5150
Wire Wire Line
	8325 5250 8550 5250
Text Label 5975 4625 0    50   ~ 0
DD0
Text Label 5975 4725 0    50   ~ 0
DD1
Text Label 5975 4825 0    50   ~ 0
DD2
Text Label 5975 4925 0    50   ~ 0
DD3
Text Label 5975 5025 0    50   ~ 0
DD4
Text Label 5975 5125 0    50   ~ 0
DD5
Text Label 5975 5225 0    50   ~ 0
DD6
Text Label 5975 5325 0    50   ~ 0
DD7
Entry Wire Line
	6175 4625 6275 4525
Entry Wire Line
	6175 4725 6275 4625
Entry Wire Line
	6175 4825 6275 4725
Entry Wire Line
	6175 4925 6275 4825
Entry Wire Line
	6175 5025 6275 4925
Entry Wire Line
	6175 5125 6275 5025
Entry Wire Line
	6175 5225 6275 5125
Entry Wire Line
	6175 5325 6275 5225
Wire Wire Line
	5950 4625 6175 4625
Wire Wire Line
	5950 4725 6175 4725
Wire Wire Line
	5950 4825 6175 4825
Wire Wire Line
	5950 4925 6175 4925
Wire Wire Line
	5950 5025 6175 5025
Wire Wire Line
	5950 5125 6175 5125
Wire Wire Line
	5950 5225 6175 5225
Wire Wire Line
	5950 5325 6175 5325
Wire Bus Line
	6275 4150 8650 4150
Wire Wire Line
	7725 4450 7725 4350
Wire Wire Line
	6475 4350 6475 4550
Wire Wire Line
	5550 4350 5550 4425
Connection ~ 6475 4350
Wire Wire Line
	6475 4350 5550 4350
Wire Wire Line
	6475 4350 7725 4350
Wire Wire Line
	7725 7050 7725 7125
Connection ~ 7725 7050
Wire Wire Line
	7050 6750 7050 6850
Wire Wire Line
	7050 6850 7050 7050
Connection ~ 7050 6850
Connection ~ 6800 4250
Connection ~ 2775 4250
Wire Bus Line
	2775 4050 6800 4050
Connection ~ 2775 4050
Wire Bus Line
	2775 4050 2775 4250
Connection ~ 6800 4050
Wire Bus Line
	6800 4050 6800 4250
Wire Bus Line
	6800 4050 8650 4050
Entry Wire Line
	8650 3500 8750 3400
Entry Wire Line
	8650 3600 8750 3500
Entry Wire Line
	8650 3700 8750 3600
Wire Wire Line
	8750 3400 9000 3400
Wire Wire Line
	8750 3500 9000 3500
Wire Wire Line
	8750 3600 9000 3600
$Comp
L Connector_Generic:Conn_01x03 J1
U 1 1 64A71A1E
P 9200 3500
F 0 "J1" H 9280 3542 50  0000 L CNN
F 1 "EXTRA_ADDR" H 9280 3451 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x03_P1.27mm_Vertical" H 9200 3500 50  0001 C CNN
F 3 "~" H 9200 3500 50  0001 C CNN
	1    9200 3500
	1    0    0    -1  
$EndComp
Text Label 8825 3400 0    50   ~ 0
A16
Text Label 8825 3500 0    50   ~ 0
A17
Text Label 8825 3600 0    50   ~ 0
A18
$Comp
L power:VCC #PWR?
U 1 1 648D6C8F
P 6575 3000
F 0 "#PWR?" H 6575 2850 50  0001 C CNN
F 1 "VCC" H 6590 3173 50  0000 C CNN
F 2 "" H 6575 3000 50  0001 C CNN
F 3 "" H 6575 3000 50  0001 C CNN
	1    6575 3000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7125 3150 6575 3150
Wire Wire Line
	6575 3150 6575 3000
$Comp
L power:VCC #PWR?
U 1 1 648FAFBD
P 2550 3000
F 0 "#PWR?" H 2550 2850 50  0001 C CNN
F 1 "VCC" H 2565 3173 50  0000 C CNN
F 2 "" H 2550 3000 50  0001 C CNN
F 3 "" H 2550 3000 50  0001 C CNN
	1    2550 3000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 3150 2550 3150
Wire Wire Line
	2550 3150 2550 3000
$Comp
L power:VCC #PWR?
U 1 1 6491E002
P 2550 6400
F 0 "#PWR?" H 2550 6250 50  0001 C CNN
F 1 "VCC" H 2565 6573 50  0000 C CNN
F 2 "" H 2550 6400 50  0001 C CNN
F 3 "" H 2550 6400 50  0001 C CNN
	1    2550 6400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 6550 2550 6550
Wire Wire Line
	2550 6550 2550 6400
$Comp
L power:VCC #PWR?
U 1 1 649415AB
P 6575 6400
F 0 "#PWR?" H 6575 6250 50  0001 C CNN
F 1 "VCC" H 6590 6573 50  0000 C CNN
F 2 "" H 6575 6400 50  0001 C CNN
F 3 "" H 6575 6400 50  0001 C CNN
	1    6575 6400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7125 6550 6575 6550
Wire Wire Line
	6575 6550 6575 6400
Wire Bus Line
	8650 3500 8650 4050
Wire Bus Line
	4625 775  4625 1750
Wire Bus Line
	2250 775  2250 1825
Wire Bus Line
	8650 775  8650 1750
Wire Bus Line
	6275 775  6275 1825
Wire Bus Line
	4625 4150 4625 5150
Wire Bus Line
	2250 4150 2250 5225
Wire Bus Line
	8650 4150 8650 5150
Wire Bus Line
	6275 4150 6275 5225
Wire Bus Line
	800  850  800  2625
Wire Bus Line
	4825 850  4825 2625
Wire Bus Line
	800  4250 800  6025
Wire Bus Line
	2775 4250 2775 6250
Wire Bus Line
	4825 4250 4825 6025
Wire Bus Line
	6800 4250 6800 6250
Wire Bus Line
	6800 850  6800 4050
Wire Bus Line
	2775 850  2775 4050
$EndSCHEMATC
