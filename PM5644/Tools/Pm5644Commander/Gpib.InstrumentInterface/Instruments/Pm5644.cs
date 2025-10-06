using Gpib.InstrumentInterface.Exceptions;
using Gpib.InstrumentInterface.Interfaces;
using Gpib.InstrumentInterface.Models;
using Ivi.Visa;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gpib.InstrumentInterface.Instruments
{

    public class Pm5644 : IPatternGenerator
    {
        private bool _disposed = false;
        private InstrumentAccess _instrumentAccess;

        private readonly Tuple<PatternType, int, int>[] _patternMapping = new[]
        {
            new Tuple<PatternType, int, int>(PatternType.Philips, 0, 1),
            new Tuple<PatternType, int, int>(PatternType.CBEBU, 1, 1),
            new Tuple<PatternType, int, int>(PatternType.CBEBUGrid, 1, 2),
            new Tuple<PatternType, int, int>(PatternType.Red75, 1, 3),
            new Tuple<PatternType, int, int>(PatternType.G1P4, 1, 4),
            new Tuple<PatternType, int, int>(PatternType.G1P5, 1, 5),
        };

        public Pm5644(InterfaceType interfaceType, string device)
        {
            _instrumentAccess = new InstrumentAccess(interfaceType, device);
        }

        public void CheckIdentification()
        {
            _instrumentAccess.WriteLine("*IDN?");

            var response = _instrumentAccess.ReadLine();

            if (!response.StartsWith("PHILIPS,PM5644"))
                throw new InvalidInstrumentException($"Incorrect instrument on: {_instrumentAccess.Device}. Instrument response: {response}");
        }

        public string RawCmd(string cmd)
        {
            var sw = new Stopwatch();
            sw.Start();
            _instrumentAccess.WriteLine(cmd);
            var res = _instrumentAccess.ReadLine();
            Console.WriteLine("Elapsed: " + sw.ElapsedMilliseconds);
            sw.Stop();
            return res;
        }

        public PatternType GetPattern()
        {
            _instrumentAccess.WriteLine("PATTERN?");
            var pattern = _instrumentAccess.ReadInt64();
            _instrumentAccess.WriteLine("PATTERNGROUP?");
            var group = _instrumentAccess.ReadInt64();
            var mapping = _patternMapping.SingleOrDefault(el => el.Item2 == group && el.Item3 == pattern);

            Console.WriteLine($"Group: {group} Pattern: {pattern}");

            if (mapping == null)
            {
                // throw exception
            }

            return mapping?.Item1 ?? PatternType.Red75;
        }

        public void SetPattern(PatternType pattern)
        {
            var mapping = _patternMapping.SingleOrDefault(el => el.Item1 == pattern);

            if (mapping == null)
            {
                // throw exception
            }

            _instrumentAccess.WriteLine($"PATTERNGROUP {mapping.Item2}");
            _instrumentAccess.WriteLine($"PATTERN {mapping.Item3}");
        }

        public void SetText(TextField box, string text)
        {
            if (box == TextField.Top)
                _instrumentAccess.WriteLine($"TEXTA \"{text}\"");
            else
                _instrumentAccess.WriteLine($"TEXTB \"{text}\"");
        }

        public void SetClock(string value)
        {
            var dt = DateTime.Now.AddSeconds(1); // The commands take a while...

            if (value != null)
                dt = DateTime.Parse(value);

            _instrumentAccess.WriteLine("TIMEFORMAT EUR");
            _instrumentAccess.WriteLine("DATEFORMAT EUR");
            _instrumentAccess.WriteLine(string.Format("YEAR {0:yy}", dt));
            _instrumentAccess.WriteLine(string.Format("MONTH {0:MM}", dt));
            _instrumentAccess.WriteLine(string.Format("DAY {0:dd}", dt));
            _instrumentAccess.WriteLine(string.Format("HOUR {0:HH}", dt));
            _instrumentAccess.WriteLine(string.Format("MINUTE {0:mm}", dt));
            _instrumentAccess.WriteLine(string.Format("SECOND {0:ss}", dt));
        }

        public void SetClodeMode(ClockMode mode)
        {
            if (mode == ClockMode.DateTime)
            {
                _instrumentAccess.WriteLine("DATE ON");
            }
            else if (mode == ClockMode.Time)
            {
                _instrumentAccess.WriteLine("DATE OFF");
                _instrumentAccess.WriteLine("TIME ON");
            }
            else
            {
                _instrumentAccess.WriteLine("DATE OFF");
                _instrumentAccess.WriteLine("TIME OFF");
            }
        }

        public void SetTimeFormat(TimeFormat format)
        {
            if (format == TimeFormat.TwentyFourHour)
                _instrumentAccess.WriteLine("TIMEFORMAT EUR");
            else
                _instrumentAccess.WriteLine("TIMEFORMAT US");
        }

        public void SetDateFormat(DateFormat format)
        {
            switch (format)
            {
                case DateFormat.DayMonthYear:
                    _instrumentAccess.WriteLine("DATEFORMAT EUR");
                    break;
                case DateFormat.MonthDayYear:
                    _instrumentAccess.WriteLine("DATEFORMAT US");
                    break;
                case DateFormat.YearMonthDay:
                    _instrumentAccess.WriteLine("DATEFORMAT ISO");
                    break;
            }
        }

        public void SetTopDemoLogo(int logoIdx)
        {
            _instrumentAccess.WriteLine($"DEMOLOGO {logoIdx + 8}");
        }

        public void SetBottomDemoLogo(int logoIdx)
        {
            _instrumentAccess.WriteLine($"DEMOLOGO {logoIdx}");
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                _instrumentAccess.CloseDevice();
            }

            _disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
