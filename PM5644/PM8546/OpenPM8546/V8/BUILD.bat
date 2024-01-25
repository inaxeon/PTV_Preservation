@ECHO OFF
c:\Wincupl\shared\cupl -m1lxfjae -u C:\Wincupl\Shared\cupl.dl g22v10 V8.PLD
DEL V8_G22V10.JED
REN V8.JED V8_G22V10.JED
c:\Wincupl\shared\cupl -m1lxfjae -u C:\Wincupl\Shared\cupl.dl p22v10 V8.PLD
DEL V8_P22V10.JED
REN V8.JED V8_P22V10.JED
DEL *.mx
DEL *.sim
DEL *.lst
DEL *.abs
DEL *.doc