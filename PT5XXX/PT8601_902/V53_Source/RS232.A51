$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG320.INC)		;Include the predefined 8052 register set

;************************************************************************
;* Copyright PHILIPS TV TEST EQUIPMENT A/S, BRONDBY 1997		*
;* Project: PT8639 SDI Test Signal Generator				*
;* Module:  RS232.A51							*
;* Author:  Kim Engedahl, DEV						*
;* Org.  :  960722							*
;* Rev.  :  980514, KEn DEV						*
;* Status:  Version 1.0							*
;* 									*
;* This module contains the following functions:			*
;* 									*
;* Changes:								*
;* 980514: Released as 400 002 0678 1 SW: 1.0				*
;* 971112: Introduced to new variables: ParamCnt & StringCnt which	*
;*	    counts the number of numeric- & string-parameters received	*
;*	   Parameters are now reset when decoding a new command		*
;* 970305: Optimization in RxIntr routine				*
;* 970218: Could not read more than one number, (BufState_5)		*
;* 970127: Variable Tmp removed, RxInput & RxOutput placed in upper	*
;*	   memory now utilizing 108 bytes				*
;* 970124: Input buffer increased to 64 bytes, now utilizing 106 upper	*
;'	   bytes							*
;* 970122: Added test of buffer overrun					*
;************************************************************************

NAME		RS232

EXTRN CODE( ?C?LMUL, Command_Table)

EXTRN BIT( Buffer_OV, Illegal_Cmd)

PUBLIC RS232Intr, RS232Init, Def_Unit_Adr, MyAddress
PUBLIC CharHandler, TestInputBuffer

PUBLIC WriteChar, WriteASCII, WriteString, WriteLong, WriteInteger
PUBLIC WriteEndOfTx

PUBLIC Parameter, String, CmdDelimiter, TxChkSum, ParamCnt, StrCnt

;************************************************************************

Def_Unit_Adr	EQU	016H

XORValue	EQU	003H

IdleState	EQU	000H
DataState	EQU	001H
QuoteState	EQU	002H		;MUST be DataState XOR 03H
DelState	EQU	003H

State_0		EQU	0
State_1		EQU	State_0+1
State_2		EQU	State_0+2
State_3		EQU	State_0+3
State_4		EQU	State_0+4
State_5		EQU	State_0+5
State_6		EQU	State_0+6
State_7		EQU	State_0+7
State_8		EQU	State_0+8

RxBufferLen	EQU	56
StringLen	EQU	18

;************************************************************************
RS232_Bit	SEGMENT	BIT
		RSEG	RS232_Bit

Tx_ACK_Pending:	DBIT	1
TX_BUSY:	DBIT	1
TX_SBUF_Empty:	DBIT	1

;************************************************************************

RS232_Data	SEGMENT	DATA
		RSEG	RS232_Data

MyAddress:	DS	1		;

BufState:	DS	1		;
Char:		DS	1		;
CharType:	DS	1		;

CmdNdx:		DS	1		;
StrNdx:		DS	1		;
ParamNdx:	DS	1		;Index for parameter, (0-2)

ParamCnt:	DS	2		;Number of numeric parameters received
StrCnt:		DS	1		;Number of string parameters received

RxInputSize:	DS	1		;

RxState:	DS	1		;
RxChkSum:	DS	1		;

Tx_ACK_Buffer:	DS	1		;
TxChkSum:	DS	1		;
					;Reserve ( 64+16+16+1+4+5+1+1=108)
					; bytes in upper RAM
RxBuffer	EQU	100H-RxBufferLen
String		EQU	RxBuffer-Stringlen
Parameter	EQU	String-12	;3 long values
CmdDelimiter	EQU	Parameter-1
Cmd		EQU	Parameter-4
Buffer		EQU	Cmd-5
RxOutput	EQU	Buffer-1
RxInput		EQU	RxOutput-1

;************************************************************************

RS232_Constant	SEGMENT	CODE
		RSEG	RS232_Constant

