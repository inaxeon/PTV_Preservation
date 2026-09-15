/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : clock.c
 *   Author      : Matt Millman
 *   Description : Date and time
 *
 *   Accurate timekeeping in the PM5644 is not a straightforward business.
 *   There are two clocks:
 *   
 *   The hardware RTC is responsible for timekeeping when the unit is powered
 *   down. But once it powers up the increase of the RTC's VCC from 3V to 5V
 *   throws its oscillator frequency way off, making it utterly hopeless for
 *   timekeeping in the powered-on state.
 *
 *   Enter the software clock, which is implemented in this file. It is
 *   referenced to the vertical sync thus offers extremely accurate
 *   timekeeping when powered on. The hardware RTC is updated from here
 *   once each second.
 *
 *   In future the timecode decoder will be implemented, which means the
 *   software clock will source from timecode rather than internal counters.
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
#include "clock.h"
#include "config.h"

#define RTC_CONTROL         0x00
#define RTC_HUNDREDTHS      0x01
#define RTC_SECOND          0x02
#define RTC_MINUTE          0x03
#define RTC_HOUR            0x04
#define RTC_YEARDATE        0x05
#define RTC_WDMONTH         0x06

#define RTC_CONTROL_STOP    (1 << 7)
#define RTC_CONTROL_GO      0x00

#define CLOCK_STOP_TIME     (1 << 1)
#define CLOCK_STOP_DATE     (1 << 2)
#define CLOCK_NEEDS_UPDATE  (1 << 3)

#if defined(LINES_625)
#define LINE_FREQ 15625
#elif defined(LINES_525)
#define LINE_FREQ 15734
#else
#error Line count not defined
#endif

#define TRIGGER1_IN_LINES(x) do { \
    TL1 = ((0xFFFF - (x)) & 0xFF); \
    TH1 = ((0xFFFF - (x)) >> 8); \
    } while (0);

#define TIMER1_REMAINING() (0xFFFF - ((TL1) | (TH1 << 8)))

static void tick_second(void);
static void tick_day(void);
static uint8_t number_of_days(uint8_t month_number, int year);
static void read_rtc(void);

static uint8_t _year;
static uint8_t _month;
static uint8_t _day;
static uint8_t _hour;
static uint8_t _minute;
static uint8_t _second;
static uint8_t _clock_state;

void timer1_ISR (void) interrupt 3
{
    if (_clock_state & CLOCK_STOP_TIME)
        return;

    tick_second();
    _clock_state |= CLOCK_NEEDS_UPDATE;

    TRIGGER1_IN_LINES(LINE_FREQ - 1);
}

void clock_init(void)
{
    _year = 0;
    _month = 0;
    _day = 0;
    _hour = 0;
    _minute = 0;
    _second = 0;
    _clock_state = CLOCK_STOP_TIME | CLOCK_STOP_DATE;

    config_write_byte(RTC_CONTROL, 0x00);
    read_rtc();

    TRIGGER1_IN_LINES(LINE_FREQ - 1);
    TR1 = 1;
}

bool clock_needs_update(void)
{
    if (_clock_state & CLOCK_NEEDS_UPDATE)
    {
        _clock_state &= ~CLOCK_NEEDS_UPDATE;
        return true;
    }

    return false;
}

void clock_set_year(uint8_t value)
{
    if (value >= 100)
        return;

    _year = value;

    if ((_year % 4) != 0 && _month == (2 - 1) && _day == (29 - 1))
        _day = (28 - 1); // Kill leap day
}

void clock_set_month(uint8_t value)
{
    if (--value >= 12)
        return;
    
    _month = value;
}

void clock_set_day(uint8_t value)
{
    if (--value >= number_of_days(_month, _year))
        return;

    _day = value;
}

void clock_set_hour(uint8_t value)
{
    if (value >= 60)
        return;
    
    _hour = value;
}

void clock_set_minute(uint8_t value)
{
    if (value >= 60)
        return;

    _minute = value;
}

