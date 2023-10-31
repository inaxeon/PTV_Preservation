/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File   : i2c.h
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

#ifndef __I2C_H__
#define __I2C_H__

bool i2c_write_byte(bool send_start, bool rep_start, bool send_stop, uint8_t byte);
uint8_t i2c_read_byte(bool nack, bool send_stop);

bool i2c_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint8_t len);
bool i2c_write(uint8_t addr, uint8_t reg, const uint8_t *buf, uint8_t len);

#endif /* __I2C_H__ */