$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG320.INC)		;Include the predefined 80C320 register set
$INCLUDE( MACROS.INC)		;Include user defined macros

;************************************************************************
;* Copyright PHILIPS TV TEST EQUIPMENT A/S, BRONDBY 1997		*
;* Project: PT8601 Analog Test Signal generator				*
;* 			PT8601/902 Recreation				*
;* Module:  ANLGENER.A51						*
;* Author:  Kim Engedahl, DEV						*
;			Modified by Matt Millman 			*
;* Org.  :  970101							*
;* Rev.  :  990613, KEn DEV						*
;* Status:  Version 1.4							*
;* 									*
;* Changes:								*
;* 990613: Added TextPos to choose between type A&B patterns, i.e.	*
;*	   placement in-/outside safe area				*
;* 990609: GreyScale 5/10: PAL signals was used instead of NTSC		*
;* 990308: HW protection only on HW type & 900 version			*
;* 990224: CB75RedPattG changed to EBUCBRedPattG			*
;* 980928: Releasing as SW 2.5						*
;* 980928: Added 5- & 10-step staircase in both G & M.			*
;* 960703: Releasing as SW 1.2						*
;************************************************************************

NAME		ANLGENER

EXTRN CODE( RS232Intr, RS232Init, CharHandler, TestInputBuffer)
EXTRN CODE( Reset_DAC, Read_EEPROM)

EXTRN CODE( GA1_F1L22, GA2_F1L22, GA3_F1L22, GA4_F1L22, GA5_F1L22, GA6_F1L22)
EXTRN CODE( GB1_F1L22, GB2_F1L22, GB3_F1L22, GB4_F1L22, GB5_F1L22, GB6_F1L22)
EXTRN CODE( G7_F1L22, G8_F1L22)
EXTRN CODE( CB75GreyPattG, EBUCBRedPattG, Win15PattG, Win20PattG, Win100PattG)
EXTRN CODE( CrossPattg, PLUGEPattG, SafePattG)

EXTRN CODE( MA1_F1L20, MA2_F1L20, MA3_F1L20, MA4_F1L20, MA5_F1L20, MA6_F1L20)
EXTRN CODE( MB1_F1L20, MB2_F1L20, MB3_F1L20, MB4_F1L20, MB5_F1L20, MB6_F1L20)
EXTRN CODE( CBSMPTEPattM, Win15PattM, Win20PattM, Win100PattM, CrossPattM)
EXTRN CODE( PLUGEPattM, SafePattM)

EXTRN CODE( GOffsetReset, PT_HWType)

EXTRN DATA( MyAddress)

PUBLIC	StatusPort
PUBLIC	GenericMSBPort, LineAdrPort, FinePortH, FinePortL
PUBLIC	ScHPhasePort
PUBLIC	SCFreqLSBPort, SCFreqMSBPort
PUBLIC	TextPort

PUBLIC	NewPattern, PatternType, PatternAttr, PatternPtr
PUBLIC	ComplexPtr, ComplexCnt

PUBLIC	GenlockOffset, UserOffset
PUBLIC	OffsetCal, LineOffset, CoarseOffset, FineOffset

PUBLIC	UserScHOffset, ScHOffset, ScHPhaseCal
PUBLIC	DACLevel, DACOffset

PUBLIC	Status, Status_S0, Status_SYSSEL, Status_TXT_ON, Status_TXT_0, Status_TXT_1
PUBLIC	OSDTextLN1, OSDTextLN2, TextPos, Text1Enable, Text2Enable, Tmp1Bit, Tmp2Bit, CoarseGTMax
PUBLIC	PALSystem, NTSCSystem

PUBLIC	ErrorStatus, Buffer_OV, Illegal_Del, Illegal_Cmd, Illegal_Par
PUBLIC	IIC_CheckSum, IIC_NoAck

PUBLIC	TmpBuffer, TextTable
PUBLIC	HWRunning

;************************************************************************
	CSEG	AT 00H		;00H is address for Reset vector
	LJMP	Begin

	CSEG	AT 03H		;03H is address for External Interrupt 0,
	LJMP	RelLineCntIntr

	CSEG	AT 0BH		;0BH is address for Timer 0 Overflow
	RETI

	CSEG	AT 13H		;13H is address for External Interrupt 1,
	RETI

	CSEG	AT 1BH		;1BH is address for Timer 1 Overflow
	RET

	CSEG	AT 23H		;23H is address for Serial interrupt
	LJMP	RS232Intr

;************************************************************************
?STACK	SEGMENT	IDATA		; ?STACK goes into IDATA RAM.
	RSEG	?STACK		; switch to ?STACK segment.
	DS	20		; reserve your stack space

;************************************************************************
;Bank 0 is the generel bank, NOT TO BE USED DIRECTLY
;Bank 1 is reserved for field-/line-/counter-interrupt
;Bank 2 is reserved for RS232-interrupt
;Bank 3 is used for general purpose RAM

Global_BITDATA	SEGMENT	DATA BITADDRESSABLE
		RSEG	Global_BITDATA

Status:		DS	1		;Status port and it's bit definition
Status_S0	BIT	Status.0	;S1S0: line selector for field blanking
Status_S1	BIT	Status.1	; etc.
Status_SYSSEL	BIT	Status.2	;0: PAL-G, 1: NTSC
Status_TXT_ON	BIT	Status.3	;1: In lines with text on
Status_TXT_0	BIT	Status.4	;
Status_TXT_1	BIT	Status.5	;
;No Name	BIT	Status.6	;Set to 1 in ( line 1, field1)
Status_Field1	BIT	Status.7	;Low in field 1, 1 in field 2

ErrorStatus:	DS	1		;
Buffer_OV	BIT	ErrorStatus.0	;Input buffer overrun
Illegal_Del	BIT	ErrorStatus.1	;Illegal delimiter
Illegal_Cmd	BIT	ErrorStatus.2	;Illegal command
Illegal_Par	BIT	ErrorStatus.3	;Illegal parameter
IIC_NoAck	BIT	ErrorStatus.4	;No acknowledge from IIC Circuit
IIC_CheckSum	BIT	ErrorStatus.5	;Checksum error reading from EEPROM
;Not used	BIT	ErrorStatus.6
;Noy Used	BIT	ErrorStatus.7
;************************************************************************
Global_BIT	SEGMENT	BIT
		RSEG	Global_BIT

