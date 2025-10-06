using Gpib.InstrumentInterface.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Gpib.InstrumentInterface;
using Gpib.InstrumentInterface.Models;

namespace Pm5644Commander.Gui
{
    public partial class Pm5644Commander : Form
    {
        private readonly Timer _secondTimer;
        private InterfaceType _interfaceType;

        public Pm5644Commander()
        {
            _secondTimer = new Timer();
            InitializeComponent();
        }

        private void Pm5644Commander_Load(object sender, EventArgs e)
        {
            ddlPattern.SelectedIndex = 0;
            ddlBottomDemoLogo.SelectedIndex = 0;
            ddlClockMode.SelectedIndex = 0;
            ddlDateFormat.SelectedIndex = 0;
            ddlTimeFormat.SelectedIndex = 0;
            ddlTopDemoLogo.SelectedIndex = 0;

            _secondTimer.Interval = 1000;
            _secondTimer.Tick += SecondTimer_Tick;
            _secondTimer.Start();

            LoadSettings();
        }

        private void LoadSettings()
        {
            ddlPattern.SelectedIndex = Properties.Settings.Default.Pattern;
            ddlClockMode.SelectedIndex = Properties.Settings.Default.ClockMode;
            ddlDateFormat.SelectedIndex = Properties.Settings.Default.DateFormat;
            ddlTimeFormat.SelectedIndex = Properties.Settings.Default.TimeFormat;
            txtTopText.Text = Properties.Settings.Default.TopText;
            ddlTopDemoLogo.SelectedIndex = Properties.Settings.Default.TopLogo;
            txtBottomText.Text = Properties.Settings.Default.BottomText;
            ddlBottomDemoLogo.SelectedIndex = Properties.Settings.Default.BottomLogo;
            txtGpibAddress.Text = Properties.Settings.Default.InstrumentAddress;
            txtComPort.Text = Properties.Settings.Default.ComPort;
            _interfaceType = (InterfaceType)Properties.Settings.Default.InterfaceType;

            if (_interfaceType == InterfaceType.Rs232)
            {
                btnSelectCom.Checked = true;
                btnSelectGpib.Checked = false;
            }
            else
            {
                btnSelectCom.Checked = false;
                btnSelectGpib.Checked = true;
            }
        }


        private void SaveSettings()
        {
            Properties.Settings.Default.Pattern = ddlPattern.SelectedIndex;
            Properties.Settings.Default.ClockMode = ddlClockMode.SelectedIndex;
            Properties.Settings.Default.DateFormat = ddlDateFormat.SelectedIndex;
            Properties.Settings.Default.TimeFormat = ddlTimeFormat.SelectedIndex;
            Properties.Settings.Default.TopText = txtTopText.Text;
            Properties.Settings.Default.TopLogo = ddlTopDemoLogo.SelectedIndex;
            Properties.Settings.Default.BottomText = txtBottomText.Text;
            Properties.Settings.Default.BottomLogo = ddlBottomDemoLogo.SelectedIndex;
            Properties.Settings.Default.InstrumentAddress = txtGpibAddress.Text;
            Properties.Settings.Default.ComPort = txtComPort.Text;
            Properties.Settings.Default.InterfaceType = (int)_interfaceType;
            Properties.Settings.Default.Save();
        }

        private void SecondTimer_Tick(object sender, EventArgs e)
        {
            if (!rbClockSpecific.Checked)
                txtClockSpecific.Text = DateTime.Now.ToString();
        }

        private void EnableControls()
        {
            grpAddress.Enabled = true;
            grpPattern.Enabled = true;
            grpClock.Enabled = true;
            grpTopText.Enabled = true;
            grpBottomText.Enabled = true;
        }

        private void DisableControls()
        {
            grpAddress.Enabled = false;
            grpPattern.Enabled = false;
            grpClock.Enabled = false;
            grpTopText.Enabled = false;
            grpBottomText.Enabled = false;
        }