TypeTable:	DB 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'D', 'R'
		DB 'R', 'D', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R'
		DB 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'D', 'Q', 'R'
		DB 'D', 'R', 'R', 'R', 'R', 'R', 'R', 'N', 'S', 'N', 'N', 'R'
		DB 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'R', 'D'
		DB 'R', 'R', 'R', 'D', 'R', 'A', 'A', 'A', 'A', 'A', 'A', 'A'
		DB 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A'
		DB 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'R', 'R', 'R', 'R', 'R'
		DB 'R', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A'
		DB 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A'
		DB 'A', 'A', 'A', 'R', 'R', 'R', 'R', 'R'

;************************************************************************
RS232_Interrupt	SEGMENT	CODE
		RSEG	RS232_Interrupt
		USING	2

;************************************************************************
;* Name:	RS232Intr
;* Function:	Serial RS232 receiver interrupt code, NOT TO BE USED!!
;* Revision:	0.1
;* Date:	970122, KEn
;* Input:	-
;* Output:	-
;* Destroys:	R0: Index, R1: State, R2: Data, R3: Data type, R4: PUSH Acc
;* Calls	-
;* Time:	-
;************************************************************************
RS232Intr:
	PUSH	DPS			;Push Data Pointer Selector
	MOV	DPS, #0			;Select Data Pointer Selector 0

	PUSH	PSW			;Push PSW
	MOV	PSW, #010H		;ALWAYS use register bank 2

	JBC	RI, RxInt		;If receiver interrupt, jump..

;=========================TRANSMITTER INTERRUPT ===============================

	CLR	TI			;Clear interrupt
					
	JBC	Tx_ACK_Pending, TxInt_A	;If no acknowledge is pending...
	SETB	Tx_SBUF_Empty		;indicate SBUF empty

	POP	PSW			;Restore Processor Status Word
	POP	DPS			;Restore Data Pointer Selector
	RETI

TxInt_A:
	MOV	SBUF0, Tx_ACK_Buffer	;Transmit acknowledge

	POP	PSW			;Restore Processor Status Word
	POP	DPS			;Restore Data Pointer Selector
	RETI


;=========================== RECEIVER INTERRUPT ===============================
RxInt:
	PUSH	DPL			;
	PUSH	DPH			;
	MOV	R4, A			;Push ACC
	MOV	A, SBUF0			;Get received character

	JNB	SM2, RxInt_A		;If SM2 = 0 we're receiving data..

	CJNE	A, MyAddress, RxInt_End	;else test received data for address..

	CLR	SM2			;if MyAddress then clear flag
					; ie. ready to receive data
	MOV	RxState, #DataState	;Initialize state machine
	MOV	RxChkSum, #0		;Reset Checksum

	SJMP	RxInt_End

RxInt_A:
	MOV	R2, A			;Temporarily save received byte

	MOV	R1, RxState		
	CJNE	R1, #DelState, RxInt_B	;Last byte, ie. checksum received, ? ..

	SETB	SM2			;Yes, set flag SM2 ie. ready to receive
					; address once again

	CLR	C			;Compare calculated checksum with
	MOV	A, RxChkSum		; received checksum
	ANL	A, #07FH		;Remove bit 7
	SUBB	A, R2
	JZ	RxChkSumTested
	MOV	A, #01			;Prepare to acknowledge checksum error

RxChkSumTested:
	ADD	A, #080H		;NOTE! A IS 0 or 1
	MOV	R2, A			;Store checksum result in R2

	MOV	Tx_ACK_Buffer, A	;Store acknowledge in buffer

	JB	Tx_BUSY, Tx_Is_Busy

	CLR	Tx_SBUF_Empty
	MOV	SBUF0, Tx_ACK_Buffer

	SJMP	RxInt_E			;End by storing result of checksum

Tx_Is_Busy:
	SETB	Tx_ACK_Pending

	SJMP	RxInt_E			;End by storing result of checksum

