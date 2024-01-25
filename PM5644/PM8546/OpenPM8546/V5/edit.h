/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 *
 *   File   : edit.h
 *   Author : Matt Millman
 *   Description : Text editor
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

#ifndef __EDIT_H__
#define __EDIT_H__

void edit_init(void);
void edit_vblank_isr(void);
uint8_t edit_needs_update(void);
bool edit_text_field(void);
void edit_char_down(void);
void edit_char_up(void);
void edit_char_next(void);
void edit_backspace(void);
uint8_t edit_save(void);
bool edit_is_bank1(void);
void edit_set_bank1(bool block1);

#endif /* __EDIT_H__ */