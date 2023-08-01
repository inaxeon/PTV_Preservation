$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG320.INC)		;Include the predefined 80C320 register set

;************************************************************************
;* Copyright ProTeleVision Technologies A/S, BRONDBY 1998		*
;* Project: PT8631 Analog Test Pattern generator			*
;* Module:  COMM.A51							*
;* Author:  Kim Engedahl, DEV						*
;* Org.  :  980306							*
;* Rev.  :  981108, KEn, DEV						*
;* Status:  Version 1.0 (the DALLAS 80C320 running at 19.6608MHz)	*
;* 									*
;* IýC timing:								*
;* 	START-/STOP condition: 4.0us					*
;* 	Repeated START condition: 4.7us					*
;* 	Busfree time between STOP and START condition: 4.7us		*
;* 	Clock   SCL(low): 4.7us   SCL(high): 4.0us			*
;* 									*
;* Changes:								*
;* 981108: Released in SW ver. 2.1					*
;* 981002: Released in SW ver. 2.0					*
;* 980603: Released in SW ver. 1.0					*
;************************************************************************

NAME		COMM

EXTRN BIT( IIC_NoAck)

PUBLIC Reset_DAC, Write_DAC, Read_EEPROM, Write_EEPROM

;************************************************************************

DAC_IIC_Adr	EQU	058H
EEPROM_IIC_Adr	EQU	0A0H

SCL_Pin		BIT	P1.6
SDA_Pin		BIT	P1.7

;************************************************************************

IIC_BIT		SEGMENT	BIT
		RSEG	IIC_BIT

EE_W_Control:	DBIT	1

;************************************************************************

IIC_DATA	SEGMENT	DATA
		RSEG	IIC_DATA

ErrorCnt:	DS	1
IICAddress:	DS	1

;************************************************************************
IIC_Routines	SEGMENT	CODE
	RSEG	IIC_Routines
	USING	0

;************************************************************************
;* Name:	Reset_DAC
;* Function:	Write command ( Acc) and data ( R1) to DAC
;* Revision:	0.0
;* Date:	970311, KEn
;* Input:	-
;* Output:	-
;* Destroys:	R0, R1, R2, R5, Acc, B
;* Calls	-
;* Time:	-
;************************************************************************
Reset_DAC:
	MOV	A, #010H		;Reset command
	MOV	R1, #000H		;Dummy data byte

;************************************************************************
;* Name:	Write_DAC
;* Function:	Write command ( Acc) and data ( R1) to DAC
;* Revision:	2.0
;* Date:	980527, KEn
;* Input:	-
;* Output:	-
;* Destroys:	R0, R1, R2, R5, Acc, B
;* Calls	-
;* Time:	-
;************************************************************************
Write_DAC:
	MOV	IICAddress, #DAC_IIC_Adr
	CLR	EE_W_Control

DAC_EE_R_W:
	MOV	ErrorCnt, #5		;Reset IIC error counter to 5
	MOV	B, A			;Copy DAC command to reg. B

DAC_Write_Addr:
	MOV	A, IICAddress
	LCALL	TxAddress		;Write IýC address of DAC
	JNC	DAC_Write_Cmd		;Examine acknowledge from DAC
	
DAC_No_Response:
	LCALL	Stop_Condition		;No response from DAC

	MOV	R5, #164
	DJNZ	R5, $			;+3 Delay = 100 us

	DJNZ	ErrorCnt, DAC_Write_Addr;If no response after 5 attemps..

	SETB	IIC_NoAck		; raise error flag
	RET

DAC_Write_Cmd:
	CLR	F0			;Select write mode
	MOV	A, B
	LCALL	RxTxByte		;Write command to DAC
	JC	DAC_No_Response		;Examine acknowledge from DAC

DAC_Write_Byte:
	CLR	F0			;Select write mode
	MOV	A, R1
	LCALL	RxTxByte		;Write data byte to DAC

	LJMP	Stop_Condition

;************************************************************************
;* Name:	Read_EEPROM
;* Function:	Reads ( R2) bytes from EýPROM address ( Acc++) to internal
;*		RAM address ( @R1++)
;* Revision:	1.0
;* Date:	971114, KEn
;* Input:	-
;* Output:	-
;* Destroys:	R0, R1, R2, R5, Acc, B
;* Calls	-
;* Time:	-
;************************************************************************
Read_EEPROM:
	MOV	IICAddress, #EEPROM_IIC_Adr

	SETB	EE_W_Control
	SJMP	EE_R_W

