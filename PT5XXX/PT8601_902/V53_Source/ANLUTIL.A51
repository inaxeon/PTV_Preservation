$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG320.INC)		;Include the predefined 80C320 register set
$INCLUDE( MACROS.INC)		;Include user defined macros

;************************************************************************
;* Project: PT8601 Analog Test Pattern generator			*
;* 			PT8601/902 Recreation				*
;* Module:  ANLUTIL.A51							*
;* Author:  Kim Engedahl, DEV						*
;			Modified by Matt Millman 			*
;* Org.  :  230730							*
;* Status:  Version 1.0 (the DALLAS 80C320 running at 14.756MHz)	*
;* 									*
;************************************************************************

NAME		ANLUTIL

EXTRN CODE( TextPort)
EXTRN CODE( TextTable)
EXTRN DATA( OSDTextLN1, OSDTextLN2)
EXTRN DATA( PatternType, PatternAttr)
EXTRN BIT( Text1Enable, Text2Enable)
EXTRN BIT( Status_TXT_ON)
EXTRN BIT( Tmp1Bit, Tmp2Bit)

PUBLIC WriteOSDText, InsertOSDText

;************************************************************************
UtilCode		SEGMENT	CODE
			RSEG	UtilCode
			USING	0

;************************************************************************
;* Name:	StringLen
;* Function:	Calculate the length of a string in samples
;* Revision:	1.0
;* Date:	980527, KEn
;* Input:	R0: String to calucate length of
;* Output:	R1
;* Destroys:	Acc, R1, DPTR
;* Calls	-
;* Time:	-
;************************************************************************
StringLen:
	MOV	R1, #0

?SLLoop:
	CLR	C
	MOV	A, @R0		;Get char to display
	JZ	?SLEnd

	MOV	DPTR, #TextTable

	SUBB	A, #020H
	RLC	A

	JNC	?SLGetSamples		;If table entry > 255
	INC	DPH1			; TextTable += 256
?SLGetSamples:
	MOVC	A, @A+DPTR		;Get no of samples
	ADD	A, R1			;Add no of samples to result
	XCH	A, R1

	INC	R0			;Increment string data pointer
	SJMP	?SLLoop
?SLEnd:
	INC	R1			; Fudge for half-space added below
	RET				;Return string length in R1

;************************************************************************
;* Name:	CenterString
;* Function:	Center a string around a user specified y coordinate
;* Revision:	1.0
;* Date:	980525, KEn
;* Input:	R2: center position, R0: text string
;* Output:	Acc: position to center text
;* Destroys:	Acc, R0, R1, DPTR
;* Calls	-
;* Time:	-
;************************************************************************
CenterString:
	LCALL	StringLen		;Calculate length of string in samples
					;Result returned in R1
	CLR	C
	MOV	A, R1			
	RRC	A			;Divide result by 2
	
	XCH	A, R2			;Get center position
	CLR	C
	SUBB	A, R2			;return( Center - StringLen/2)
	RET

;************************************************************************
;* Name:	ClearOSDLine
;* Function:	Clear a textline in the dualport RAM
;* Revision:	1.0
;* Date:	980602, KEn
;* Input:	R1: Lineno.
;* Output:	-
;* Destroys:	Acc, R0, DPTR
;* Calls	-
;* Time:	-
;************************************************************************
ClearOSDLine:
	CJNE	R1, #01, ?COLLine2
	MOV	DPTR, #TextPort+080H	;Start of text RAM for line 1

	JMP	?COLClearLine

?COLLine2:
	CJNE	R1, #02, ?COLEnd
	MOV	DPTR, #TextPort+0180H	;Start of text RAM for line 2

	JNC	?COLClearLine

?COLClearLine:
	MOV	R0, #080H		;Clear 128 bytes of text RAM
	CLR	A
?COLLoop:
	MOVX	@DPTR, A
	INC	DPTR
	DJNZ	R0, ?COLLoop		;Cleared ALL 128 bytes ??
?COLEnd:
	RET

