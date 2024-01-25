/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : logogen.c
 *   Author      : Matt Millman
 *   Description : Logo generator hardware driver
 *
 *   The job of this driver is quite simple. Load the addresses of the
 *   characters into the DPRAM at the appropriate positions and set the
 *   START bit on the line before the text or logo is to be displayed.
 *   The hardware does the rest.
 *
 *   But when updating the DPRAM it is absolutely critical for the CPU
 *   to -not- clash with the sequencing logic or else the write will be
 *   blocked, thus timing of updates must be carefully considered.
 *
 *   Line 0 (bytes 0-255) of the DPRAM is always left clear.
 *   Line 1 (256-511) is the top box.
 *   Line 2 (512-767) is the clock.
 *   Line 3 (768-1023) is the bottom box.
 *
 *   PM8546 characters are variable width. One, two or three blocks wide.
 *   Examples:
 *   1 Block: I, i, j
 *   2 Block: A, B, C
 *   3 Block: M, W
 *
 *   For a 1-block character, only 1 byte is written to the DPRAM,
 *   2 for a 2-block, and so on.
 *
 *   Large logos reside in the second bank of the pixel EPROMs. The bank
 *   cannot be changed in the middle of a line thus they cannot be mixed
 *   with text. The exception is the "PTV" logo at the end of the first
 *   bank, which is treated as a single large character.
 *
 *   As with the text editor, we have to think about overvoltage quite a
 *   bit in here. We cannot render the clock while the base is still showing
 *   the grid. Thus we must wait until the next field before switching it on
 *   and switch it off -immediately- when the base says so otherwise it will
 *   write the grid over our clock, and we get an overvoltage condition.
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
#include "logogen.h"
#include "cmd.h"
#include "i2c.h"
#include "config.h"
#include "clock.h"

#define HPRESET_REG     0x8000
#define VCONTROL_REG    0xA000
#define DPRAM_BASE      0x4000

#define LINE_LEN        0x100
#define SPACE           0x3F

#if defined(LINES_625)
#define LINE_HEIGHT     21 /* Per field. 42 lines total */
#define LINES_TO_TEXTA  44
#define LINES_TO_TEXTB  60
#define LINES_TO_CLOCK  83
#if defined(ASPECT_4_3)
#define CENTER          54
#define DATE_OFFSET     29
#define TIME_OFFSET     63
#if defined(STANDARD_PAL)
#define DEFAULT_PRESET  6 /* DELAY=ON */
#elif defined(STANDARD_SECAM)
#define DEFAULT_PRESET  3 /* DELAY=OFF */
#else
#error Standard not defined
#endif
#elif defined(ASPECT_16_9)
#define CENTER          80
#define DATE_OFFSET     53
#define TIME_OFFSET     91
#define DEFAULT_PRESET  4 /* Fine tune text H position */
#else
#error Aspect ratio not defined
#endif
#elif defined(LINES_525)
// NOTE: 525 line version starts text on the opposite field
// to the 625 line version to ensure correct vertical alignment.
// This is implemented in V16.
#define LINE_HEIGHT     18 /* Per field. 36 lines total */
#define LINES_TO_TEXTA  36
#define LINES_TO_CLOCK  65
#define LINES_TO_TEXTB  48
#define CENTER          52
#define DATE_OFFSET     28
#define TIME_OFFSET     61
#define DEFAULT_PRESET  2 /* DELAY=ON */
#else
#error Line count not defined
#endif


#define VC_SEL0         (1 << 4)
#define VC_SEL1         (1 << 5)
#define VC_START        (1 << 6)
#define VC_BANK1        (1 << 7)

#define TS_OFF_A        0
#define TS_LINE1        1
#define TS_OFF_B        2
#define TS_CLOCK        3
#define TS_OFF_C        4
#define TS_LINE2        5
#define TS_OFF_D        6

#define HPRESET *(volatile unsigned char xdata *)(HPRESET_REG)
#define VCONTROL *(volatile unsigned char xdata *)(VCONTROL_REG)
#define DPRAM(addr) *(volatile unsigned char xdata *)(DPRAM_BASE + addr)

#define TRIGGER0_IN_LINES(x) do { \
    TL0 = ((0xFFFF - (x)) & 0xFF); \
    TH0 = ((0xFFFF - (x)) >> 8); \
    } while (0);

