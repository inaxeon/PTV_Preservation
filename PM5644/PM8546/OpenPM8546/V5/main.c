/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : main.c
 *   Author      : Matt Millman
 *   Description : Main application code
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
#include "rs232.h"
#include "cmd.h"
#include "i2c.h"
#include "config.h"
#include "edit.h"
#include "clock.h"

static void load_config(void);
static void texta_loaded(void);
static void textb_loaded(void);
static void set_standard_text(void);
static void set_clear_text(void);
static void process_rx_cmd(uint8_t cmd);
static void set_logo(uint8_t param);
static void handle_reset_config(uint8_t param);

extern uint8_t _g_rxcmd;
extern uint8_t _g_rxcmd_idx;
extern char _g_text_buf[];

void vblank_ISR (void) interrupt 0
{
    logogen_vblank_isr();
    edit_vblank_isr();
    clock_vblank_isr();
    rs232_vblank_isr();
}

void timer1_ISR (void) interrupt 3
{
    // This counter is physically hooked up but...
    // Not sure what we need it for.
}

void mcu_init(void)
{
    IE = 0x00; //Disable all interrupts
    TMOD = 0x55; // Timer0/1 Configure as 16-bit counters
    EX0 = 1; // Enable external interrupt 0 (vblank)
    ET0 = 1; // Enable timer0 overflow (line counter)
    IT0 = 1; // INT0: Falling edge 
    EA = 1; // Enable interrupts globally
    PCON = 0x80; // Enable double serial baud rate
    P1 = 0xFF; // NOTE: P1.3 (BLANK2 CTRL) SET TO 1 HERE!
}

void main (void)
{
    mcu_init();
    config_validate();
    rs232_init();
    cmd_init();
    clock_init();
    logogen_init();
    edit_init();

    while (1)
    {
        uint8_t edit_update;

        // Most of what happens inside the logo generator is initiated by
        // the base, thus happens in cmd_work().
        cmd_work();

        if (clock_needs_update())
        {
            logogen_update_clock();

            // NOTE: The RTC's clock is tuned for the power off state (VCC=3V)
            // When powered on (VCC=5V) it will run faster, thus we no longer
            // trust it. So we update the RTC every second to keep it accurate.
            clock_update_rtc();
        }

        edit_update = edit_needs_update();

        if (edit_update == TEXTA)
            logogen_texta_loaded();

        if (edit_update == TEXTB)
            logogen_textb_loaded();
    }
}
