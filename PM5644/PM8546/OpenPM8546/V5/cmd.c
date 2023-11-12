/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : cmd.c
 *   Author      : Matt Millman
 *   Description : Command interpreter
 *
 *   The PM5644 MCU translates human readable SCPI commands into three
 *   byte commands which are exchanged between the logo generator and base.
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
#include "cmd.h"
#include "rs232.h"
#include "logogen.h"
#include "config.h"
#include "clock.h"
#include "edit.h"

#define MSG_TYPE_BASE_TO_LG     0x01
#define MSG_TYPE_LG_TO_BASE     0x03

#define SUBCMD_IS_DATA          0x80 // Parameter byte contains 7-bit data
#define SUBCMD_IS_LOGO          0xC0 // ... contains 4-bit logo index

// Values the parameter byte may contain. The names are guessed based on
// what they are observed to do.
#define SUBCMD_OK               0x06
#define SUBCMD_ALT              0x10
#define SUBCMD_UP               0x11
#define SUBCMD_DOWN             0x12
#define SUBCMD_CLEAR            0x15
#define SUBCMD_ADVANCE          0x18
#define SUBCMD_STANDARD         0x1D
#define SUBCMD_USER             0x1E
#define SUBCMD_SAVE             0x21 // !
#define SUBCMD_READ_NEXT        0x23 // #
#define SUBCMD_BANKSEL          0x2A // *
#define SUBCMD_QUERY            0x3F // ?
#define SUBCMD_LOGOGEN_ON       0x41 // A
#define SUBCMD_LOGOGEN_OFF      0x42 // B
#define SUBCMD_INCREMENT        0x49 // I
#define SUBCMD_SET_DATE         0x44 // D
#define SUBCMD_SET_TIME         0x54 // T
#define SUBCMD_LOGOGEN_IS_ON    0x61 // a
#define SUBCMD_LOGOGEN_IS_OFF   0x62 // b

static void process(char cmd, uint8_t param);
static void handle_reset(uint8_t param);
static void handle_logogen_ctrl(uint8_t param);
static void handle_date_time(char cmd, uint8_t param);
static void handle_format(uint8_t param);
static void handle_char(char cmd, uint8_t param);
static void handle_text(uint8_t param);
static void handle_edit_char(uint8_t param);

uint8_t _g_rxcmd_idx;
extern char _g_xferbuf[3];
extern char _g_text_buf[];

void cmd_init(void)
{
    _g_rxcmd_idx = 0;
}

void cmd_work(void)
{
    if (rs232_cmd_ready())
    {
        rs232_cmd_reset();

        if (_g_xferbuf[2] == MSG_TYPE_BASE_TO_LG)
            process(_g_xferbuf[0], _g_xferbuf[1]);
    }
}

void cmd_respond(char cmd, uint8_t param)
{
    _g_xferbuf[0] = cmd;
    _g_xferbuf[1] = param;
    _g_xferbuf[2] = MSG_TYPE_LG_TO_BASE;

    rs232_start_tx();
}

static void process(char cmd, uint8_t param)
{
    switch (cmd)
    {
    case 'R':
        // Reset: Sent at power on...
        // And also when the "set clock" mode exits? o_O
        handle_reset(param);
        break;
    case 'F':
        // Sent whenever anything about the format of the clock is changed.
        handle_format(param);
        break;
    case 'L':
        // Sent to switch the logo generator off/on
        // and also when a logo has been set.
        handle_logogen_ctrl(param);
        break;
    case 'H': //Hour
    case 'M': //Minute
    case 'S': //Second
    case 'Y': //Year
    case 'O': //Month
    case 'D': //Day
        // Everything time and date related
        handle_date_time(cmd, param);
        break;
    case 'C':
        // Input char (editor)
        handle_edit_char(param);
        break;
    case 'T':
        // Text control
        handle_text(param);
        break;
    case '<': //TextA
    case '>': //TextB
        // Input text (SCPI)
        handle_char(cmd, param);
        break;
    default:
        break;
    }
}

