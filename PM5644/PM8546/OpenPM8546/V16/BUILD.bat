@ECHO OFF
c:\Wincupl\shared\cupl -m1lxfjae -u C:\Wincupl\Shared\cupl.dl g22v10 V16.PLD
DEL V16_G22V10.JED
REN V16.JED V16_G22V10.JED
c:\Wincupl\shared\cupl -m1lxfjae -u C:\Wincupl\Shared\cupl.dl p22v10 V16.PLD
DEL V16_P22V10.JED
REN V16.JED V16_P22V10.JED
DEL *.mx
DEL *.sim
DEL *.lst
DEL *.abs
DEL *.doc