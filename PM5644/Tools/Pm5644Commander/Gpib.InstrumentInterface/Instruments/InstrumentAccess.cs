using Gpib.InstrumentInterface.Interfaces;
using Ivi.Visa;
using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Threading;

namespace Gpib.InstrumentInterface.Instruments
{
    public class InstrumentAccess
    {
        private readonly InterfaceType _interfaceType;
        private readonly string _device;

        private IMessageBasedSession _session;
        private SerialPort _serialPort;

        public string Device { get { return _device; } }

        public InstrumentAccess(InterfaceType interfaceType, string device)
        {
            _interfaceType = interfaceType;
            _device = device;
        }

        public void OpenDevice()
        {
            if (_interfaceType == InterfaceType.Rs232)
            {
                if (_serialPort != null)
                    return;

                _serialPort = new SerialPort();
                _serialPort.PortName = _device;
                _serialPort.BaudRate = 9600;
                _serialPort.DataBits = 8;
                _serialPort.Handshake = Handshake.RequestToSend;
                _serialPort.Parity = Parity.None;
                _serialPort.StopBits = StopBits.One;
                _serialPort.WriteTimeout = 3000;

                _serialPort.Open();
            }
            else if (_interfaceType == InterfaceType.Gpib)
            {
                if (_session != null)
                    return;

                _session = GlobalResourceManager.Open(_device) as IMessageBasedSession;
                _session.TimeoutMilliseconds = 10000;
                _session.TerminationCharacterEnabled = false;
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public void CloseDevice()
        {
            if (_interfaceType == InterfaceType.Rs232)
            {
                if (_serialPort.IsOpen)
                    _serialPort.Close();
            }
            else if (_interfaceType == InterfaceType.Gpib)
            {
                _session.Dispose();
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public void WriteLine(string str)
        {
            OpenDevice();

            if (_interfaceType == InterfaceType.Rs232)
            {
                var bytes = Encoding.ASCII.GetBytes(str + "\n");

                for (int i = 0; i < bytes.Length; i++)
                {
                    _serialPort.Write(bytes, i, 1);
                    Thread.Sleep(1); // Don't know why this has to be done one at a time, with a delay in-between?
                }

            }
            else if (_interfaceType == InterfaceType.Gpib)
            {
                _session.FormattedIO.WriteLine(str);
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public string ReadLine()
        {
            OpenDevice();

            if (_interfaceType == InterfaceType.Rs232)
            {
                return ReadSerialLine();
            }
            else if (_interfaceType == InterfaceType.Gpib)
            {
                return _session.FormattedIO.ReadLine();
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public long ReadInt64()
        {
            OpenDevice();

            if (_interfaceType == InterfaceType.Rs232)
            {
                return long.Parse(ReadSerialLine());
            }
            else if (_interfaceType == InterfaceType.Gpib)
            {
                return _session.FormattedIO.ReadInt64();
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        private string ReadSerialLine()
        {
            byte[] buffer = new byte[512];
            do
            {
                _serialPort.Read(buffer, 0, 1);
            } while (buffer[0] == '\r' || buffer[0] == '\n');

            int pos = 0;
            do
            {
                pos++;
                _serialPort.Read(buffer, pos, 1);
            } while (buffer[pos] != '\r' && buffer[pos] != '\n');

            var result = Encoding.ASCII.GetString(buffer, 0, pos);
            return result.Trim(new[] { '\r', '\n', ' ' });
        }

        public void SetTimeout(int ms)
        {
            if (_interfaceType == InterfaceType.Rs232)
            {
                _serialPort.ReadTimeout = ms;
            }
            else if (_interfaceType == InterfaceType.Gpib)
            {
                // Not needed as "button press" mode not yet working
            }
            else
            {
                throw new NotImplementedException();
            }
        }
    }
}