void clock_set_second(uint8_t value)
{
    if (value >= 60)
        return;

    _second = value;
    TRIGGER1_IN_LINES(LINE_FREQ - 1); // Reset seconds
}

void clock_increment_year(void)
{
    if ((_year) + 1 >= 100)
        _year = 0;
    else
        _year++;

    if ((_year % 4) != 0 && _month == (2 - 1) && _day == (29 - 1))
        _day = (28 - 1); // Kill leap day

    _clock_state |= CLOCK_NEEDS_UPDATE;
}

void clock_increment_month(void)
{
    if ((_month + 1) >= 12)
        _month = 0;
    else
        _month++;

    _clock_state |= CLOCK_NEEDS_UPDATE;
}

void clock_increment_day(void)
{
if ((_day + 1) >= number_of_days(_month, _year))
        _day = 0;
    else
        _day++;

    _clock_state |= CLOCK_NEEDS_UPDATE;
}

void clock_increment_hour(void)
{
    if ((_hour + 1) >= 24)
        _hour = 0;
    else
        _hour++;

    _clock_state |= CLOCK_NEEDS_UPDATE;
}

void clock_increment_minute(void)
{
    if ((_minute + 1) >= 60)
        _minute = 0;
    else
        _minute++;

    _clock_state |= CLOCK_NEEDS_UPDATE;
}

void clock_increment_second(void)
{
    if ((_second + 1) >= 60)
        _second = 0;
    else
        _second++;

    _clock_state |= CLOCK_NEEDS_UPDATE;
}

uint8_t clock_get_year(void)
{
    return _year % 100;
}

uint8_t clock_get_month(void)
{
    return _month + 1;
}

uint8_t clock_get_day(void)
{
    return _day + 1;
}

uint8_t clock_get_hour(void)
{
    return _hour;
}

uint8_t clock_get_minute(void)
{
    return _minute;
}

uint8_t clock_get_second(void)
{
    return _second;
}

void clock_update_rtc(void)
{
    uint8_t rtc_data;
    uint8_t tmp;

    config_write_byte(RTC_CONTROL, RTC_CONTROL_STOP);

    tmp = _day + 1; // RTC indexes days from 1
    rtc_data = tmp % 10;
    rtc_data |= (tmp / 10) << 4;
    rtc_data |= (_year % 4) << 6;

    config_write_byte(RTC_YEARDATE, rtc_data);
    config_write_byte(CONFIG_YEAR, _year);

    tmp = _month + 1; // RTC indexes days from 1
    rtc_data = tmp % 10;
    rtc_data |= (tmp / 10) << 4;

    config_write_byte(RTC_WDMONTH, rtc_data);

    tmp = _hour; // Store for interrupt safety
    rtc_data = tmp % 10;
    rtc_data |= (tmp / 10) << 4;

    config_write_byte(RTC_HOUR, rtc_data);

    tmp = _minute; // Store for interrupt safety
    rtc_data = tmp % 10;
    rtc_data |= (tmp / 10) << 4;

    config_write_byte(RTC_MINUTE, rtc_data);

    tmp = _second; // Store for interrupt safety
    rtc_data = tmp % 10;
    rtc_data |= (tmp / 10) << 4;

    config_write_byte(RTC_SECOND, rtc_data);

    tmp = (uint8_t)(((uint32_t)TIMER1_REMAINING() * 100) / LINE_FREQ);
    rtc_data = tmp % 10;
    rtc_data |= (tmp / 10) << 4;

    config_write_byte(RTC_HUNDREDTHS, rtc_data);
    config_write_byte(RTC_CONTROL, RTC_CONTROL_GO);
}

