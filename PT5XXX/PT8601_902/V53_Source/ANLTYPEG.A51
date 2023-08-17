$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG320.INC)		;Include the predefined 80C320 register set
$INCLUDE( MACROS.INC)		;Include user defined macros

;************************************************************************
;* Project: PT8601 Analog Test Pattern generator			*
;* 			PT8601/902 Recreation				*
;* Module:  ANLTYPEG.A51						*
;* Author:  Matt Millman						*
;* Org.  :  230730							*
;* Status:  Version 1.0 (the DALLAS 80C320 running at 14.756MHz)	*
;* 									*
;* This module contains the following functions:			*
;* 									*
;*	G7_F1L22							*
;*	G8_F1L22							*
;* 									*
;* Type 7 pattern: Philips 4:3 pattern					*
;* Type 8 pattern: Philips 4:3 pattern wo/APAL				*
;*									*
;* NOTE! This system can NOT handle displaying line 288 separately,	*
;* this line must ALWAYS be a copy of line 287				*
;*									*
;************************************************************************

NAME		TypeG_LineRoutines

PUBLIC	G7_F1L22, G8_F1L22

EXTRN CODE( GenericMSBPort, LineAdrPort)
EXTRN DATA( StatusPort, Status)
EXTRN BIT( Status_TXT_ON, Status_TXT_1)
EXTRN BIT( Text1Enable, Text2Enable)
EXTRN DATA( PatternPtr)
EXTRN DATA( ComplexPtr, ComplexCnt)

;************************************************************************

PALG_LineRoutine_Code	SEGMENT	CODE
	RSEG	PALG_LineRoutine_Code
	USING	1

;************************************************************************
;* Type 7: Philips pattern
;* Field n: 4 frames
;* Timing: Worst case: ?? cycles
;************************************************************************
G7_F1L22:				;PhilipsF1_G
	MOV	ComplexPtr+1, #HIGH(130-2)	;+2
	MOV	ComplexPtr, #LOW(130-2)	;+2

	MOV	ComplexCnt, #(32-1)			;+2
G7_F1L23A:
	UpdateType3 G7_F1L23			;+41

G7_F1L23:
	DJNZ	ComplexCnt, G7_F1L23A	;+2

	MOV	C, Text1Enable				;+1
	MOV	Status_TXT_ON, C			;+2

	MOV	ComplexCnt, #(17-1)			;+2
G7_F1L54A:
	UpdateType3 G7_F1L54			;+41

G7_F1L54:
	DJNZ	ComplexCnt, G7_F1L54A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text

	MOV	ComplexCnt, #(97-1)			;+2
G7_F1L70A:
	UpdateType3 G7_F1L70			;+41

G7_F1L70:
	DJNZ	ComplexCnt, G7_F1L70A	;+2

	UpdateType3 G7_F1L166			;+41

;************************************************************************
G7_F1L166:					;
	MOV	ComplexPtr+1, #HIGH(418-2)	;+2
	MOV	ComplexPtr, #LOW(418-2)	;+2

	MOV	ComplexCnt, #(77-1)			;+2
G7_F1L167A:
	UpdateType3 G7_F1L167			;+41

G7_F1L167:
	DJNZ	ComplexCnt, G7_F1L167A	;+2
	MOV	C, Text2Enable				;+1
	MOV	Status_TXT_ON, C			;+2
	SETB Status_TXT_1

	MOV	ComplexCnt, #(16)			;+2
G7_F1L243A:
	UpdateType3 G7_F1L243			;+41

G7_F1L243:
	DJNZ	ComplexCnt, G7_F1L243A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text
	CLR Status_TXT_1

	MOV	ComplexCnt, #(52-2)			;+2
G7_F1L259A:
	UpdateType3 G7_F1L259			;+41

G7_F1L259:
	DJNZ	ComplexCnt, G7_F1L259A	;+2
	UpdateType3 G7_F1L310			;+41

;************************************************************************
G7_F1L310:
	UpdateType4 -26, G7_F2L22

;************************************************************************
G7_F2L22:					;PhilipsF2_G
	MOV	ComplexPtr+1, #HIGH(131-2)	;+2
	MOV	ComplexPtr, #LOW(131-2)	;+2

	MOV	ComplexCnt, #(32-1)			;+2
G7_F2L23A:
	UpdateType3 G7_F2L23			;+41

G7_F2L23:
	DJNZ	ComplexCnt, G7_F2L23A	;+2
	MOV	C, Text1Enable				;+1
	MOV	Status_TXT_ON, C			;+2

	MOV	ComplexCnt, #(16)			;+2
G7_F2L54A:
	UpdateType3 G7_F2L54			;+41

G7_F2L54:
	DJNZ	ComplexCnt, G7_F2L54A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text

	MOV	ComplexCnt, #(97-1)			;+2
G7_F2L70A:
	UpdateType3 G7_F2L70			;+41

G7_F2L70:
	DJNZ	ComplexCnt, G7_F2L70A	;+2

	UpdateType3 G7_F2L166			;+41

