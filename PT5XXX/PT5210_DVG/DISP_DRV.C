/***************************************************************************/
/*	Copyright ProTeleVision Technologies A/S, BRONDBY 1998						*/
/*	Project:		PT5230 Digital Video Generator										*/
/*	Module:		DISP_DRV.C																	*/
/*	Author:		Kim Engedahl, DEV															*/
/*	Org. date:	960710																		*/
/*	Rev. date:	991103, KEn, DEV															*/
/*	Status:		Version 1.1																	*/
/*																									*/
/*	This module contains the following functions:									*/
/*																									*/
/*		bit DisplayBusyTest();																*/
/*		void InitDisplay();																	*/
/*		void WriteAddressLN1( UC pos);													*/
/*		void WriteAddressLN2( UC pos);													*/
/*		void ClearToPosLN1( UC pos);														*/
/*		void ClearToPosLN2( UC pos);														*/
/*		void ClearRestLN1();																	*/
/*		void ClearRestLN2();																	*/
/*		void WriteCodeLN1( char pos, code char* LineTxt);							*/
/*		void WriteCodeLN2( char pos, code char* LineTxt);							*/
/*		void WriteCode1( code char* LineTxt);											*/
/*		void WriteCode2( code char* LineTxt);											*/
/*		void WriteTxtLN1( char pos, char* LineTxt);									*/
/*		void WriteTxtLN2( char pos, char* LineTxt);									*/
/*		void WriteTxt1( char* LineTxt);													*/
/*		void WriteTxt2( char* LineTxt);													*/
/*		void WriteCharLN1( char pos, char val);										*/
/*		void WriteCharLN2( char pos, char val);										*/
/*		void WriteChar1( char val);														*/
/*		void WriteChar2( char val);														*/
/*		void WriteCGChar( UC Address, UC Data);										*/
/*		void CharBlinkLN2( UC Pos, UC status);											*/
/*																									*/
/*	Changes:																						*/
/* 991103 Replaced UserTimer with dedicated DispTimer in DisplayBusyTest()	*/
/* 980616 Released as 4008 002 06812													*/
/* 980514 Released as 4008 002 06811													*/
/* 980415 Display ALL characters above 127 as a placeholder						*/
/* 971218 removed include-file 52sync.h												*/
/* 970925 Added variable bit Line1Active.												*/
/***************************************************************************/

//******************************************************************
//	LCD Commands, (for the L4042):
//	Clear display - ALL memory (RAM) is erased							01
//	Cursor home 1st char. on 1st line										02
//	Direction of cursor with next character entry;
//		left																			04
//		right																			06
//	Display shift with data entry;
//		left																			07
//		right																			05
//	Cursor;
//		ON																				0E
//		OFF																			0C
//		Blink																			0D
//		Shift left																	10
//		Shift right																	14
//	Display control "ON"															0E
//	Display control "OFF"														0A
//		(when display off ALL memory is retained in memory)
//	Display shift with no data entry;
//		left																			18
//		right																			1C
// *****************************************************************

// Include files:

#include <xa.h>
#include <string.h>

#include "mas.h"
#include "disp_drv.h"

												// NOP is 3 clocks ie. 100ns at 30MHz
#define delay500	asm("NOP");asm("NOP");asm("NOP");asm("NOP");asm("NOP");

#define DisplayData		ud3

#define DisplayEN_High	{ ud4buf |= 0x01;	ud4 = ud4buf; }
#define DisplayEN_Low 	{ ud4buf &= 0xFE;	ud4 = ud4buf; }

#define DisplayEN_Pulse	{ DisplayEN_High; delay500; DisplayEN_Low; delay500; }

#define DisplayRS0_RW0	{ ud4buf &= 0xF9; ud4 = ud4buf; }
#define DisplayRS0_RW1	{ ud4buf &= 0xF9; ud4buf |= 0x02; ud4 = ud4buf; }
#define DisplayRS1_RW0	{ ud4buf &= 0xF9; ud4buf |= 0x04; ud4 = ud4buf; }
#define DisplayRS1_RW1	{ ud4buf |= 0x06; ud4 = ud4buf; }

#define MaxDisplayCharNo		40			// Number of characters on each line

							// Predefined patterns for the user-programmable addresses
							//	 in the display-(controller)
