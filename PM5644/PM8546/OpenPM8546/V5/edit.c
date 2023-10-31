/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 *
 *   File        : edit.c
 *   Author      : Matt Millman
 *   Description : Text editor
 *
 *   The PM8546 is known to contain a built in text editor to allow entry
 *   and modification of text (and possibly?) entry of logos without the
 *   need for a PM8547. It is driven by buttons on the front panel whose
 *   functions are reasonably well understood, however the capability and
 *   behaviour of the original editor is unknown.
 *
 *   This version gives an experience nearly exactly the same as that of the
 *   PT5xxx series, except that editing is done in-pattern rather on an LCD
 *   screen. The job is a lot more difficult for this editor because the
 *   PM8546 cannot blank parts of the pattern, so we have to be pedantic
 *   when it comes to size and position i.e. we cannot allow text or logos
 *   to spill outside of the black boxes, otherwise we end up with a major
 *   overvoltage condition at the output as our output is added to that of
 *   the base! If there is only space for a single-block character remaining
 *   in a box, then the user cannot be allowed to enter anything larger,
 *   and, we also have to shrink the cursor.
 *
 *   This editor is further complicated because it also allows the entry
 *   of logos. Due to hardware limitations text and logos cannot be mixed
 *   within a single box.
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
#include "edit.h"
#include "logogen.h"
#include "config.h"

#define EDIT_TEXTA          (1 << 0)
#define EDIT_TEXTB          (1 << 1)
#define EDIT_BLOCK1         (1 << 2)
#define EDIT_BLINK2         (1 << 5) // Large cursor '_' (2 block)
#define EDIT_BLINK1         (1 << 6) // Small cursor '.' (1 block)
#define EDIT_NEEDS_UPDATE   (1 << 7)

static uint8_t _field_len;
static uint8_t _num_blocks;
static uint8_t _blink_timeout;
static uint8_t _edit_state;
static char _last_char;
extern char _g_text_buf[];
extern code promblock_t _g_char_blocks[];
extern code promblock_t _g_logo_blocks[];

void edit_init(void)
{
    _edit_state = 0;
    _field_len = 0;
    _last_char = 0;
    _blink_timeout = 0;
}

void edit_vsync_isr(void)
{
    if (_edit_state & (EDIT_BLINK2 | EDIT_BLINK1))
    {
        if (!--_blink_timeout)
        {
            if (_g_text_buf[_field_len - 1] == '_' || _g_text_buf[_field_len - 1] == '.')
            {
                // Cursor off
                _g_text_buf[_field_len - 1] = ' ';
            }
            else
            {
                // Cursor on
                if (_edit_state & EDIT_BLINK2)
                    _g_text_buf[_field_len - 1] = '_';
                if (_edit_state & EDIT_BLINK1)
                    _g_text_buf[_field_len - 1] = '.';
            }

            _edit_state |= EDIT_NEEDS_UPDATE;
            _blink_timeout = 25;
        }
    }
}

static bool get_next_char(char current_char, char *next_char, uint8_t blocks_available)
{
    uint8_t i;

    if (current_char == LAST_CHAR)
        return false;

    for (i = current_char + 1; i < (LAST_CHAR + 1); i++)
    {
        // Find the next char which will fit in the available space
        const promblock_t* pb = &_g_char_blocks[i - FIRST_CHAR];
        if (pb->len && blocks_available >= pb->len)
        {
            *next_char = i;
            return true;
        }
    }

    return false;
}

static bool get_prev_char(char current_char, char *prev_char, uint8_t blocks_available)
{
    uint8_t i;

    if (current_char == FIRST_CHAR)
        current_char++;

    for (i = current_char - 1; i >= FIRST_CHAR; i--)
    {
        // Find the prev char which will fit in the available space
        const promblock_t* pb = &_g_char_blocks[i - FIRST_CHAR];
        if (pb->len && blocks_available >= pb->len)
        {
            *prev_char = i;
            return true;
        }
    }

    return false;
}

static bool get_next_logo(char current_logo, char *next_logo, uint8_t blocks_available)
{
    uint8_t i; // -Can't- go below zero

    current_logo &= ~CHAR_LOGO_FLAG;

    if (current_logo == LAST_LOGO)
        return false;

    for (i = current_logo + 1; i < (LAST_LOGO + 1); i++)
    {
        // Find the next char which will fit in the available space
        const promblock_t* pb = &_g_logo_blocks[i];
        if (pb->len && blocks_available >= pb->len)
        {
            *next_logo = (i | CHAR_LOGO_FLAG);
            return true;
        }
    }

    return false;
}