;************************************************************************
G7_F2L166:					;
	MOV	ComplexPtr+1, #HIGH(419-2)	;+2
	MOV	ComplexPtr, #LOW(419-2)	;+2

	MOV	ComplexCnt, #(77-1)			;+2
G7_F2L167A:
	UpdateType3 G7_F2L167			;+41

G7_F2L167:
	DJNZ	ComplexCnt, G7_F2L167A	;+2
	MOV	C, Text2Enable				;+1
	MOV	Status_TXT_ON, C			;+2
	SETB Status_TXT_1

	MOV	ComplexCnt, #(16)			;+2
G7_F2L243A:
	UpdateType3 G7_F2L243			;+41

G7_F2L243:
	DJNZ	ComplexCnt, G7_F2L243A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text
	CLR Status_TXT_1

	MOV	ComplexCnt, #(52-2)			;+2
G7_F2L259A:
	UpdateType3 G7_F2L259			;+41

G7_F2L259:
	DJNZ	ComplexCnt, G7_F2L259A	;+2
	UpdateType3 G7_F2L310			;+41

;************************************************************************
G7_F2L310:
	UpdateType4 -25, G7_F3L22

;************************************************************************
G7_F3L22:				;PhilipsF1_G
	MOV	ComplexPtr+1, #HIGH(706-2)	;+2
	MOV	ComplexPtr, #LOW(706-2)	;+2

	MOV	ComplexCnt, #(32-1)			;+2
G7_F3L23A:
	UpdateType3 G7_F3L23			;+41

G7_F3L23:
	DJNZ	ComplexCnt, G7_F3L23A	;+2

	MOV	C, Text1Enable				;+1
	MOV	Status_TXT_ON, C			;+2

	MOV	ComplexCnt, #(17-1)			;+2
G7_F3L54A:
	UpdateType3 G7_F3L54			;+41

G7_F3L54:
	DJNZ	ComplexCnt, G7_F3L54A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text

	MOV	ComplexCnt, #(97-1)			;+2
G7_F3L70A:
	UpdateType3 G7_F3L70			;+41

G7_F3L70:
	DJNZ	ComplexCnt, G7_F3L70A	;+2

	UpdateType3 G7_F3L166			;+41

;************************************************************************
G7_F3L166:					;
	MOV	ComplexPtr+1, #HIGH(994-2)	;+2
	MOV	ComplexPtr, #LOW(994-2)	;+2

	MOV	ComplexCnt, #(77-1)			;+2
G7_F3L167A:
	UpdateType3 G7_F3L167			;+41

G7_F3L167:
	DJNZ	ComplexCnt, G7_F3L167A	;+2
	MOV	C, Text2Enable				;+1
	MOV	Status_TXT_ON, C			;+2
	SETB Status_TXT_1

	MOV	ComplexCnt, #(16)			;+2
G7_F3L243A:
	UpdateType3 G7_F3L243			;+41

G7_F3L243:
	DJNZ	ComplexCnt, G7_F3L243A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text
	CLR Status_TXT_1

	MOV	ComplexCnt, #(52-2)			;+2
G7_F3L259A:
	UpdateType3 G7_F3L259			;+41

G7_F3L259:
	DJNZ	ComplexCnt, G7_F3L259A	;+2
	UpdateType3 G7_F3L310			;+41

;************************************************************************
G7_F3L310:
	UpdateType4 -26, G7_F4L22

;************************************************************************
G7_F4L22:					;PhilipsF2_G
	MOV	ComplexPtr+1, #HIGH(707-2)	;+2
	MOV	ComplexPtr, #LOW(707-2)	;+2

	MOV	ComplexCnt, #(32-1)			;+2
G7_F4L23A:
	UpdateType3 G7_F4L23			;+41

G7_F4L23:
	DJNZ	ComplexCnt, G7_F4L23A	;+2
	MOV	C, Text1Enable				;+1
	MOV	Status_TXT_ON, C			;+2

	MOV	ComplexCnt, #(16)			;+2
G7_F4L54A:
	UpdateType3 G7_F4L54			;+41

G7_F4L54:
	DJNZ	ComplexCnt, G7_F4L54A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text

	MOV	ComplexCnt, #(97-1)			;+2
G7_F4L70A:
	UpdateType3 G7_F4L70			;+41

G7_F4L70:
	DJNZ	ComplexCnt, G7_F4L70A	;+2

	UpdateType3 G7_F4L166			;+41

;************************************************************************
G7_F4L166:					;
	MOV	ComplexPtr+1, #HIGH(995-2)	;+2
	MOV	ComplexPtr, #LOW(995-2)	;+2

	MOV	ComplexCnt, #(77-1)			;+2
G7_F4L167A:
	UpdateType3 G7_F4L167			;+41

G7_F4L167:
	DJNZ	ComplexCnt, G7_F4L167A	;+2
	MOV	C, Text2Enable				;+1
	MOV	Status_TXT_ON, C			;+2
	SETB Status_TXT_1

	MOV	ComplexCnt, #(16)			;+2
G7_F4L243A:
	UpdateType3 G7_F4L243			;+41

G7_F4L243:
	DJNZ	ComplexCnt, G7_F4L243A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text
	CLR Status_TXT_1

	MOV	ComplexCnt, #(52-2)			;+2