code UC CGCharacters[] = {
	0x1F, 0x1B, 0x1B, 0x1B, 0x1B, 0x1F, 0x1B, 0x1F, 	// Error =inverse '!'
	0x00, 0x02, 0x06, 0x0E, 0x06, 0x02, 0x00, 0x00, 	// Arrow LEFT
	0x04, 0x0E, 0x1F, 0x00, 0x1F, 0x0E, 0x04, 0x00, 	// Arrow UP/DOWN
	0x00, 0x08, 0x0C, 0x0E, 0x0C, 0x08, 0x00, 0x00, 	// Arrow RIGHT
	0x00, 0x0E, 0x08, 0x0C, 0x08, 0x0E, 0x00, 0x00, 	// Execute icon

	0x0E, 0x11, 0x11, 0x1F, 0x1B, 0x1B, 0x1F, 0x00, 	// Lock icon
	0x04, 0x0E, 0x1F, 0x00, 0x00, 0x00, 0x00, 0x00, 	// Arrow UP
	0x00, 0x00, 0x00, 0x00, 0x1F, 0x0E, 0x04, 0x00, 	// Arrow DOWN
	0x04, 0x04, 0x1F, 0x04, 0x1F, 0x04, 0x04, 0x00, 	// Not Equal icon
	0x0E, 0x01, 0x01, 0x1F, 0x1B, 0x1B, 0x1F, 0x00, 	// Unlock icon

	0x00, 0x0E, 0x12, 0x15, 0x11, 0x0E, 0x00, 0x00,	 	// SIGNAL-OUT icon
	0x00, 0x0E, 0x08, 0x08, 0x08, 0x0E, 0x00, 0x00, 	// Instant icon
	0x01, 0x01, 0x05, 0x09, 0x1F, 0x08, 0x04, 0x00, 	// Return icon
	0x00, 0x0E, 0x0A, 0x0E, 0x08, 0x08, 0x00, 0x00, 	// Preset icon
	0x00, 0x0E, 0x08, 0x0E, 0x02, 0x0E, 0x00, 0x00, 	// Store icon
	0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 	// Empty space
	
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x00,		// Bar 0/10
	0x00, 0x00, 0x10, 0x00, 0x10, 0x00, 0x1F, 0x00, 	// Bar 1/10
	0x00, 0x00, 0x10, 0x10, 0x10, 0x10, 0x1F, 0x00, 	// Bar 2/10
	0x00, 0x00, 0x18, 0x10, 0x18, 0x10, 0x1F, 0x00, 	// Bar 3/10
	0x00, 0x00, 0x18, 0x18, 0x18, 0x18, 0x1F, 0x00, 	// Bar 4/10
	0x00, 0x00, 0x1C, 0x18, 0x1C, 0x18, 0x1F, 0x00, 	// Bar 5/10
	0x00, 0x00, 0x1C, 0x1C, 0x1C, 0x1C, 0x1F, 0x00, 	// Bar 6/10
	0x00, 0x00, 0x1E, 0x1C, 0x1E, 0x1C, 0x1F, 0x00, 	// Bar 7/10
	0x00, 0x00, 0x1E, 0x1E, 0x1E, 0x1E, 0x1F, 0x00, 	// Bar 8/10
	0x00, 0x00, 0x1F, 0x1E, 0x1F, 0x1E, 0x1F, 0x00, 	// Bar 9/10
	0x00, 0x00, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x00, 	// Bar 10/10

	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x00, 	// Negative bar 0/10
	0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x1F, 0x00, 	// Negative bar 1/10
	0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x1F, 0x00, 	// Negative bar 2/10
	0x00, 0x00, 0x03, 0x01, 0x03, 0x01, 0x1F, 0x00, 	// Negative bar 3/10
	0x00, 0x00, 0x03, 0x03, 0x03, 0x03, 0x1F, 0x00, 	// Negative bar 4/10
	0x00, 0x00, 0x07, 0x03, 0x07, 0x03, 0x1F, 0x00, 	// Negative bar 5/10
	0x00, 0x00, 0x07, 0x07, 0x07, 0x07, 0x1F, 0x00, 	// Negative bar 6/10
	0x00, 0x00, 0x0F, 0x07, 0x0F, 0x07, 0x1F, 0x00, 	// Negative bar 7/10
	0x00, 0x00, 0x0F, 0x0F, 0x0F, 0x0F, 0x1F, 0x00, 	// Negative bar 8/10
	0x00, 0x00, 0x1F, 0x0F, 0x1F, 0x0F, 0x1F, 0x00, 	// Negative bar 9/10
	0x00, 0x00, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x00, 	// Negative bar 10/10 

	0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F, 0x10,	 	// Center bar 0/10
	0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F, 0x10, 	// Center bar 2/10
	0x10, 0x10, 0x18, 0x18, 0x18, 0x18, 0x1F, 0x10, 	// Center bar 4/10
	0x10, 0x10, 0x1C, 0x1C, 0x1C, 0x1C, 0x1F, 0x10, 	// Center bar 6/10
	0x10, 0x10, 0x1E, 0x1E, 0x1E, 0x1E, 0x1F, 0x10, 	// Center bar 8/10
	0x10, 0x10, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x10  	// Center bar 10/10
};