static void handle_reset(uint8_t param)
{
    switch (param)
    {
    case SUBCMD_SET_DATE:
    case SUBCMD_SET_TIME:
        clock_start();
        break;
    default:
        if (param & SUBCMD_IS_DATA)
            logogen_ctrl(0xFF, param);
        break;
    }

    cmd_respond('r', (param & FORMAT_LG_ON) ? SUBCMD_LOGOGEN_IS_ON : SUBCMD_LOGOGEN_IS_OFF);
}

static void handle_format(uint8_t param)
{
    switch (param)
    {
    case SUBCMD_SET_DATE:
        clock_stop_date();
        break;
    case SUBCMD_SET_TIME:
        clock_stop_time();
        break;
    default:
        if (param & SUBCMD_IS_DATA)
            logogen_ctrl(0xF7, param);
        break;
    }

    cmd_respond('f', 0x64 /* OK (?) */);

    // INTERESTING OBSERVATION: By responding to this command with 0x79 the
    // logo generator appears to be able to block user input on the from
    // front panel, then unblock it again by sending 0x23 subsequently.
    // What could this be for ...?
}

static void handle_logogen_ctrl(uint8_t param)
{
    switch (param)
    {
    case SUBCMD_LOGOGEN_ON:
        logogen_ctrl(FORMAT_LG_ON, 0x80 | FORMAT_LG_ON);
        // The base appears to want a status result.
        // but it does nothing with it. Eh...
        cmd_respond('l', SUBCMD_LOGOGEN_IS_ON);
        break;
    case SUBCMD_LOGOGEN_OFF:
        logogen_ctrl(FORMAT_LG_ON, 0x80);
        cmd_respond('l', SUBCMD_LOGOGEN_IS_OFF);
        break;
    case SUBCMD_INCREMENT:
        // This -may- be used to cycle through various customer logos
        // programmed into a custom logo generator. We don't use it.
        cmd_respond('l', SUBCMD_OK);
        break;
    case SUBCMD_QUERY:
        // And presumably this returns which logo sequence is active
        // Return zero for now.
        cmd_respond('l', SUBCMD_IS_DATA | 0);
        break;
    default:
        if (param & SUBCMD_IS_LOGO)
            logogen_set_demologo(param & 0x0F);
        cmd_respond('l', SUBCMD_OK);
        break;
    }
}

static void handle_date_time(char cmd, uint8_t param)
{
    uint8_t tmp;

    if (param == SUBCMD_QUERY)
    {
        switch (cmd)
        {
        case 'H':
            cmd_respond('h', SUBCMD_IS_DATA | clock_get_hour());
            break;
        case 'M':
            cmd_respond('m', SUBCMD_IS_DATA | clock_get_minute());
            break;
        case 'S':
            cmd_respond('s', SUBCMD_IS_DATA | clock_get_second());
            break;
        case 'Y':
            cmd_respond('y', SUBCMD_IS_DATA | clock_get_year());
            break;
        case 'O':
            cmd_respond('o', SUBCMD_IS_DATA | clock_get_month());
            break;
        case 'D':
            cmd_respond('d', SUBCMD_IS_DATA | clock_get_day());
            break;
        }
    }
    else if (param == SUBCMD_INCREMENT)
    {
        switch (cmd)
        {
        case 'H':
            clock_increment_hour();
            break;
        case 'M':
            clock_increment_minute();
            break;
        case 'S':
            clock_increment_second();
            break;
        case 'Y':
            clock_increment_year();
            break;
        case 'O':
            clock_increment_month();
            break;
        case 'D':
            clock_increment_day();
            break;
        }

        cmd_respond(cmd + ('a' - 'A'), SUBCMD_OK);
    }
    else if (param & SUBCMD_IS_DATA)
    {
        tmp = param & 0x7F;

        switch (cmd)
        {
        case 'Y':
            clock_set_year(tmp);
            break;
        case 'O':
            clock_set_month(tmp);
            break;
        case 'D':
            clock_set_day(tmp);
            break;
        case 'H':
            clock_set_hour(tmp);
            break;
        case 'M':
            clock_set_minute(tmp);
            break;
        case 'S':
            clock_set_second(tmp);
            break;
        }

        cmd_respond(cmd + ('a' - 'A'), SUBCMD_OK);
    }
    else
    {
        cmd_respond(cmd + ('a' - 'A'), SUBCMD_OK);
    }
}

