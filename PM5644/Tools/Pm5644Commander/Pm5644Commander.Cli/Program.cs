using Gpib.InstrumentInterface;
using Gpib.InstrumentInterface.Interfaces;
using Gpib.InstrumentInterface.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pm5644Commander.Cli
{
    class Program
    {
        private enum OperationType
        {
            None,
            ReadPattern,
            SetPattern,
            SetUpperText,
            RawCmd,
            SetClock,
        }

        static void Main(string[] args)
        {
            var operation = OperationType.None;
            string addr = null;
            string value = null;

            for (int i = 0; i < args.Count(); i++)
            {
                switch (args[i])
                {
                    case "/RawCmd":
                        operation = OperationType.RawCmd;
                        break;
                    case "/ReadPattern":
                        operation = OperationType.ReadPattern;
                        break;
                    case "/SetPattern":
                        operation = OperationType.SetPattern;
                        break;
                    case "/SetUpperText":
                        operation = OperationType.SetUpperText;
                        break;
                    case "/SetClock":
                        operation = OperationType.SetClock;
                        break;
                    case "/Address":
                        addr = args[++i];
                        break;
                    case "/Value":
                        value = args[++i];
                        break;
                }
            }

            if (string.IsNullOrEmpty(addr))
            {
                Console.Error.WriteLine("Must specify address i.e. GPIB0::2::INSTR");
                return;
            }

            if (operation == OperationType.SetPattern
                )
            {
                if (value == null)
                {
                    Console.Error.WriteLine("Must specify index");
                    return;
                }
            }

            var instr = InstrumentFactory.GetInstrument(addr);

            switch (operation)
            {
                case OperationType.RawCmd:
                    var response = instr.RawCmd(value);
                    Console.WriteLine($"Response: {response}");
                    break;
                case OperationType.SetPattern:
                    PatternType newPattern;
                    if (Enum.TryParse(value, true, out newPattern))
                        instr.SetPattern(newPattern);
                    break;
                case OperationType.ReadPattern:
                    //var pattern = instr.GetPattern();
                    //Console.WriteLine($"Current Pattern: {pattern}");
                    break;
                case OperationType.SetUpperText:
                    instr.SetText(TextField.Top, value);
                    break;
                case OperationType.SetClock:
                    instr.SetClock(value);
                    break;
                default:
                    Console.WriteLine("No operation specified");
                    return;
            }

            instr.Dispose();
        }
    }
}