static void write_text(int line, int offset, const char *str);
static void clear_all(void);
static void clear_line(uint8_t line);
static void put_clock_char(uint16_t *dpram_ptr, uint8_t idx);
static void set_flags(uint8_t mask, uint8_t flags);
static void clear_time(void);
static void clear_date(void);

extern code char _standard_texta[];
extern code char _standard_textb[];
char _g_text_buf[MAX_TEXT];
static uint8_t _ctrl;
static uint8_t _text_flags;
static uint8_t _text_state;

// Chars marked "NOT ALLOWED" are prohibited for entry by the PM5644 main MCU.
// But we use some of them for special purposes...
code promblock_t _g_char_blocks[] = {
    { 1, 0x3F },  // ' ': 8064
    { 1, 0x7F },  // '!': 16256
    { 0, 0x00 },  // NOT ALLOWED: '"'
    { 0, 0x00 },  // NOT ALLOWED: '#'
    { 0, 0x00 },  // NOT ALLOWED: '$'
    { 0, 0x00 },  // NOT ALLOWED: '%'
    { 2, 0x3C },  // '&': 7680
    { 1, 0x7E },  // ''': 16128
    { 1, 0xEC },  // '(': 30208
    { 1, 0xED },  // ')': 30336
    { 0, 0x00 },  // NOT ALLOWED: '*'
    { 2, 0x98 },  // '+': 19456
    { 1, 0x7D },  // ',': 16000
    { 2, 0x96 },  // '-': 19200
    { 1, 0x7C },  // '.': 15872
    { 2, 0x9C },  // '/': 19968
    { 2, 0x80 },  // '0': 16384
    { 2, 0x82 },  // '1': 16640
    { 2, 0x84 },  // '2': 16896
    { 2, 0x86 },  // '3': 17152
    { 2, 0x88 },  // '4': 17408
    { 2, 0x8A },  // '5': 17664
    { 2, 0x8C },  // '6': 17920
    { 2, 0x8E },  // '7': 18176
    { 2, 0x90 },  // '8': 18432
    { 2, 0x92 },  // '9': 18688
    { 2, 0x94 },  // ':': 18944
    { 0, 0x00 },  // NOT ALLOWED: ';'
    { 0, 0x00 },  // NOT ALLOWED: '<'
    { 2, 0x9A },  // '=': 19712
    { 0, 0x00 },  // NOT ALLOWED: '>'
    { 0, 0x00 },  // NOT ALLOWED: '?'
    { 0, 0x00 },  // NOT ALLOWED: '@'
    { 2, 0x00 },  // 'A': 0
    { 2, 0x02 },  // 'B': 256
    { 2, 0x04 },  // 'C': 512
    { 2, 0x06 },  // 'D': 768
    { 2, 0x08 },  // 'E': 1024
    { 2, 0x0A },  // 'F': 1280
    { 2, 0x0C },  // 'G': 1536
    { 2, 0x0E },  // 'H': 1792
    { 1, 0x10 },  // 'I': 2048
    { 2, 0x11 },  // 'J': 2176
    { 2, 0x13 },  // 'K': 2432
    { 2, 0x15 },  // 'L': 2688
    { 3, 0x17 },  // 'M': 2944
    { 2, 0x1A },  // 'N': 3328
    { 2, 0x1C },  // 'O': 3584
    { 2, 0x1E },  // 'P': 3840
    { 2, 0x20 },  // 'Q': 4096
    { 2, 0x22 },  // 'R': 4352
    { 2, 0x24 },  // 'S': 4608
    { 2, 0x26 },  // 'T': 4864
    { 2, 0x28 },  // 'U': 5120
    { 2, 0x2A },  // 'V': 5376
    { 3, 0x2C },  // 'W': 5632
    { 2, 0x2F },  // 'X': 6016
    { 2, 0x31 },  // 'Y': 6272
    { 2, 0x33 },  // 'Z': 6528
    { 0, 0x00 },  // NOT ALLOWED: '['
    { 0, 0x00 },  // NOT ALLOWED: '\'
    { 0, 0x00 },  // NOT ALLOWED: ']'
    { 0, 0x00 },  // NOT ALLOWED: '^'
    { 2, 0x9E },  // '_': 20224
    { 0, 0x00 },  // NOT ALLOWED: '`'
    { 2, 0x40 },  // 'a': 8192
    { 2, 0x42 },  // 'b': 8448
    { 2, 0x44 },  // 'c': 8704
    { 2, 0x46 },  // 'd': 8960
    { 2, 0x48 },  // 'e': 9216
    { 1, 0x4A },  // 'f': 9472
    { 2, 0x4B },  // 'g': 9600
    { 2, 0x4D },  // 'h': 9856
    { 1, 0x4F },  // 'i': 10112
    { 1, 0x50 },  // 'j': 10240
    { 2, 0x51 },  // 'k': 10368
    { 1, 0x53 },  // 'l': 10624
    { 3, 0x54 },  // 'm': 10752
    { 2, 0x57 },  // 'n': 11136
    { 2, 0x59 },  // 'o': 11392
    { 2, 0x5B },  // 'p': 11648
    { 2, 0x60 },  // 'q': 12288
    { 2, 0x62 },  // 'r': 12544
    { 2, 0x64 },  // 's': 12800
    { 2, 0x66 },  // 't': 13056
    { 2, 0x68 },  // 'u': 13312
    { 2, 0x6A },  // 'v': 13568
    { 3, 0x6C },  // 'w': 13824
    { 2, 0x6F },  // 'x': 14208
    { 2, 0x71 },  // 'y': 14464
    { 2, 0x73 },  // 'z': 14720
    { 0, 0x00 },  // NOT ALLOWED: '{'
    { 0, 0x00 },  // NOT ALLOWED: '|'
    { 0, 0x00 },  // NOT ALLOWED: '}'
    { 11, 0xF0 }, // NOT ALLOWED: '~' (PTV Logo)
    { 2, 0xFE }   // NOT ALLOWED: 0x7F (Double space) 
};