static void handle_text(uint8_t param)
{
    uint8_t tmp;

    switch (param)
    {
    case SUBCMD_STANDARD:
        logogen_set_standard_text();
        cmd_respond('t', SUBCMD_OK);
        break;
    case SUBCMD_USER:
        logogen_set_clear_text();
        cmd_respond('t', SUBCMD_OK);
        break;
    case SUBCMD_CLEAR:
        logogen_set_clear_text();
        cmd_respond('t', SUBCMD_OK);
        break;
    case SUBCMD_ALT:
        if (edit_text_field())
            cmd_respond('t', 0x1A); // LED4 ON
        else
            cmd_respond('t', 0x07); // LED4 OFF
        break;
    case SUBCMD_BANKSEL:
        if (edit_is_bank1())
        {
            edit_set_bank1(false);
            cmd_respond('t', 0x07); // LED4 OFF
        }
        else
        {
            edit_set_bank1(true);
            cmd_respond('t', 0x1A); // LED4 ON
        }
        break;
    case SUBCMD_ADVANCE:
        edit_backspace();
        cmd_respond('t', SUBCMD_OK);
        break;
    case SUBCMD_SAVE:
        tmp = edit_save();
        if (tmp == TEXTA)
            logogen_texta_loaded();
        if (tmp == TEXTB)
            logogen_textb_loaded();
        cmd_respond('t', SUBCMD_OK);
        break;
    default:
        cmd_respond('t', SUBCMD_OK);
        break;
    }
}

static void handle_edit_char(uint8_t param)
{
    switch (param)
    {
    case SUBCMD_UP:
        edit_char_up();
        break;
    case SUBCMD_DOWN:
        edit_char_down();
        break;
    case SUBCMD_ADVANCE:
        edit_char_next();
        break;
    }

    cmd_respond('c', SUBCMD_OK);
}

static void handle_char(char cmd, uint8_t param)
{
    if (param == SUBCMD_ALT)
    {
        _g_rxcmd_idx = 0;
        cmd_respond(cmd, SUBCMD_READ_NEXT);
    }
    else if (param == SUBCMD_ADVANCE)
    {
        if (cmd == '<')
        {
            _g_text_buf[_g_rxcmd_idx] = 0;
            logogen_texta_loaded();
            config_write_str(CONFIG_TEXTA, _g_text_buf);
        }
        else
        {
            _g_text_buf[_g_rxcmd_idx] = 0;
            logogen_textb_loaded();
            config_write_str(CONFIG_TEXTB, _g_text_buf);
        }

        cmd_respond(cmd, SUBCMD_OK);
    }
    else if (param & SUBCMD_IS_DATA)
    {
        // Text comes in one character at a time.
        // The full sequence is quite complicated.

        if (cmd == '<')
        {
            if ((_g_rxcmd_idx + 1) == MAX_TEXT)
            {
                _g_text_buf[MAX_TEXT - 1] = 0;
                logogen_texta_loaded();
                config_write_str(CONFIG_TEXTA, _g_text_buf);
                cmd_respond(cmd, SUBCMD_OK);
            }
            else
            {
                param &= ~SUBCMD_IS_DATA;
                _g_text_buf[_g_rxcmd_idx++] = param;
                cmd_respond(cmd, SUBCMD_READ_NEXT);
            }
        }
        else
        {
            if ((_g_rxcmd_idx + 1) == MAX_TEXT)
            {
                _g_text_buf[MAX_TEXT - 1] = 0;
                logogen_textb_loaded();
                config_write_str(CONFIG_TEXTB, _g_text_buf);
                cmd_respond(cmd, SUBCMD_OK);
            }
            else
            {
                param &= ~SUBCMD_IS_DATA;
                _g_text_buf[_g_rxcmd_idx++] = param;
                cmd_respond(cmd, SUBCMD_READ_NEXT);
            } 
        }
    }
    else
    {
        cmd_respond(cmd, SUBCMD_OK);
    }
}
