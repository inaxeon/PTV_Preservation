/***************************************************************************/
/*	Copyright ProTeleVision Technologies A/S, BRONDBY 1998						*/
/*	Project:		PT5230 Digital Video Generator										*/
/*	Module:		PIIC2.C																		*/
/*	Author:		Preben Christiansen, DEV												*/
/*	Org. date:	960713																		*/
/*	Rev. date:	980616, KEn DEV															*/
/*	Status:		Version 2.0 																*/
/* Purpose:		IIC driver for IIC2 on ext. port										*/
/*																									*/
/*	This module contains the following functions:									*/
/*																									*/
/*		bit ByteTxb( UC XS)																	*/
/*		UC IIC2Read( UC Address)															*/
/*		bit IIC2Write( UC Address, UC Data)												*/
/*		bit IIC2Write2( UC Address, UC Data, UC Data2)								*/
/*		bit IIC2WrStr( UC Address, UC subadr, char *s)								*/
/*		bit IIC2RdStr( UC Address, UC subadr, char *s)								*/
/*		bit IIC2WrLongInt( UC Address, UC subadr, UL a, UI b)						*/
/*		UL IIC2RdLong( UC Address, UC subadr)											*/
/*		UI IIC2RdInt( UC Address, UC subadr)											*/
/*																									*/
/*	Changes:																						*/
/* 980616: Released as 4008 002 06812													*/
/* 980514: Released as 4008 002 06811													*/
/***************************************************************************/

#include <string.h>
#include <xa.h>                      // define 8051 registers 

#include "mas.h"
#include "util.h"
#include "iic.h"

#define SDA			(( ind1 & 8)>>3)
#define SCL			( ind1 & 4)
#define SDA_0		{ ud1buf &= ~8; ud1= ud1buf;}
#define SCL_0		{ ud1buf &= ~4; ud1= ud1buf;}
#define SDA_1		{ ud1buf |= 8; ud1= ud1buf;}
#define SCL_1		{ ud1buf |= 4; ud1= ud1buf;}

// Each "pau=0" delays xx us. (0.15?)
#define PAUS0		pau=0;
#define PAUS		PAUS0;PAUS0
#define PAUS1		PAUS0;PAUS0;PAUS0
#define SCL_3L		SCL_0;PAUS1;PAUS;PAUS
#define SCL_3H		SCL_1;PAUS1;PAUS1
#define STARTCond	SDA_0;PAUS1;PAUS1;PAUS;SCL_0
#define STOPCond	SDA_0;SCL_3L;SCL_1;while((SCL)==0); SCL_3H;SDA_1;PAUS1;PAUS

#define Retry			3

UC IIC2ErrorCode;

static near UC pau;
sbit  CY @ 0x207;				     // Carry
sbit  Acknowledge;

/***************************************************************************/
/*	ByteTxb																 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		970112, KEn			     													*/
/*																									*/
/*	Function:	EEPROM int read from IIC-bus 2										*/
/*	Remarks:																						*/
/*	Returns:																						*/
/*	Updates:		-																				*/
/***************************************************************************/
bit ByteTxb( UC XS) {

	static bit Ack;
	register UC NoOfBit = 8;

   do {									// Coded to almost fastest execute time
		SCL_0;
		XS <<= 1;
		if ( CY)
			SDA_1
		else
			SDA_0;
		PAUS1;
		SCL_1; PAUS1; PAUS;
		while( SCL == 0)
			;
		SCL_0; PAUS;
	} while( --NoOfBit);

	SDA_1; SDA_1; SDA_1; PAUS1;
											// Ready for reading Acknowledge bit
	SCL_1; PAUS; PAUS;
	while( SCL == 0)
		;
	Ack = !( SDA);						// Read here ack-bit
	SCL_0;

	return( Ack);
}