code promblock_t _g_logo_blocks[] = {
    { 12, 0x3F }, // PTV Logo
#if defined(ASPECT_4_3)
#if defined(LINES_625)
    { 28, 0x62 }, // PHILIPS 4:3
#elif defined(LINES_525)
    { 27, 0x62 }, // PHILIPS 4:3
#else
#error Line count not defined
#endif
#elif defined(ASPECT_16_9)
    { 30, 0xA1 }, // PHILIPS 16:9
#else
#error Aspect ratio not defined
#endif
#if defined(LINES_625)
    { 30, 0x81 }, // EBU Colour bars
    { 30, 0xC1 }, // "COLOUR" demo
#elif defined(LINES_525)
    { 27, 0x83 }, // EBU Colour bars
    { 27, 0xC3 }, // "COLOUR" demo
#else
#error Line count not defined
#endif
};

const uint8_t _g_last_logo = ((sizeof(_g_logo_blocks) / sizeof(promblock_t)) - 1);

void timer0_ISR (void) interrupt 1
{
    switch (_text_state)
    {
        case TS_LINE1:
            if (_text_flags & LOGOGEN_TEXTA_ON)
            {
                if (_text_flags & LOGOGEN_LOGO1_ON)
                    VCONTROL = VC_START | VC_SEL0 | VC_BANK1;
                else
                    VCONTROL = VC_START | VC_SEL0;
            }
            _text_state = TS_OFF_B;
            TRIGGER0_IN_LINES(LINE_HEIGHT);
            break;
        case TS_OFF_B:
            VCONTROL = 0;
            _text_state = TS_CLOCK;
            TRIGGER0_IN_LINES(LINES_TO_CLOCK);
            break;
        case TS_CLOCK:
            if (_text_flags & LOGOGEN_CLOCK_ON)
                VCONTROL = VC_START | VC_SEL1 | VC_BANK1;
            _text_state = TS_OFF_C;
            TRIGGER0_IN_LINES(LINE_HEIGHT);
            break;
        case TS_OFF_C:
            VCONTROL = 0;
            _text_state = TS_LINE2;
            TRIGGER0_IN_LINES(LINES_TO_TEXTB);
            break;
        case TS_LINE2:
            if (_text_flags & LOGOGEN_TEXTB_ON)
            {
                if (_text_flags & LOGOGEN_LOGO2_ON)
                    VCONTROL = VC_START | VC_SEL1 | VC_SEL0 | VC_BANK1;
                else
                    VCONTROL = VC_START | VC_SEL1 | VC_SEL0;
            }
            _text_state = TS_OFF_D;
            TRIGGER0_IN_LINES(LINE_HEIGHT);
            break;
        case TS_OFF_D:
            VCONTROL = 0;
            _text_state = TS_OFF_A;
            TR0 = 0; // Timer off
            break;
    }
}

