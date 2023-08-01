$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG52.INC)		;Include the predefined 8052 register set
$INCLUDE( MACROS.INC)		;Include user defined macros

;************************************************************************
;* Copyright PHILIPS TV TEST EQUIPMENT A/S, BRONDBY 1997		*
;* Project: PT8601 Analog Test Signal generator				*
;* Module:  ANLCMD.A51							*
;* Author:  Kim Engedahl, DEV						*
;* Org.  :  970101							*
;* Rev.  :  990308, KEn DEV						*
;* Status:  Version 1.2							*
;* 									*
;* Changes:								*
;* 990308 Renamed some variables					*
;* 980928 Added command: AT, ReadHWInformationCommand			*
;* 970703 In CalculateOffset: 6 lines has been chosen for both NTSC&PAL	*
;*	   to correct the 1 line displacement problem.			*
;* 970625 DACLevel & Offset no longer different in G- & M-system	*
;************************************************************************

NAME		ANLCMD

EXTRN CODE( ?C?ULDIV)

EXTRN CODE( Write_DAC, Read_EEPROM, Write_EEPROM)
EXTRN CODE( WriteString, WriteLong, WriteChar)
EXTRN CODE( WriteInteger, WriteEndOfTx)
EXTRN CODE( TextTable)

EXTRN CODE( GenericMSBPort)
EXTRN CODE( SCFreqLSBPort, SCFreqMSBPort)

EXTRN DATA( PatternType, MyAddress)
EXTRN BIT( NewPattern)

EXTRN DATA( Parameter, String, TmpBuffer, OSDText)

EXTRN DATA( GenlockOffset, UserOffset)
EXTRN DATA( OffsetCal, LineOffset, CoarseOffset, FineOffset)
EXTRN DATA( UserScHOffset, ScHOffset, ScHPhaseCal)
EXTRN DATA( DACLevel, DACOffset)

EXTRN DATA( TxChkSum, CmdDelimiter)

EXTRN DATA( ErrorStatus)

EXTRN BIT( Status_SYSSEL, Status_S0)
EXTRN BIT( Illegal_Del, Illegal_Cmd, Illegal_Par, IIC_CheckSum)
EXTRN BIT( TextPos, TextEnable, TmpBit)
EXTRN BIT( CoarseGTMax)
EXTRN BIT( PALSystem, NTSCSystem, HWRunning)

PUBLIC Command_Table, CalculateOffset, GOffsetReset, PT_HWType

;************************************************************************
DACOffsetREG	EQU	0	;DAC internal address
DACLevelREG	EQU	1	; do.

PT_HWType	EQU	000H	;1 IIC EEPROM addresses
PT_HWVersion	EQU	001H	;1
;Not used	EQU	002H	;1

IIC_G_Address	EQU	003H	;4+1
IIC_G_SchPhase	EQU	008H	;2+1

IIC_M_Address	EQU	00BH	;4+1
IIC_M_SchPhase	EQU	010H	;2+1

IIC_DAC_Level	EQU	013H	;1+1
IIC_DAC_Offset	EQU	015H	;1+1

IIC_UserTxt	EQU	020H	;Occupies 100 bytes

;************************************************************************
Application_Code	SEGMENT	CODE
			RSEG	Application_Code
			USING	0

;************************************************************************
;* Name:	DivBy32
;* Function:	
;* Revision:	1.0
;* Date:	970627, KEn
;* Input:	TmpBuffer:TmpBuffer+1
;* Output:	TmpBuffer:TmpBuffer+1 = (TmpBuffer:TmpBuffer+1)/32
;* Destroys:	A, C & R0
;* Calls	-
;* Time:	-
;************************************************************************
DivBy32:
	MOV	R0, #05
DivBy32Loop:
	CLR	C
	MOV	A, TmpBuffer
	RRC	A
	MOV	TmpBuffer, A

	MOV	A, TmpBuffer+1
	RRC	A
	MOV	TmpBuffer+1, A
	DJNZ	R0, DivBy32Loop
	RET

;************************************************************************
;* Name:	MulBy32
;* Function:	
;* Revision:	1.0
;* Date:	970627, KEn
;* Input:	TmpBuffer:TmpBuffer+1
;* Output:	TmpBuffer:TmpBuffer+1 = (TmpBuffer:TmpBuffer+1)/32
;* Destroys:	A, C & R0
;* Calls	-
;* Time:	-
;************************************************************************
MulBy32:
	MOV	R0, #05
MulBy32Loop:
	CLR	C
	MOV	A, TmpBuffer+1
	RLC	A
	MOV	TmpBuffer+1, A

	MOV	A, TmpBuffer
	RLC	A
	MOV	TmpBuffer, A
	DJNZ	R0, MulBy32Loop
	RET

;************************************************************************
;* Name:	LoadDACSystem
;* Function:	
;* Revision:	1.0
;* Date:	970625, KEn
;* Input:	
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	-
;************************************************************************
LoadDACSystem:

	MOV	A, #IIC_DAC_Level	;Get DAC-Level and DAC-Offset
	MOV	R2, #04
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	MOV	DACLevel, TmpBuffer
	MOV	DACOffset, TmpBuffer+2

	MOV	A, #DACLevelREG
	MOV	R1, DACLevel
	LCALL	Write_DAC

	MOV	A, #DACOffsetREG
	MOV	R1, DACOffset
	LCALL	Write_DAC

	CLR	C
	MOV	A, DACLevel
	SUBB	A, TmpBuffer+1

	ADD	A, DACOffset
	SUBB	A, TmpBuffer+3
	JZ	EndLoadDACSystem
	SETB	IIC_CheckSum

EndLoadDACSystem:
	RET

;************************************************************************
;* Name:	CopyTextRAM
;* Function:	Write content of OSDText to screen RAM
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	TextTable
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	-
;************************************************************************
CopyTextRAM:
	MOV	C, TextEnable
	MOV	TmpBit, C
	CLR	TextEnable		;Disable TEXT while loading RAM

	JB	Status_S0, $		;Wait for text bit to clear

	MOV	DPTR, #0E0D0H		;Clear 26 bytes of TEXT RAM
	MOV	R0, #026
	CLR	A