PALSystem:	DBIT	1		;0: PAL-G  1: PAL-G with ID
NTSCSystem:	DBIT	1		;0: NTSC  1: NTSC without piedestal
NewPattern:	DBIT	1		;1: New pattern received

UpdOffsetFlag:	DBIT	1		;1: Delayed field interrupt has
					; occurred -> update line offset

Text1Enable:	DBIT	1		;1: User text ON
Text2Enable:	DBIT	1		;1: User text ON (Complex line 2)
TextPOS:		DBIT	1		;1: Text inside safearea (TYPE nB)
Tmp1Bit:		DBIT	1		;Temporary bit. Used in ANLCMD.A51
Tmp2Bit:		DBIT	1		;Temporary bit. Used in ANLCMD.A51

CoarseGTMax:	DBIT	1		;1: CoarseOffset >= Max. value

HWRunning:	DBIT	1		;

;************************************************************************
Global_DATA	SEGMENT	DATA
		RSEG	Global_DATA

PatternType:	DS	1		;User selected pattern type
PatternAttr:	DS	1		;User selected pattern attribute.

OffsetCal:	DS	4		;Calibration offset
ScHPhaseCal:	DS	2		;ScH-Phase calibration

UserOffset:	DS	4		;User offset
GenlockOffset:	DS	4		;Genlock offset
UserScHOffset:	DS	2		;User ScH-Phase offset

DACLevel:	DS	1		;ONLY used during DAC-calibration
DACOffset:	DS	1		;ONLY used during DAC-calibration

LineOffset:	DS	2		;Calculated line offset
CoarseOffset:	DS	2		;Calculated coarse offset (n*74ns)
FineOffset:	DS	2		;Calculated fine offset, (n*0.145ns)
ScHOffset:	DS	2		;Calculated ScHPhase offset

PatternPtr:	DS	2		;Pointer to pattern table, (MACROS.INC)

ComplexPtr:	DS	2		;Pointer to complex linenumber.
ComplexCnt:	DS	2		;Counter for displaing complex lines.

TmpBuffer:	DS	11		;Temporary array

					;Port references, etc.
StatusPort	EQU	08000H		;

GenericMSBPort	EQU	09000H		;ALWAYS write this port FIRST

LineAdrPort	EQU	0C000H		;Port to write new pattern address

CoarsePort	EQU	0A000H		;Port to write coarse offset < 860
					;A001 is also used

FinePortL	EQU	0B008H		;Port to write fine offset
FinePortH	EQU	0B009H		; do.

ScHPhasePort	EQU	0D006H		;Port to write ScH-Phase

SCFreqLSBPort	EQU	0D000H		;Address of 16 LSB Subcarrier frequency
SCFreqMSBPort	EQU	0D001H		;Address of 16 MSB Subcarrier frequency

NCOFreqPort	EQU	0B000H		;Address of 13.5 MHz NCO (LSB of 32bit)

TextPort	EQU	0E000H		;Address of textport  

					;Definitions for register bank 1
absR0		EQU	008H		;No. of lines with same S1S0
absR1		EQU	009H		;S1S0 pattern

absR2		EQU	00AH		;Temporary register

absR3		EQU	00BH		;LineRoutinePtr
absR4		EQU	00CH		; do. +1

absR5		EQU	00DH		;Not Used / PatternPtr
absR6		EQU	00EH		;LineType / PatternPtr+1

absR7		EQU	00FH		;Reg. to push ACC

; Extended scratchpad
OSDTextLN1		EQU	080H		; User text line 1 (11 bytes)
OSDTextLN2		EQU	OSDTextLN1+11	; User text line 2 (17 bytes)
; NO FREE MEMORY AFTER THIS. ALL USED IN RS232.A51 !!!

;************************************************************************
Global_TABLES	SEGMENT	CODE
		RSEG	Global_TABLES

;************************************************************************
;* Data arranged as:
;*       <lines>, xxxxxzyyb
;* where 
;*	 <lines> = number of lines to next update
;*	 xxxxx=linetype
;*       z=field, ( 0 in field1, 1 in field2)
;*       yy = S1S0
;************************************************************************
S1S0_M:		;Frame 1
		DB	  3,038H,   3,048H,   3,038H,  11,068H, 242,070H
		DB	  1,0FAH,   2,03CH,   1,044H,   2,04CH,   1,05CH
		DB	  2,03CH,   1,054H,  10,06CH,   1,075H, 242,0FCH
		;Frame 2
		DB	  3,038H,   3,048H,   3,038H,  11,068H, 242,070H
		DB	  1,0FAH,   2,03CH,   1,044H,   2,04CH,   1,05CH
		DB	  2,03CH,   1,054H,  10,06CH,   1,075H, 242,0FCH
		DB	  0

S1S0_G:		;Frame 1
		DB	  2,010H,   1,020H,   2,000H,   1,033H,   1,078H
		DB	 15,030H,   1,0F9H, 255,0F8H,  31,0F8H,   1,0FBH
		DB	  2,000H,   1,00CH,   2,014H,   2,004H,   1,01CH
		DB	  1,034H,   16,034H, 255,0FCH,  31,0FCH,  1,0FFH
		DB	  1,0FEH,   2,004H
		;Frame 2
		DB	  2,010H,   1,020H,   2,000H,   1,030H,  16,030H
		DB	  1,0F9H, 255,0F8H,  31,0F8H,   1,0F8H,   2,000H
		DB	  1,00CH,   2,014H,   2,004H,   1,01CH,   1,037H
		DB	 16,034H, 255,0FCH,  31,0FCH,   1,0FCH,   1,0FEH
		DB	  2,004H
		;Frame 3
		DB	  2,010H,   1,020H,   2,000H,   1,033H,  16,030H
		DB	  1,0F9H, 255,0F8H,  31,0F8H,   1,0FBH,   2,000H
		DB	  1,00CH,   2,014H,   2,004H,   1,01CH,   1,034H
		DB	 16,034H, 255,0FCH,  31,0FCH,   1,0FFH,   1,0FEH
		DB	  2,004H
		;Frame 4
		DB	  2,010H,   1,020H,   2,000H,   1,030H,  16,030H
		DB	  1,0F9H, 255,0F8H,  31,0F8H,   1,0F8H,   2,000H
		DB	  1,00CH,   2,014H,   2,004H,   1,01CH,   1,037H
		DB	 16,034H, 255,0FCH,  31,0FCH,   1,0FCH,   1,0FEH
		DB	  2,004H
		DB	  0