static near UC Line1Pos;		// Current position on Line 1 in the display
static near UC Line2Pos;		// Current position on Line 2 in the display
static bit Line1Active;			// 1: Line 1 active, 0: Line 2 active

static bit BUSY;
static near UC tmp;

/***************************************************************************/
/*	DisplayBusyTest													 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		991103, KEn			     													*/
/*																									*/
/*	Function:	Wait for display to signal ready to receive						*/
/*	Remarks:		Uses the global disp-timer DispTimer.								*/
/*					Note the test is NOT a global test for the display to accept*/
/*					a character, it is merely a ready flag when to write to the	*/
/*					display WITHOUT creating interfaerence on the screen			*/
/*	Returns:		0: if display changed from busy to ready before timeout		*/
/*					1: display didn't get ready before timeout						*/
/* Updates:		--																				*/
/***************************************************************************/
bit DisplayBusyTest() {
	
	DispTimer = 10;					// Set timeout-value at 100ms
	BUSY = 1;

	DisplayRS0_RW1;

	asm("NOP");							// Tas setup time, 140ns
	asm("NOP");

	do {
		delay500;

		DisplayEN_High;				// DisplayEN_High width min. 450ns

		delay500;						// Tddr data delay tim max. 320ns

		if (( ind1 & 0x40) == 0)	// Read & test port
			BUSY = 0;

		DisplayEN_Low;					// DisplayEN_High width min 450.ns

	} while (( DispTimer > 0) && BUSY);

	return( DispTimer == 0);
}

/***************************************************************************/
/*	InitDisplay															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970925, KEn			     													*/
/*																									*/
/*	Function:	Initialize the display controller									*/
/*	Remarks:		It is VERY important to keep the specified timing				*/
/* Returns:		--																				*/
/* Updates:		Resets Line1Pos and Line2Pos, which keeps track of the		*/
/*					cursor position on line 1 and line 2								*/
/***************************************************************************/
void InitDisplay() {

	DisplayRS0_RW0;

	waitms( 20);					// Delay for >= 15mS after POWER-ON

	DisplayData = 0x38;
	DisplayEN_Pulse;
	waitms( 7);						// Delay for >= 4.1ms

	DisplayData = 0x38;
	DisplayEN_Pulse;
	waitus( 200);					// Delay for >= 100us

	DisplayData = 0x38;
	DisplayEN_Pulse;
	waitus( 100);					// Delay for >= 40us

	DisplayData = 0x38;
	DisplayEN_Pulse;
	waitus( 100);					// Delay for >= 40us
	
	DisplayData = 0x06;
	DisplayEN_Pulse;
	waitus( 100);					// Delay for >= 40us

	DisplayData = 0x0C;
	DisplayEN_Pulse;
	waitus( 100);					// Delay for >= 40us 
	
	DisplayData = 0x01;
	DisplayEN_Pulse;
	waitms( 4);						// Delay for >= 1.64ms

	DisplayData = 0x80;
	DisplayEN_Pulse;
	waitus( 100);					// Delay for >= 40us

	Line1Pos = Line2Pos = 0;
	Line1Active = TRUE;
}

/***************************************************************************/
/*	WriteAddressLN1													 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970925, KEn			     													*/
/*																									*/
/*	Function:	Set (invisible) cursor in display line 1 at position pos		*/
/*	Remarks:		--																				*/
/* Returns:		--																				*/
/* Updates:		Line1Pos, which keeps track of the cursor-position on line 1*/
/*					Line1Active which keeps track of which line is active			*/
/***************************************************************************/
void WriteAddressLN1( UC pos) {

	Line1Pos = pos;
	Line1Active = TRUE;

	DisplayBusyTest();				// Wait for "safe" period to update display

	DisplayRS0_RW0;

	DisplayData = Line1Pos | 0x80;
	DisplayEN_Pulse;
	
	DisplayRS0_RW1;
}