ResetTextLoop:
	MOVX	@DPTR, A
	INC	DPTR
	DJNZ	R0, ResetTextLoop

	MOV	DPTR, #0E0D0H		;Start of text RAM
	MOV	A, #094
	MOVX	@DPTR, A		;Write half a space to RAM

	MOV	DPTR, #0E0D1H		;Start of text RAM
	MOV	R0, #8
	MOV	R1, #OSDText

WriteText:
	PUSH	DPH
	PUSH	DPL

	CLR	C
	MOV	A, @R1
	SUBB	A, #020H
	RL	A
	MOV	B, A			;Table entry
	MOV	DPTR, #TextTable

	MOVC	A, @A+DPTR
	MOV	R2, A			;Get no of samples

	MOV	A, B
	INC	DPTR
	MOVC	A, @A+DPTR		;Get address of 1st character

	POP	DPL
	POP	DPH

NextSample:
	MOVX	@DPTR, A		;Write character address to text RAM
	INC	A
	INC	DPTR
	DJNZ	R2, NextSample

	INC	R1
	DJNZ	R0, WriteText

	MOV	C, TmpBit
	MOV	TextEnable, C
	RET

;************************************************************************
;* Name:	Command_Table
;* Function:	Command lookup table
;* Revision:	1.1
;* Date:	980928, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	-
;************************************************************************
Command_Table:
	LJMP	DummyCommand		;Command number 0 is
					; reserved as no-command

	DB	'AA'			;Command number 1 spelling etc.
	LJMP	UnitAddressCommand	;   -      -    1 Execute-address

	DB	'AG'			;Command number 2 spelling
	LJMP	GOffsetCommand		;Command number 2 Execute-address

	DB	'AK'			;   -      -    3 spelling etc.
	LJMP	G7OffsetCommand		;Command number 3 Execute-address

	DB	'AM'			;   -      -    3 spelling etc.
	LJMP	MOffsetCommand		;Command number 3 Execute-address

	DB	'AL'			;   -      -    3 spelling etc.
	LJMP	M1OffsetCommand		;Command number 3 Execute-address

	DB	'AQ'			;   -      -    4 spelling etc.
	LJMP	ReadSystemCommand	;Command number 4 Execute-address

	DB	'AB'			;   -      -    5 SPELLING ETC.
	LJMP	ReadOffsetCommand	;Command number 5 Execute-address

	DB	'AO'			;   -      -    6 spelling etc.
	LJMP	GenlockOffsetCommand	;Command number 6 Execute-address

	DB	'AH'			;   -      -    8 spelling etc.
	LJMP	ScHPhaseCommand		;Command number 8 Execute-address

	DB	'AP'			;   -      -    7 spelling etc.
	LJMP	PatternCommand		;Command number 7 Execute-address

	DB	'AF'			;   -      -    11 spelling etc.
	LJMP	TextONCommand		;Command number 11 Execute-address

	DB	'AN'			;   -      -    12 spelling etc.
	LJMP	TextCommand		;Command number 12 Execute-address

	DB	'AS'			;   -      -    13 spelling etc.
	LJMP	ReadStatusCommand	;Command number 13 Execute-address

	DB	'AX'			;   -      -    14 spelling etc.
	LJMP	GPhaseCommand		;Command number 14 Execute-address

	DB	'AY'			;   -      -    15 spelling etc.
	LJMP	MPhaseCommand		;Command number 15 Execute-address

	DB	'AD'			;   -      -    9 spelling etc.
	LJMP	DACLevelCommand		;Command number 9 Execute-address

	DB	'AC'			;   -      -    10 spelling etc.
	LJMP	DACOffsetCommand	;Command number 10 Execute-address

	DB	'AZ'			;   -      -    16 spelling etc.
	LJMP	ResetCommand		;Command number 16 Execute-address

	DB	'AW'			;   -      -    17 spelling etc.
	LJMP	WriteUserTextCommand	;Command number 17 Execute-address

	DB	'AR'			;   -      -    18 spelling etc.
	LJMP	ReadUserTextCommand	;Command number 18 Execute-address

	DB	'AV'			;   -      -    19 spelling etc.
	LJMP	ReadHWVersionCommand	;   -      -    19 Execute-address

	DB	'AT'			;Command number 20 spelling etc.
	LJMP	ReadHWInformationCommand;Command number 20 Execute-address

	DB	'AI'			;   -      -    21 spelling etc.
	LJMP	ReadSWVersionCommand	;   -      -    21 Execute-address

CommandTableEnd:
	DB	0			;End indicator
DummyCommand:
	RET

;************************************************************************
;* Name:	UnitAddressCommand
;* Function:	Write new address to the unit
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteChar, WriteEndOfTx
;* Time:	-
;************************************************************************
UnitAddressCommand:
	JNB	HWRunning, UnitAddressEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', UnitAddressRequest

	MOV	R0, #Parameter+3	
	MOV	A, @R0
	MOV	MyAddress, A		
	ORL	A, #40H			;( MyAddress+64) MUST be returned

	LJMP	WriteChar

UnitAddressRequest:
	CJNE	A, #'?', UnitAddressError

	CLR	A
	MOV	R6, A
	MOV	R7, MyAddress
		
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

UnitAddressError:
	SETB	Illegal_Del
UnitAddressEnd:
	RET

;************************************************************************
;* Name:	GOffsetCommand
;* Function:	Select SDI625 system with specific line- and phase-offset
;* Revision:	1.0
;* Date:	970627, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, CalculateOffset
;* Time:	-
;************************************************************************
GOffsetCommand:
	JNB	HWRunning, GOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', GOffsetError
	CLR	PALSystem
	LJMP	GOffsetCommon

G7OffsetCommand:
	JNB	HWRunning, GOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', GOffsetError
	SETB	PALSystem