RxInt_B:

	MOV	DPTR, #TypeTable
	MOVC	A, @A+DPTR		;Get type of received data from table
	MOV	R3, A			;Save received data type

	CJNE	R3, #'Q', RxInt_C	;Received data a quote
	XRL	RxState, #XORValue	;Yes, toggle between  data state and
					; quote state
	SJMP	RxInt_E

RxInt_C:
	CJNE	R1, #QuoteState, RxInt_D;If in quote state ..

	SJMP	RxInt_E			; ALL ASCII is allowed

RxInt_D:
	CJNE	R3, #'D', RxInt_E	;Received data a delimiter ??
	MOV	RxState, #DelState	;Yes, go to delimiter state

RxInt_E:
	MOV	R0, #RxInput		;Address of index to RX buffer to R0
	MOV	A, @R0			;Update pointer to RxInput
	INC	A
	ANL	A, #RxBufferLen-1	;It is a ring-buffer
	MOV	@R0, A			;Save new index to RX buffer

	ADD	A, #RxBuffer		;Add index to RX buffer[0]

	MOV	R0, A			;Move index to R0
	MOV	A, R2			;Get received character
	MOV	@R0, A			;Store character

	ADD	A, RxChkSum
	MOV	RxChkSum, A

	INC	RxInputSize		;Increment no of chars in buffer

	CLR	C
	MOV	A, #RxBufferLen
	SUBB	A, RxInputSize
	JNC	RxInt_End		;If overflow in buffer..
	SETB	Buffer_OV		; set overflow flag

RxInt_End:
	MOV	A, R4			;Restore ACC
	POP	DPH			;
	POP	DPL			;
	POP	PSW			;Restore status word
	POP	DPS			;Restore Data Pointer Selector
	RETI				;


;************************************************************************

RS232_Functions	SEGMENT	CODE
	RSEG	RS232_Functions
	USING	0

;************************************************************************
;* Name:	RS232Init
;* Function:	Initialise the RS232 input buffer and state machine
;* Revision:	0.1
;* Date:	970122, KEn
;* Input:	-
;* Output:	-
;* Destroys:	-
;* Calls	-
;* Time:	?
;************************************************************************
RS232Init:
	MOV	RxInputSize, #0		;Number of chars in RxBuffer

	MOV	R0, #RxInput
	MOV	@R0, #0			;Reset start of RS232 ring-buffer
	INC	R0
	MOV	@R0, #0			;Reset end of RS232 ring-buffer
	
	MOV	RxState, #IdleState	;RS232 receiver state machine

	MOV	Char, #0		;Received char
	MOV	CharType, #0		;Received char type
	MOV	BufState, #State_0	;Char Handler state machine

	MOV	MyAddress, #Def_Unit_Adr

	CLR	Tx_ACK_Pending		;Rest transmit buffer variables
	CLR	Tx_BUSY
	SETB	TX_SBUF_Empty

	RET

;************************************************************************
;* Name:	CharHandler
;* Function:	RS232 command state machine
;* Revision:	0.1
;* Date:	970124, PRC/KEn
;* Input:	BufState, Char
;* Output:	Cmd
;* Destroys:	Acc, B, R0-R2, R4-R7, Flags
;* Calls	?C?LMUL
;* Time:	-
;************************************************************************
CharHandler:
	MOV	R0, #RxOutput		

	MOV	A, @R0			;Get index to RX buffer
	INC	A			;
	ANL	A, #RxBufferLen-1	;Increment index
	MOV	@R0, A			;Save new index to RX buffer

	ADD	A, #RxBuffer		;Add index to RX Buffer[0]
	MOV	R0, A
	MOV	A, @R0			;Get received data and

	MOV	Char, A			;Save received data

	MOV	DPTR, #TypeTable
	MOVC	A, @A+DPTR		;Get type of received data from table
	MOV	CharType, A		;Save received data type

	MOV	A, BufState
	MOV	B, #03
	MUL	AB			;+4
	MOV	DPTR, #BufStateTable
	JMP	@A+DPTR