void logogen_vblank_isr(void)
{
    _text_state = TS_LINE1;

    TRIGGER0_IN_LINES(LINES_TO_TEXTA);

    TR0 = 1;

    if (_text_flags & LOGOGEN_ACTIVATE_CLOCK)
    {
        _text_flags &= ~LOGOGEN_ACTIVATE_CLOCK;
        _text_flags |= LOGOGEN_CLOCK_ON;
    }

    if (_text_flags & LOGOGEN_ACTIVATE_LG)
    {
        _text_flags &= ~LOGOGEN_ACTIVATE_LG;
        P1 &= ~0x08; // BLANK2 CTRL
    }
}

void logogen_update_text(uint8_t field)
{
    if (field == TEXTA || field == TEXTB)
    {
        int offset;
        uint8_t maxchars;
        uint8_t render_complete_state = field == TEXTA ? TS_CLOCK : TS_OFF_A;
        int len = logogen_get_text_len(_g_text_buf, field == TEXTA ?
            TEXTA_MAXBLOCKS : TEXTB_MAXBLOCKS, &maxchars);

        if (len)
        {
            offset = (CENTER) - (len / 2);
            _g_text_buf[maxchars] = 0;
            while (_text_state != render_complete_state);
            clear_line(field == TEXTA ? 1 : 3);
            write_text(field == TEXTA ? 1 : 3, offset, _g_text_buf);
        }
        else
        {
            while (_text_state != render_complete_state);
            clear_line(field == TEXTA ? 1 : 3);
        }
    }
}

void logogen_update_clock(void)
{
    uint8_t tmp;
    uint16_t dpram_ptr;

    while (_text_state != TS_LINE2); // Wait till after the clock has rendered

    dpram_ptr = (LINE_LEN * 2) + DATE_OFFSET;

    if (!(_ctrl & FORMAT_nDATE_ON))
    {
        tmp = (_ctrl & FORMAT_DATEFMT_MASK) >> FORMAT_DATEFMT_SHIFT;

        if (tmp == FORMAT_EUR)
        {
            // Assumed to be DD:MM:YY
            tmp = clock_get_day();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
            put_clock_char(&dpram_ptr, 11 /* - */);
            tmp = clock_get_month();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
            put_clock_char(&dpram_ptr, 11 /* - */);
            tmp = clock_get_year();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
        }
        else if (tmp == FORMAT_US)
        {
            // MM:DD:YY
            tmp = clock_get_month();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
            put_clock_char(&dpram_ptr, 11 /* - */);
            tmp = clock_get_day();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
            put_clock_char(&dpram_ptr, 11 /* - */);
            tmp = clock_get_year();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
        }
        else
        {   // ISO8601: YY:MM:DD
            tmp = clock_get_year();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
            put_clock_char(&dpram_ptr, 11 /* - */);
            tmp = clock_get_month();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
            put_clock_char(&dpram_ptr, 11 /* - */);
            tmp = clock_get_day();
            put_clock_char(&dpram_ptr, (tmp / 10));
            put_clock_char(&dpram_ptr, (tmp % 10));
        }
    }

    dpram_ptr = (LINE_LEN * 2) + TIME_OFFSET;

    if (!(_ctrl & FORMAT_nTIME_ON))
    {
        uint8_t hour_adjusted = clock_get_hour();
        tmp = (_ctrl & FORMAT_TIMEFMT_MASK) >> FORMAT_TIMEFMT_SHIFT;

        // FORMAT_US is assumed to be 12-hour time.
        if (tmp == FORMAT_US)
        {
            if (hour_adjusted > 12)
                hour_adjusted -= 12;

            if (hour_adjusted == 0)
                hour_adjusted = 12;
        }

        // FORMAT_ISO is never sent by the front panel
        // So FORMAT_EUR must be 24-hour time.

        put_clock_char(&dpram_ptr, (hour_adjusted / 10));
        put_clock_char(&dpram_ptr, (hour_adjusted % 10));
        put_clock_char(&dpram_ptr, 10 /* : */);
        tmp = clock_get_minute();
        put_clock_char(&dpram_ptr, (tmp / 10));
        put_clock_char(&dpram_ptr, (tmp % 10));
        put_clock_char(&dpram_ptr, 10 /* : */);
        tmp = clock_get_second();
        put_clock_char(&dpram_ptr, (tmp / 10));
        put_clock_char(&dpram_ptr, (tmp % 10));
    }
}