GOffsetCommon:
	MOV	R0, #Parameter		;Save Unit Offset
	MOV	Useroffset, @R0
	INC	R0
	MOV	Useroffset+1, @R0
	INC	R0
	MOV	Useroffset+2, @R0
	INC	R0
	MOV	Useroffset+3, @R0

	JB	Status_SYSSEL, GOffsetReset
	LJMP	CalculateOffset		;Calculate new offset

GOffsetError:
	SETB	Illegal_Del
GOffsetEnd:
	RET
		
GOffsetReset:				;System has changed
	CLR	Status_SYSSEL		;Select G system

	MOV	A, #IIC_G_Address	;Get Calibration Offset for G
	MOV	R2, #05
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	MOV	OffsetCal, TmpBuffer
	MOV	OffsetCal+1, TmpBuffer+1
	MOV	OffsetCal+2, TmpBuffer+2
	MOV	OffsetCal+3, TmpBuffer+3

	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1
	ADD	A, TmpBuffer+2
	ADD	A, TmpBuffer+3

	CLR	C
	SUBB	A, TmpBuffer+4
	JZ	GetGScHPhaseCal
	SETB	IIC_CheckSum

GetGScHPhaseCal:
	MOV	A, #IIC_G_ScHPhase	;Get ScHPhase Calibration for G
	MOV	R2, #03
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	MOV	A, TmpBuffer+1		;Add ScHOffset and ScHPhaseCal
	MOV	ScHPhaseCal+1, A
	ADD	A, UserScHOffset+1
	MOV	ScHOffset+1, A

	MOV	A, TmpBuffer
	MOV	ScHPhaseCal, A
	ADDC	A, UserScHOffset
	MOV	ScHOffset, A

	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1

	CLR	C
	SUBB	A, TmpBuffer+2
	JZ	LoadDACGSystem
	SETB	IIC_CheckSum

LoadDACGSystem:
	LCALL	LoadDACSystem		;Reload DAC registers

	CLR	EA			;Temporarily disable interrupt

	MOV	A, #015H		;Initialize subcarrier NCO to PAL-G
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	MOV	A, #096H
	MOV	DPTR, #SCFreqLSBPort
	MOVX	@DPTR, A

	MOV	A, #054H
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	MOV	A, #013H
	MOV	DPTR, #SCFreqMSBPort
	MOVX	@DPTR, A

	CLR	A
	MOV	DPTR, #GenericMSBPort	;This port MUST contain 0 at ALL time
	MOVX	@DPTR, A

	SETB	EA			;Enable interrupt

	LJMP	CalculateOffset		;Calculate new offset

;************************************************************************
;* Name:	MOffsetCommand
;* Function:	Select SDI525 system with specific line- and phase-offset
;* Revision:	1.0
;* Date:	960630, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, CalculateOffset
;* Time:	-
;************************************************************************
MOffsetCommand:
	JNB	HWRunning, MOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', MOffsetError
	CLR	NTSCSystem
	LJMP	MOffsetCommon

M1OffsetCommand:
	JNB	HWRunning, MOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', MOffsetError
	SETB	NTSCSystem

MOffsetCommon:
	MOV	R0, #Parameter		;Save Unit Offset
	MOV	Useroffset, @R0
	INC	R0
	MOV	Useroffset+1, @R0
	INC	R0
	MOV	Useroffset+2, @R0
	INC	R0
	MOV	Useroffset+3, @R0

	JNB	Status_SYSSEL, MOffsetReset
	LJMP	CalculateOffset		;Calculate new offset

MOffsetError:
	SETB	Illegal_Del
MOffsetEnd:
	RET

MOffsetReset:				;System has changed
	SETB	Status_SYSSEL		;Select M system

	MOV	A, #IIC_M_Address	;Get Calibration Offset for M
	MOV	R2, #05
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	MOV	OffsetCal, TmpBuffer
	MOV	OffsetCal+1, TmpBuffer+1
	MOV	OffsetCal+2, TmpBuffer+2
	MOV	OffsetCal+3, TmpBuffer+3

	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1
	ADD	A, TmpBuffer+2
	ADD	A, TmpBuffer+3

	CLR	C
	SUBB	A, TmpBuffer+4
	JZ	GetMScHPhaseCal
	SETB	IIC_CheckSum

GetMScHPhaseCal:
	MOV	A, #IIC_M_ScHPhase	;Get ScHPhase Calibration for M
	MOV	R2, #03
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	MOV	A, TmpBuffer+1		;Add ScHOffset and ScHPhaseCal
	MOV	ScHPhaseCal+1, A
	ADD	A, UserScHOffset+1
	MOV	ScHOffset+1, A

	MOV	A, TmpBuffer
	MOV	ScHPhaseCal, A
	ADDC	A, UserScHOffset
	MOV	ScHOffset, A

	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1

	CLR	C
	SUBB	A, TmpBuffer+2
	JZ	LoadDACMSystem
	SETB	IIC_CheckSum

LoadDACMSystem:
	LCALL	LoadDACSystem		;Reload DAC registers

	CLR	EA			;Temporarily disable interrupt

	MOV	A, #0F8H		;Initialise subcarrier NCO to PAL-G
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	MOV	A, #03EH
	MOV	DPTR, #SCFreqLSBPort
	MOVX	@DPTR, A

	MOV	A, #043H
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	MOV	A, #0E0H
	MOV	DPTR, #SCFreqMSBPort
	MOVX	@DPTR, A

	CLR	A			;This port MUST contain 0 at ALL time
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	SETB	EA			;Enable interrupt
	LJMP	CalculateOffset		;Calculate new offset

;************************************************************************
;* Name:	ReadSystemCommand
;* Function:	Write system information to RS232
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadSystemCommand:
	JNB	HWRunning, ReadSystemEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', ReadSystemError

	CLR	A
	MOV	R6, A

	MOV	TxChkSum, A		;Reset checksum to be transmitted

	JB	Status_SYSSEL, ReadSystemM