static void read_rtc(void)
{
    uint8_t rtc_data;
    uint8_t tmp;

    _year = config_read_byte(CONFIG_YEAR);
    tmp = _year & 0x03; // Grab the last two bits of year we stored
    _year &= ~0x03; // Clear them from the main counter
    rtc_data = config_read_byte(RTC_YEARDATE);
    _year |= (rtc_data >> 6);
    // If the RTC has rolled over, add 4 years. We have no way to know
    // if it has rolled over twice. Boo hoo.
    if ((rtc_data >> 6) < tmp)
        _year += 4;

    _day = ((rtc_data & 0x30) >> 4) * 10;
    _day += (rtc_data & 0x0F);
    _day--; // RTC indexes days from 1

    rtc_data = config_read_byte(RTC_WDMONTH) & 0x1F;
    _month = ((rtc_data & 0x10) >> 4) * 10;
    _month += (rtc_data & 0x0F);
    _month--; // RTC indexes months from 1

    rtc_data = config_read_byte(RTC_HOUR) & 0x3F;
    _hour = ((rtc_data & 0x30) >> 4) * 10;
    _hour += (rtc_data & 0x0F);

    rtc_data = config_read_byte(RTC_MINUTE);
    _minute = (rtc_data >> 4) * 10;
    _minute += (rtc_data & 0x0F);

    rtc_data = config_read_byte(RTC_SECOND);
    _second = (rtc_data >> 4) * 10;
    _second += (rtc_data & 0x0F);

    rtc_data = config_read_byte(RTC_HUNDREDTHS);
    tmp = (rtc_data >> 4) * 10;
    tmp += (rtc_data & 0x0F);
    
    // Load factored hundredths into counter
    TRIGGER1_IN_LINES(((uint32_t)tmp * LINE_FREQ) / 100);

    _clock_state &= ~(CLOCK_STOP_TIME | CLOCK_STOP_DATE);
}

void clock_stop_time(void)
{
    _clock_state |= CLOCK_STOP_TIME;
    TRIGGER1_IN_LINES(LINE_FREQ - 1); // Reset seconds
}

void clock_stop_date(void)
{
    _clock_state |= CLOCK_STOP_DATE;
}

void clock_start(void)
{
    _clock_state &= ~(CLOCK_STOP_TIME | CLOCK_STOP_DATE);
}

static uint8_t number_of_days(uint8_t month_number, int year)
{
    switch (month_number)
    {
    case 0:
        return 31;
    case 1:
        if ((year % 4) == 0)
            return 29;
        else
            return 28;
    case 2:
        return 31;
    case 3:
        return 30;
    case 4:
        return 31;
    case 5:
        return 30;
    case 6:
        return 31;
    case 7:
        return 31;
    case 8:
        return 30;
    case 9:
        return 31;
    case 10:
        return 30;
    case 11:
        return 31;
    }
    return 0;
}

static void tick_second(void)
{
    if (_second < (60 - 1))
    {
        _second++;
    }
    else
    {
        _second = 0;
        if (_minute < (60 - 1))
        {
            _minute++;
        }
        else
        {
            _minute = 0;
            if (_hour < (24 - 1))
            {
                _hour++;
            }
            else
            {
                _hour = 0;

                if (!(_clock_state & CLOCK_STOP_DATE))
                    tick_day();
            }
        }
    }
}

static void tick_day(void)
{
    uint8_t num_days = number_of_days(_month, _year);
    
    if ((_day + 1) < num_days)
    {
        _day++;
    }
    else
    {
        _day = 0;
        if (_month < (12 - 1))
        {
            _month++;
        }
        else
        {
            _month = 0;
            if (_year < (100 - 1))
                _year++;
            else
                _year = 0;
        }
    }
}



#if 0

// MM: TODO: The below was written by Claude. Look at in future.