/***************************************************************************/
/*	WriteAddressLN2													 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970925, KEn			     													*/
/*																									*/
/*	Function:	Set (invisible) cursor in display line 2 at position pos		*/
/*	Remarks:		--																				*/
/* Returns:		--																				*/
/* Updates:		Line2Pos, which keeps track of the cursor-position on line 2*/
/*					Line1Active which keeps track of which line is active			*/
/***************************************************************************/
void WriteAddressLN2( UC pos) {

	Line2Pos = pos;
	Line1Active = FALSE;

	DisplayBusyTest();				// Wait for "safe" period to update display

	DisplayRS0_RW0;

	DisplayData = Line2Pos | 0xC0;
	DisplayEN_Pulse;
	
	DisplayRS0_RW1;
}

/***************************************************************************/
/*	WriteChar1															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970925, KEn			     													*/
/*																									*/
/*	Function:	Write ONE character on current cursor position on line 1		*/
/*	Remarks:		--																				*/
/* Returns:		--																				*/
/* Updates:		Line1Pos, which keeps track of the cursor-position on line 1*/
/***************************************************************************/
void WriteChar1( char val) {

	if ( !Line1Active)
		WriteAddressLN1( Line1Pos);

	DisplayBusyTest();				// Wait for "safe" period to update display

	DisplayRS1_RW0;

	if ( val < 0)						// If val > 127 insert a placeholder
		val = 0xDB;

	DisplayData = val;
	DisplayEN_Pulse;

	DisplayRS1_RW1;

	Line1Pos++;
}

/***************************************************************************/
/*	WriteChar2															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970925, KEn			     													*/
/*																									*/
/*	Function:	Write ONE character on current cursor position on line 2		*/
/*	Remarks:		--																				*/
/* Returns:		--																				*/
/* Updates:		Line2Pos, which keeps track of the cursor-position on line 2*/
/***************************************************************************/
void WriteChar2( char val) {

	if ( Line1Active)
		WriteAddressLN2( Line2Pos);

	DisplayBusyTest();				// Wait for "safe" period to update display

	DisplayRS1_RW0;

	if ( val < 0)						// If val > 127 insert a placeholder
		val = 0xDB;

	DisplayData = val;
	DisplayEN_Pulse;

	DisplayRS1_RW1;

	Line2Pos++;
}