ReadSystemG:
	MOV	C, PALSystem
	LJMP	ReadSystemCont	

ReadSystemM:
	MOV	A, #02
	MOV	C, NTSCSystem

ReadSystemCont:				;0: PAL-G, 1: PAL-G w/PAL-ID
	ADDC	A, #0			;2: NTSC, 3: NTSC without piedestal
	MOV	R7, A

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

ReadSystemError:
	SETB	Illegal_Del
ReadSystemEnd:
	RET

;************************************************************************
;* Name:	ReadOffsetCommand
;* Function:	Write user offset to RS232
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteLong, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadOffsetCommand:
	JNB	HWRunning, ReadOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', ReadOffsetError

	MOV	R4, UserOffset
	MOV	R5, UserOffset+1
	MOV	R6, UserOffset+2
	MOV	R7, UserOffset+3

	MOV	TxChkSum, #0		;Reset checksum to be transmitted

	LCALL	WriteLong
	LJMP	WriteEndOfTx

ReadOffsetError:
	SETB	Illegal_Del
ReadOffsetEnd:
	RET

;************************************************************************
;* Name:	GenlockOffsetCommand
;* Function:	Read/write genlock offset to Generator/RS232
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	CalculateOffset, WriteLong, WriteEndOfTx
;* Time:	-
;************************************************************************
GenlockOffsetCommand:
	JNB	HWRunning, GenlockOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', GenlockOffsetRequest

	MOV	R0, #Parameter		;Save Genlock Offset
	MOV	GenlockOffset, @R0
	INC	R0
	MOV	GenlockOffset+1, @R0
	INC	R0
	MOV	GenlockOffset+2, @R0
	INC	R0
	MOV	GenlockOffset+3, @R0
		
	LJMP	CalculateOffset		;Calculate new offset

GenlockOffsetRequest:
	CJNE	A, #'?', GenlockOffsetError

	MOV	R4, GenlockOffset
	MOV	R5, GenlockOffset+1
	MOV	R6, GenlockOffset+2
	MOV	R7, GenlockOffset+3

	MOV	TxChkSum, #0		;Reset checksum to be transmitted

	LCALL	WriteLong
	LJMP	WriteEndOfTx

GenlockOffsetError:
	SETB	Illegal_Del
GenlockOffsetEnd:
	RET

;************************************************************************
;* Name:	PattternCommand
;* Function:	Set/read pattern in/from generator.
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
PatternCommand:
	JNB	HWRunning, PatternEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', PatternRequest

	MOV	R0, #Parameter+3
	MOV	A, @R0
	MOV	B, #03
	MUL	AB
	MOV	PatternType, A		;Save new pattern information

	SETB	NewPattern		;Notisfy system about new pattern
	RET

PatternRequest:
	CJNE	A, #'?', PatternError

	MOV	A, PatternType
	MOV	B, #03
	DIV	AB

	MOV	R7, A

	CLR	A
	MOV	R6, A
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

PatternError:
	SETB	Illegal_Del
PatternEnd:
	RET
	
;************************************************************************
;* Name:	ScHPhaseCommand
;* Function:	Set/read ScH-Phase in/from generator.
;* Revision:	1.0
;* Date:	970627, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
ScHPhaseCommand:
	JNB	HWRunning, ScHPhaseEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', ScHPhaseRequest
					; 0 <= ScHPhase < 2048
	MOV	R0, #Parameter+2	;Save ScHPhase
	MOV	TmpBuffer, @R0
	INC	R0
	MOV	TmpBuffer+1, @R0

	LCALL	MulBy32

	MOV	A, TmpBuffer+1		;Add ScHOffset and ScHPhaseCal
	MOV	UserScHOffset+1, A
	ADD	A, ScHPhaseCal+1
	MOV	ScHOffset+1, A

	MOV	A, TmpBuffer
	MOV	UserScHOffset, A
	ADDC	A, ScHPhaseCal
	MOV	ScHOffset, A
	RET

ScHPhaseRequest:
	CJNE	A, #'?', ScHPhaseError

	MOV	TmpBuffer, UserScHOffset
	MOV	TmpBuffer+1, UserScHOffset+1
	LCALL	DivBy32

	MOV	R6, TmpBuffer
	MOV	R7, TmpBuffer+1

	MOV	TxChkSum, #00		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

ScHPhaseError:
	SETB	Illegal_Del
ScHPhaseEnd:
	RET

;************************************************************************
;* Name:	DACLevelCommand
;* Function:	Set/read/save DAC level
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, Write_EEPROM, WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
DACLevelCommand:
	JNB	HWRunning, DACLevelEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', DACLevelRequest

	MOV	R0, #Parameter+3
	MOV	DACLevel, @R0
	
	MOV	A, #DACLevelREG
	MOV	R1, DACLevel
	LJMP	Write_DAC
		
DACLevelRequest:
	CJNE	A, #'?', DACLevelSave

	MOV	A, #IIC_DAC_Level	;Set DAC-level address
	MOV	R2, #02
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	CLR	C
	MOV	A, TmpBuffer
	SUBB	A, TmpBuffer+1

	JZ	TransmitDACLevel
	SETB	IIC_CheckSum

TransmitDACLevel:
	CLR	A
	MOV	R6, A
	MOV	R7, TmpBuffer		;Load R7 with DAC level

	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

DACLevelSave:
	CJNE	A, #'$', DACLevelError

	MOV	A, DACLevel
	MOV	TmpBuffer, A
	MOV	TmpBuffer+1, A

	MOV	A, #IIC_DAC_Level	;Set DAC-level address
	MOV	R1, #TmpBuffer
	MOV	R2, #02

	LJMP	Write_EEPROM

DACLevelError:
	SETB	Illegal_Del
DACLevelEnd:
	RET

;************************************************************************
;* Name:	DACOffsetCommand
;* Function:	Set/read/save DAC offset
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, Write_EEPROM, WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
DACOffsetCommand:
	JNB	HWRunning, DACOffsetEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', DACOffsetRequest

	MOV	R0, #Parameter+3
	MOV	DACOffset, @R0

	MOV	A, #DACOffsetREG
	MOV	R1, DACOffset
	LJMP	Write_DAC