;************************************************************************
;* Name:	WriteOSDText
;* Function:	Update text insertion in video text RAM
;* Revision:	1.1
;* Date:	990421, KEn
;* Input:	R1: LineNo
;* Output:	-
;* Destroys:	Acc, B, R0, R1, R2, R3 DPTR, DPTR1
;* Calls	-
;* Time:	-
;************************************************************************
WriteOSDText:
	MOV	C, Text1Enable
	MOV	Tmp1Bit, C
	CLR	Text1Enable		;Disable TEXT while loading RAM

	MOV	C, Text2Enable
	MOV	Tmp2Bit, C
	CLR	Text2Enable		;Disable TEXT while loading RAM

	; MM: Fun fact: PT8601/00 waits on Status_S0 which is wrong (and a bug)
	JB	Status_TXT_ON, $ ; Wait for bit to clear

	CJNE	R1, #01, ?WOTLine2	;Is line 1 is to be updated?

	MOV R3, #050h	; This is the horizontal text position for standard patterns

	MOV	A, PatternType	
	CJNE	A, #Philips4x3, ?WOTLine1Insert

	MOV	R2, #61			;Center text in complex text style PAL
	MOV	R0, #OSDTextLN1
	LCALL	CenterString		;Destroys: Acc, R0, R1, DPTR
	MOV	R3, A
?WOTLine1Insert:
	MOV	R1, #01			;
	LCALL	ClearOSDLine		;Destroys: Acc, R0, DPTR

	MOV	A, R3
	LJMP 	InsertOSDText

?WOTLine2:
	CJNE	R1, #02, ?WOTEnd	;Is line 2 is to be updated?

	MOV	A, PatternType

	MOV	R2, #61			;Center text in complex text style PAL
	MOV	R0, #OSDTextLN2
	LCALL	CenterString		;Destroys: Acc, R0, R1, DPTR
	MOV	R3, A
	MOV	R1, #02
	LCALL	ClearOSDLine		;Destroys: Acc, R0, DPTR

	MOV	A, R3
	LJMP 	InsertOSDText

?WOTEnd:
	RET

;************************************************************************
;* Name:	InsertOSDText
;* Function:	Insert string into video RAM
;* Revision:	1.1
;* Date:	000705, KEn
;* Input:	R1: LineNo, A: X-Pos
;* Output:	-
;* Destroys:	Acc, B, R0, R1, R2, DPTR, DPTR1
;* Calls	-
;* Time:	-
;************************************************************************
InsertOSDText:
	CJNE	R1, #01, ?IOTLine2	;Is line 1 to be updated?

	MOV	DPTR, #TextPort+080H	;Start of text RAM for line 1
	MOV	R0, #OSDTextLN1
	SJMP	?IOTContinue

?IOTLine2:
	CJNE	R1, #02, ?IOTEnd	;Is line 2 to be updated?
	MOV	R0, #OSDTextLN2
	MOV	DPTR, #TextPort+180H	;Start of text RAM for line 2

?IOTContinue:
	ADD	A, DPL			;Add X-Position to start of line
	MOV	DPL, A
	MOV	A, DPH
	ADDC	A, #00
	MOV	DPH, A

	MOV	A, #094
	MOVX	@DPTR, A		;Write half a space to RAM
	INC	DPTR

?IOTWriteText:
	CLR	C
	MOV	A, @R0		;Get char to display
	JZ	?IOTEnd

	INC	DPS			;Select text table pointer
	MOV	DPTR, #TextTable

	SUBB	A, #020H
	RLC	A
	MOV	B, A			;Table entry

	JNC	?IOTGetSamples		;If table entry > 255
	INC	DPH1			; TextTable += 256
?IOTGetSamples:
	MOVC	A, @A+DPTR		;Get no of samples
	MOV	R2, A

	MOV	A, B
	INC	A
	MOVC	A, @A+DPTR		;Get address of 1st character

	INC	R0			;Increment text pointer

	INC	DPS 			;Select video RAM pointer
?IOTNextSample:
	PUSH	ACC
	PUSH	DPL

	MOV	A, DPL			;Check if text posistion exceeds
	ANL	A, #07FH		; position 103
	SETB	C
	SUBB	A, #103

	POP	DPL	
	POP	ACC

	JNC	?IOTEnd			;and end if it does 

	MOVX	@DPTR, A		;Write character address to video RAM
	INC	A
	INC	DPTR			;Increment video RAM pointer
	DJNZ	R2, ?IOTNextSample

	SJMP	?IOTWriteText

?IOTEnd:

	MOV	C, Tmp1Bit
	MOV	Text1Enable, C
	MOV	C, Tmp2Bit
	MOV	Text2Enable, C

	MOV	DPS, #0			;Select "default" pointer
	RET

END