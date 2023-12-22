/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : logogen.c
 *   Author      : Matt Millman
 *   Description : Logo generator hardware driver
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

 #ifndef __LOGOGEN_H__
 #define __LOGOGEN_H__

#define LOGOGEN_TEXTA_ON        (1 << 1)
#define LOGOGEN_CLOCK_ON        (1 << 2)
#define LOGOGEN_TEXTB_ON        (1 << 3)
#define LOGOGEN_LOGO1_ON        (1 << 4)
#define LOGOGEN_LOGO2_ON        (1 << 5)
#define LOGOGEN_ACTIVATE_CLOCK  (1 << 6)
#define LOGOGEN_ACTIVATE_LG     (1 << 7)


#if defined(ASPECT_4_3)
#define TEXTA_MAXBLOCKS     18
#define TEXTB_MAXBLOCKS     28
#elif defined(ASPECT_16_9)
#define TEXTA_MAXBLOCKS     20
#define TEXTB_MAXBLOCKS     30
#else
#error Aspect ratio not defined
#endif


#define TEXTA               1
#define TEXTB               2
#define MAX_TEXT            32 /* 31 + null terminator */

#define FIRST_CHAR          0x20
#define LAST_CHAR           0x7E
#define CHAR_LOGO_FLAG      0x80
#define FIRST_LOGO          0x00

typedef struct 
{
    const uint8_t len;
    const uint8_t addr;
} promblock_t;

void logogen_init(void);
void logogen_update_text(uint8_t field);
void logogen_texta_loaded(void);
void logogen_textb_loaded(void);
void logogen_set_standard_text(void);
void logogen_set_clear_text(void);
void logogen_set_demologo(uint8_t param);
void logogen_vblank_isr(void);
int logogen_get_text_len(const char *str, int maxblocks, uint8_t *maxchars);
void logogen_ctrl(uint8_t mask, uint8_t config);
void logogen_update_clock(void);

extern const uint8_t _g_last_logo;

#endif /* __LOGOGEN_H__ */