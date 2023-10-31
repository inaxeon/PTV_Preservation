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

#define ST_DELAYCMD_MASK        0x7
#define ST_DELAYCMD_LG_ON       1

#define ST_UPDATE_CLOCK         (1 << 5)
#define ST_DELAYCMD_EXEC        (1 << 6)
#define ST_DELAYCMD_QUEUED      (1 << 7)

#define FPS 50

#endif /* __PROJECT_H__ */