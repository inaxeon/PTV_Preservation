/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : i2c.c
 *   Author      : Matt Millman
 *   Description : I2C interface
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
#include "i2c.h"

#define i2c_delay() do { _nop_(); _nop_(); } while(0)
#define read_sda()  !!(P1 & 0x80)
#define set_scl()   do { P1 |= 0x40; } while(0)
#define clear_scl() P1 &= ~0x40
#define set_sda()   do { P1 |= 0x80; } while(0)
#define clear_sda() do { P1 &= ~0x80; } while(0)

#define I2C_READ    1
#define I2C_WRITE   0

static void start_cond(bool repeat)
{
    if (repeat)
    { 
        set_sda();
        i2c_delay();
        set_scl();
    }

    clear_sda();
    i2c_delay();
    clear_scl();
}

static void stop_cond(void)
{
    clear_sda();
    i2c_delay();
    set_scl();
    i2c_delay();
    set_sda();
    i2c_delay();
}

static void write_bit(bool dbit)
{
    if (dbit)
        set_sda();
    else
        clear_sda();

    i2c_delay();
    set_scl();
    i2c_delay();
    clear_scl();
}

static bool read_bit(void)
{
    bool dbit;

    set_sda();
    i2c_delay();
    set_scl();
    i2c_delay();
    dbit = read_sda();
    clear_scl();
    
    return dbit;
}

bool i2c_write_byte(bool send_start, bool rep_start, bool send_stop, uint8_t byte)
{
    uint8_t dbit;
    bool nack;

    if (send_start)
        start_cond(rep_start);

    for (dbit = 0; dbit < 8; ++dbit)
    {
        write_bit((byte & 0x80) != 0);
        byte <<= 1;
    }

    nack = read_bit();

    if (send_stop)
        stop_cond();

    return !nack;
}

uint8_t i2c_read_byte(bool nack, bool send_stop)
{
    uint8_t byte = 0;
    uint8_t dbit;

    for (dbit = 0; dbit < 8; ++dbit)
        byte = (byte << 1) | read_bit();

    write_bit(nack);

    if (send_stop)
        stop_cond();

    return byte;
}

bool i2c_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint8_t len)
{
    if (!i2c_write_byte(true, false, false, addr << 1 | I2C_WRITE))
        goto fail;

    if (!i2c_write_byte(false, false, false, reg))
        goto fail;

    if (!i2c_write_byte(true, true, false, addr << 1 | I2C_READ))
        goto fail;

    while (len > 1)
    {
        *buf++ = i2c_read_byte(false, false);
        len--;
    }

    *buf = i2c_read_byte(true, true);
    return true;
fail:
    stop_cond();
    return false;
}

bool i2c_write(uint8_t addr, uint8_t reg, const uint8_t *buf, uint8_t len)
{
    uint8_t i;

    if (!i2c_write_byte(true, false, false, addr << 1 | I2C_WRITE))
        goto fail;

    if (!i2c_write_byte(false, false, false, reg))
        goto fail;

    for (i = 0; i < len; i++)
    {
        if (!i2c_write_byte(false, false, (i + 1) == len, *(buf + i)))
            goto fail;
    }

    return true;
fail:
    stop_cond();
    return false;
}