int logogen_get_text_len(const char *str, int maxblocks, uint8_t *maxchars)
{
    uint8_t len = (uint8_t)strlen(str);
    int ret = 0;
    int i;

    for (i = 0; i < len; i++)
    {
        const promblock_t* pb = str[i] & CHAR_LOGO_FLAG ? &_g_logo_blocks[str[i] & (uint8_t)~CHAR_LOGO_FLAG] :
            &_g_char_blocks[str[i] - FIRST_CHAR];

        if ((ret + pb->len) > maxblocks)
        {
            *maxchars = i;
            return ret;
        }

        ret += pb->len;
    }

    *maxchars = len;
    return ret;
}

void logogen_init(void)
{
    clear_all();

    HPRESET = DEFAULT_PRESET;
    VCONTROL = 0x00;
    _text_state = TS_LINE1;
    _text_flags = 0;
    _ctrl = (FORMAT_ISO << FORMAT_DATEFMT_SHIFT) | (FORMAT_ISO << FORMAT_TIMEFMT_SHIFT);

    config_read_str(CONFIG_TEXTA, _g_text_buf, MAX_TEXT);
    logogen_texta_loaded();

    config_read_str(CONFIG_TEXTB, _g_text_buf, MAX_TEXT);
    logogen_textb_loaded();
}

// Handle the configuration byte sent by the base
void logogen_ctrl(uint8_t mask, uint8_t config)
{
    uint8_t ctrl_old = _ctrl;

    _ctrl &= ~mask;
    _ctrl |= config;

    if (!(ctrl_old & FORMAT_nDATE_ON) && (_ctrl & FORMAT_nDATE_ON))
        clear_date(); // Date has been switched off. Do it fast to avoid overvoltage.

    if (!(ctrl_old & FORMAT_nTIME_ON) && (_ctrl & FORMAT_nTIME_ON))
        clear_time(); // Time has been switched off. Do it fast to avoid overvoltage.

    if (// Date or time format has changed
        ((_ctrl & (FORMAT_DATEFMT_MASK | FORMAT_TIMEFMT_MASK))
        != (ctrl_old & (FORMAT_DATEFMT_MASK | FORMAT_TIMEFMT_MASK))) ||
        // Date has been switched on.
        ((ctrl_old & FORMAT_nDATE_ON) && !(_ctrl & FORMAT_nDATE_ON)) ||
        // Time has been switched on.
        ((ctrl_old & FORMAT_nTIME_ON) && !(_ctrl & FORMAT_nTIME_ON))
    )
    {
        logogen_update_clock();
    }

    if (!(_ctrl & FORMAT_nDATE_ON) || !(_ctrl & FORMAT_nTIME_ON))
        _text_flags |= LOGOGEN_ACTIVATE_CLOCK; // Delay to avoid overvoltage

    if ((_ctrl & FORMAT_nDATE_ON) && (_ctrl & FORMAT_nTIME_ON))
        _text_flags &= ~LOGOGEN_CLOCK_ON;

    if (_ctrl & FORMAT_LG_ON)
    {
        if (P1 & 0x08)
            _text_flags |= LOGOGEN_ACTIVATE_LG; // Delay to avoid overvoltage
    }
    else
    {
        P1 |= 0x08; // BLANK2 CTRL
    }
}

void logogen_texta_loaded(void)
{
    if (_g_text_buf[0] != 0)
        set_flags(LOGOGEN_TEXTA_ON, LOGOGEN_TEXTA_ON);
    else
        set_flags(LOGOGEN_TEXTA_ON, 0);

    logogen_update_text(TEXTA);
}

void logogen_textb_loaded(void)
{
    if (_g_text_buf[0] != 0)
        set_flags(LOGOGEN_TEXTB_ON, LOGOGEN_TEXTB_ON);
    else
        set_flags(LOGOGEN_TEXTB_ON, 0);

    logogen_update_text(TEXTB);
}

void logogen_set_standard_text(void)
{
    strcpy(_g_text_buf, _standard_texta);
    logogen_texta_loaded();
    config_write_str(CONFIG_TEXTA, _g_text_buf);

    strcpy(_g_text_buf, _standard_textb);
    logogen_textb_loaded();
    config_write_str(CONFIG_TEXTB, _g_text_buf);
}