DACOffsetRequest:
	CJNE	A, #'?', DACOffsetSave

	MOV	A, #IIC_DAC_Offset	;Set DAC-offset address
	MOV	R2, #02
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	CLR	C
	MOV	A, TmpBuffer
	SUBB	A, TmpBuffer+1

	JZ	WriteDACOffset
	SETB	IIC_CheckSum

WriteDACOffset:
	CLR	A
	MOV	R6, A
	MOV	R7, TmpBuffer		;Load R7 with DAC offset

	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

DACOffsetSave:
	CJNE	A, #'$', DACOffsetError

	MOV	A, DACOffset
	MOV	TmpBuffer, A
	MOV	TmpBuffer+1, A

	MOV	A, #IIC_DAC_Offset	;Set DAC-Offset address
	MOV	R1, #TmpBuffer
	MOV	R2, #02
	LJMP	Write_EEPROM

DACOffsetError:
	SETB	Illegal_Del
DACOffsetEnd:
	RET

;************************************************************************
;* Name:	TextONCommand
;* Function:	Enable/disable OSD text 
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
TextONCommand:
	JNB	HWRunning, TextONEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', TextONRequest

	MOV	R0, #Parameter+7
	MOV	A, @R0
	RRC	A
	MOV	TextPos, C
	
	MOV	R0, #Parameter+3
	MOV	A, @R0

	RRC	A
	MOV	TextEnable, C
	RET

TextONRequest:
	CJNE	A, #'?', TextONError

	CLR	A
	MOV	R6, A
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	MOV	C, TextEnable
	RLC	A
	MOV	R7, A

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

TextONError:
	SETB	Illegal_Del
TextONEnd:
	RET

;************************************************************************
;* Name:	TextCommand
;* Function:	Read/write user text to OSD RAM
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	CopyTextRAM, WriteString, WriteEndOfTx
;* Time:	-
;************************************************************************
TextCommand:
	JNB	HWRunning, TextEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', TextRequest

	MOV	R0, #String
	MOV	R1, #OSDtext
NextOSDChar:
	MOV	A, @R0
	MOV	@R1, A
	INC	R0
	INC	R1

	CJNE	R0, #String+8, NextOSDChar
	LJMP	CopyTextRAM

TextRequest:
	CJNE	A, #'?', TextError

	MOV	R0, #OSDText

	MOV	TxChkSum, #0		;Reset checksum to be transmitted

	LCALL	WriteString
	LJMP	WriteEndOfTx

TextError:
	SETB	Illegal_Del
TextEnd:
	RET

;************************************************************************
;* Name:	ReadStatusCommand
;* Function:	Read status and clear
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadStatusCommand:
	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', ReadStatusError

	CLR	A
	MOV	R6, A
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	MOV	R7, ErrorStatus		;Copy ErrorStatus to R7
	MOV	ErrorStatus, A		;Reset ErrorStatus

	LCALL	WriteInteger
	LJMP	WriteEndOfTx
	
ReadStatusError:
	SETB	Illegal_Del
ReadStatusEnd:
	RET

;************************************************************************
;* Name:	GPhaseCommand
;* Function:	Store/read present phase in/from G system to IIC
;* Revision:	1.0
;* Date:	970627, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, Write_EEPROM, WriteChar, WriteInteger
;*		WriteEndOfTx
;* Time:	-
;************************************************************************
GPhaseCommand:
	JNB	HWRunning, GPhaseEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', StoreGPhase

ReadGPhase:
	MOV	A, #IIC_G_Address
	MOV	R1, #TmpBuffer
	MOV	R2, #05H
	LCALL	Read_EEPROM
	
	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1
	ADD	A, TmpBuffer+2
	ADD	A, TmpBuffer+3

	CLR	C
	SUBB	A, TmpBuffer+4
	JZ	GPhaseOK
	SETB	IIC_CheckSum

GPhaseOK:
	MOV	R4, TmpBuffer
	MOV	R5, TmpBuffer+1
	MOV	R6, TmpBuffer+2
	MOV	R7, TmpBuffer+3

	MOV	TxChkSum, #0		;Reset checksum to be transmitted

	LCALL	WriteLong

	MOV	A, #','
	LCALL	WriteChar

	MOV	A, #IIC_G_ScHPhase
	MOV	R1, #TmpBuffer
	MOV	R2, #03H
	LCALL	Read_EEPROM
	
	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1

	CLR	C
	SUBB	A, TmpBuffer+2
	JZ	GScHPhaseOK
	SETB	IIC_CheckSum

GScHPhaseOK:
	LCALL	DivBy32

	MOV	R6, TmpBuffer
	MOV	R7, TmpBuffer+1

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

GPhaseEnd:
	RET

StoreGPhase:
	CJNE	A, #'$', GPhaseError

	MOV	A, UserOffset
	MOV	OffsetCal, A
	MOV	TmpBuffer, A

	MOV	A, UserOffset+1
	MOV	OffsetCal+1, A
	MOV	TmpBuffer+1, A

	MOV	A, UserOffset+2
	MOV	OffsetCal+2, A
	MOV	TmpBuffer+2, A

	MOV	A, UserOffset+3
	MOV	OffsetCal+3, A
	MOV	TmpBuffer+3, A

	ADD	A, TmpBuffer
	ADD	A, TmpBuffer+1
	ADD	A, TmpBuffer+2

	MOV	TmpBuffer+4, A

	MOV	A, #IIC_G_Address
	MOV	R1, #TmpBuffer
	MOV	R2, #05
	LCALL	Write_EEPROM