static bool get_prev_logo(char current_logo, char *next_logo, uint8_t blocks_available)
{
    int8_t i; // -Can- go below zero

    current_logo &= ~CHAR_LOGO_FLAG;

    if (current_logo == 0) //Logoset start
        current_logo++;

    for (i = current_logo - 1; i >= 0; i--)
    {
        // Find the prev char which will fit in the available space
        const promblock_t* pb = &_g_logo_blocks[i];
        if (pb->len && blocks_available >= pb->len)
        {
            *next_logo = (i | CHAR_LOGO_FLAG);
            return true;
        }
    }

    return false;
}

static void calc_len_without_last_char(void)
{
    uint8_t len = (uint8_t)strlen(_g_text_buf);
    char tmplast;

    if (len > 0)
    {
        tmplast = _g_text_buf[len - 1];
        _g_text_buf[len - 1] = 0;
    }

    _num_blocks = logogen_get_text_len(_g_text_buf, TEXTA_MAXBLOCKS, &_field_len);

    if (len > 0)
        _g_text_buf[len - 1] = tmplast;
}

bool edit_text_field(void)
{
    if ((_edit_state & (EDIT_TEXTA | EDIT_TEXTB)) == 0 || _edit_state & EDIT_TEXTB)
    {
        if (_edit_state & EDIT_TEXTB)
            config_write_str(CONFIG_TEXTB, _g_text_buf); // Save TEXTB
        // Either in start-up state, or swap back to TEXTA
        config_read_str(CONFIG_TEXTA, _g_text_buf, MAX_TEXT);
        calc_len_without_last_char();
        _edit_state = EDIT_TEXTA;
    }
    else if (_edit_state & EDIT_TEXTA)
    {
        // Save TEXTA
        config_write_str(CONFIG_TEXTA, _g_text_buf);
        // Swap to TEXTB
        config_read_str(CONFIG_TEXTB, _g_text_buf, MAX_TEXT);
        calc_len_without_last_char();
        _edit_state = EDIT_TEXTB;
    }

    _field_len = (uint8_t)strlen(_g_text_buf);
    _g_text_buf[_field_len] = 0;
    _last_char = 0;
    _edit_state |= EDIT_NEEDS_UPDATE;

    if (_g_text_buf[0] & CHAR_LOGO_FLAG)
        _edit_state |= EDIT_BLOCK1;
    else
        _edit_state &= ~EDIT_BLOCK1;

    return !!(_edit_state & EDIT_BLOCK1);
}

void edit_char_down(void)
{
    char prev_char;
    uint8_t last_real_char; // Last char excluding the cursor
    uint8_t blocks_available;

    if (!_field_len)
        return; // No character to edit

    last_real_char = _last_char != 0 ? _last_char : _g_text_buf[_field_len - 1];

    if (!(_edit_state & EDIT_BLOCK1) && last_real_char & CHAR_LOGO_FLAG)
        last_real_char = FIRST_CHAR;

    if (_edit_state & EDIT_BLOCK1 && !(last_real_char & CHAR_LOGO_FLAG))
        last_real_char = FIRST_LOGO;

    blocks_available = ((_edit_state & EDIT_TEXTA) ? TEXTA_MAXBLOCKS : TEXTB_MAXBLOCKS) - _num_blocks;

    if (_edit_state & EDIT_BLOCK1 ?
        get_prev_logo(last_real_char, &prev_char, blocks_available) :
        get_prev_char(last_real_char, &prev_char, blocks_available))
    {
        _g_text_buf[_field_len - 1] = prev_char;
        _edit_state |= EDIT_NEEDS_UPDATE;

        if (_last_char)
        {
            // Clear the cursor
            _edit_state &= ~(EDIT_BLINK2 | EDIT_BLINK1);
            _last_char = 0;
        }
    }
}

