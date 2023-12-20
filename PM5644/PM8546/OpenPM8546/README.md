# OpenPM8546

This folder contains a reconstruction of the software for the Philips PM8546 logo generator, whose original software is unobtainable.

It implements all of the known functionality of the original hardware and generates an identical output. With no example of an original PM8546 available to study, it may differ in some unknown ways.

## Features

* Top box text / logo generation
* Bottom box text / logo generation
* Logos in up to 8 colours as per original hardware
* Clock (date/time) 12/24 hr mode, configurable date format
* Built in text editor
* All settings configurable from front panel and SCPI

## NOT IMPLEMENTED (yet)

* Anything other than PAL 16:9
* Timecode decoder

## Contents

* V5: Firmware
* V8: Address and timecode decoder
* V15: Horizontal counter PAL
* V16: Vertical counter PAL
* V18: Green PROM
* V19: Blue PROM
* V20: Red PROM
* V28: Y/G encoder PAL
* V28_MONO: Y/G encoder PAL (for monochrome builds where UV/BR components are omitted)
* V29: UV/BR encoder PAL
* V29_MONO: TESTING ONLY. DO NOT USE!