StoreGScHPhase:
	MOV	A, UserScHOffset
	MOV	TmpBuffer, A
	MOV	ScHPhaseCal, A
	MOV	ScHOffset, A

	MOV	A, UserScHOffset+1
	MOV	TmpBuffer+1, A
	MOV	ScHPhaseCal+1, A
	MOV	ScHOffset+1, A

	ADD	A, TmpBuffer

	MOV	TmpBuffer+2, A

	MOV	A, #IIC_G_ScHPhase
	MOV	R1, #TmpBuffer
	MOV	R2, #03
	LCALL	Write_EEPROM

	CLR	A
	MOV	UserOffset, A
	MOV	UserOffset+1, A
	MOV	UserOffset+2, A
	MOV	UserOffset+3, A

	MOV	UserScHOffset, A
	MOV	UserScHOffset+1, A

	LJMP	CalculateOffset

GPhaseError:
	SETB	Illegal_Del
	RET

;************************************************************************
;* Name:	MPhaseCommand
;* Function:	Store/read present phase in/from M system to IIC
;* Revision:	1.0
;* Date:	970627, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, Write_EEPROM, WriteChar, WriteInteger
;*		WriteEndOfTx
;* Time:	-
;************************************************************************
MPhaseCommand:
	JNB	HWRunning, MPhaseEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', StoreMPhase

ReadMPhase:
	MOV	A, #IIC_M_Address
	MOV	R1, #TmpBuffer
	MOV	R2, #05H
	LCALL	Read_EEPROM

	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1
	ADD	A, TmpBuffer+2
	ADD	A, TmpBuffer+3

	CLR	C
	SUBB	A, TmpBuffer+4
	JZ	MPhaseOK
	SETB	IIC_CheckSum

MPhaseOK:
	MOV	R4, TmpBuffer
	MOV	R5, TmpBuffer+1
	MOV	R6, TmpBuffer+2
	MOV	R7, TmpBuffer+3

	MOV	TxChkSum, #0		;Reset checksum to be transmitted

	LCALL	WriteLong

	MOV	A, #','
	LCALL	WriteChar

	MOV	A, #IIC_M_ScHPhase
	MOV	R1, #TmpBuffer
	MOV	R2, #03H
	LCALL	Read_EEPROM
	
	MOV	A, TmpBuffer
	ADD	A, TmpBuffer+1

	CLR	C
	SUBB	A, TmpBuffer+2
	JZ	MScHPhaseOK
	SETB	IIC_CheckSum

MScHPhaseOK:
	LCALL	DivBy32

	MOV	R6, TmpBuffer
	MOV	R7, TmpBuffer+1

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

MPhaseEnd:
	RET

StoreMPhase:
	CJNE	A, #'$', MPhaseError

	MOV	A, UserOffset
	MOV	OffsetCal, A
	MOV	TmpBuffer, A

	MOV	A, UserOffset+1
	MOV	OffsetCal+1, A
	MOV	TmpBuffer+1, A

	MOV	A, UserOffset+2
	MOV	OffsetCal+2, A
	MOV	TmpBuffer+2, A

	MOV	A, UserOffset+3
	MOV	OffsetCal+3, A
	MOV	TmpBuffer+3, A

	ADD	A, TmpBuffer
	ADD	A, TmpBuffer+1
	ADD	A, TmpBuffer+2

	MOV	TmpBuffer+4, A

	MOV	A, #IIC_M_Address
	MOV	R1, #TmpBuffer
	MOV	R2, #05
	LCALL	Write_EEPROM

StoreMScHPhase:
	MOV	A, UserScHOffset
	MOV	TmpBuffer, A
	MOV	ScHPhaseCal, A
	MOV	ScHOffset, A

	MOV	A, UserScHOffset+1
	MOV	TmpBuffer+1, A
	MOV	ScHPhaseCal+1, A
	MOV	ScHOffset+1, A

	ADD	A, TmpBuffer

	MOV	TmpBuffer+2, A

	MOV	A, #IIC_M_ScHPhase
	MOV	R1, #TmpBuffer
	MOV	R2, #03
	LCALL	Write_EEPROM

	CLR	A
	MOV	UserOffset, A
	MOV	UserOffset+1, A
	MOV	UserOffset+2, A
	MOV	UserOffset+3, A

	MOV	UserScHOffset, A
	MOV	UserScHOffset+1, A

	LJMP	CalculateOffset

MPhaseError:
	SETB	Illegal_Del
	RET

;************************************************************************
;* Name:	ResetCommand
;* Function:	Reset ALL offsets and EEPROM
;* Revision:	1.2
;* Date:	990308, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Write_EEPROM, CalculateOffset
;* Time:	-
;************************************************************************
ResetError:
	SETB	Illegal_Del
ResetEnd:
	RET

ResetCommand:
	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', ResetError

	SETB	HWRunning

	CLR	A
	MOV	OffsetCal+3, A
	MOV	OffsetCal+2, A
	MOV	OffsetCal+1, A
	MOV	OffsetCal, A

	MOV	GenlockOffset+3, A
	MOV	GenlockOffset+2, A
	MOV	GenlockOffset+1, A
	MOV	GenlockOffset, A

	MOV	UserOffset+3, A
	MOV	UserOffset+2, A
	MOV	UserOffset+1, A
	MOV	UserOffset, A

	MOV	ScHOffset+1, A
	MOV	ScHOffset, A

	MOV	ScHPhaseCal+1, A
	MOV	ScHPhaseCal, A

	MOV	UserScHOffset+1, A
	MOV	UserScHOffset, A

	MOV	A, #128			;Preset DAC-offset & DAC-level to 128
	MOV	DACLevel, A
	MOV	DACOffset, A

	MOV	A, #DACLevelREG
	MOV	R1, DACLevel
	LCALL	Write_DAC

	MOV	A, #DACOffsetREG
	MOV	R1, DACOffset
	LCALL	Write_DAC

	CLR	A
	MOV	R0, #TmpBuffer