TextTable:    	;	(spc) !                             &
		DB	1,94, 1,93, 1,0,  1,0,  1,0,  1,0,  2,65, 1,0

		;   	                        ,     -     . 
		DB	1,0,  1,0,  1,0,  1,0,  1,92, 2,95, 1,91, 1,0

		;   	0     1     2     3     4     5     6     7
		DB	2,69, 2,71, 2,73, 2,75, 2,77, 2,79, 2,81, 2,83

		;   	8     9     :
		DB	2,85, 2,87, 2,89, 1,0,  1,0,  1,0,  1,0,  1,0

		;   	      A     B     C     D     E     F     G
		DB	1,0,  2,1,  2,3,  2,5,  2,7,  2,9,  2,11, 2,13

		;   	H     I     J     K     L     M     N     O
		DB	2,15, 1,17, 2,18, 2,20, 2,22, 3,24, 2,27, 2,29

		;   	P     Q     R     S     T     U     V     W
		DB	2,31, 2,33, 2,35, 2,37, 2,39, 2,41, 2,43, 3,45

		;   	X     Y     Z                             _
		DB	2,48, 2,50, 2,52, 1,0,  1,0,  1,0,  1,0,  2,97

;************************************************************************
;* Name:	-----
;* Function:	Main routine for the analog composite generator
;* Revision:	1.1
;* Date:	980928, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	-
;************************************************************************
D1GenerMain	SEGMENT	CODE
		RSEG	D1GenerMain
		USING	0

Begin:
	MOV	SP, #?STACK-1	

	MOV	R1, #8