/***************************************************************************/
/*	ClearToPosLN1														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Clear from current cursor position to position <pos>			*/
/*					on line 1 																	*/
/*	Remarks:		Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void ClearToPosLN1( UC pos) {

	while ( Line1Pos < pos)
		WriteChar1( ' ');
}

/***************************************************************************/
/*	ClearToPosLN2														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Clear from current cursor position to position <pos>			*/
/*					on line 2 																	*/
/*	Remarks:		Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void ClearToPosLN2( UC pos) {

	while ( Line2Pos < pos)
		WriteChar2( ' ');
}

/***************************************************************************/
/*	ClearRestLN1														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Clear rest of line 1 from current cursor position				*/
/*	Remarks:		Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void ClearRestLN1() {

	while ( Line1Pos < MaxDisplayCharNo)
		WriteChar1( ' ');
}

/***************************************************************************/
/*	ClearRestLN2														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Clear rest of line 2 from current cursor position				*/
/*	Remarks:		Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void ClearRestLN2() {

	while ( Line2Pos < MaxDisplayCharNo)
		WriteChar2( ' ');
}

/***************************************************************************/
/*	WriteCharLN1														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a character at a specific position on line 1				*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not.																			*/
/*					Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCharLN1( char pos, char val) {

	WriteAddressLN1( pos);

	WriteChar1( val);
}

/***************************************************************************/
/*	WriteCharLN2														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a character at a specific position on line 2				*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not.																			*/
/*					Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCharLN2( char pos, char val) {

	WriteAddressLN2( pos);

	WriteChar2( val);
}

/***************************************************************************/
/*	WriteCodeLN1														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string starting at a specific position on line 1		*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 1.		*/
/*					Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCodeLN1( char pos, code char* LineTxt) {

	WriteAddressLN1( pos);

	while ( tmp = *LineTxt++)
		WriteChar1( tmp);
}

/***************************************************************************/
/*	WriteCodeLN2														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string starting at a specific position on line 2		*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 2.		*/
/*					Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCodeLN2( char pos, code char* LineTxt) {

	WriteAddressLN2( pos);

	while ( tmp = *LineTxt++)
		WriteChar2( tmp);
}

/***************************************************************************/
/*	WriteCode1															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string starting at the current cursor position on 	*/
/*					line 1																		*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 1.		*/
/*					Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCode1( code char* LineTxt) {

	while ( tmp = *LineTxt++)
		WriteChar1( tmp);
}

/***************************************************************************/
/*	WriteCode2															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string starting at the current cursor position on 	*/
/*					line 2																		*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 2.		*/
/*					Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCode2( code char* LineTxt) {

	while ( tmp = *LineTxt++)
		WriteChar2( tmp);
}

/***************************************************************************/
/*	WriteTxtLN1															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string from DATA memory starting at a specific 		*/
/*					position on line 1.														*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 1.		*/
/*					Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteTxtLN1( char pos, char* LineTxt) {

	WriteAddressLN1( pos);

	while ( tmp = *LineTxt++)
		WriteChar1( tmp);
}

/***************************************************************************/
/*	WriteTxtLN2															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string from DATA memory starting at a specific 		*/
/*					position on line 2.														*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 2.		*/
/*					Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteTxtLN2( char pos, char* LineTxt) {

	WriteAddressLN2( pos);

	while ( tmp = *LineTxt++)
		WriteChar2( tmp);
}

/***************************************************************************/
/*	WriteTxt1															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string fomr DATA memory starting at the current 		*/
/*					cursor position on line 1.												*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 1.		*/
/*					Cursor position on line 1 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteTxt1( char* LineTxt) {

	while ( tmp = *LineTxt++)
		WriteChar1( tmp);
}

/***************************************************************************/
/*	WriteTxt2															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a string fomr DATA memory starting at the current 		*/
/*					cursor position on line 2.												*/
/*	Remarks:		Note that there is no test whether the position is legal or	*/
/*					not or if the string will exceed the length of line 2.		*/
/*					Cursor position on line 2 is updated								*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteTxt2( char* LineTxt) {

	while ( tmp = *LineTxt++)
		WriteChar2( tmp);
}

/***************************************************************************/
/*	WriteCGChar															 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Write a predefined pattern, (from the CGPatterns array), to	*/
/*					one of the eight user programmable addresses in the display	*/
/*	Remarks:		Note that there is no test whether the display-address is	*/
/*					legal or not, nor is there any test of the existence of the	*/
/*					data.																			*/
/*					Address is on of the eight user programmable addresses in	*/
/*					the display, Data is one of the predefined patterns in the	*/
/*					array CGPatterns[]														*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void WriteCGChar( UC Address, UC Data) {

	DisplayBusyTest(); 				// Wait for "safe" period to update display

	DisplayRS0_RW0;
											// Address refer to one of the eight user
											//  programmable characters in the display
	DisplayData = 0x40 + 8*Address;
	DisplayEN_Pulse;

	for ( tmp = 0; tmp < 8; tmp++) {
		DisplayBusyTest();			// Wait for "safe" period to update display

		DisplayRS1_RW0;
											// Data refer to one of the predefined pattern
		DisplayData = CGCharacters[ 8*Data + tmp];
		DisplayEN_Pulse;

		DisplayRS1_RW1;
	}
}

/***************************************************************************/
/*	CharBlinkLN2														 	  	 DISP_DRV.C */
/*																									*/
/* Author:		Kim Engedahl, DEV, 950403	 											*/
/* Revised:		970108, KEn			     													*/
/*																									*/
/*	Function:	Makes the character at position <pos> on line2 blink 			*/
/*	Remarks:		Note that there is no test whether the display-address is	*/
/*					legal or not.																*/
/*					The blink function used is the built-in blink in the display*/
/*					Blinking is done by showing the character and a black field	*/
/*					with an interval of app. 0.4sec										*/
/*					status > 0, makes it blink 											*/
/* Returns:		--																				*/
/* Updates:		--																				*/
/***************************************************************************/
void CharBlinkLN2( UC Pos, UC status) {

	DisplayBusyTest();				// Wait for "safe" period to update display

	DisplayRS0_RW0;

	DisplayData = Pos | 0xC0;
	DisplayEN_Pulse;

	DisplayBusyTest();				// Wait for "safe" period to update display

	DisplayRS0_RW0;

	if ( status > 0)
		DisplayData = 0x0D;
	else
		DisplayData = 0x0C;

	DisplayEN_Pulse;

	DisplayRS1_RW1;
}
