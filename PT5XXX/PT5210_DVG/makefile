
# Makefile for PT5210 project
# HT C compiler manual: c:\ht-xa\doc\xaman.pdf
# The crucial option for XAC is -Zg9, without it
# RAM check routine results if FAILURE, with it
# it reports OK.

SMALL=1

!if$(SMALL)
CFLAGS = -q -O -C -BL -Zg9 -DSMALL_MEM -Ept5210.err
!else
CFLAGS = -q -C -BL -O -E+pt5210.err
!endif

LFLAGS = 
AFLAGS =

CC = c:\ht-xa\bin\xac
LN = c:\ht-xa\bin\hlink
OH = c:\ht-xa\bin\objtohex

LIBS  = 
START = 

.c.obj:
      $(CC) $(CFLAGS) $&.c

OBJECTS = mas.obj menu.obj menutree.obj menuhlp.obj message.obj \
          util.obj text.obj tables.obj factory.obj timing.obj rs232cmd.obj \
          rs232err.obj rs232par.obj cont_drv.obj disp_drv.obj keyb_drv.obj \
          unit_drv.obj iniic.obj piic1.obj piic2.obj serial1.obj xadrivr.obj \
          xaintfc.obj

pt5210.bin: pt5210.hex
  hex2bin pt5210.hex
  dksum pt5210.bin

pt5210.hex: $(OBJECTS)

!if$(SMALL)
  $(LN) @link_sma
!else
  $(LN) @link_lar
!endif
  $(OH) -I C:.\l.obj pt5210.hex

mas.obj:      MAS.C
menu.obj:     MENU.C
menutree.obj: MENUTREE.C
menuhlp.obj:  MENUHLP.C
message.obj:  MESSAGE.C
util.obj:     UTIL.C
text.obj:     TEXT.C
tables.obj:   TABLES.C
factory.obj:  FACTORY.C
timing.obj:   TIMING.C
rs232cmd.obj: RS232CMD.C
rs232err.obj: RS232ERR.C
rs232par.obj: RS232PAR.C
cont_drv.obj: CONT_DRV.C
disp_drv.obj: DISP_DRV.C
keyb_drv.obj: KEYB_DRV.C
unit_drv.obj: UNIT_DRV.C
iniic.obj:    INIIC.C
piic1.obj:    PIIC1.C
piic2.obj:    PIIC2.C
serial1.obj:  SERIAL1.C
xadrivr.obj:  XADRIVR.C
xaintfc.obj:  XAINTFC.C

clean:
    del *.obj
    del *.hex
    del *.err
    del *.map
    del *.sym