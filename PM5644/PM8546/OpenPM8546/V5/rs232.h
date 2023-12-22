/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : rs232.c
 *   Author      : Matt Millman
 *   Description : Communications interface
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

 #ifndef __RS232_H__
 #define __RS232_H__

void rs232_init(void);
void rs232_vblank_isr(void);
bool rs232_cmd_ready(void);
void rs232_cmd_reset(void);
void rs232_start_tx(void);


 #endif /* __RS232_H__ */