void logogen_set_clear_text(void)
{
    _g_text_buf[0] = 0;
    logogen_texta_loaded();
    config_write_str(CONFIG_TEXTA, _g_text_buf);

    _g_text_buf[0] = 0;
    logogen_textb_loaded();
    config_write_str(CONFIG_TEXTB, _g_text_buf);
}

void logogen_set_demologo(uint8_t param)
{
    // SCPI Input allowed: 0-15. So...
    // 0-7 = set bottom logo index (most likely to be used)
    // 8-15 = set top logo index (logo index = param - 8)

    if (param < 8)
    {
        if (param > _g_last_logo)
            return;

        _g_text_buf[0] = (param | CHAR_LOGO_FLAG);
        _g_text_buf[1] = 0;

        logogen_textb_loaded();
        config_write_str(CONFIG_TEXTB, _g_text_buf);
    }
    else
    {
        param -= 8;

        if (param > _g_last_logo)
            return;

        _g_text_buf[0] = (param | CHAR_LOGO_FLAG);
        _g_text_buf[1] = 0;

        logogen_texta_loaded();
        config_write_str(CONFIG_TEXTA, _g_text_buf);
    }
}

static void clear_all(void)
{
    int i;

    for (i = 0; i < LINE_LEN * 4; i++)
        DPRAM(i) = SPACE;
}

static void clear_line(uint8_t line)
{
    int i;

    for (i = 0; i < LINE_LEN; i++)
        DPRAM((LINE_LEN * line) + i) = SPACE;

    if (line == 1)
        _text_flags &= ~LOGOGEN_LOGO1_ON;

    if (line == 3)
        _text_flags &= ~LOGOGEN_LOGO2_ON;
}

static void clear_time(void)
{
    uint16_t dpram_ptr;
    uint8_t tmp;
    dpram_ptr = (LINE_LEN * 2) + TIME_OFFSET;

    // Don't clear if clock is being rendered
    while (_text_state == TS_CLOCK)
    {
        uint8_t tl0_copy = TL0;
        // Wait until last line completes
        while (TL0 == tl0_copy);
    }

    for (tmp = 0; tmp < 16; tmp++)
        DPRAM(dpram_ptr + tmp) = SPACE;
}

static void clear_date(void)
{
    uint16_t dpram_ptr;
    uint8_t tmp;
    dpram_ptr = (LINE_LEN * 2) + DATE_OFFSET;

    // Don't clear if clock is being rendered
    while (_text_state == TS_CLOCK)
    {
        uint8_t tl0_copy = TL0;
        // Wait until last line completes
        while (TL0 == tl0_copy);
    }

    for (tmp = 0; tmp < 16; tmp++)
        DPRAM(dpram_ptr + tmp) = SPACE;
}

static void set_flags(uint8_t mask, uint8_t flags)
{
    _text_flags &= ~mask;
    _text_flags |= flags;
}

static void write_text(int line, int offset, const char *str)
{
    int len = strlen(str);
    int i;
    uint8_t block;
    uint16_t dpram_ptr = (LINE_LEN * line) + offset;

    for (i = 0; i < len; i++)
    {
        const promblock_t* pb = str[i] & CHAR_LOGO_FLAG ? &_g_logo_blocks[str[i] & (uint8_t)~CHAR_LOGO_FLAG] :
            &_g_char_blocks[str[i] - FIRST_CHAR];

        for (block = 0; block < pb->len; block++)
            DPRAM(dpram_ptr++) = pb->addr + block;
    }

    if (line == 1)
    {
        if (str[0] & CHAR_LOGO_FLAG)
            _text_flags |= LOGOGEN_LOGO1_ON;
        else
            _text_flags &= ~LOGOGEN_LOGO1_ON;
    }

    if (line == 3)
    {
        if (str[0] & CHAR_LOGO_FLAG)
            _text_flags |= LOGOGEN_LOGO2_ON;
        else
            _text_flags &= ~LOGOGEN_LOGO2_ON;
    }
}

static void put_clock_char(uint16_t *dpram_ptr, uint8_t idx)
{
    idx <<= 1;

    DPRAM(*dpram_ptr) = idx;
    (*dpram_ptr)++;
    DPRAM(*dpram_ptr) = idx + 1;
    (*dpram_ptr)++;
}