ResetLoopA:
	MOV	@R0, A
	INC	R0
	CJNE	R0, #TmpBuffer+11, ResetLoopA

	MOV	A, #IIC_G_Address	;Clear OffsetCal, ScHPhase, DAC-offset,
	MOV	R1, #TmpBuffer		; & DAC-level in M
	MOV	R2, #08
	LCALL	Write_EEPROM

	MOV	A, #IIC_M_Address	;Clear OffsetCal, ScHPhase, DAC-offset,
	MOV	R1, #TmpBuffer		; & DAC-level in M
	MOV	R2, #08
	LCALL	Write_EEPROM

	MOV	A, #IIC_UserTxt
ResetLoopB:
	MOV	R1, #TmpBuffer
	MOV	R2, #00BH
	PUSH	ACC
	LCALL	Write_EEPROM

	MOV	A, #128			;Preset DAC-offset & DAC-level to 128
	MOV	TmpBuffer, A
	MOV	TmpBuffer+1, A
	MOV	TmpBuffer+2, A
	MOV	TmpBuffer+3, A

	MOV	A, #IIC_DAC_Level	;Clear DAC-offset & DAC-level
	MOV	R1, #TmpBuffer
	MOV	R2, #04
	LCALL	Write_EEPROM

	POP	ACC
	ADD	A, #00BH
	CJNE	A, #(IIC_UserTxt+10*11), ResetLoopB

	MOV	TmpBuffer, #HWType
	MOV	TmpBuffer+1, #HWVersion

	MOV	A, #PT_HWType		;Write Generator information
	MOV	R1, #TmpBuffer
	MOV	R2, #02
	LCALL	Write_EEPROM

	LJMP	CalculateOffset

;************************************************************************
;* Name:	WriteUserTextCommand
;* Function:	Write 10 bytes of user text in IIC area n, (n: 0-9)
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Write_EEPROM
;* Time:	-
;************************************************************************
WriteUserTextCommand:
	JNB	HWRunning, WriteUserTextEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #';', WriteUserTextError

	MOV	R0, #String		;Calculate checksum
	MOV	A, @R0
	INC	R0
WriteChecksum:
	ADD	A, @R0
	INC	R0
	CJNE	R0, #String+10, WriteChecksum

	MOV	@R0, A			;Insert checksum at String+10

	MOV	R0, #Parameter+3
	MOV	A, @R0
	MOV	B, #0BH
	MUL	AB
	ADD	A, #IIC_UserTxt

	MOV	R1, #String
	MOV	R2, #00BH
	LJMP	Write_EEPROM		;Write 10 bytes + checksum

WriteUserTextError:
	SETB	Illegal_Del
WriteUserTextEnd:
	RET

;************************************************************************
;* Name:	ReadUserTextCommand
;* Function:	Read m, (<11), bytes of user text from IIC area n, (n: 0-9)
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	Read_EEPROM, WriteString, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadUserTextCommand:
	JNB	HWRunning, ReadUserTextEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', ReadUserTextError

	MOV	R0, #Parameter+3
	MOV	A, @R0
	MOV	B, #00BH
	MUL	AB
	ADD	A, #IIC_UserTxt

	MOV	R1, #TmpBuffer
	MOV	R2, #00BH
	LCALL	Read_EEPROM		;Read 10 bytes + checksum

	MOV	R0, #TmpBuffer+1	;Calculate checksum
	MOV	A, TmpBuffer
ReadChecksum:
	ADD	A, @R0
	INC	R0
	CJNE	R0, #TmpBuffer+10, ReadChecksum

	CLR	C			;Compare calculated checksum with
	SUBB	A, TmpBuffer+10		; the checksum read
	JZ	ReadChecksumOK		;If different checksum..
	SETB	IIC_CheckSum		; raise error flag

ReadChecksumOK:
	MOV	TmpBuffer+10, #0	;Insert END-OF-STRING

	MOV	R0, #TmpBuffer
	MOV	TxChkSum, #0		;Reset checksum to be transmitted

	LCALL	WriteString
	LJMP	WriteEndOfTx

ReadUserTextError:
	SETB	Illegal_Del
ReadUserTextEnd:
	RET

;************************************************************************
;* Name:	ReadHWVersionCommand
;* Function:	Return hardware version for the software
;* Revision:	1.0
;* Date:	990318, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadHWVersionCommand:
	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', ReadHWVersionError

	MOV	R6, #HWVersion
	MOV	R7, #HWType

	CLR	A
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

ReadHWVersionError:
	SETB	Illegal_Del
ReadHWVersionEnd:
	RET

;************************************************************************
;* Name:	ReadHWInformationCommand
;* Function:	Return hardware information
;* Revision:	1.0
;* Date:	980928, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadHWInformationCommand:

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', ?RHWIError

	MOV	R7, #HWInformation

	CLR	A
	MOV	R6, A
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

?RHWIError:
	SETB	Illegal_Del
?RHWIEnd:
	RET

;************************************************************************
;* Name:	ReadSWVersionCommand
;* Function:	Return software version for the software
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	WriteInteger, WriteEndOfTx
;* Time:	-
;************************************************************************
ReadSWVersionCommand:
	JNB	HWRunning, ReadSWVersionEnd

	MOV	R0, #CmdDelimiter
	MOV	A, @R0
	CJNE	A, #'?', SWVersionDummy

	MOV	R7, #SWVersion

	CLR	A
	MOV	R6, A
	MOV	TxChkSum, A		;Reset checksum to be transmitted

	LCALL	WriteInteger
	LJMP	WriteEndOfTx

SWVersionDummy:
	CJNE	A, #';', ReadSWVersionError
	RET

ReadSWVersionError:
	SETB	Illegal_Del
ReadSWVersionEnd:
	RET

;************************************************************************
;* Name:	CalculateOffset
;* Function:	Calculate line- and phase-offset
;* Revision:	1.1
;* Date:	970703 KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	?C?ULDIV
;* Time:	-
;************************************************************************
JTCalculateOffset:
	LJMP	CalculateOffsetM

CalculateOffset:
	JB	Status_SYSSEL, JTCalculateOffset

