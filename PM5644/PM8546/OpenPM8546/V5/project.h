/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File   : project.h
 *   Author : Matt Millman
 *
 *   This is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *   This software is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *   You should have received a copy of the GNU General Public License
 *   along with this software.  If not, see <http://www.gnu.org/licenses/>.
 */

 #ifndef __PROJECT_H__
 #define __PROJECT_H__

#include <intrins.h>
#include <reg51.h>
#include <stdio.h>
#include <string.h>
#include "types.h"

//#define PAL_4_3_BUILD
//#define PAL_16_9_BUILD
//#define SECAM_BUILD
#define PAL_M_BUILD

#if defined(PAL_4_3_BUILD)
#define LINES_625
#define STANDARD_PAL
#define ASPECT_4_3
#elif defined(PAL_16_9_BUILD)
#define LINES_625
#define STANDARD_PAL
#define ASPECT_4_3
#elif defined(SECAM_BUILD)
#define LINES_625
#define STANDARD_SECAM
#define ASPECT_4_3
#elif defined(PAL_M_BUILD)
#define LINES_525
#define STANDARD_PAL
#define ASPECT_4_3
#endif

#define ST_DELAYCMD_MASK        0x7
#define ST_DELAYCMD_LG_ON       1

#define ST_UPDATE_CLOCK         (1 << 5)
#define ST_DELAYCMD_EXEC        (1 << 6)
#define ST_DELAYCMD_QUEUED      (1 << 7)

#endif /* __PROJECT_H__ */