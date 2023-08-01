/***************************************************************************/
/*	Copyright ProTeleVision Technologies A/S, BRONDBY 1998						*/
/*	Project:		PT5230 Digital Video Generator										*/
/*	Module:		KEYB_DRV.H																	*/
/*	Author:		Kim Engedahl, DEV															*/
/*	Org. date:	980203																		*/
/*	Rev. date:	980616, KEn, DEV															*/
/*	Status:		Version 1.0																	*/
/*																									*/
/*	Changes:																						*/
/* 980616: Released as 4008 002 06812													*/
/* 980514: Released as 4008 002 06811													*/
/***************************************************************************/

#define LEFTButton          0x1E
#define DOWNButton          0x1B
#define RIGHTButton         0x17
#define UPButton            0x1D

#define EXECButton          0x0F

#define OUTPUTButton        0x3B
#define PRESETButton        0x3D
#define GENLOCKButton       0x2F

#define NOButton			0x3F
#define NOCommand			0x3F
#define KeybMask            0x3F

#define MASTERButton		LEFTButton & RIGHTButton & EXECButton
#define FACTORYButton		LEFTButton & RIGHTButton

#define NormalRepeatFreq	15
#define FastRepeatFreq		4

extern UC Button;
extern UC OldButton;
extern UC ButtonCommand;
extern UC OldButtonCommand;

extern UC RepeatCount;
extern UC RepeatDelay;
extern UC Repeat1Delay;

extern bit ButtonEnable;
extern bit HorizontalRepeat;
extern bit VerticalRepeat;
extern bit RepeatOn;
extern bit CombiOn;

extern UC UpdateLEDs();
extern bit ButtonReady();
