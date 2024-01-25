/*
 *   Philips PM8546 Logo Generator Firmware
 *   Open source recreation
 * 
 *   File        : clock.c
 *   Author      : Matt Millman
 *   Description : Date and time
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

 #ifndef __CLOCK_H__
 #define __CLOCK_H__

void clock_vblank_isr(void);
void clock_init(void);
bool clock_needs_update(void);
void clock_set_year(uint8_t value);
void clock_set_month(uint8_t value);
void clock_set_day(uint8_t value);
void clock_set_hour(uint8_t value);
void clock_set_minute(uint8_t value);
void clock_set_second(uint8_t value);
void clock_increment_year(void);
void clock_increment_month(void);
void clock_increment_day(void);
void clock_increment_hour(void);
void clock_increment_minute(void);
void clock_increment_second(void);
uint8_t clock_get_year(void);
uint8_t clock_get_month(void);
uint8_t clock_get_day(void);
uint8_t clock_get_hour(void);
uint8_t clock_get_minute(void);
uint8_t clock_get_second(void);
void clock_update_rtc(void);
void clock_stop_time(void);
void clock_stop_date(void);
void clock_start(void);

#endif /* __CLOCK_H__ */