/* ============================================================================
 * EBU/LTC-style timecode decoder (grey-code link from external decoder chip)
 * ----------------------------------------------------------------------------
 * Reverse engineered from the original PM8546 firmware, via Ghidra.
 * NOT wired up yet - this is a straight port of the original 8051 state
 * machine so the algorithm can
 * be reviewed/tested before it gets hooked up to the software clock.
 *
 * Hardware: an external analogue decoder does the bi-phase/grey-code
 * demodulation and exports plain clock + data:
 *   - clock -> INT1
 *   - data  -> P1.4
 *
 * Each frame is 80 bit-times, matching SMPTE/EBU LTC: a long sync pulse
 * (measured by width, not bit-decoded) followed by 64 data bits shifted in
 * as 8 bytes. Those 8 bytes are simultaneously:
 *   - combined pairwise (with a nibble swap) into 4 "field" bytes holding
 *     hours/minutes/seconds/frames, plus 2 flag bits stolen from the top of
 *     the seconds/minutes bytes (drop-frame/colour-frame)
 *   - kept in full as an 8-byte "user bits" block, validated with a simple
 *     nibble-sum checksum before being latched
 *
 * Omitted from this port (present in the original but not essential to the
 * algorithm): a P1.2-gated alternate ISR mode, a P1.1 scope/debug pin toggle,
 * and a Timer1 reload used as an inter-bit timeout watchdog.
 * ========================================================================= */

#define TC_DATA_BIT()           (!!(P1 & 0x10))    /* P1.4 */
#define TC_SYNC_PULSE_WIDTH     0x0C
#define SWAP_NIBBLES(x)         ((uint8_t)(((x) >> 4) | ((x) << 4)))

/* sync/frame-boundary hunting state */
static uint8_t _tc_frame_synced;     /* 1 = shifting frame data, 0 = hunting for the sync pulse */
static uint8_t _tc_frame_valid;      /* 1 = previous frame's 8 bytes were shifted in cleanly */
static uint8_t _tc_bit_sync;         /* pulse-train lock indicator (cleared on mistimed edges) */
static uint8_t _tc_pulse_state1;
static uint8_t _tc_pulse_state2;
static uint8_t _tc_pulse_state3;
static uint8_t _tc_sync_pulse_count;
static uint8_t _tc_frame_bit_count;  /* total bit-times seen since the last sync pulse (0..0x50) */
static uint8_t _tc_swap_disable;     /* mirrors an external flag bit whose producer wasn't traced */

/* bit/byte shifting state */
static uint8_t _tc_shiftreg;
static uint8_t _tc_bit_count;
static uint8_t _tc_byte_count;
static uint8_t _tc_raw_fields[4];    /* combined hours/minutes/seconds/frames bytes */
static uint8_t _tc_user_bits_raw[8]; /* raw shifted bytes, one per completed byte in the frame */

/* decoded results */
uint8_t tc_hours;
uint8_t tc_minutes;
uint8_t tc_seconds;
uint8_t tc_frames;
uint8_t tc_flags;             /* bit3 = colour-frame, bit7 = drop-frame (stolen sign bits) */
uint8_t tc_user_bits_valid;
uint8_t tc_user_bits[3];

static void tc_reset_to_search(void)
{
    _tc_frame_synced = 0;
    _tc_pulse_state1 = 1;
    _tc_pulse_state2 = 1;
    _tc_pulse_state3 = 1;
    _tc_sync_pulse_count = 0;
}

static void tc_extract_frame(void)
{
    uint8_t sum;

    tc_frames  = _tc_raw_fields[3] & 0x3f;
    tc_seconds = _tc_raw_fields[2] & 0x7f;
    tc_flags   = SWAP_NIBBLES(_tc_raw_fields[2] & 0x80);
    tc_minutes = _tc_raw_fields[1] & 0x7f;
    tc_flags  |= (_tc_raw_fields[1] & 0x80);
    tc_hours   = _tc_raw_fields[0] & 0x3f;

    /* The original also gates the block below on two external flag bits
     * whose producers weren't traced - assumed enabled here. */

    if (SWAP_NIBBLES(_tc_user_bits_raw[7]) != 0x08)
    {
        tc_user_bits_valid = 0;
        return;
    }

    sum  = 0x08;
    sum += _tc_user_bits_raw[6];
    sum += SWAP_NIBBLES(_tc_user_bits_raw[5]);
    sum += _tc_user_bits_raw[4];
    sum += SWAP_NIBBLES(_tc_user_bits_raw[3]);
    sum += _tc_user_bits_raw[2];
    sum += SWAP_NIBBLES(_tc_user_bits_raw[1]);

    if (((_tc_user_bits_raw[0] + sum + 1) & 0x0f) != 0)
    {
        tc_user_bits_valid = 0;
        return;
    }

    tc_user_bits[0] = _tc_user_bits_raw[6] | _tc_user_bits_raw[5];
    tc_user_bits[1] = _tc_user_bits_raw[4] | _tc_user_bits_raw[3];
    tc_user_bits[2] = _tc_user_bits_raw[2] | _tc_user_bits_raw[1];
    tc_user_bits_valid = 1;
}