BufStateTable:
	LJMP	BufState_0
	LJMP	BufState_1
	LJMP	BufState_2
	LJMP	BufState_3
	LJMP	BufState_4
	LJMP	BufState_5
	LJMP	BufState_6
	LJMP	BufState_7
	LJMP	BufState_8
;------------------------------------------------------------------------
BufState_0:
	MOV	A, CharType

BufState_00:
	CJNE	A, #'A', BufState_01
	
	MOV	BufState, #State_1

	MOV	CmdNdx, #Cmd		;Initialize Command index

	MOV	R0, CmdNdx
	MOV	@R0, Char		;Save 1st received character

	CLR	A
	MOV	StrCnt, A		;Reset string counter
	MOV	ParamCnt, A		;Reset parameter counter

	MOV	R1, #12			;Reset parameters
	MOV	R0, #Parameter
BS00_LOOP:
	MOV	@R0, A
	INC	R0
	DJNZ	R1, BS00_LOOP	

	MOV	R0, #String		;Reset string ie. use null
	MOV	@R0, A
	RET	

BufState_01:
	CJNE	A, #'D', BufState_07
	RET
	
BufState_07:
	MOV	BufState, #State_7
	RET
;------------------------------------------------------------------------
BufState_1:
	MOV	A, CharType

BufState_11:
	CJNE	A, #'A', BufState_16

	INC	CmdNdx			;Increment command index, ie. char no
					; in command
	MOV	R0, CmdNdx
	MOV	@R0, Char		;Save nth received character
	RET	

BufState_16:
	CJNE	A, #'D', BufState_13

	MOV	BufState, #State_6

	MOV	R0, #CmdDelimiter
	MOV	@R0, Char		;Save delimiter info

	RET

BufState_13:
	CJNE	A, #'Q', BufState_12

	INC	StrCnt

	MOV	StrNdx, #(String-1)
	MOV	BufState, #State_3
	RET

BufState_12:
	CJNE	A, #'N', BufState_17

	INC	ParamCnt

	MOV	A, #Parameter
	MOV	ParamNdx, A		;Initialize parameter index, ie. 1st
	MOV	R0, A			; parameter, (out of possible three)

	CLR	A			;Convert ASCII to integer
	MOV  	@R0, A			;R4
	INC	R0
	MOV  	@R0, A
	INC	R0
	MOV  	@R0, A
	INC	R0

	CLR	C
	MOV	A, Char
	SUBB	A, #'0'
	MOV  	@R0, A			;Save received digit

	MOV	BufState, #State_2
	RET

BufState_17:
	MOV	BufState, #State_7
	RET
;------------------------------------------------------------------------
BufState_2:
	MOV	A, CharType

BufState_22:
	CJNE	A, #'N', BufState_25

	MOV	R0, ParamNdx
	MOV	AR4, @R0
	INC	R0
	MOV	AR5, @R0
	INC	R0
	MOV	AR6, @R0
	INC	R0
	MOV	AR7, @R0

	MOV  	R3, #00AH
	CLR  	A
	MOV  	R2, A
	MOV  	R1, A
	MOV  	R0, A
	LCALL	?C?LMUL		 	;Value = 10*Value

	MOV	A, ParamNdx
	ADD	A, #03
	MOV	R0, A

	CLR	C
	MOV  	A, Char			;Get new digit
	SUBB	A, #'0'

	CLR	C
	ADD	A, R7
	MOV	@R0, A
	DEC	R0
	CLR	A
	ADDC	A, R6
	MOV	@R0, A
	DEC	R0
	CLR	A			
	ADDC	A, R5
	MOV	@R0, A
	CLR	A			
	DEC	R0
	ADDC	A, R4
	MOV	@R0, A

	RET	

BufState_25:
	CJNE	A, #'S', BufState_26	;Separator

	MOV	BufState, #State_5
	RET
	
BufState_26:
	CJNE	A, #'D', BufState_27	;Delimiter

	MOV	BufState, #State_6

	MOV	R0, #CmdDelimiter
	MOV	@R0, Char		;Save delimiter info
	RET