CalculateOffsetG:
	MOV	A, GenlockOffset+3	;Add GenlockOffset and OffsetCal
	ADD	A, OffsetCal+3
	MOV	R7, A
	MOV	A, GenlockOffset+2
	ADDC	A, OffsetCal+2
	MOV	R6, A
	MOV	A, GenlockOffset+1
	ADDC	A, OffsetCal+1
	MOV	R5, A
	MOV	A, GenlockOffset
	ADDC	A, OffsetCal
	MOV	R4, A			;RH = GenlockOffset + OffsetCal

	JNC	AddUserOffsetG		;If overflow ..
	CLR	C			; subtract 4*625*864*512 = 4E1B0000
	MOV	A, R5
	SUBB	A, #0EBH
	MOV	R5, A
	MOV	A, R4
	SUBB	A, #041H
	MOV	R4, A

AddUserOffsetG:
	MOV	A, R7			;Add UserOffset to previous result
	ADD	A, Useroffset+3
	MOV	R7, A
	MOV	A, R6
	ADDC	A, Useroffset+2
	MOV	R6, A
	MOV	A, R5
	ADDC	A, Useroffset+1
	MOV	R5, A
	MOV	A, R4
	ADDC	A, Useroffset
	MOV	R4, A

	JNC	CalculateGCont		;If overflow
	CLR	C			; subtract 4*625*864*512 = 41EB0000
	MOV	A, R5
	SUBB	A, #0EBH
	MOV	R5, A
	MOV	A, R4
	SUBB	A, #041H
	MOV	R4, A

CalculateGCont:				;RH = UserOffset+GenlockOffset+OffsetCal
	MOV     R3, #000H		;RL = 4*625*864*512
	MOV     R2, #000H
	MOV     R1, #0EBH
	MOV     R0, #041H
	LCALL	?C?ULDIV		;RL = RH % (4*625*864*512)
					;RH = RH / (4*625*864*512)
	MOV     R7, AR3
	MOV     R6, AR2
	MOV     R5, AR1
	MOV     R4, AR0			;RH = RL = RH % (4*625*864*512)

	MOV  	R3, #000H		;RL = 864*512
	MOV  	R2, #0C0H
	MOV  	R1, #006H
	MOV  	R0, #000H
	LCALL	?C?ULDIV		;LineOffset = RH = RH / (864*512)
					;RL = RH % (864*512)

	CLR	C			;FineOffset = 442367 - FineOffset
	MOV	A, #0FFH
	SUBB	A, R3
	MOV	R3, A
	MOV	A, #0BFH
	SUBB	A, R2
	MOV	R2, A
	MOV	A, #006H
	SUBB	A, R1
	MOV	R1, A

	JMP	EndCalculateOffset


CalculateOffsetM:
	MOV	A, GenlockOffset+3	;Add GenlockOffset and OffsetCal
	ADD	A, OffsetCal+3
	MOV	R7, A
	MOV	A, GenlockOffset+2
	ADDC	A, OffsetCal+2
	MOV	R6, A
	MOV	A, GenlockOffset+1
	ADDC	A, OffsetCal+1
	MOV	R5, A
	MOV	A, GenlockOffset
	ADDC	A, OffsetCal
	MOV	R4, A			;RH = GenlockOffset + OffsetCal

	MOV	A, R7			;Add UserOffset to previsous result
	ADD	A, Useroffset+3
	MOV	R7, A
	MOV	A, R6
	ADDC	A, Useroffset+2
	MOV	R6, A
	MOV	A, R5
	ADDC	A, Useroffset+1
	MOV	R5, A
	MOV	A, R4
	ADDC	A, Useroffset
	MOV	R4, A

CalculateMCont:				;RH = UserOffset+GenlockOffset+OffsetCal
	MOV     R3, #000H		;RL = 2*525*858*512
	MOV     R2, #048H
	MOV     R1, #07EH
	MOV     R0, #01BH
	LCALL	?C?ULDIV		;RL = RH % (2*525*858*512)
					;RH = RH / (2*525*858*512)
	MOV     R7, AR3
	MOV     R6, AR2
	MOV     R5, AR1
	MOV     R4, AR0			;RH = RL = RH % (2*525*858*512)

	MOV  	R3, #000H		;RL = 858*512
	MOV  	R2, #0B4H
	MOV  	R1, #006H
	MOV  	R0, #000H
	LCALL	?C?ULDIV		;LineOffset = RH = RH / (858*512)
					;RL = RH % (858*512)

	CLR	C			;FineOffset = 439295 - FineOffset
	MOV	A, #0FFH
	SUBB	A, R3
	MOV	R3, A
	MOV	A, #0B3H
	SUBB	A, R2
	MOV	R2, A
	MOV	A, #006H
	SUBB	A, R1
	MOV	R1, A

EndCalculateOffset:
	CLR	EA			;Disable interrupts temporarily

	MOV	A, R6
	CPL	A			;LineOffset = -LineOffset
	MOV	LineOffset, A

	MOV	A, R7
	CPL	A			;LineOffset+1 = -LineOffset+1
	MOV	LineOffset+1, A
					;CoarseOffset = 10 MSB, ( of 19 bit)
	CLR	C			;CoarseOffset = (R1>>1)   (R2>>1)
	MOV	A, R1
	RRC	A
	MOV	CoarseOffset, A		;CoarseOffset
	MOV	A, R2
	RRC	A
	MOV	CoarseOffset+1, A	;CoarseOffset+1

	CLR	C			;Subtract 863-857=6 from Coarse offset
	MOV	A, CoarseOffset+1
	SUBB	A, #006H
	MOV	A, CoarseOffset
	SUBB	A, #000H
	MOV	CoarseGTMax, C		;If carry, offset >= 857

	MOV	A, R2			;FineOffset = 9 LSB, ( of 19 bit)
	RRC	A			;FineOffset = R2.0+R3
	MOV	A, R3
	RRC	A
	MOV	FineOffset, A

	CLR	A
	RRC	A
	MOV	FineOffset+1, A
					
	SETB	EA			;Enable interrupts again
	RET
END