/* Called once per clock edge on INT1 with the sampled P1.4 level.
 * Mirrors FUN_CODE_1b44 (EBU_Greycode_BitShiftAndDecode) in the original. */
static void tc_process_bit(uint8_t data_bit)
{
    if (_tc_frame_synced)
    {
        uint8_t nib_lo, nib_hi;

        _tc_shiftreg = (_tc_shiftreg >> 1) | (data_bit ? 0x80 : 0x00);

        if (--_tc_bit_count != 0)
            return;

        _tc_byte_count--;
        _tc_bit_count = 8;

        nib_lo = _tc_shiftreg & 0x0f;
        if (!_tc_swap_disable)
            nib_lo = SWAP_NIBBLES(nib_lo);
        _tc_raw_fields[_tc_byte_count >> 1] |= nib_lo;

        nib_hi = _tc_shiftreg & 0xf0;
        if (!_tc_swap_disable)
            nib_hi = SWAP_NIBBLES(nib_hi);
        _tc_user_bits_raw[_tc_byte_count] = nib_hi;

        if (_tc_byte_count != 0)
            return;

        tc_reset_to_search();
        return;
    }

    if (!data_bit)
    {
        if (_tc_pulse_state1)
        {
            _tc_pulse_state1 = 0;
            _tc_pulse_state2 = 1;
            _tc_pulse_state3 = 1;
            _tc_sync_pulse_count = 0;
            _tc_bit_sync = 0;
            return;
        }
        if (_tc_pulse_state2)
        {
            _tc_pulse_state2 = 0;
            _tc_pulse_state3 = 1;
            _tc_sync_pulse_count = 0;
            _tc_bit_sync = 0;
            return;
        }
        if (_tc_sync_pulse_count == 0)
        {
            _tc_pulse_state2 = 0;
            _tc_pulse_state3 = 1;
            _tc_sync_pulse_count = 0;
            _tc_bit_sync = 0;
            return;
        }
        if (_tc_sync_pulse_count != TC_SYNC_PULSE_WIDTH)
        {
            _tc_pulse_state1 = 0;
            _tc_pulse_state2 = 1;
            _tc_pulse_state3 = 1;
            _tc_sync_pulse_count = 0;
            _tc_bit_sync = 0;
            return;
        }
        _tc_pulse_state3 = 0;
        return;
    }

    /* data_bit == 1 */
    if (_tc_pulse_state1 || _tc_pulse_state2)
    {
        tc_reset_to_search();
        return;
    }
    if (_tc_pulse_state3)
    {
        _tc_sync_pulse_count++;
        if (_tc_sync_pulse_count <= TC_SYNC_PULSE_WIDTH)
            return;
        tc_reset_to_search();
        return;
    }

    /* pulse width confirmed - check whether the preceding frame was
     * exactly 80 bit-times long */
    if (_tc_frame_bit_count == 0x50)
    {
        _tc_frame_bit_count = 0;
        if (_tc_frame_valid)
            tc_extract_frame();
        _tc_frame_synced = 1;
        _tc_frame_valid = 1;
        _tc_bit_count = 8;
        _tc_byte_count = 8;
        _tc_sync_pulse_count = 0;
        return;
    }

    _tc_frame_bit_count = 0;
    _tc_frame_valid = 0;
    tc_reset_to_search();
}

/* Not enabled yet - to hook up: set IT1 = 1; EX1 = 1; in mcu_init(). */
void timecode_ISR(void) interrupt 2
{
    _tc_frame_bit_count++;
    tc_process_bit(TC_DATA_BIT());
}

#endif