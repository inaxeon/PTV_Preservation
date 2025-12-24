@ECHO OFF
c:\Wincupl\shared\cupl -m1lxfjae -u C:\Wincupl\Shared\cupl.dl g22v10 V28.PLD
DEL V28_G22V10.JED
REN V28.JED V28_G22V10.JED
c:\Wincupl\shared\cupl -m1lxfjae -u C:\Wincupl\Shared\cupl.dl p22v10 V28.PLD
DEL V28_P22V10.JED
REN V28.JED V28_P22V10.JED
DEL *.mx
DEL *.sim
DEL *.lst
DEL *.abs
DEL *.doc