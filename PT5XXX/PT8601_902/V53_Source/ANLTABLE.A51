$NOMOD51			;Disable the predefined 8051 register set

$INCLUDE( REG52.INC)		;Include the predefined 8052 register set
$INCLUDE( MACROS.INC)		;Include user defined macros

;************************************************************************
;* Copyright PHILIPS TV TEST EQUIPMENT A/S, BRONDBY 1997		*
;* Project: PT8601 Analog Test Signal generator				*
;* Module:  ANLTABLE.A51						*
;* Author:  Kim Engedahl, DEV						*
;* Org.  :  970516							*
;* Rev.  :  990224, KEn DEV						*
;* Status:  Version 1.1							*
;* 									*
;* This module contains NO functions					*
;* Changes:								*
;* 990224: In CB75RedPattG: Colorbar_75 changed to EBUColorbar_G.	*
;*	    CB75RedPattG changed name to EBUCBRedPattG			*
;************************************************************************

NAME	PATTERN_Tables

PUBLIC	CB75GreyPattG, EBUCBRedPattG, Win15PattG, Win20PattG, Win100PattG
PUBLIC	CrossPattG, PLUGEPattG, SafePattG

PUBLIC	CBSMPTEPattM, Win15PattM, Win20PattM, Win100PattM, CrossPattM
PUBLIC	PLUGEPattM, SafePattM

;************************************************************************
		CSEG at 0800H
;NOTE!!
; The pattern definition is NOT allowed to pass from 0FFH to 000H ie.
; over a 255 byte boundary

;************************************************************************
;* PAL-G pattern definitions
;************************************************************************
CB75GreyPattG:	DB	Colorbar75_G
		DB	Greyline75_G

EBUCBRedPattG:	DB	EBUColorbar_G
		DB	Red75_G

Win15PattG:	DB	BlackBurst_G
		DB	RulerForWindows_G
		DB	MarkerForRuler_G
		DB	BlackBurst_G
		DB	Marker_Windows15_G
		DB	BlackBurst_G
		DB	Window15_G
		DB	BlackBurst_G

Win20PattG:	DB	BlackBurst_G
		DB	RulerForWindows_G
		DB	MarkerForRuler_G
		DB	BlackBurst_G
		DB	Marker_Windows20_G
		DB	BlackBurst_G
		DB	Window20_G
		DB	BlackBurst_G

Win100PattG:	DB	BlackBurst_G
		DB	RulerForWindows_G
		DB	MarkerForRuler_G
		DB	BlackBurst_G
		DB	Marker_Windows100_G
		DB	BlackBurst_G
		DB	Window100_G
		DB	BlackBurst_G

CrossPattG:	DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G
		DB	Whiteline_G
		DB	X_Hatch_19lines_G

PLUGEPattG:	DB	BlackBurst_G
		DB	Pluge_White_G
		DB	Pluge_GreyC_G
		DB	Pluge_GreyD_G
		DB	Pluge_GreyE_G
		DB	BlackBurst_G

SafePattG:	DB	BlackBurst_G
		DB	SafeArea_A_G
		DB	BlackBurst_G
		DB	SafeArea_B_G
		DB	BlackBurst_G
		DB	SafeArea_C_G
		DB	SafeArea_D_G
		DB	SafeArea_E_G
		DB	SafeArea_D_G
		DB	SafeArea_C_G
		DB	BlackBurst_G
		DB	SafeArea_B_G
		DB	BlackBurst_G
		DB	SafeArea_A_G
		DB	BlackBurst_G

;************************************************************************
;* NTSC pattern definitions
;************************************************************************
CBSMPTEPattM:	DB	SMPTEColorbar
		DB	BlueBars_SMPTE_M	
		DB	I_White_Q_SMPTE_M


Win15PattM:	DB	Sync_Burst_Setup_M
		DB	RulerForWindows_M
		DB	MarkerLine_M
		DB	Sync_Burst_Setup_M
		DB	Marker_Windows15_M
		DB	Sync_Burst_Setup_M
		DB	Window15IRE_M
		DB	Sync_Burst_Setup_M

Win20PattM:	DB	Sync_Burst_Setup_M
		DB	RulerForWindows_M
		DB	MarkerLine_M
		DB	Sync_Burst_Setup_M
		DB	Marker_Windows20_M
		DB	Sync_Burst_Setup_M
		DB	Window20IRE_M
		DB	Sync_Burst_Setup_M

Win100PattM:	DB	Sync_Burst_Setup_M
		DB	RulerForWindows_M
		DB	MarkerLine_M
		DB	Sync_Burst_Setup_M
		DB	Marker_Windows100_M
		DB	Sync_Burst_Setup_M
		DB	Window100IRE_M
		DB	Sync_Burst_Setup_M

CrossPattM:	DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M
		DB	Whiteline_M
		DB	X_Hatch_17lines_M

PLUGEPattM:	DB	Sync_Burst_Setup_M
		DB	Pluge_White_M
		DB	Pluge_GreyC_M
		DB	Pluge_GreyD_M
		DB	Pluge_GreyE_M
		DB	Sync_Burst_Setup_M

SafePattM:	DB	Sync_Burst_Setup_M
		DB	SafeArea_A_M
		DB	Sync_Burst_Setup_M
		DB	SafeArea_B_M
		DB	Sync_Burst_Setup_M
		DB	SafeArea_C_M
		DB	SafeArea_D_M
		DB	SafeArea_E_M
		DB	SafeArea_D_M
		DB	SafeArea_C_M
		DB	Sync_Burst_Setup_M
		DB	SafeArea_B_M
		DB	Sync_Burst_Setup_M
		DB	SafeArea_A_M
		DB	Sync_Burst_Setup_M

END