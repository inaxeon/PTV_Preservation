@echo off

PATH=%PATH%;C:\Keil\Bin

c51 main.c

echo main.obj > tmp.rsp
echo TO pm8546 RAMSIZE(128) PL(68) PW(78) CODE(80h) XDATA(8000h)  >> tmp.rsp
bl51 @tmp.rsp

oh51 pm8546 HEXFILE(pm8546.hex)

REM ### usage: build -clean to remove intermediate files after build
if "%1" == "-clean" del tmp.rsp
if "%1" == "-clean" del *.lst
if "%1" == "-clean" del *.obj
if "%1" == "-clean" del *.m51