ZeroLoop:			;Reset internal RAM, ie. clear 248 bytes
	MOV	@R1, A		; of internal RAM, ie. DO NOT CLEAR the first
	INC	R1		; 8 bytes.
	CJNE	R1, #0, ZeroLoop

				;Initialise the timer, counters and the serial
				; interface.
	MOV	TMOD, #055H	;Timer 0: 16 bit counter, external trigger
				;Timer 1: 16 bit counter, external trigger

	MOV	T2CON, #034H	;Timer 2: baud rate generator, 76.8 kBaud

	MOV	RCAP2L, #0FAH	;Reload value 65530, ( 0FFFAH).
	MOV	RCAP2H, #0FFH

	MOV	SCON0, #0F0H	;Serial control: Mode 3, using timer 2
				; 9-bit receive/transmit

	MOV	TCON, #055H	;Start Counter0, Counter 1 and set edge
				; triggered interrupt for the external
				; interrupt

	SETB	TR2		;Start timer 2

		    ;  TSTXTX
		    ;  2 1100
	MOV	IP, #00000001B	;Field- & line-interrupt's highest priopity
				;Field, V-pulse = X1
				;Line, H-pulse = X0
				;Delayed field = T1
				;Line-counter = T0

	LCALL	RS232Init		;Initialise RS232 buffers etc.

	MOV	MyAddress, #016H	;Analog generator is located at: 016H

	;****************************************************************
	;Initialize 13.5 MHz NCO to 040000000H. GenericMSBPort used to
	;synchronize something in the NCO.
	;NOTE! After this initialization, GenericMSBPort MUST ALWAYS
	;contain 0, ZERO, when communicating with the NCO.
	;****************************************************************
	MOV	A, #01
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	CLR	A
	MOV	DPTR, #NCOFreqPort
	MOVX	@DPTR, A

	INC	DPTR
	MOVX	@DPTR, A

	INC	DPTR
	MOVX	@DPTR, A

	MOV	A, #040H
	INC	DPTR
	MOVX	@DPTR, A

	CLR	A
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	;****************************************************************
	;Initialise subcarrier NCO to PAL-G
	;****************************************************************
	MOV	A, #015H
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

	;****************************************************************
	;Initialize GenericMSBPort
	;****************************************************************
	CLR	A
	MOV	DPTR, #GenericMSBPort
	MOVX	@DPTR, A

	;****************************************************************
	;Initialize ScHPhase, (requires GenericMSBPort = 0)
	;****************************************************************
	MOV	DPTR, #ScHPhasePort
	MOVX	@DPTR, A

	;****************************************************************
	;Initialize coarseoffset, (requires GenericMSBPort = 0)
	;****************************************************************
	MOV	DPTR, #CoarsePort
	MOVX	@DPTR, A

	CLR	CoarseGTMax
	;****************************************************************
	;Initialize fineoffset (+1 is LSB), (requires GenericMSBPort = 0)
	;****************************************************************
	CLR	A
	MOV	DPTR, #FinePortL	;NB! LSB MUST be loaded before MSB
	MOVX	@DPTR, A

	MOV	DPTR, #FinePortH
	MOVX	@DPTR, A

	;****************************************************************
	;Initialize pattern line address, (requires GenericMSBPort = 0)
	;****************************************************************
	MOV	DPTR, #LineAdrPort
	MOVX	@DPTR, A

	;****************************************************************
	;Initialize text RAM
	;****************************************************************
	SETB	Tmp1Bit

	;Set statusbit, Status_TXT_1, while resetting
	;
	;The DPRAM (V56) does not allow writes on one port while a read
	;is occuring at the same address on the other. Thus writes by
	;this process may be ignored depending on what the output logic
	;happens to be doing, leading to erratic wierd behaviour.
	;Setting this bit points it at the second 256 bytes so we can
	;clear the first 256.
	;
	; DPRAM Memory map:
	; 0x000-0x07F : Line 1 when blank (always zero'd)
	; 0x080-0x0FF : Line 1 when visible
	; 0x100-0x17F : Line 2 when blank (not used. Uses line 1 blank)
	; 0x180-0x1FF : Line 2 when visible

	SETB	Status_TXT_1 
	MOV	A, Status
	MOV	DPTR, #StatusPort
	MOVX	@DPTR, A

	MOV	DPTR, #TextPort
TextRAMReset:
	MOV	R0, #00			; Clear bytes 0-255 of TEXT RAM
	CLR	A
TextRAMLoop:
	MOVX	@DPTR, A
	INC	DPTR
	DJNZ	R0, TextRAMLoop

	;Clear statusbit, Status_TXT_1
	;This points the output logic at the first 256 bytes so we can
	;clear out the second 256.
	CLR	Status_TXT_1		
	MOV	A, Status
	MOV	DPTR, #StatusPort
	MOVX	@DPTR, A

	MOV	DPTR, #TextPort+0100H

	JBC	Tmp1Bit, TextRAMReset

	;****************************************************************
	;Initialize DAC
	;****************************************************************
	LCALL	Reset_DAC

	;****************************************************************
	;Initialize register 1, ie. interrupt variables
	;****************************************************************
	MOV	absR0, #01		;Reset S1S0 table pointer
	MOV	absR1, #61		; to G system, (ie. offset from M)

	MOV	absR3, #HIGH( GA1_F1L22)
	MOV	absR4, #LOW( GA1_F1L22)

	MOV	absR6, #LOW( BlackBurst_G)

	;****************************************************************
	;Initialize status register
	;The initial generator setup really doesn't matter as a complete
	;setup wil be received from the master immediately after power-up,
	;patterntype should be set at black burst though
	;****************************************************************
	CLR	PALSystem		;PAL-G without ID, Text OFF

	CLR	A
	MOV	Status, A
	MOV	DPTR, #StatusPort
	MOVX	@DPTR, A

	MOV	PatternType, #( 3*14)	;Blackburst

	LCALL	GOffsetReset		;Initialize offset etc

		    ;  TSTXTX
		    ;  2 1100
	MOV	IE, #10010001B		;Enable external-interrupts

	CLR	HWRunning		;Default generator status

	MOV	A, #PT_HWType		;Read hardware type, version
	MOV	R2, #02			; from EEPROM
	MOV	R1, #TmpBuffer
	LCALL	Read_EEPROM

	CLR	C			;If correct generator type..
	MOV	A, #HWType		;
	SUBB	A, TmpBuffer
	JNZ	Main

	CLR	C			;If correct 900 version number..
	MOV	A, #HWVersion	;
	SUBB	A, TmpBuffer+1
	JNZ	Main

	SETB	HWRunning		;Enable generator card

Main:
	LCALL	TestInputBuffer

	JC	NewCharReceived
	LJMP	Main

NewCharReceived:
	LCALL	CharHandler
	LJMP	Main

;************************************************************************
;* Name:	RelLineCntIntr
;* Function:	Relative Line counter interrupt code, NOT TO BE USED!!
;* Revision:	1.0
;* Date:	970603, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	?
;* Remarks:	-
;************************************************************************
RelLineCntIntrCode	SEGMENT	CODE
	RSEG	RelLineCntIntrCode
	USING	1			;SAME BANK AS DelayedFieldIntrCode

RelLineCntIntr:
	PUSH	PSW			;+2
	PUSH	DPL			;+2
	PUSH	DPH			;+2
	PUSH	DPS			;+2
	MOV	DPS, #0			;+3

	MOV	PSW, #08H		;+3 ALWAYS use register bank 1
	MOV	R7, A			;+1 Push accumulator

	JNB	IE1, TestFieldUpdIntr	;+4 If HW field interrupt..
	CLR	IE1			;+2  reset field interrupt

	MOV	TH1, LineOffset		;+3  load offset to delayed field
	MOV	TL1, LineOffset+1	;+3

TestFieldUpdIntr:
	JBC	TF1, TempFieldUpdIntr	;+4 If SW field interrupt service intr.
					;   otherwise..

	DJNZ	R0, NoS1S0Update	;+3 If time to update S1S0..

	MOV	DPTR, #S1S0_M		;+3 Load basis pointer for Table Entry

	MOV	A, R1			;+1
	MOVC	A, @A+DPTR		;+3 Get no. of lines to next S1S0 upd.

	JNZ	 StoreNoOfLines		;+3 If ( NoOfLines == 0)...
					;    table entry is out of bound
	JB	Status_SYSSEL, TFULbl1	;+4  reset table pointer to NTSC...
	MOV	A, #61			;+2  or PAL
TFULbl1:
	MOV	R1, A			;+1
	MOVC	A, @A+DPTR		;+3 Get no. of lines to next S1S0 upd.

StoreNoOfLines:
	MOV	R0, A			;+1 Save no. of lines in R0

	INC	R1			;+1 Update pointer to next table entry

	MOV	A, R1			;+1
	MOVC	A, @A+DPTR		;+3 Get linetype for next R0 lines
	MOV	R2, A			;+1 Save linetype information in R2

	INC	R1			;+1 Update pointer to next table entry

	MOV	C, ACC.2		;+2 Store field type in carry
	ANL	A, #03			;+2 Isolate S1S0
	MOV	ACC.6, C		;+2 Recall field type from carry

	ANL	Status, #0BCH		;+3 Remove S1S0 & field information
	ORL	Status, A		;+2 Update status: S1S0 & field bit

	JBC	TF0, PatternUpdate	;+4

	MOV	A, Status		;+2 Update status port with S1S0
	MOV	DPTR, #StatusPort	;+3
	MOVX	@DPTR, A		;+3

	MOV	A, R2			;+1 Linetype F8 -> 1F: DO NOT UPDATE
	SWAP	A			;+1
	RL	A			;+1
	ANL	A, #01FH		;+2 Acc. = Linetype

	CJNE	A, #01FH, FindLineType	;+4

	MOV	A, R7			;+1 Linetype = 01FH, ie. DO NOT UPDATE
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+4

TempFieldUpdIntr:
	LJMP	FieldUpdIntr		;+4 Jump to interrupt routine handler

FindLineType:
	JB	Status_SYSSEL, UpdLineType	;+4
	JB	PALSystem, UpdLineType		;+4 If system is PAL-ID..

	CJNE	A, #00FH, UpdLineType	;+4 If line 7, ie. line with PAL-ID..
	MOV	A, #BlackBurst_G	;+2  reset line to black burst
UpdLineType:
	MOV	DPTR, #LineAdrPort	;+3 NOTE: GenericMSBPort MUST contain 0
	MOVX	@DPTR, A		;+3 Write update to line port

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+4

NoS1S0Update:
	JBC	TF0, PatternUpdate	;+4
	JBC	UpdOffsetFlag, UpdOffset;+4

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+4

PatternUpdate:
	MOV	DPH, R3			;+2 Update pointer to routine
	MOV	DPL, R4			;+2

	CLR	A			;+1 
	JMP	@A+DPTR			;+3 Jump to interrupt routine

UpdOffset:				;Update lineoffset every F4/F8
	;NOTE: GenericMSBPort MUST contain 0
	;AND should ALWAYS be set to ZERO
	;before writing the FineOffset

	MOV	A, FineOffset+1		;+2
	MOV	DPTR, #FinePortL	;+3 NB! LSB MUST be loaded before MSB
	MOVX	@DPTR, A		;+3

	MOV	A, FineOffset		;+2
	MOV	DPTR, #FinePortH	;+3
	MOVX	@DPTR, A		;+3

	MOV	A, CoarseOffset		;+2
	MOV	DPTR, #GenericMSBPort	;+3
	MOVX	@DPTR, A		;+3

	MOV	A, CoarseOffset+1	;+2
	MOV	DPTR, #CoarsePort	;+3
	JNB	CoarseGTMax, LoadCoarseOffset	;+4
	INC	DPTR			;+3
LoadCoarseOffset:
	MOVX	@DPTR, A		;+3

	CLR	A			;+1 NOTE: GenericMSBPort MUST contain 0
	MOV	DPTR, #GenericMSBPort	;+3  AND should ALWAYS be set to ZERO
	MOVX	@DPTR, A		;+3  before writing the FineOffset

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+4


;************************************************************************
;* Name:	DelFieldIntr
;* Function:	Delayed field interrupt
;* Revision:	1.1
;* Date:	980928, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	Worst case: 53 cycles + 5 cycles, (ie. PAL-G)
;************************************************************************
DelayedFieldIntrCode	SEGMENT	CODE
	RSEG	DelayedFieldIntrCode
	USING	1

FieldUpdIntr:
	SETB	UpdOffsetFlag		;+1 Flag for update of line offset

	MOV	A, Status		;+1
	SETB	ACC.7			;+1 Set bit 7 in ONE line ONLY every
	MOV	DPTR, #StatusPort	;+2  4 fields
	MOVX	@DPTR, A		;+2

	MOV	A, ScHOffset		;+1
	MOV	DPTR, #GenericMSBPort	;+2
	MOVX	@DPTR, A		;+2

	MOV	A, ScHOffset+1		;+1
	MOV	DPTR, #ScHPhasePort	;+2
	MOVX	@DPTR, A		;+2

	CLR	A			;+1 NOTE: GenericMSBPort MUST contain 0
	MOV	DPTR, #GenericMSBPort	;+2
	MOVX	@DPTR, A		;+2

	MOV	R0, #01			;+1 Reset S1S0 table

	JB	Status_SYSSEL, DelFieldIntr_M
	LJMP	DelFieldIntr_G

;**************************************************************************
;* NTSC SYSTEM
;* Worst case timing: 53 cycles + 3 cycles
;**************************************************************************
DelFieldIntr_M:
	MOV	R1, #00			;+1 Offset from S1S0_M

	MOV	TH0, #HIGH( -21)	;+2 Next active pattern interrupt
	MOV	TL0, #LOW( -21)		;+2  in line 20

	MOV	A, PatternType		;+1
	MOV	DPTR, #PatternTable_M	;+2
	JMP	@A+DPTR			;+2

PatternTable_M:
	LJMP	Pattern0_M		;+2 SMPTE Colorbar
	LJMP	Pattern14_M		;+2 ONLY USED in 625, BlackBurst
	LJMP	Pattern14_M		;+2 ONLY USED in 625, BlackBurst
	LJMP	Pattern14_M		;+2 ONLY USED in 625, BlackBurst
	LJMP	Pattern14_M		;+2 ONLY USED in 625, BlackBurst
	LJMP	Pattern5_M		;+2 Window 15%
	LJMP	Pattern6_M		;+2 Window 20%
	LJMP	Pattern7_M		;+2 Window 100%
	LJMP	Pattern8_M		;+2 Crosshatch
	LJMP	Pattern9_M		;+2 PLUGE
	LJMP	Pattern10_M		;+2 Safe Area
	LJMP	Pattern11_M		;+2 Shallowramp
	LJMP	Pattern12_M		;+2 Multiburst
	LJMP	Pattern13_M		;+2 Red 75%
	LJMP	Pattern14_M		;+2 Blackburst
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used
	LJMP	Pattern14_M		;+2 Not used

;**************************************************************************
Pattern0_M:				;SMPTE Colorbar, (525 only)
	JB	TextPos, Pattern0_MB

	MOV	R3, #HIGH( MA3_F1L20)	;+6/+10
	MOV	R4, #LOW( MA3_F1L20)

	JBC	NewPattern, NewPattern0_M
	LJMP	FieldUpdIntrEnd

Pattern0_MB:
	MOV	R3, #HIGH( MB3_F1L20)	;+6/+10
	MOV	R4, #LOW( MB3_F1L20)

	JBC	NewPattern, NewPattern0_M
	LJMP	FieldUpdIntrEnd

NewPattern0_M:
	MOV	PatternPtr, #HIGH( CBSMPTEPattM)
	MOV	PatternPtr+1, #LOW( CBSMPTEPattM)

	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern5_M:				;Window 15%
	JB	TextPos, Pattern5_MB

	MOV	R3, #HIGH( MA2_F1L20)	;+6/+10
	MOV	R4, #LOW( MA2_F1L20)

	JBC	NewPattern, NewPattern5_M
	LJMP	FieldUpdIntrEnd

Pattern5_MB:
	MOV	R3, #HIGH( MB2_F1L20)	;+6/+10
	MOV	R4, #LOW( MB2_F1L20)

	JBC	NewPattern, NewPattern5_M
	LJMP	FieldUpdIntrEnd

NewPattern5_M:
	MOV	PatternPtr, #HIGH( Win15PattM)
	MOV	PatternPtr+1, #LOW( Win15PattM)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern6_M:				;Window 20%
	JB	TextPos, Pattern6_MB

	MOV	R3, #HIGH( MA2_F1L20)	;+6/+10
	MOV	R4, #LOW( MA2_F1L20)

	JBC	NewPattern, NewPattern6_M
	LJMP	FieldUpdIntrEnd

Pattern6_MB:
	MOV	R3, #HIGH( MB2_F1L20)	;+6/+10
	MOV	R4, #LOW( MB2_F1L20)

	JBC	NewPattern, NewPattern6_M
	LJMP	FieldUpdIntrEnd

NewPattern6_M:
	MOV	PatternPtr, #HIGH( Win20PattM)
	MOV	PatternPtr+1, #LOW( Win20PattM)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern7_M:				;Window 100%
	JB	TextPos, Pattern7_MB

	MOV	R3, #HIGH( MA2_F1L20)	;+6/+10
	MOV	R4, #LOW( MA2_F1L20)

	JBC	NewPattern, NewPattern7_M
	LJMP	FieldUpdIntrEnd

Pattern7_MB:
	MOV	R3, #HIGH( MB2_F1L20)	;+6/+10
	MOV	R4, #LOW( MB2_F1L20)

	JBC	NewPattern, NewPattern7_M
	LJMP	FieldUpdIntrEnd

NewPattern7_M:
	MOV	PatternPtr, #HIGH( Win100PattM)
	MOV	PatternPtr+1, #LOW( Win100PattM)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern8_M:				;Cross hatch
	JB	TextPos, Pattern8_MB

	MOV	R3, #HIGH( MA6_F1L20)	;+6/+10
	MOV	R4, #LOW( MA6_F1L20)

	JBC	NewPattern, NewPattern8_M
	LJMP	FieldUpdIntrEnd

Pattern8_MB:
	MOV	R3, #HIGH( MB6_F1L20)	;+6/+10
	MOV	R4, #LOW( MB6_F1L20)

	JBC	NewPattern, NewPattern8_M
	LJMP	FieldUpdIntrEnd

NewPattern8_M:
	MOV	PatternPtr, #HIGH( CrossPattM)
	MOV	PatternPtr+1, #LOW( CrossPattM)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern9_M:				;PLUGE
	JB	TextPos, Pattern9_MB

	MOV	R3, #HIGH( MA4_F1L20)	;+6/+10
	MOV	R4, #LOW( MA4_F1L20)

	JBC	NewPattern, NewPattern9_M
	LJMP	FieldUpdIntrEnd

Pattern9_MB:
	MOV	R3, #HIGH( MB4_F1L20)	;+6/+10
	MOV	R4, #LOW( MB4_F1L20)

	JBC	NewPattern, NewPattern9_M
	LJMP	FieldUpdIntrEnd

NewPattern9_M:
	MOV	PatternPtr, #HIGH( PLUGEPattM)
	MOV	PatternPtr+1, #LOW( PLUGEPattM)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern10_M:				;Safe Area
	JB	TextPos, Pattern10_MB

	MOV	R3, #HIGH( MA5_F1L20)	;+6/+10
	MOV	R4, #LOW( MA5_F1L20)

	JBC	NewPattern, NewPattern10_M
	LJMP	FieldUpdIntrEnd

Pattern10_MB:
	MOV	R3, #HIGH( MB5_F1L20)	;+6/+10
	MOV	R4, #LOW( MB5_F1L20)

	JBC	NewPattern, NewPattern10_M
	LJMP	FieldUpdIntrEnd

NewPattern10_M:
	MOV	PatternPtr, #HIGH( SafePattM)
	MOV	PatternPtr+1, #LOW( SafePattM)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern11_M:				;Shallowramp
	JB	TextPos, Pattern11_MB

	MOV	R3, #HIGH( MA1_F1L20)	;+6/+7
	MOV	R4, #LOW( MA1_F1L20)

	JBC	NewPattern, NewPattern11_M
	LJMP	FieldUpdIntrEnd

Pattern11_MB:
	MOV	R3, #HIGH( MB1_F1L20)	;+6/+7
	MOV	R4, #LOW( MB1_F1L20)

	JBC	NewPattern, NewPattern11_M
	LJMP	FieldUpdIntrEnd

NewPattern11_M:
	MOV	R6, #ShallowRamp_M
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern12_M:				;Multiburst
	JB	TextPos, Pattern12_MB

	MOV	R3, #HIGH( MA1_F1L20)	;+6/+7
	MOV	R4, #LOW( MA1_F1L20)

	JBC	NewPattern, NewPattern12_M
	LJMP	FieldUpdIntrEnd

Pattern12_MB:
	MOV	R3, #HIGH( MB1_F1L20)	;+6/+7
	MOV	R4, #LOW( MB1_F1L20)

	JBC	NewPattern, NewPattern12_M
	LJMP	FieldUpdIntrEnd

NewPattern12_M:
	MOV	R6, #FCC_Multiburst_M
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern13_M:				;75% Red
	JB	TextPos, Pattern13_MB

	MOV	R3, #HIGH( MA1_F1L20)	;+6/+7
	MOV	R4, #LOW( MA1_F1L20)

	JBC	NewPattern, NewPattern13_M
	LJMP	FieldUpdIntrEnd

Pattern13_MB:
	MOV	R3, #HIGH( MB1_F1L20)	;+6/+7
	MOV	R4, #LOW( MB1_F1L20)

	JBC	NewPattern, NewPattern13_M
	LJMP	FieldUpdIntrEnd

NewPattern13_M:
	MOV	R6, #Red_M
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern14_M:				;Black
	JB	TextPos, Pattern14_MB

	MOV	R3, #HIGH( MA1_F1L20)	;+6/+7
	MOV	R4, #LOW( MA1_F1L20)

	JBC	NewPattern, NewPattern14_M
	LJMP	FieldUpdIntrEnd

Pattern14_MB:
	MOV	R3, #HIGH( MB1_F1L20)	;+6/+7
	MOV	R4, #LOW( MB1_F1L20)

	JBC	NewPattern, NewPattern14_M
	LJMP	FieldUpdIntrEnd

NewPattern14_M:
	MOV	R6, #Sync_Burst_Setup_M
	LJMP	FieldUpdIntrEnd

;**************************************************************************
;* PAL-G/PAL-G with ID SYSTEM
;* Worst case timing: 53 cycles + 5 cycle
;**************************************************************************
DelFieldIntr_G:
	MOV	R1, #61			;+1 Offset from S1S0_M

	MOV	TH0, #HIGH( -23)	;+2 Next active pattern interrupt
	MOV	TL0, #LOW( -23)		;+2  in line 22

	MOV	A, PatternType		;+1
	MOV	DPTR, #SetPatternTable	;+2
	JMP	@A+DPTR			;+2

SetPatternTable:
	LJMP	Pattern14_G		;+2 ONLY USED in 525, BlackBurst
	LJMP	Pattern1_G		;+2 EBU Colorbar
	LJMP	Pattern2_G		;+2 Colorbar 100%
	LJMP	Pattern3_G		;+2 Colorbar 75%+grey
	LJMP	Pattern4_G		;+2 Colorbar 75%+red
	LJMP	Pattern5_G		;+2 Window 15%
	LJMP	Pattern6_G		;+2 Window 20%
	LJMP	Pattern7_G		;+2 Window 100%
	LJMP	Pattern8_G		;+2 Crosshatch
	LJMP	Pattern9_G		;+2 PLUGE
	LJMP	Pattern10_G		;+2 Safe Area
	LJMP	Pattern11_G		;+2 Shallowramp
	LJMP	Pattern12_G		;+2 Multiburst
	LJMP	Pattern13_G		;+2 Red 75%
	LJMP	Pattern14_G		;+2 Blackburst
	LJMP	Pattern15_G		;+2 Philips
	LJMP	Pattern16_G		;+2 Philips wo/APAL
	LJMP	Pattern17_G		;+2 CCIR17
	LJMP	Pattern18_G		;+2 Multipulse
	LJMP	Pattern19_G		;+2 Sinc5MHz
	LJMP	Pattern20_G		;+2 Linesweep
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used
	LJMP	Pattern14_G		;+2 Not used

;**************************************************************************
Pattern1_G:				;EBU Colorbar, (625 only)
	JB	TextPos, Pattern1_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern1_G
	LJMP	FieldUpdIntrEnd

Pattern1_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern1_G
	LJMP	FieldUpdIntrEnd

NewPattern1_G:
	MOV	R6, #EBUColorbar_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern2_G:				;100% Colorbar, (625 only)
	JB	TextPos, Pattern2_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern2_G
	LJMP	FieldUpdIntrEnd

Pattern2_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern2_G
	LJMP	FieldUpdIntrEnd

NewPattern2_G:
	MOV	R6, #Colorbar100_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern3_G:				;75% Colorbar+grey, (625 only)
	JB	TextPos, Pattern3_GB

	MOV	R3, #HIGH( GA3_F1L22)	;+6/+10
	MOV	R4, #LOW( GA3_F1L22)

	JBC	NewPattern, NewPattern3_G
	LJMP	FieldUpdIntrEnd

Pattern3_GB:
	MOV	R3, #HIGH( GB3_F1L22)	;+6/+10
	MOV	R4, #LOW( GB3_F1L22)

	JBC	NewPattern, NewPattern3_G
	LJMP	FieldUpdIntrEnd

NewPattern3_G:
	MOV	PatternPtr, #HIGH( CB75GreyPattG)
	MOV	PatternPtr+1, #LOW( CB75GreyPattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern4_G:				;EBU Colorbar+Red, (625 only)
	JB	TextPos, Pattern4_GB

	MOV	R3, #HIGH( GA3_F1L22)	;+6/+10
	MOV	R4, #LOW( GA3_F1L22)

	JBC	NewPattern, NewPattern4_G
	LJMP	FieldUpdIntrEnd

Pattern4_GB:
	MOV	R3, #HIGH( GB3_F1L22)	;+6/+10
	MOV	R4, #LOW( GB3_F1L22)

	JBC	NewPattern, NewPattern4_G
	LJMP	FieldUpdIntrEnd

NewPattern4_G:
	MOV	PatternPtr, #HIGH( EBUCBRedPattG)
	MOV	PatternPtr+1, #LOW( EBUCBRedPattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern5_G:				;Window 15%
	JB	TextPos, Pattern5_GB

	MOV	R3, #HIGH( GA2_F1L22)	;+6/+10
	MOV	R4, #LOW( GA2_F1L22)

	JBC	NewPattern, NewPattern5_G
	LJMP	FieldUpdIntrEnd

Pattern5_GB:
	MOV	R3, #HIGH( GB2_F1L22)	;+6/+10
	MOV	R4, #LOW( GB2_F1L22)

	JBC	NewPattern, NewPattern5_G
	LJMP	FieldUpdIntrEnd

NewPattern5_G:
	MOV	PatternPtr, #HIGH( Win15PattG)
	MOV	PatternPtr+1, #LOW( Win15PattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern6_G:				;Window 20%
	JB	TextPos, Pattern6_GB

	MOV	R3, #HIGH( GA2_F1L22)	;+6/+10
	MOV	R4, #LOW( GA2_F1L22)

	JBC	NewPattern, NewPattern6_G
	LJMP	FieldUpdIntrEnd

Pattern6_GB:
	MOV	R3, #HIGH( GB2_F1L22)	;+6/+10
	MOV	R4, #LOW( GB2_F1L22)

	JBC	NewPattern, NewPattern6_G
	LJMP	FieldUpdIntrEnd

NewPattern6_G:
	MOV	PatternPtr, #HIGH( Win20PattG)
	MOV	PatternPtr+1, #LOW( Win20PattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern7_G:				;Window 100%
	JB	TextPos, Pattern7_GB

	MOV	R3, #HIGH( GA2_F1L22)	;+6/+10
	MOV	R4, #LOW( GA2_F1L22)

	JBC	NewPattern, NewPattern7_G
	LJMP	FieldUpdIntrEnd

Pattern7_GB:
	MOV	R3, #HIGH( GB2_F1L22)	;+6/+10
	MOV	R4, #LOW( GB2_F1L22)

	JBC	NewPattern, NewPattern7_G
	LJMP	FieldUpdIntrEnd

NewPattern7_G:
	MOV	PatternPtr, #HIGH( Win100PattG)
	MOV	PatternPtr+1, #LOW( Win100PattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern8_G:				;Cross hatch
	JB	TextPos, Pattern8_GB

	MOV	R3, #HIGH( GA6_F1L22)	;+6/+10
	MOV	R4, #LOW( GA6_F1L22)

	JBC	NewPattern, NewPattern8_G
	LJMP	FieldUpdIntrEnd

Pattern8_GB:
	MOV	R3, #HIGH( GB6_F1L22)	;+6/+10
	MOV	R4, #LOW( GB6_F1L22)

	JBC	NewPattern, NewPattern8_G
	LJMP	FieldUpdIntrEnd

NewPattern8_G:
	MOV	PatternPtr, #HIGH( CrossPattG)
	MOV	PatternPtr+1, #LOW( CrossPattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern9_G:				;PLUGE
	JB	TextPos, Pattern9_GB

	MOV	R3, #HIGH( GA4_F1L22)	;+6/+10
	MOV	R4, #LOW( GA4_F1L22)

	JBC	NewPattern, NewPattern9_G
	LJMP	FieldUpdIntrEnd

Pattern9_GB:
	MOV	R3, #HIGH( GB4_F1L22)	;+6/+10
	MOV	R4, #LOW( GB4_F1L22)

	JBC	NewPattern, NewPattern9_G
	LJMP	FieldUpdIntrEnd

NewPattern9_G:
	MOV	PatternPtr, #HIGH( PLUGEPattG)
	MOV	PatternPtr+1, #LOW( PLUGEPattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern10_G:				;Safe Area
	JB	TextPos, Pattern10_GB

	MOV	R3, #HIGH( GA5_F1L22)	;+6/+10
	MOV	R4, #LOW( GA5_F1L22)	

	JBC	NewPattern, NewPattern10_G
	LJMP	FieldUpdIntrEnd

Pattern10_GB:
	MOV	R3, #HIGH( GB5_F1L22)	;+6/+10
	MOV	R4, #LOW( GB5_F1L22)	

	JBC	NewPattern, NewPattern10_G
	LJMP	FieldUpdIntrEnd

NewPattern10_G:
	MOV	PatternPtr, #HIGH( SafePattG)
	MOV	PatternPtr+1, #LOW( SafePattG)
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern11_G:				;Shallowramp
	JB	TextPos, Pattern11_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern11_G
	LJMP	FieldUpdIntrEnd

Pattern11_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern11_G
	LJMP	FieldUpdIntrEnd

NewPattern11_G:
	MOV	R6, #ShallowRamp_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern12_G:				;Multiburst
	JB	TextPos, Pattern12_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern12_G
	LJMP	FieldUpdIntrEnd

Pattern12_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern12_G
	LJMP	FieldUpdIntrEnd

NewPattern12_G:
	MOV	R6, #CCIR18_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern13_G:				;75% Red
	JB	TextPos, Pattern13_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern13_G
	LJMP	FieldUpdIntrEnd

Pattern13_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern13_G
	LJMP	FieldUpdIntrEnd

NewPattern13_G:
	MOV	R6, #Red75_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern14_G:				;Black burst
	JB	TextPos, Pattern14_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern14_G
	LJMP	FieldUpdIntrEnd

Pattern14_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern14_G
	LJMP	FieldUpdIntrEnd

NewPattern14_G:
	MOV	R6, #BlackBurst_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern15_G:				;Philips
Pattern16_G:				;Philips wo/APAL
	MOV	A, PatternAttr
	JNB	ACC.0, Pattern16woAPAL_G

	MOV	R3, #HIGH( G7_F1L22)	;+/+
	MOV	R4, #LOW( G7_F1L22)

	LJMP	FieldUpdIntrEnd

Pattern16woAPAL_G:
	MOV	R3, #HIGH( G8_F1L22)	;+/+
	MOV	R4, #LOW( G8_F1L22)

	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern17_G:				;CCIR17
	JB	TextPos, Pattern17_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern17_G
	LJMP	FieldUpdIntrEnd

Pattern17_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern17_G
	LJMP	FieldUpdIntrEnd

NewPattern17_G:
	MOV	R6, #CCIR17_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern18_G:				;Multipulse
	JB	TextPos, Pattern18_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern18_G
	LJMP	FieldUpdIntrEnd

Pattern18_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern18_G
	LJMP	FieldUpdIntrEnd

NewPattern18_G:
	MOV	R6, #Multipulse_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern19_G:				;Sinc5MHz
	JB	TextPos, Pattern19_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern19_G
	LJMP	FieldUpdIntrEnd

Pattern19_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern19_G
	LJMP	FieldUpdIntrEnd

NewPattern19_G:
	MOV	R6, #Sinc5MHz_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
Pattern20_G:				;Linesweep
	JB	TextPos, Pattern20_GB

	MOV	R3, #HIGH( GA1_F1L22)	;+6/+7
	MOV	R4, #LOW( GA1_F1L22)

	JBC	NewPattern, NewPattern20_G
	LJMP	FieldUpdIntrEnd

Pattern20_GB:
	MOV	R3, #HIGH( GB1_F1L22)	;+6/+7
	MOV	R4, #LOW( GB1_F1L22)

	JBC	NewPattern, NewPattern20_G
	LJMP	FieldUpdIntrEnd

NewPattern20_G:
	MOV	R6, #Line_sweep_G
	LJMP	FieldUpdIntrEnd

;**************************************************************************
FieldUpdIntrEnd:
	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+2
END