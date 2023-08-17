;************************************************************************
;* Copyright PHILIPS TV TEST EQUIPMENT A/S, BRONDBY 1997		*
;* Project: PT8601 Analog Test Signal generator				*
;* Module:  MACROS.INC							*
;* Author:  Kim Engedahl, DEV						*
;* Org.  :  960702							*
;* Rev.  :  990308, KEn DEV						*
;* Status:  Version 1.2							*
;* 									*
;* This module contains the following functions:			*
;* 									*
;* Changes:								*
;* 990308: Renamed some variables					*
;* 990224: Released as version 2.6					*
;* 980928: Released as version 2.5					*
;* 980928: Added GreyScale5_G, GreyScale10_G, GreyScale5_M & 		*
;*	   GreyScale10_M. Added HWInformation & SW900Version.		*
;* 970703: Released as version 1.2					*
;* 970625: Added HWVersion						*
;* 970122: Added SWVersion						*
;* 970108: Added new signals						*
;************************************************************************

SWVersion		EQU	28
HWType			EQU	01	;This IS PT8601
HWVersion		EQU	2	;/900 version: 0=Normal 1,2,..= 901,902
HWInformation		EQU	0

Philips4x3		EQU	3*15
Philips4x3woAPAL	EQU	3*16

SyncTypeUU_G		EQU	000H
SyncTypeUV_G		EQU	001H
SyncTypeVV_G		EQU	002H
SyncTypeU0_G		EQU	003H
SyncTypeVU_G		EQU	004H
SyncLine_G		EQU	005H
BlackBurst_G		EQU	006H
SyncTypeUU_M		EQU	007H
SyncTypeUV_M		EQU	008H
SyncTypeVV_M		EQU	009H
SyncTypeU0_M		EQU	00AH
SyncTypeVU_M		EQU	00BH
Sync_M			EQU	00CH
Sync_Burst_M		EQU	00DH
Sync_Burst_Setup_M	EQU	00EH
Line7Puls_G		EQU	00FH
EBUColorbar_G		EQU	010H
CCIR17_G		EQU	011H		;Only available from RS232
CCIR18_G		EQU	012H
Multipulse_G		EQU	013H		;Only available from RS232
Whiteline_G		EQU	014H
Sinc5MHz_G		EQU	015H		;Only available from RS232
Line_sweep_G		EQU	016H		;Only available from RS232
Greyline75_G		EQU	017H
Red75_G			EQU	018H
Window15_G		EQU	019H
Window20_G		EQU	01AH
Window100_G		EQU	01BH
RulerForWindows_G	EQU	01CH
MarkerForRuler_G	EQU	01DH
Marker_Windows15_G	EQU	01EH
Marker_Windows20_G	EQU	01FH
Marker_Windows100_G	EQU	020H
X_Hatch_19lines_G	EQU	021H
Pluge_White_G		EQU	022H
Pluge_GreyC_G		EQU	023H
Pluge_GreyD_G		EQU	024H
Pluge_GreyE_G		EQU	025H
SafeArea_A_G		EQU	026H
SafeArea_B_G		EQU	027H
SafeArea_C_G		EQU	028H
SafeArea_D_G		EQU	029H
SafeArea_E_G		EQU	02AH
Shallowramp_G		EQU	02BH
SMPTEColorbar		EQU	02CH
BlueBars_SMPTE_M	EQU	02DH
I_White_Q_SMPTE_M	EQU	02EH
Window15IRE_M		EQU	02FH
Window20IRE_M		EQU	030H
Window100IRE_M		EQU	031H
RulerForWindows_M	EQU	032H
MarkerLine_M		EQU	033H
Marker_Windows15_M	EQU	034H
Marker_Windows20_M	EQU	035H
Marker_Windows100_M	EQU	036H
Whiteline_M		EQU	037H
X_Hatch_17lines_M	EQU	038H
Pluge_White_M		EQU	039H
Pluge_GreyC_M		EQU	03AH
Pluge_GreyD_M		EQU	03BH
Pluge_GreyE_M		EQU	03CH
SafeArea_A_M		EQU	03DH
SafeArea_B_M		EQU	03EH
SafeArea_C_M		EQU	03FH
SafeArea_D_M		EQU	040H
SafeArea_E_M		EQU	041H
Red_M			EQU	042H
Shallowramp_M		EQU	043H
FCC_Multiburst_M	EQU	044H
Colorbar75_G		EQU	045H
Colorbar100_G		EQU	046H
GreyScale5_G		EQU	047H
GreyScale10_G		EQU	048H
GreyScale5_M		EQU	049H
GreyScale10_M		EQU	04AH

UpdateType1 MACRO NoOfLines, LineLabel

	MOV	A, Status		;+2 Update status port with S1S0 etc.
	MOV	DPTR, #StatusPort	;+3
	MOVX	@DPTR, A		;+3

	MOV	A, R6			;+2 NOTE: GenericMSBPort MUST contain 0
	MOV	DPTR, #LineAdrPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

	MOV	TH0, #HIGH( NoOfLines)	;+3
	MOV	TL0, #LOW( NoOfLines)	;+3

	MOV	R3, #HIGH( LineLabel)	;+2
	MOV	R4, #LOW( LineLabel)	;+2

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+3 -----> +36
ENDM


UpdateType2 MACRO UpdateLine, NoOfLines, LineLabel

	MOV	A, Status		;+2
	MOV	DPTR, #StatusPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

$IF ( UpdateLine)
	MOV	DPH, R5			;+2 #LOW( StatusPort) = 0 -> DPL = 0

	MOV	A, R6			;+1
	MOVC	A, @A+DPTR		;+3

	MOV	DPTR, #LineAdrPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

	INC	R6			;+1
$ENDIF
	MOV	TH0, #HIGH( NoOfLines)	;+3
	MOV	TL0, #LOW( NoOfLines)	;+3

	MOV	R3, #HIGH( LineLabel)	;+2
	MOV	R4, #LOW( LineLabel)	;+2

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+3 -----> +28/+41
ENDM


UpdateType3 MACRO LineLabel
	MOV	A, Status		;+2
	MOV	DPTR, #StatusPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

	MOV	A, ComplexPtr		;+2
	ADD	A, #02			;+2
	MOV	ComplexPtr, A		;+2
	MOV	A, ComplexPtr+1		;+2
	ADDC	A, #0			;+2

	MOV	ComplexPtr+1, A		;+2
	MOV	DPTR, #GenericMSBPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

	MOV	A, ComplexPtr		;+2
	MOV	DPTR, #LineAdrPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

	CLR	A			;+1
	MOV	DPTR, #GenericMSBPort	;+3
	MOVX	@DPTR, A		;+3 Write update to line port

	MOV	TH0, #HIGH( -1)		;+3
	MOV	TL0, #LOW( -1)		;+3

	MOV	R3, #HIGH( LineLabel)	;+2
	MOV	R4, #LOW( LineLabel)	;+2

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+3 -----> +61
ENDM


UpdateType4 MACRO NoOfLines, LineLabel
	MOV	A, Status		;+2 Update status port with S1S0 etc.
	MOV	DPTR, #StatusPort	;+3
	MOVX	@DPTR, A		;+3

	MOV	TH0, #HIGH( NoOfLines)	;+3
	MOV	TL0, #LOW( NoOfLines)	;+3

	MOV	R3, #HIGH( LineLabel)	;+2
	MOV	R4, #LOW( LineLabel)	;+2

	MOV	A, R7			;+1
	POP	DPS			;+2
	POP	DPH			;+2
	POP	DPL			;+2
	POP	PSW			;+2
	RETI				;+3 -----> +28
ENDM