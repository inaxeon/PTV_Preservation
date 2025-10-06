using Gpib.InstrumentInterface.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gpib.InstrumentInterface.Interfaces
{
    public interface IPatternGenerator : IDisposable
    {
        string RawCmd(string cmd);
        void CheckIdentification();
        void SetClodeMode(ClockMode mode);
        void SetPattern(PatternType pattern);
        void SetText(TextField box, string text);
        void SetTopDemoLogo(int logoIdx);
        void SetBottomDemoLogo(int logoIdx);
        void SetClock(string value);
        void SetTimeFormat(TimeFormat format);
        void SetDateFormat(DateFormat format);
    }
}