BufState_27:
	MOV	BufState, #State_7
	RET
;------------------------------------------------------------------------
BufState_3:
	MOV	A, CharType

BufState_33:
	CJNE	A, #'Q', BufState_34

	INC	StrNdx

	MOV	R0, StrNdx
	MOV	@R0, #00

	MOV	BufState, #State_4
	RET	

BufState_34:
	INC	StrNdx

	MOV	R0, StrNdx
	MOV	@R0, Char
	RET
;------------------------------------------------------------------------
BufState_4:
	MOV	A, CharType

BufState_43:
	CJNE	A, #'Q', BufState_45

	MOV	R0, StrNdx
	MOV	@R0, Char

	MOV	BufState, #State_3
	RET	

BufState_45:
	CJNE	A, #'S', BufState_46
	MOV	BufState, #State_5
	RET	

BufState_46:
	CJNE	A, #'D', BufState_47

	MOV	BufState, #State_6

	MOV	R0, #CmdDelimiter
	MOV	@R0, Char		;Save delimiter info

	RET

BufState_47:
	MOV	BufState, #State_7
	RET
;------------------------------------------------------------------------
BufState_5:
	MOV	A, CharType

BufState_53:
	CJNE	A, #'Q', BufState_52

	INC	StrCnt

	MOV	StrNdx, #(String-1)	;Initialize string. NOTE only ONE
	MOV	BufState, #State_3	; string exists
	RET

BufState_52:
	CJNE	A, #'N', BufState_57

	INC	ParamCnt

	MOV	A, ParamNdx		;Prepare for next parameter
	ADD	A, #04			
	MOV	ParamNdx, A

	MOV	R0, A			;Initialize next parameter

	CLR	A			;Convert ASCII to integer
	MOV  	@R0, A			;R4
	INC	R0
	MOV  	@R0, A
	INC	R0
	MOV  	@R0, A
	INC	R0

	CLR	C
	MOV	A, Char
	SUBB	A, #'0'
	MOV  	@R0, A			;Save received digit

	MOV	BufState, #State_2
	RET
	
BufState_57:
	MOV	BufState, #State_7
	RET
;------------------------------------------------------------------------
BufState_6:
	MOV	A, Char
	CJNE	A, #080H, BufState_60

	LCALL	Command_Execute		;Execute command

BufState_60:
	MOV	BufState, #State_0	;Checksum error in recevied command
	RET
;------------------------------------------------------------------------
BufState_7:
	MOV	A, CharType

BufState_78:
	CJNE	A, #'D', BufState_77
	MOV	BufState, #State_8
	RET	

BufState_77:
	RET
;------------------------------------------------------------------------
BufState_8:
	MOV	BufState, #State_0
	RET	

;************************************************************************
;* Name:	Command_Execute
;* Function:	Validate and possibly execute received RS232 command
;* Revision:	0.1
;* Date:	970126, SAA/KEn
;* Input:	First, Second
;* Output:	-
;* Destroys:	Acc, B, R0, R1, R2, DPTR
;* Calls	-
;* Time:	-
;************************************************************************
Command_Execute:
	MOV	DPTR, #Command_Table-2
	MOV	R1, #0			;R1 is Command-counter

Command_Loop:
	MOV	R0, #Cmd
	MOV	A, @R0
	MOV	R2, A

	INC	R1
	MOV	A, R1
	MOV	B, #05
	MUL	AB
	MOVC	A, @A+DPTR

	JZ	Command_Not_Found	;Zero byte is end-of-table indicator
	CJNE	A, AR2, Command_Loop

	MOV	R0, #Cmd+1
	MOV	A, @R0
	MOV	R2, A

	MOV	A, R1
	MOV	B, #05
	MUL	AB
	INC	A
	MOVC	A, @A+DPTR
	CJNE	A, AR2, Command_Loop

	MOV	DPTR, #Command_Table	;Command validated
	MOV	A, R1
	MOV	B, #05
	MUL	AB
	JMP	@A+DPTR

