/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : rs232.c
 *   Author      : Matt Millman
 *   Description : Communications interface
 *
 *   All communications between the logo generator and the base
 *   are 3 bytes long and formatted as follows:
 *
 *   BASE->LG: <UPPERCASE CHAR>,<PARAMETER>,0x01
 *   LG->BASE: <LOWERCASE CHAR>,<PARAMETER>,0x03
 *
 *   Commands in the lower bank do not use alpha chars. Response command
 *   is usually the lowercase char of the request. Each byte in each
 *   direction has to be acknowledged before another may be sent.
 *   0x01 vs 0x03 indicates the direction of the message and is useful
 *   for glitch filtering.
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
#include "rs232.h"

#define ST_RX               (1 << 0)
#define ST_CMD_RECEIVED     (1 << 1)
#define ST_TX               (1 << 2)

#define ACK_LG_TO_BASE      0x7C
#define ACK_BASE_TO_LG      0x7E

static void rs232_send(uint8_t txdata);

uint8_t _g_xferbuf[3];
static uint8_t _idx;
static uint8_t _state;

// IMPLEMENT STATE TIMEOUTS!!

void rs232_isr(void) interrupt 4
{
    if (RI == 1)
    {
        uint8_t rxdata = SBUF;
        RI = 0;

        if (_state == ST_RX)
        {
            _g_xferbuf[_idx++] = rxdata;
            SBUF = ACK_LG_TO_BASE;

            if (_idx == 3)
            {
                _idx = 0;
                _state = ST_CMD_RECEIVED;
            }
        }
        if (_state == ST_TX)
        {
            if (_idx != 3)
            {
                if (rxdata == ACK_BASE_TO_LG)
                    SBUF = _g_xferbuf[_idx++];
            }
            else
            {
                _idx = 0;
                _state = ST_RX;
            }
        }
    }

    if (TI == 1)
        TI = 0;
}

void rs232_init(void)
{
    // Serial Mode 2, 9-Data Bit, REN Enabled
    // Baud is fixed in mode 2. 500kbaud.
    SCON = 0x90;
    ES = 1; // Enable serial interrupts

    _idx = 0;
    _state = ST_RX;
}

bool rs232_cmd_ready(void)
{
    return _state == ST_CMD_RECEIVED;
}

void rs232_cmd_reset(void)
{
    _state = ST_RX;
}

void rs232_start_tx(void)
{
    _state = ST_TX;
    SBUF = _g_xferbuf[_idx++];
}
