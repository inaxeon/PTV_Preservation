# PM8546

CC = c:\Keil\bin\c51
LN = c:\Keil\bin\bl51
OH = c:\Keil\bin\oh51

PROJECT = logogen
CFLAGS =
LIBS  = 
START = 

.c.obj:
	$(CC) $(CFLAGS) $&.c

OBJECTS = main.obj logogen.obj cmd.obj rs232.obj i2c.obj config.obj edit.obj clock.obj

$(PROJECT).hex: $(OBJECTS)
	echo $(OBJECTS: =,) > tmp.rsp
	echo TO $(PROJECT) RAMSIZE(128) PL(68) PW(78) CODE(80h) XDATA(8000h) DISABLEWARNING(16) >> tmp.rsp
	$(LN) @tmp.rsp 
	$(OH) $(PROJECT) HEXFILE($<)

clean:
	del $(PROJECT)
    del *.obj
    del *.hex
    del *.lst
    del *.rsp
	del *.m51