Command_Not_Found:
	SETB	Illegal_Cmd
	RET

;************************************************************************
;* Name:	TestInputBuffer
;* Function:	Test if any characters in the RS232 input buffer
;* Revision:	0.1
;* Date:	970124, KEn
;* Input:	-
;* Output:	CY=0 if no new character, otherwise a character received
;* Destroys:	Acc, CY
;* Calls	-
;* Time:	6us
;************************************************************************
TestInputBuffer:
	MOV	R0, #RxInput
	MOV	A, @R0
	INC	R0
	CLR	C
	SUBB	A, @R0			;RxInput - RxOutput
	JNZ	NewCharReady		;if (( RxInput-RxOutput) == 0)..
					; No characters in buffer
	CLR	C
	RET

NewCharReady:				;else
	DEC	RxInputSize

	SETB	C			;Characters in buffer
	RET

;************************************************************************
;* Name:	WriteASCII/WriteChar
;* Function:	Write a character to the serial RS232 interface
;* 		( WriteASCII converts binary number 0-9 to ASCII value)
;* Revision:	0.1
;* Date:	970122, KEn
;* Input:	Character to transmit in Acc
;* Output:	Updates TxChkSum
;* Destroys:	Acc
;* Calls	-
;* Time:	-
;************************************************************************
WriteASCII:
	ANL	A, #00FH	;Send the ASCII-character for numbers 0-9
	ADD	A, #'0'

WriteChar:
	SETB	Tx_BUSY

	JNB	Tx_SBUF_Empty, $	;Wait for transmitter buffer to empty

	MOV	SBUF0, A

	ADD	A, TxChkSum
	MOV	TxChkSum, A		;Update checksum

	CLR	Tx_SBUF_Empty
	JNB	Tx_SBUF_Empty, $	;Wait for transmitter buffer to empty

	CLR	Tx_BUSY
	RET
	
;************************************************************************
;* Name:	WriteEndOfTx
;* Function:	Write delimiter and checksum to the serial RS232 interface
;* Revision:	0.1
;* Date:	970122, KEn
;* Input:	-
;* Output:	-
;* Destroys:	Acc
;* Calls	-
;* Time:	-
;************************************************************************
WriteEndOfTx:
	MOV	A, #';'
	LCALL	WriteChar

	MOV	A, TxChkSum
	ANL	A, #07FH

	LJMP	WriteChar
	
;************************************************************************
;* Name:	WriteString
;* Function:	Write a string to the serial RS232 interface
;* Revision:	1.0
;* Date:	971112, KEn
;* Input:	R0: Address of first char
;		if R0 == 0FFH, then use DPTR as source
;* Output:	Adding to TxChkSum
;* Destroys:	Acc, R0, R1
;* Calls	-
;* Time:	-
;************************************************************************
WriteString:
	MOV	A, #'"'
	LCALL	WriteChar

	CJNE	R0, #0FFH, ?WS_02	;Is output coming from DPTR..
	MOVX	A, @DPTR
?WS_01:
	JZ	?WS_END

	SETB	Tx_BUSY
	JNB	Tx_SBUF_Empty, $	;Wait for transmitter buffer to empty

	MOV	SBUF0, A			;Transmit character

	ADD	A, TxChkSum
	MOV	TxChkSum, A		;Update checksum

	CLR	Tx_SBUF_Empty
	JNB	Tx_SBUF_Empty, $	;Wait for transmitter buffer to empty

	CLR	Tx_BUSY

	INC	DPTR
	MOVX	A, @DPTR		;Get character
	
	SJMP	?WS_01

?WS_02:					;No, output is coming from R0
	MOV	A, @R0
