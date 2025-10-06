using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gpib.InstrumentInterface.Exceptions
{
    public class InvalidInstrumentException : Exception
    {
        public InvalidInstrumentException(string message) : base(message)
        {

        }
    }
}