;************************************************************************
;* Name:	Write_EEPROM
;* Function:	Writes ( R2) bytes to EýPROM address ( Acc++) from 
;*		internal RAM address ( @R1++)
;* Revision:	2.0
;* Date:	980528, KEn
;* Input:	-
;* Output:	-
;* Destroys:	R0, R1, R2, R5, Acc, B
;* Calls	-
;* Time:	-
;************************************************************************
Write_EEPROM:
	MOV	IICAddress, #EEPROM_IIC_Adr

	CLR	EE_W_Control

EE_R_W:
	MOV	ErrorCnt, #32		;Reset IIC timeout count to 32->10.4ms
	MOV	B, A			;Copy EýPROM (sub)address to reg. B

Write_Loop:
	MOV	A, IICAddress
	LCALL	TxAddress		;Write IýC address of EýPROM
	JNC	Write_SubAddress	;Examine acknowledge from EýPROM
	
No_Response:
	LCALL	Stop_Condition		;No response from EýPROM

	MOV	R5, #200
NRLoop:
	SJMP	$+2			;+3
	NOP				;+1
	NOP				;+1
	DJNZ	R5, NRLoop		;+3 Delay = 326 us

	DJNZ	ErrorCnt, Write_Loop	;If no response after 10.4 ms..

	SETB	IIC_NoAck		; raise error flag
	RET

Write_SubAddress:
	CLR	F0			;Select write mode
	MOV	A, B
	LCALL	RxTxByte		;Write (sub)address to EýPROM
	JC	No_Response		;Examine acknowledge from EýPROM

	JB	EE_W_Control, Read_Bytes

;************************************************************************
Write_Byte:
	CLR	F0			;Select write mode
	MOV	A, @R1
	LCALL	RxTxByte		;Write data byte to EýPROM
	LCALL	Stop_Condition

	INC	R1			;Increment source address
	MOV	A, B
	ADD	A, #01			;Increment destination address
	MOV	B, A

	MOV	ErrorCnt, #32		;Reset IIC timeout count to 32->10.4ms
	DJNZ	R2, Write_Loop		;Wait 10 ms OR until acknowledge

	RET

;************************************************************************
Read_Bytes:
	MOV	ErrorCnt, #05		;Reset errorcnt to 5 attempts

Read_BytesA:
	LCALL	Stop_Condition

	MOV	A, IICAddress
	LCALL	RxAddress		;Write IýC address of EýPROM
	JNC	ReadNextByte		;if acknowledge from EýPROM read next..

	DJNZ	ErrorCnt, Read_BytesA	;If no acknowledge after 5 attempts.

	SETB	IIC_NoAck		; raise error flag
	RET

ReadNextByte:
	DJNZ	R2, NotLastByte

	LCALL	Rx_LastByte		;Read the last byte WITHOUT acknowledge
	MOV	@R1, A
	LJMP	Stop_Condition

NotLastByte:
	LCALL	Rx_NextByte		;Read a bytes WITH acknowledge

	MOV	@R1, A			;Save the read byte
	INC	R1			;Increment destination address
	SJMP	ReadNextByte

;************************************************************************
;* Name:	RxAddress
;* Function:	Read from an IýC-component
;* Function:	Set up receving from an IýC-component
;* Revision:	2.0
;* Date:	971114, SAA/KEn
;* Input:	IýC-Address in ACC.
;* Output:	Acknowledge from IýC-address in Carry
;* Destroys:	-
;* Calls	-
;* Time:	-
;* Remarks:	-
;************************************************************************
RxAddress:				
	CLR	SDA_Pin		;+2 Start condition for reading

	SETB	ACC.0		;+2 -> SDA set low

	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	NOP			;+1 -> SDA low for 21 cycles = 4.2 us

	CLR	SCL_Pin		;+2
	JB	SCL_Pin, $	;+4

	CLR	F0		;+2 Select write mode
	SJMP	RxTxByte	;+3

;************************************************************************
;* Name:	TxAddress
;* Function:	Set up transmission to an IýC-component
;* Revision:	2.0
;* Date:	980528, SAA/KEn
;* Input:	IýC-address in Acc.
;* Output:	Ackowledge from IýC-address in Carry
;* Destroys:	-
;* Calls	-
;* Time:	-
;* Remarks:	Routine has been timed
;************************************************************************
TxAddress:
	CLR	SDA_Pin		;+2 Start condition for writing

	CLR	ACC.0		;+2 -> SDA set low

	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	NOP			;+1 -> SDA low for 21 cycles = 4.2 us

	CLR	SCL_Pin		;+2
	JB	SCL_Pin, $	;+4

	CLR	F0		;+2 Select write mode
	SJMP	RxTxByte	;+3 DO NOT DELETE!!!! Used for timing purpose