        private void RunCommand(Action<IPatternGenerator> action)
        {
            if (string.IsNullOrEmpty(txtGpibAddress.Text))
            {
                MessageBox.Show("No instrument address set", "No address set", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                using (var instr = InstrumentFactory.GetInstrument(_interfaceType, _interfaceType == InterfaceType.Rs232 ? txtComPort.Text : txtGpibAddress.Text))
                {
                    DisableControls();
                    action(instr);
                    SaveSettings();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "An error occurred", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                EnableControls();
            }
        }

        private void UpdateSetClockControls()
        {
            if (rbClockSpecific.Checked)
                txtClockSpecific.Enabled = true;
            else
                txtClockSpecific.Enabled = false;
        }

        private void rbClockSpecific_CheckedChanged(object sender, EventArgs e)
        {
            UpdateSetClockControls();
        }

        private void rbClockNow_CheckedChanged(object sender, EventArgs e)
        {
            UpdateSetClockControls();
        }

        private void UpdateTopTextControls()
        {
            if (rbTopTextText.Checked)
            {
                txtTopText.Enabled = true;
                ddlTopDemoLogo.Enabled = false;
            }
            else if (rbTopTextDemoLogo.Checked)
            {
                txtTopText.Enabled = false;
                ddlTopDemoLogo.Enabled = true;
            }
            else
            {
                txtTopText.Enabled = false;
                ddlTopDemoLogo.Enabled = false;
            }
        }

        private void rbTopTextText_CheckedChanged(object sender, EventArgs e)
        {
            UpdateTopTextControls();
        }

        private void rbTopTextDemoLogo_CheckedChanged(object sender, EventArgs e)
        {
            UpdateTopTextControls();
        }


        private void UpdateBottomTextControls()
        {
            if (rbBottomTextText.Checked)
            {
                txtBottomText.Enabled = true;
                ddlBottomDemoLogo.Enabled = false;
            }
            else if (rbBottomTextDemoLogo.Checked)
            {
                txtBottomText.Enabled = false;
                ddlBottomDemoLogo.Enabled = true;
            }
            else
            {
                txtBottomText.Enabled = false;
                ddlBottomDemoLogo.Enabled = false;
            }
        }
        private void rbBottomTextText_CheckedChanged(object sender, EventArgs e)
        {
            UpdateBottomTextControls();
        }

        private void rbBottomTextDemoLogo_CheckedChanged(object sender, EventArgs e)
        {
            UpdateBottomTextControls();
        }

        private void rbBottomTextCustomerLogo_CheckedChanged(object sender, EventArgs e)
        {
            UpdateBottomTextControls();
        }

        private void btnSetClockMode_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                switch (ddlClockMode.SelectedIndex)
                {
                    case 0:
                        instr.SetClodeMode(ClockMode.Off);
                        break;
                    case 1:
                        instr.SetClodeMode(ClockMode.Time);
                        break;
                    case 2:
                        instr.SetClodeMode(ClockMode.DateTime);
                        break;
                }
            });
        }

        private void btnSetTopText_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                if (rbTopTextText.Checked)
                {
                    instr.SetText(TextField.Top, txtTopText.Text);
                }
                else
                {
                    switch (ddlTopDemoLogo.SelectedIndex)
                    {
                        case 0:
                            instr.SetTopDemoLogo(0);
                            break;
                    }
                }
            });
        }

        private void txtSetBottomText_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                if (rbBottomTextText.Checked)
                {
                    instr.SetText(TextField.Bottom, txtBottomText.Text);
                }
                else
                {
                    switch (ddlBottomDemoLogo.SelectedIndex)
                    {
                        case 0:
                            instr.SetBottomDemoLogo(0);
                            break;
                        case 1:
                            instr.SetBottomDemoLogo(1);
                            break;
                        case 2:
                            instr.SetBottomDemoLogo(2);
                            break;
                        case 3:
                            instr.SetBottomDemoLogo(3);
                            break;
                    }
                }
            });
        }

        private void btnSetDateFormat_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                switch (ddlDateFormat.SelectedIndex)
                {
                    case 0:
                        instr.SetDateFormat(DateFormat.DayMonthYear);
                        break;
                    case 1:
                        instr.SetDateFormat(DateFormat.YearMonthDay);
                        break;
                    case 2:
                        instr.SetDateFormat(DateFormat.MonthDayYear); 
                        break;
                }
            });
        }

        private void btnSetTimeFormat_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                switch (ddlTimeFormat.SelectedIndex)
                {
                    case 0:
                        instr.SetTimeFormat(TimeFormat.TwentyFourHour);
                        break;
                    case 1:
                        instr.SetTimeFormat(TimeFormat.TwelveHour);
                        break;
                }
            });
        }

        private void btnSetClock_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                if (rbClockSpecific.Checked)
                    instr.SetClock(txtClockSpecific.Text);
                else
                    instr.SetClock(null);
            });
        }

        private void btnSetPattern_Click(object sender, EventArgs e)
        {
            RunCommand((instr) =>
            {
                switch (ddlPattern.SelectedIndex)
                {
                    case 0:
                        instr.SetPattern(PatternType.Philips);
                        break;
                    case 1:
                        instr.SetPattern(PatternType.CBEBU);
                        break;
                    case 2:
                        instr.SetPattern(PatternType.CBEBUGrid);
                        break;
                    case 3:
                        instr.SetPattern(PatternType.Red75);
                        break;
                    case 4:
                        instr.SetPattern(PatternType.G1P4);
                        break;
                    case 5:
                        instr.SetPattern(PatternType.G1P5);
                        break;
                }
            });
        }

        private void btnSelectGpib_CheckedChanged(object sender, EventArgs e)
        {
            _interfaceType = InterfaceType.Gpib;
        }

        private void btnSelectCom_CheckedChanged(object sender, EventArgs e)
        {
            _interfaceType = InterfaceType.Rs232;
        }
    }
}
