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

#include "project.h"
#include "config.h"
#include "i2c.h"

#define RTC_ADDR    0x50

code char _standard_texta[] = "PHILIPS";
code char _standard_textb[] = "PM5644 16:9";

void config_validate(void)
{
    uint16_t magic;
    uint8_t version;

    i2c_read(RTC_ADDR, CONFIG_MAGIC, (uint8_t *)&magic, sizeof(uint16_t));
    i2c_read(RTC_ADDR, CONFIG_VERSION, &version, sizeof(uint8_t));

    if (magic == OPEN_PM8546_MAGIC && version == OPEN_PM8546_VERSION)
        return;

    config_set_default();
}

void config_set_default(void)
{
    uint16_t magic = OPEN_PM8546_MAGIC;
    i2c_write(RTC_ADDR, CONFIG_MAGIC, (uint8_t *)&magic, sizeof(uint16_t));
    config_write_byte(CONFIG_VERSION, OPEN_PM8546_VERSION);
    config_write_byte(CONFIG_YEAR, 92); // The year the 16:9 PM5644 was born
    config_write_str(CONFIG_TEXTA, _standard_texta);
    config_write_str(CONFIG_TEXTB, _standard_textb);
}

void config_write_byte(uint8_t setting, uint8_t buf)
{
    i2c_write(RTC_ADDR, setting, &buf, sizeof(uint8_t));
    // Not sure what to do about errors presently
}

uint8_t config_read_byte(uint8_t setting)
{
    uint8_t ret;
    if (!i2c_read(RTC_ADDR, setting, &ret, sizeof(uint8_t)))
        ret = 0;
    return ret;
}

void config_write_str(uint8_t setting, const char *buf)
{
    i2c_write(RTC_ADDR, setting, buf, (uint8_t)(strlen(buf) + 1));
    // Not sure what to do about errors presently
}

void config_read_str(uint8_t setting, char *buf, uint8_t len)
{
    i2c_read(RTC_ADDR, setting, buf, len);
    // Not sure what to do about errors presently
}