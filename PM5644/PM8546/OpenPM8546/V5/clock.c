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
static uint8_t _field_counter;
static uint8_t _clock_state;

void clock_vsync_isr(void)
{
    if (_clock_state & CLOCK_STOP_TIME)
        return;

    if (++_field_counter == FPS)
    {
        _field_counter = 0;
        tick_second();
        _clock_state |= CLOCK_NEEDS_UPDATE;
    }
}

void clock_init(void)
{
    _year = 0;
    _month = 0;
    _day = 0;
    _hour = 0;
    _minute = 0;
    _second = 0;
    _field_counter = 0;
    _clock_state = CLOCK_STOP_TIME | CLOCK_STOP_DATE;

    config_write_byte(RTC_CONTROL, 0x00);
    read_rtc();
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

void clock_set_time(uint8_t hour, uint8_t minute, uint8_t second, uint8_t hundredths)
{
    _hour = hour;
    _minute = minute;
    _second = second;
    _field_counter = hundredths / 2;
}

void clock_set_date(uint8_t year, uint8_t month, uint8_t day)
{
    _year = year;
    _month = month;
    _day = day;
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
    _field_counter = 0;
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

    //TODO: Different for NTSC/PAL-M
    tmp = _field_counter;
    rtc_data = (tmp * 2) % 10;
    rtc_data |= ((tmp * 2) / 10) << 4;

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

    //TODO: Different for NTSC/PAL-M
    rtc_data = config_read_byte(RTC_HUNDREDTHS);
    tmp = (rtc_data >> 4) * 10;
    tmp += (rtc_data & 0x0F);
    _field_counter = tmp / 2;

    _clock_state &= ~(CLOCK_STOP_TIME | CLOCK_STOP_DATE);
}

void clock_stop_time(void)
{
    _clock_state |= CLOCK_STOP_TIME;
    _field_counter = 0;
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