void edit_char_up(void)
{
    char next_char;
    uint8_t last_real_char; // Last char excluding the cursor
    uint8_t blocks_available;

    if (!_field_len)
        return; // No character to edit

    last_real_char = _last_char != 0 ? _last_char : _g_text_buf[_field_len - 1];

    if (!(_edit_state & EDIT_BLOCK1) && last_real_char & CHAR_LOGO_FLAG)
        last_real_char = FIRST_CHAR;

    if (_edit_state & EDIT_BLOCK1 && !(last_real_char & CHAR_LOGO_FLAG))
        last_real_char = FIRST_LOGO;

    blocks_available = ((_edit_state & EDIT_TEXTA) ? TEXTA_MAXBLOCKS : TEXTB_MAXBLOCKS) - _num_blocks;

    if (_edit_state & EDIT_BLOCK1 ?
        get_next_logo(last_real_char, &next_char, blocks_available) :
        get_next_char(last_real_char, &next_char, blocks_available))
    {
        _g_text_buf[_field_len - 1] = next_char;
        _edit_state |= EDIT_NEEDS_UPDATE;

        if (_last_char)
        {
            // Clear the cursor
            _edit_state &= ~(EDIT_BLINK2 | EDIT_BLINK1);
            _last_char = 0;
        }
    }
}

void edit_char_next(void)
{
    int blocks_available;
    uint8_t tmp_num_blocks;

    if (_last_char)
        return; // Already editing a new char

    tmp_num_blocks = logogen_get_text_len(_g_text_buf, (_edit_state & EDIT_TEXTA) ? TEXTA_MAXBLOCKS : TEXTB_MAXBLOCKS, &_field_len);
    blocks_available = ((_edit_state & EDIT_TEXTA) ? TEXTA_MAXBLOCKS : TEXTB_MAXBLOCKS) - tmp_num_blocks;

    if (blocks_available < 1)
        return; // No space for another character

    _num_blocks = tmp_num_blocks;

    if (_field_len < (MAX_TEXT - 1))
    {
        // If at the start of the line, there don't copy default next from the previous
        _last_char = _field_len > 0 ? _g_text_buf[_field_len - 1] : ' ';

        if (blocks_available > 1)
        {
            // 2 or more blocks left to fill
            _blink_timeout = 25;
            _g_text_buf[_field_len] = '_';
            _edit_state |= EDIT_BLINK2;
        }
        else
        {
            // Only one block left to fill. Can't use an underscore as the cursor
            // because in this scenario there isn't enough space for it.
            _blink_timeout = 25;
            _g_text_buf[_field_len] = '.';
            _edit_state |= EDIT_BLINK1;
        }

        _field_len++;
        _edit_state |= EDIT_NEEDS_UPDATE;
        _g_text_buf[_field_len] = 0;
    }
}

void edit_backspace(void)
{
    if (_field_len)
    {
        _g_text_buf[_field_len - 1] = 0;
        _field_len--;
        _num_blocks = logogen_get_text_len(_g_text_buf, (_edit_state & EDIT_TEXTA) ? TEXTA_MAXBLOCKS : TEXTB_MAXBLOCKS, &_field_len);
        _edit_state &= ~(EDIT_BLINK2 | EDIT_BLINK1);
        _last_char = 0;
        _edit_state |= EDIT_NEEDS_UPDATE;
    }
}

uint8_t edit_save(void)
{
    if (_field_len > 0 && _last_char)
    {
        // Don't include an unselected new char in the result
        _g_text_buf[_field_len - 1] = 0;
    }

    config_write_str(_edit_state & EDIT_TEXTA ? CONFIG_TEXTA : CONFIG_TEXTB, _g_text_buf);

    if (_edit_state & EDIT_TEXTA)
    {
        _edit_state = 0;
        return TEXTA;
    }
    else
    {
        _edit_state = 0;
        return TEXTB;
    }
}

uint8_t edit_needs_update(void)
{
    if (_edit_state & EDIT_NEEDS_UPDATE)
    {
        _edit_state &= ~EDIT_NEEDS_UPDATE;
        return (_edit_state & EDIT_TEXTA) ? TEXTA : TEXTB;
    }

    return 0;
}

bool edit_is_bank1(void)
{
    return (_edit_state & EDIT_BLOCK1) == EDIT_BLOCK1;
}

extern void text_update();

void edit_set_bank1(bool bank1)
{
    if ((!bank1 && (_edit_state & EDIT_BLOCK1)) ||
        (bank1 && !(_edit_state & EDIT_BLOCK1)))
    {
        // Clear text if swapping
        _g_text_buf[0] = 0;
        _field_len = 0;
        _last_char = 0;
        _edit_state |= EDIT_NEEDS_UPDATE;

        if (bank1)
            _edit_state |= EDIT_BLOCK1;
        else
            _edit_state &= ~EDIT_BLOCK1;
    }
}