G7_F4L259A:
	UpdateType3 G7_F4L259			;+41

G7_F4L259:
	DJNZ	ComplexCnt, G7_F4L259A	;+2
	UpdateType3 G7_F4L310			;+41

;************************************************************************
G7_F4L310:
	UpdateType4 -25, G7_F1L22

;************************************************************************
;* Type 8:  Philips wo/APAL 
;* Field n: 
;* Timing: Worst case: ?? cycles
;************************************************************************
G8_F1L22:				;PhilipsF1_G
	MOV	ComplexPtr+1, #HIGH(1282-2)	;+2
	MOV	ComplexPtr, #LOW(1282-2)	;+2

	MOV	ComplexCnt, #(32-1)			;+2
G8_F1L23A:
	UpdateType3 G8_F1L23			;+41

G8_F1L23:
	DJNZ	ComplexCnt, G8_F1L23A	;+2

	MOV	C, Text1Enable				;+1
	MOV	Status_TXT_ON, C			;+2

	MOV	ComplexCnt, #(17-1)			;+2
G8_F1L54A:
	UpdateType3 G8_F1L54			;+41

G8_F1L54:
	DJNZ	ComplexCnt, G8_F1L54A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text

	MOV	ComplexCnt, #(97-1)			;+2
G8_F1L70A:
	UpdateType3 G8_F1L70			;+41

G8_F1L70:
	DJNZ	ComplexCnt, G8_F1L70A	;+2

	UpdateType3 G8_F1L166			;+41

;************************************************************************
G8_F1L166:					;
	MOV	ComplexPtr+1, #HIGH(1570-2)	;+2
	MOV	ComplexPtr, #LOW(1570-2)	;+2

	MOV	ComplexCnt, #(77-1)			;+2
G8_F1L167A:
	UpdateType3 G8_F1L167			;+41

G8_F1L167:
	DJNZ	ComplexCnt, G8_F1L167A	;+2
	MOV	C, Text2Enable				;+1
	MOV	Status_TXT_ON, C			;+2
	SETB Status_TXT_1

	MOV	ComplexCnt, #(16)			;+2
G8_F1L243A:
	UpdateType3 G8_F1L243			;+41

G8_F1L243:
	DJNZ	ComplexCnt, G8_F1L243A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text
	CLR Status_TXT_1

	MOV	ComplexCnt, #(52-2)			;+2
G8_F1L259A:
	UpdateType3 G8_F1L259			;+41

G8_F1L259:
	DJNZ	ComplexCnt, G8_F1L259A	;+2
	UpdateType3 G8_F1L310			;+41

;************************************************************************
G8_F1L310:
	UpdateType4 -26, G8_F2L22

;************************************************************************
G8_F2L22:					;PhilipsF2_G
	MOV	ComplexPtr+1, #HIGH(1283-2)	;+2
	MOV	ComplexPtr, #LOW(1283-2)	;+2

	MOV	ComplexCnt, #(32-1)			;+2
G8_F2L23A:
	UpdateType3 G8_F2L23			;+41

G8_F2L23:
	DJNZ	ComplexCnt, G8_F2L23A	;+2
	MOV	C, Text1Enable				;+1
	MOV	Status_TXT_ON, C			;+2

	MOV	ComplexCnt, #(16)			;+2
G8_F2L54A:
	UpdateType3 G8_F2L54			;+41

G8_F2L54:
	DJNZ	ComplexCnt, G8_F2L54A	;+2
	CLR	Status_TXT_ON		;+1 Clear possible text

	MOV	ComplexCnt, #(97-1)			;+2
G8_F2L70A:
	UpdateType3 G8_F2L70			;+41

G8_F2L70:
	DJNZ	ComplexCnt, G8_F2L70A	;+2

	UpdateType3 G8_F2L166			;+41

;************************************************************************
G8_F2L166:					;
	MOV	ComplexPtr+1, #HIGH(1571-2)	;+2
	MOV	ComplexPtr, #LOW(1571-2)	;+2

	MOV	ComplexCnt, #(77-1)			;+2
G8_F2L167A:
	UpdateType3 G8_F2L167			;+41

G8_F2L167:
	DJNZ	ComplexCnt, G8_F2L167A	;+2
	MOV	C, Text2Enable				;+1
	MOV	Status_TXT_ON, C			;+2
	SETB Status_TXT_1

	MOV	ComplexCnt, #(16)			;+2
G8_F2L243A:
	UpdateType3 G8_F2L243			;+41

G8_F2L243:
	DJNZ	ComplexCnt, G8_F2L243A		;+2
	CLR	Status_TXT_ON		;+1 Clear possible text
	CLR Status_TXT_1

	MOV	ComplexCnt, #(52-2)			;+2
G8_F2L259A:
	UpdateType3 G8_F2L259			;+41

G8_F2L259:
	DJNZ	ComplexCnt, G8_F2L259A	;+2
	UpdateType3 G8_F2L310			;+41

;************************************************************************
G8_F2L310:
	UpdateType4 -25, G8_F1L22

END
