/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : config.c
 *   Author      : Matt Millman
 *   Description : Configuration store
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

#ifndef __CONFIG_H__
#define __CONFIG_H__

#define OPEN_PM8546_MAGIC   0x4F38
#define OPEN_PM8546_VERSION 1

#define CONFIG_BASE         0x10
#define CONFIG_MAGIC        (CONFIG_BASE + 0)
#define CONFIG_VERSION      (CONFIG_BASE + 2)
#define CONFIG_YEAR         (CONFIG_BASE + 3)
#define CONFIG_UNUSED2      (CONFIG_BASE + 4)
#define CONFIG_TEXTA        (CONFIG_BASE + 0x20)
#define CONFIG_TEXTB        (CONFIG_BASE + 0x40)
#define CONFIG_DEBUG        (CONFIG_BASE + 0x60)

#define TEXT_MODE_CLEAR     0
#define TEXT_MODE_STANDARD  1
#define TEXT_MODE_USER      2

void config_validate(void);
void config_set_default(void);
void config_write_byte(uint8_t setting, uint8_t buf);
uint8_t config_read_byte(uint8_t setting);
void config_write_str(uint8_t setting, const char *buf);
void config_read_str(uint8_t setting, const char *buf, uint8_t len);

#endif /* __CONFIG_H__ */