;************************************************************************
;* Name:	RxTxByte
;* Function:	Write/read a single byte to/from an IýC-address
;* Revision:	2.0
;* Date:	980528, SAA/KEn
;* Input:	Byte in Acc.
;* Output:	Ackowledge from IýC-address in Carry
;* Destroys:	-
;* Calls	-
;* Time:	-
;* Remarks:	-
;************************************************************************
RxTxByte:
	MOV	R5, #8		;+2
	RLC	A		;+1

ByteLoop:
	JB	F0, ByteLBL1	;+4
	NOP			;+1
	MOV	SDA_Pin, C	;+2
	SJMP	ByteLBL1A	;+3

ByteLBL1:
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
ByteLBL1A:			;   -> SCL low for RxTxByte=13 / ByteLoop=10
	SETB	SCL_Pin		;+2
	JNB	SCL_Pin, $	;+4
	NOP			;+1 -> SCL set high
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	JNB     F0, ByteLBL2	;+4
	NOP			;+1
	MOV	C, SDA_Pin	;+2
	SJMP	ByteLbl2A	;+3

ByteLBL2:
	SJMP	$+2		;+3
	SJMP	$+2		;+3
ByteLBL2A:
	RLC	A		;+1 -> SCL high for 21 cycles = 4.3us

	CLR	SCL_Pin		;+2
	JB	SCL_Pin, $	;+4

	NOP			;+1 -> SCL set low
	NOP			;+1
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	DJNZ	R5, ByteLoop	;+3 -> SCL low for +14 cycles

	JB	F0, ByteLBL3	;+4
	SETB	C		;+1

ByteLBL3:
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	MOV	SDA_Pin, C	;+2    Data setup > 250ns
	NOP			;+1 -> SCL low for 24/25 cycles = 4.9us/5.1us

	SETB	SCL_Pin		;+2
	JNB	SCL_Pin, $	;+4 

	SJMP	$+2		;+3 -> SCL set high
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3

	MOV	C, SDA_Pin	;+2
	NOP			;+1 -> SCL high for 21 cycles = 4.3us

	CLR	SCL_Pin		;+2
	JB	SCL_Pin, $	;+4 

	SETB	SDA_Pin		;+2 -> SCL set low. It is NOT necessary to
	RET			;+4    prolong this delay as SCL will be low
				;      13 cycles into RxTxbyte, ie. 19 cycles
				;      as a minimum

;************************************************************************
;* Name:	Rx_LastByte
;* Function:	Read a byte without acknowledge from the IýC-bus
;* Revision:	1.1
;* Date:	971114, SAA/KEn
;* Input:	-
;* Output:	Byte in ACC
;* Destroys:	-
;* Calls	-
;* Time:	-
;* Remarks:	-
;************************************************************************
Rx_LastByte:
	SETB	C		;+1
	SETB	F0		;+2 Select read mode

	SJMP	RxTxByte	;+3

;************************************************************************
;* Name:	Rx_NextByte
;* Function:	Read a byte with acknowledge from the IýC-bus
;* Revision:	1.1
;* Date:	971114, SAA/KEn
;* Input:	-
;* Output:	Byte in ACC
;* Destroys:	-
;* Calls	-
;* Time:	-
;* Remarks:	-
;************************************************************************
Rx_NextByte:
	CLR	C		;+1
	SETB	F0		;+2 Select read mode

	SJMP	RxTxByte	;+3

;************************************************************************
;* Name:	Stop_Condition
;* Function:	Transmit a stop condition to the IýC-bus
;* Revision:	2.0
;* Date:	980528, SAA/KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	-
;* Remarks:	-
;************************************************************************
Stop_Condition:
	CLR	SDA_Pin		;+2

	SETB	SCL_Pin		;+2
	JNB	SCL_Pin, $	;+4 

	SJMP	$+2		;+3 -> SCL set high
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3 -> SCL high for 21 cycles = 4.3us

	SETB	SDA_Pin		;+2

	SJMP	$+2		;+3 Delay to ensure repeated start condition
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3
	SJMP	$+2		;+3

	RET                	;+4 -> 25 cycles = 5.1us
END