?WS_03:
	JZ	?WS_END

	SETB	Tx_BUSY
	JNB	Tx_SBUF_Empty, $	;Wait for transmitter buffer to empty

	MOV	SBUF0, A			;Transmit character

	ADD	A, TxChkSum
	MOV	TxChkSum, A		;Update checksum

	CLR	Tx_SBUF_Empty
	JNB	Tx_SBUF_Empty, $	;Wait for transmitter buffer to empty

	CLR	Tx_BUSY

	INC	R0
	MOV	A, @R0			;Get character
	
	SJMP	?WS_03

?WS_END:
	MOV	A, #'"'
	LJMP	WriteChar

;************************************************************************
;* Name:	WriteInteger/WriteLong
;* Function:	Write a integer/long to the serial RS232 interface
;* Revision:	0.1
;* Date:	970122, KEn
;* Input:	R4, R5, R6, R7(LSB): long,  R6, R7(LSB): Integer
;* Output:	Updates TxChkSum
;* Destroys:	Acc, R0, R4, R5, R6
;* Calls	-
;* Time:	-
;************************************************************************
WriteInteger:
	CLR	A
	MOV	R4, A
	MOV	R5, A

WriteLong:
	LCALL	ConvertLong		;Convert binary number

	MOV	R1, #05
	MOV	R0, #Buffer

TestLeadingZero:			;Leading ZEROs are NOT transmitted
	MOV	A, @R0
	ANL	A, #0F0H
	JNZ	WriteNextUpper

	MOV	A, @R0
	ANL	A, #00FH
	JNZ	WriteNextLower

	INC	R0
	DJNZ	R1, TestLeadingZero

	MOV	R0, #Buffer+4
	SJMP	WriteNextLower
	
WriteNextUpper:
	MOV	A, @R0
	SWAP	A
	LCALL	WriteASCII		;Send HIGH

WriteNextLower:
	MOV	A, @R0
	LCALL	WriteASCII		;Send LOW

	INC	R0
	CJNE	R0, #Buffer+5, WriteNextUpper

	RET

;************************************************************************
;* Name:	ConvertLong
;* Function:	Convert a long to ASCII
;* Revision:	0.1
;* Date:	970122, KEn et.al
;* Input:	Binary R4, R5, R6, R7(LSB): integer
;* Output:	Output in buffer->buffer+4
;* Destroys:	R0, R4, R5, R6, R7
;* Calls	-
;* Time:	-
;************************************************************************
ConvertLong:
;	Buffer+0  +1  +2   +3   +4 
;	      99  99  99   99   99
;
;	This procedure converts a unsigned long ( 0 <= value < 2^32 ) to ASCII-
;	string with 12 digits.
;
;	Input is  R4 (MSB), R5, R6, R7 (LSB) which is in binary format
;	General:
;	Buffer -> Buffer+4 are destroyed
	MOV	R0, #Buffer

	CLR	A               ;Clear output area
	MOV	@R0, A
	INC	R0
	MOV	@R0, A
	INC	R0
	MOV	@R0, A
	INC	R0
	MOV	@R0, A
	INC	R0
	MOV	@R0, A

	MOV	R1, #32

BinaryLoop:
	MOV	A, R7		;Shift input left to get Most Significant
	RLC	A		; Bit into carry
	MOV	R7, A

	MOV	A, R6
	RLC	A
	MOV	R6, A

	MOV	A, R5
	RLC	A
	MOV	R5, A

	MOV	A, R4
	RLC	A
	MOV	R4, A

NextAdjust:
	MOV	R0, #Buffer+4

	MOV	A, @R0
	ADDC	A, @R0
	DA	A
	MOV	@R0, A

	DEC	R0
	MOV	A, @R0
	ADDC	A, @R0
	DA	A
	MOV	@R0, A

	DEC	R0
	MOV	A, @R0
	ADDC	A, @R0
	DA	A
	MOV	@R0, A

	DEC	R0
	MOV	A, @R0
	ADDC	A, @R0
	DA	A
	MOV	@R0, A

	DEC	R0
	MOV	A, @R0
	ADDC	A, @R0
	DA	A
	MOV	@R0, A

	DJNZ	R1, BinaryLoop	;Loop for 32 bits

	RET
END