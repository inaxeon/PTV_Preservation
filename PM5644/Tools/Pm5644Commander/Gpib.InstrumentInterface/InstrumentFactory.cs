using Gpib.InstrumentInterface.Exceptions;
using Gpib.InstrumentInterface.Instruments;
using Gpib.InstrumentInterface.Interfaces;
using Ivi.Visa;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gpib.InstrumentInterface
{
    public static class InstrumentFactory
    {
        public static IPatternGenerator GetInstrument(InterfaceType type, string device)
        {
            // Only support one instrument at present
            return new Pm5644(type, device);
        }
    }
}
