/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : cmd.c
 *   Author      : Matt Millman
 *   Description : Command interpreter
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

#ifndef __CMD_H__
#define __CMD_H__

// Format byte bit definitions
// This is the only configuration the
// base manages for us.
#define FORMAT_nDATE_ON             (1 << 2)
#define FORMAT_LG_ON                (1 << 3)
#define FORMAT_nTIME_ON             (1 << 6)

#define FORMAT_ISO                  1
#define FORMAT_EUR                  2
#define FORMAT_US                   3

#define FORMAT_DATEFMT_MASK         0x03
#define FORMAT_DATEFMT_SHIFT        0
#define FORMAT_TIMEFMT_MASK         0x30
#define FORMAT_TIMEFMT_SHIFT        4
// End of format byte bit definitions

void cmd_work(void);
void cmd_init(void);
void cmd_respond(char cmd, uint8_t param);

#endif /* __CMD_H__ */