/***************************************************************************/
/*	IIC2Read																 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:																					*/
/*	Remarks:																						*/
/*	Returns:		Byte read from address													*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
UC IIC2Read( UC Address) {

	register UC B;

	IIC2ErrorCode = RxIICTimeout;;

	STARTCond;

	for ( B=0; B < Retry; B++)
		if ( Acknowledge = ByteTxb( Address+1)) {
			IIC2ErrorCode = NoIICError;

			PAUS1; PAUS;

			B = 0;							// Read byte into B
			Address = 8;					// Use Address as loop - counter

			do {
				PAUS0;
				SCL_1; PAUS1;
				while(( SCL) == 0)
					;
				B += B + SDA;				// B += B + (char)SDA;
				SCL_0; PAUS1; PAUS; PAUS;
			} while ( --Address != 0);

		   // Write Acknowledge bit  (`1` for last byte to read )

			SDA_1;
			SCL_1; PAUS1; PAUS;pau=0;
			while((SCL) == 0)
				;
			SCL_0;
			break;
		}

	STOPCond;

	return( B);
}

/***************************************************************************/
/*	IIC2Write															 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	Write one byte to IIC address											*/
/*	Remarks:		--																				*/
/*	Returns:		Acknowledge bit, 1:OK, 0:ERROR										*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
bit IIC2Write( UC Address, UC Data) {

	register UC i;

	IIC2ErrorCode = TxIICTimeout;

	STARTCond;

	for ( i=0; i < Retry; i++)
		if ( Acknowledge = ByteTxb( Address)) {
			IIC2ErrorCode = TxIICDataError;

			if ( Acknowledge = ByteTxb( Data))
				IIC2ErrorCode = NoIICError;
			break;
		}

	STOPCond;

	return( Acknowledge);
}

/***************************************************************************/
/*	IIC2Write2															 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	Write two bytes to IIC address										*/
/*	Remarks:		--																				*/
/*	Returns:		Acknowledge bit, 1:OK, 0:ERROR										*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
bit IIC2Write2( UC Address, UC Data, UC Data2) {

	register UC i;

	IIC2ErrorCode = TxIICTimeout;

	STARTCond;

	for ( i=0; i < Retry; i++)
		if ( Acknowledge = ByteTxb( Address)) {
			IIC2ErrorCode = TxIICDataError;

			if ( Acknowledge = ByteTxb( Data))
				if ( Acknowledge = ByteTxb( Data2))
					IIC2ErrorCode = NoIICError;
			break;
		}

	STOPCond;
   waitms(20);						// Wait while NVRAM store bytes

	return( Acknowledge);
}

/***************************************************************************/
/*	IIC2WrStr															 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	EEPROM string write routine from IIC-bus 2						*/
/*	Remarks:																						*/
/*	Returns:		Acknowledge bit, 1:OK, 0:ERROR										*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
bit IIC2WrStr( UC Address, UC subadr, char *s) {

	register UC i;						

	IIC2ErrorCode = NoIICError;

	STARTCond;

	for ( i=0; i< Retry; i++)
		if ( Acknowledge = ByteTxb( Address))
			break;

	if ( Acknowledge) {
		Acknowledge = ByteTxb( subadr);

		for ( i=0; i<10; i++) {
			if ( Acknowledge)
				Acknowledge = ByteTxb( s[i]);

			if (( s[i] == '\0') || ( !Acknowledge)) {
				if (( !Acknowledge) && ( IIC2ErrorCode = NoIICError))
					IIC2ErrorCode = TxIICDataError;
				break;
			}

			if (((( i+1) & 3) == 0) || (( subadr+i+1) % 16) == 0) {
				STOPCond;			// packet write, enables use of alternative EEPROM
				waitms(40);			// wait while NVRAM store bytes

				STARTCond;			// store next (1-4) bytes

				if ( Acknowledge = ByteTxb( Address))
					Acknowledge = ByteTxb( subadr+i+1);
				else
					IIC2ErrorCode = TxIICTimeout;
	      }
   	}
	}
	else
		IIC2ErrorCode = TxIICTimeout;

   STOPCond;
   waitms(20);						// Wait while NVRAM store bytes

   return( Acknowledge);		// NB! allow 20ms before next write
}

/***************************************************************************/
/*	IIC2RdStr															 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	Read string[10] from IIC ( address, subaddress)					*/
/*	Remarks:		--																				*/
/*	Returns:		Acknowledge bit, 1:OK, 0:ERROR										*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
bit IIC2RdStr( UC Address, UC subadr, char *s) {

	register UC i;
														// Transmit IIC address
	if ( Acknowledge = IIC2Write( Address, subadr)) {

		for ( i=0; i<10; i++) {
			s[i] = IIC2Read( Address);			// Read char from IIC circuit

			if ( IIC2ErrorCode)
				return( 0);
		}
		s[10]= '\0';
	}

	return( Acknowledge);
}

/***************************************************************************/
/*	IIC2WrLongInt														 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	EEPROM long and integer read from IIC-bus 2						*/
/*	Remarks:																						*/
/*	Returns:		Acknowledge bit, 1:OK, 0:ERROR										*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
bit IIC2WrLongInt( UC Address, UC subadr, UL a, UI b) {

	STARTCond;

	Acknowledge = ByteTxb(Address);

	ByteTxb(subadr);

	ByteTxb((UC)(( a & 0xff000000)>>24));
	ByteTxb((UC)(( a & 0x00ff0000)>>16));
	ByteTxb((UC)(( a & 0x0000ff00)>>8));
	ByteTxb((UC)( a & 0x000000ff));

	STOPCond;
	waitms(20);								// Wait while NVRAM store bytes

	STARTCond;								// Store next (1-4) bytes

	Acknowledge = ByteTxb(Address);
	ByteTxb(subadr+4);
	ByteTxb((UC)((b & 0xff00)>>8));
	ByteTxb((UC)(b & 0x00ff));

	STOPCond;
	waitms(20);								// Wait while NVRAM store bytes
 
	return( Acknowledge);
}

/***************************************************************************/
/*	IIC2RdLong															 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	Read unsigned long from IIC ( address, subaddres)				*/
/*	Remarks:		--																				*/
/*	Returns:		Unsigned long																*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
UL IIC2RdLong( UC Address, UC subadr) {

	register UC i;
	UL y;
													// Transmit RAM address
	if ( Acknowledge = IIC2Write( Address, subadr)) {

		for ( y=i=0; i<4 ; i++)
			y = ( UL) IIC2Read( Address) + ( y << 8);
	}

	return( y);
}

/***************************************************************************/
/*	IIC2RdInt															 	  		 PIIC2.C */
/*																									*/
/* Author:		Preben Christiansen, DEV, 941124	 									*/
/* Revised:		980509, KEn			     													*/
/*																									*/
/*	Function:	Read unsigned integer from IIC ( address, subaddres)			*/
/*	Remarks:		--																				*/
/*	Returns:		Unsigned integer															*/
/*	Updates:		IIC2ErrorCode																*/
/***************************************************************************/
UI IIC2RdInt( UC Address, UC subadr) {

	UI y;
														// Transmit RAM address
	if ( Acknowledge = IIC2Write( Address, subadr)) {

		y = IIC2Read( Address)	<<	8;			// Read SCH-phase
		y += IIC2Read( Address);
	}

	return( y);
}
