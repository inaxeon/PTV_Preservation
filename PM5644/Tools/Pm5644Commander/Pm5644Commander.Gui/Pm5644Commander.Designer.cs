namespace Pm5644Commander.Gui
{
    partial class Pm5644Commander
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.grpPattern = new System.Windows.Forms.GroupBox();
            this.btnSetPattern = new System.Windows.Forms.Button();
            this.ddlPattern = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.grpClock = new System.Windows.Forms.GroupBox();
            this.txtClockSpecific = new System.Windows.Forms.TextBox();
            this.btnSetClock = new System.Windows.Forms.Button();
            this.rbClockNow = new System.Windows.Forms.RadioButton();
            this.rbClockSpecific = new System.Windows.Forms.RadioButton();
            this.btnSetTimeFormat = new System.Windows.Forms.Button();
            this.ddlTimeFormat = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.btnSetDateFormat = new System.Windows.Forms.Button();
            this.ddlDateFormat = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.btnSetClockMode = new System.Windows.Forms.Button();
            this.ddlClockMode = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.grpTopText = new System.Windows.Forms.GroupBox();
            this.ddlTopDemoLogo = new System.Windows.Forms.ComboBox();
            this.rbTopTextDemoLogo = new System.Windows.Forms.RadioButton();
            this.txtTopText = new System.Windows.Forms.TextBox();
            this.rbTopTextText = new System.Windows.Forms.RadioButton();
            this.btnSetTopText = new System.Windows.Forms.Button();
            this.grpBottomText = new System.Windows.Forms.GroupBox();
            this.ddlBottomDemoLogo = new System.Windows.Forms.ComboBox();
            this.rbBottomTextDemoLogo = new System.Windows.Forms.RadioButton();
            this.txtBottomText = new System.Windows.Forms.TextBox();
            this.rbBottomTextText = new System.Windows.Forms.RadioButton();
            this.txtSetBottomText = new System.Windows.Forms.Button();
            this.grpAddress = new System.Windows.Forms.GroupBox();
            this.btnSelectCom = new System.Windows.Forms.RadioButton();
            this.btnSelectGpib = new System.Windows.Forms.RadioButton();
            this.txtComPort = new System.Windows.Forms.TextBox();
            this.txtGpibAddress = new System.Windows.Forms.TextBox();
            this.grpPattern.SuspendLayout();
            this.grpClock.SuspendLayout();
            this.grpTopText.SuspendLayout();
            this.grpBottomText.SuspendLayout();
            this.grpAddress.SuspendLayout();
            this.SuspendLayout();
            // 
            // grpPattern
            // 
            this.grpPattern.Controls.Add(this.btnSetPattern);
            this.grpPattern.Controls.Add(this.ddlPattern);
            this.grpPattern.Controls.Add(this.label2);
            this.grpPattern.Location = new System.Drawing.Point(13, 13);
            this.grpPattern.Name = "grpPattern";
            this.grpPattern.Size = new System.Drawing.Size(320, 48);
            this.grpPattern.TabIndex = 0;
            this.grpPattern.TabStop = false;
            this.grpPattern.Text = "Pattern";
            // 
            // btnSetPattern
            // 
            this.btnSetPattern.Location = new System.Drawing.Point(234, 16);
            this.btnSetPattern.Name = "btnSetPattern";
            this.btnSetPattern.Size = new System.Drawing.Size(75, 23);
            this.btnSetPattern.TabIndex = 1;
            this.btnSetPattern.Text = "Set";
            this.btnSetPattern.UseVisualStyleBackColor = true;
            this.btnSetPattern.Click += new System.EventHandler(this.btnSetPattern_Click);
            // 
            // ddlPattern
            // 
            this.ddlPattern.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ddlPattern.FormattingEnabled = true;
            this.ddlPattern.Items.AddRange(new object[] {
            "PHILIPS",
            "EBU Colour Bars",
            "EBU Colour Bars (Grid)",
            "Red 75%",
            "Group 1 Pattern 4",
            "Group 1 Pattern 5"});
            this.ddlPattern.Location = new System.Drawing.Point(77, 17);
            this.ddlPattern.Name = "ddlPattern";
            this.ddlPattern.Size = new System.Drawing.Size(149, 21);
            this.ddlPattern.TabIndex = 0;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(6, 20);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(44, 13);
            this.label2.TabIndex = 1;
            this.label2.Text = "Pattern:";
            // 
            // grpClock
            // 
            this.grpClock.Controls.Add(this.txtClockSpecific);
            this.grpClock.Controls.Add(this.btnSetClock);
            this.grpClock.Controls.Add(this.rbClockNow);
            this.grpClock.Controls.Add(this.rbClockSpecific);
            this.grpClock.Controls.Add(this.btnSetTimeFormat);
            this.grpClock.Controls.Add(this.ddlTimeFormat);
            this.grpClock.Controls.Add(this.label5);
            this.grpClock.Controls.Add(this.btnSetDateFormat);
            this.grpClock.Controls.Add(this.ddlDateFormat);
            this.grpClock.Controls.Add(this.label3);
            this.grpClock.Controls.Add(this.btnSetClockMode);
            this.grpClock.Controls.Add(this.ddlClockMode);
            this.grpClock.Controls.Add(this.label4);
            this.grpClock.Location = new System.Drawing.Point(13, 68);
            this.grpClock.Name = "grpClock";
            this.grpClock.Size = new System.Drawing.Size(320, 175);
            this.grpClock.TabIndex = 5;
            this.grpClock.TabStop = false;
            this.grpClock.Text = "Clock";
            // 
            // txtClockSpecific
            // 
            this.txtClockSpecific.Enabled = false;
            this.txtClockSpecific.Location = new System.Drawing.Point(77, 141);
            this.txtClockSpecific.Name = "txtClockSpecific";
            this.txtClockSpecific.Size = new System.Drawing.Size(149, 20);
            this.txtClockSpecific.TabIndex = 10;
            // 
            // btnSetClock
            // 
            this.btnSetClock.Location = new System.Drawing.Point(234, 139);
            this.btnSetClock.Name = "btnSetClock";
            this.btnSetClock.Size = new System.Drawing.Size(75, 23);
            this.btnSetClock.TabIndex = 11;
            this.btnSetClock.Text = "Set";
            this.btnSetClock.UseVisualStyleBackColor = true;
            this.btnSetClock.Click += new System.EventHandler(this.btnSetClock_Click);
            // 
            // rbClockNow
            // 
            this.rbClockNow.AutoSize = true;
            this.rbClockNow.Checked = true;
            this.rbClockNow.Location = new System.Drawing.Point(8, 117);
            this.rbClockNow.Name = "rbClockNow";
            this.rbClockNow.Size = new System.Drawing.Size(105, 17);
            this.rbClockNow.TabIndex = 8;
            this.rbClockNow.TabStop = true;
            this.rbClockNow.Text = "Set clock to now";
            this.rbClockNow.UseVisualStyleBackColor = true;
            this.rbClockNow.CheckedChanged += new System.EventHandler(this.rbClockNow_CheckedChanged);
            // 
            // rbClockSpecific
            // 
            this.rbClockSpecific.AutoSize = true;
            this.rbClockSpecific.Location = new System.Drawing.Point(8, 142);
            this.rbClockSpecific.Name = "rbClockSpecific";
            this.rbClockSpecific.Size = new System.Drawing.Size(66, 17);
            this.rbClockSpecific.TabIndex = 9;
            this.rbClockSpecific.Text = "Specific:";
            this.rbClockSpecific.UseVisualStyleBackColor = true;
            this.rbClockSpecific.CheckedChanged += new System.EventHandler(this.rbClockSpecific_CheckedChanged);
            // 
            // btnSetTimeFormat
            // 
            this.btnSetTimeFormat.Location = new System.Drawing.Point(234, 78);
            this.btnSetTimeFormat.Name = "btnSetTimeFormat";
            this.btnSetTimeFormat.Size = new System.Drawing.Size(75, 23);
            this.btnSetTimeFormat.TabIndex = 7;
            this.btnSetTimeFormat.Text = "Set";
            this.btnSetTimeFormat.UseVisualStyleBackColor = true;
            this.btnSetTimeFormat.Click += new System.EventHandler(this.btnSetTimeFormat_Click);
            // 
            // ddlTimeFormat
            // 
            this.ddlTimeFormat.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ddlTimeFormat.FormattingEnabled = true;
            this.ddlTimeFormat.Items.AddRange(new object[] {
            "24-Hour",
            "12-Hour"});
            this.ddlTimeFormat.Location = new System.Drawing.Point(77, 79);
            this.ddlTimeFormat.Name = "ddlTimeFormat";
            this.ddlTimeFormat.Size = new System.Drawing.Size(149, 21);
            this.ddlTimeFormat.TabIndex = 6;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(6, 82);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(65, 13);
            this.label5.TabIndex = 8;
            this.label5.Text = "Time format:";
            // 
            // btnSetDateFormat
            // 
            this.btnSetDateFormat.Location = new System.Drawing.Point(234, 47);
            this.btnSetDateFormat.Name = "btnSetDateFormat";
            this.btnSetDateFormat.Size = new System.Drawing.Size(75, 23);
            this.btnSetDateFormat.TabIndex = 5;
            this.btnSetDateFormat.Text = "Set";
            this.btnSetDateFormat.UseVisualStyleBackColor = true;
            this.btnSetDateFormat.Click += new System.EventHandler(this.btnSetDateFormat_Click);
            // 
            // ddlDateFormat
            // 
            this.ddlDateFormat.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ddlDateFormat.FormattingEnabled = true;
            this.ddlDateFormat.Items.AddRange(new object[] {
            "DD-MM-YY",
            "YY-MM-DD",
            "MM-DD-YY"});
            this.ddlDateFormat.Location = new System.Drawing.Point(77, 48);
            this.ddlDateFormat.Name = "ddlDateFormat";
            this.ddlDateFormat.Size = new System.Drawing.Size(149, 21);
            this.ddlDateFormat.TabIndex = 4;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(6, 51);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(65, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Date format:";
            // 
            // btnSetClockMode
            // 
            this.btnSetClockMode.Location = new System.Drawing.Point(234, 16);
            this.btnSetClockMode.Name = "btnSetClockMode";
            this.btnSetClockMode.Size = new System.Drawing.Size(75, 23);
            this.btnSetClockMode.TabIndex = 3;
            this.btnSetClockMode.Text = "Set";
            this.btnSetClockMode.UseVisualStyleBackColor = true;
            this.btnSetClockMode.Click += new System.EventHandler(this.btnSetClockMode_Click);
            // 
            // ddlClockMode
            // 
            this.ddlClockMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ddlClockMode.FormattingEnabled = true;
            this.ddlClockMode.Items.AddRange(new object[] {
            "Off",
            "Time",
            "Date+Time"});
            this.ddlClockMode.Location = new System.Drawing.Point(77, 17);
            this.ddlClockMode.Name = "ddlClockMode";
            this.ddlClockMode.Size = new System.Drawing.Size(149, 21);
            this.ddlClockMode.TabIndex = 2;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(6, 20);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(37, 13);
            this.label4.TabIndex = 0;
            this.label4.Text = "Mode:";
            // 
            // grpTopText
            // 
            this.grpTopText.Controls.Add(this.ddlTopDemoLogo);
            this.grpTopText.Controls.Add(this.rbTopTextDemoLogo);
            this.grpTopText.Controls.Add(this.txtTopText);
            this.grpTopText.Controls.Add(this.rbTopTextText);
            this.grpTopText.Controls.Add(this.btnSetTopText);
            this.grpTopText.Location = new System.Drawing.Point(341, 13);
            this.grpTopText.Name = "grpTopText";
            this.grpTopText.Size = new System.Drawing.Size(320, 79);
            this.grpTopText.TabIndex = 6;
            this.grpTopText.TabStop = false;
            this.grpTopText.Text = "Top text";
            // 
            // ddlTopDemoLogo
            // 
            this.ddlTopDemoLogo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ddlTopDemoLogo.Enabled = false;
            this.ddlTopDemoLogo.FormattingEnabled = true;
            this.ddlTopDemoLogo.Items.AddRange(new object[] {
            "PTV logo"});
            this.ddlTopDemoLogo.Location = new System.Drawing.Point(65, 44);
            this.ddlTopDemoLogo.Name = "ddlTopDemoLogo";
            this.ddlTopDemoLogo.Size = new System.Drawing.Size(164, 21);
            this.ddlTopDemoLogo.TabIndex = 15;
            // 
            // rbTopTextDemoLogo
            // 
            this.rbTopTextDemoLogo.AutoSize = true;
            this.rbTopTextDemoLogo.Location = new System.Drawing.Point(9, 45);
            this.rbTopTextDemoLogo.Name = "rbTopTextDemoLogo";
            this.rbTopTextDemoLogo.Size = new System.Drawing.Size(52, 17);
            this.rbTopTextDemoLogo.TabIndex = 13;
            this.rbTopTextDemoLogo.Text = "Logo:";
            this.rbTopTextDemoLogo.UseVisualStyleBackColor = true;
            this.rbTopTextDemoLogo.CheckedChanged += new System.EventHandler(this.rbTopTextDemoLogo_CheckedChanged);
            // 
            // txtTopText
            // 
            this.txtTopText.Location = new System.Drawing.Point(65, 16);
            this.txtTopText.Name = "txtTopText";
            this.txtTopText.Size = new System.Drawing.Size(164, 20);
            this.txtTopText.TabIndex = 14;
            // 
            // rbTopTextText
            // 
            this.rbTopTextText.AutoSize = true;
            this.rbTopTextText.Checked = true;
            this.rbTopTextText.Location = new System.Drawing.Point(9, 17);
            this.rbTopTextText.Name = "rbTopTextText";
            this.rbTopTextText.Size = new System.Drawing.Size(49, 17);
            this.rbTopTextText.TabIndex = 12;
            this.rbTopTextText.TabStop = true;
            this.rbTopTextText.Text = "Text:";
            this.rbTopTextText.UseVisualStyleBackColor = true;
            this.rbTopTextText.CheckedChanged += new System.EventHandler(this.rbTopTextText_CheckedChanged);
            // 
            // btnSetTopText
            // 
            this.btnSetTopText.Location = new System.Drawing.Point(235, 43);
            this.btnSetTopText.Name = "btnSetTopText";
            this.btnSetTopText.Size = new System.Drawing.Size(75, 23);
            this.btnSetTopText.TabIndex = 16;
            this.btnSetTopText.Text = "Set";
            this.btnSetTopText.UseVisualStyleBackColor = true;
            this.btnSetTopText.Click += new System.EventHandler(this.btnSetTopText_Click);
            // 
            // grpBottomText
            // 
            this.grpBottomText.Controls.Add(this.ddlBottomDemoLogo);
            this.grpBottomText.Controls.Add(this.rbBottomTextDemoLogo);
            this.grpBottomText.Controls.Add(this.txtBottomText);
            this.grpBottomText.Controls.Add(this.rbBottomTextText);
            this.grpBottomText.Controls.Add(this.txtSetBottomText);
            this.grpBottomText.Location = new System.Drawing.Point(341, 100);
            this.grpBottomText.Name = "grpBottomText";
            this.grpBottomText.Size = new System.Drawing.Size(320, 79);
            this.grpBottomText.TabIndex = 9;
            this.grpBottomText.TabStop = false;
            this.grpBottomText.Text = "Bottom text";
            // 
            // ddlBottomDemoLogo
            // 
            this.ddlBottomDemoLogo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ddlBottomDemoLogo.Enabled = false;
            this.ddlBottomDemoLogo.FormattingEnabled = true;
            this.ddlBottomDemoLogo.Items.AddRange(new object[] {
            "PTV logo",
            "PHILIPS logo",
            "EBU colour bars",
            "Colour demo"});
            this.ddlBottomDemoLogo.Location = new System.Drawing.Point(65, 45);
            this.ddlBottomDemoLogo.Name = "ddlBottomDemoLogo";
            this.ddlBottomDemoLogo.Size = new System.Drawing.Size(164, 21);
            this.ddlBottomDemoLogo.TabIndex = 21;
            // 
            // rbBottomTextDemoLogo
            // 
            this.rbBottomTextDemoLogo.AutoSize = true;
            this.rbBottomTextDemoLogo.Location = new System.Drawing.Point(9, 46);
            this.rbBottomTextDemoLogo.Name = "rbBottomTextDemoLogo";
            this.rbBottomTextDemoLogo.Size = new System.Drawing.Size(52, 17);
            this.rbBottomTextDemoLogo.TabIndex = 18;
            this.rbBottomTextDemoLogo.Text = "Logo:";
            this.rbBottomTextDemoLogo.UseVisualStyleBackColor = true;
            this.rbBottomTextDemoLogo.CheckedChanged += new System.EventHandler(this.rbBottomTextDemoLogo_CheckedChanged);
            // 
            // txtBottomText
            // 
            this.txtBottomText.Location = new System.Drawing.Point(65, 17);
            this.txtBottomText.Name = "txtBottomText";
            this.txtBottomText.Size = new System.Drawing.Size(164, 20);
            this.txtBottomText.TabIndex = 20;
            // 
            // rbBottomTextText
            // 
            this.rbBottomTextText.AutoSize = true;
            this.rbBottomTextText.Checked = true;
            this.rbBottomTextText.Location = new System.Drawing.Point(9, 20);
            this.rbBottomTextText.Name = "rbBottomTextText";
            this.rbBottomTextText.Size = new System.Drawing.Size(49, 17);
            this.rbBottomTextText.TabIndex = 17;
            this.rbBottomTextText.TabStop = true;
            this.rbBottomTextText.Text = "Text:";
            this.rbBottomTextText.UseVisualStyleBackColor = true;
            this.rbBottomTextText.CheckedChanged += new System.EventHandler(this.rbBottomTextText_CheckedChanged);
            // 
            // txtSetBottomText
            // 
            this.txtSetBottomText.Location = new System.Drawing.Point(235, 44);
            this.txtSetBottomText.Name = "txtSetBottomText";
            this.txtSetBottomText.Size = new System.Drawing.Size(75, 23);
            this.txtSetBottomText.TabIndex = 22;
            this.txtSetBottomText.Text = "Set";
            this.txtSetBottomText.UseVisualStyleBackColor = true;
            this.txtSetBottomText.Click += new System.EventHandler(this.txtSetBottomText_Click);
            // 
            // grpAddress
            // 
            this.grpAddress.Controls.Add(this.btnSelectCom);
            this.grpAddress.Controls.Add(this.btnSelectGpib);
            this.grpAddress.Controls.Add(this.txtComPort);
            this.grpAddress.Controls.Add(this.txtGpibAddress);
            this.grpAddress.Location = new System.Drawing.Point(340, 187);
            this.grpAddress.Name = "grpAddress";
            this.grpAddress.Size = new System.Drawing.Size(321, 90);
            this.grpAddress.TabIndex = 10;
            this.grpAddress.TabStop = false;
            this.grpAddress.Text = "Generator access";
            // 
            // btnSelectCom
            // 
            this.btnSelectCom.AutoSize = true;
            this.btnSelectCom.Location = new System.Drawing.Point(10, 52);
            this.btnSelectCom.Name = "btnSelectCom";
            this.btnSelectCom.Size = new System.Drawing.Size(74, 17);
            this.btnSelectCom.TabIndex = 26;
            this.btnSelectCom.TabStop = true;
            this.btnSelectCom.Text = "COM Port:";
            this.btnSelectCom.UseVisualStyleBackColor = true;
            this.btnSelectCom.CheckedChanged += new System.EventHandler(this.btnSelectCom_CheckedChanged);
            // 
            // btnSelectGpib
            // 
            this.btnSelectGpib.AutoSize = true;
            this.btnSelectGpib.Location = new System.Drawing.Point(10, 24);
            this.btnSelectGpib.Name = "btnSelectGpib";
            this.btnSelectGpib.Size = new System.Drawing.Size(94, 17);
            this.btnSelectGpib.TabIndex = 25;
            this.btnSelectGpib.TabStop = true;
            this.btnSelectGpib.Text = "GPIB Address:";
            this.btnSelectGpib.UseVisualStyleBackColor = true;
            this.btnSelectGpib.CheckedChanged += new System.EventHandler(this.btnSelectGpib_CheckedChanged);
            // 
            // txtComPort
            // 
            this.txtComPort.Location = new System.Drawing.Point(110, 51);
            this.txtComPort.Name = "txtComPort";
            this.txtComPort.Size = new System.Drawing.Size(201, 20);
            this.txtComPort.TabIndex = 24;
            // 
            // txtGpibAddress
            // 
            this.txtGpibAddress.Location = new System.Drawing.Point(110, 23);
            this.txtGpibAddress.Name = "txtGpibAddress";
            this.txtGpibAddress.Size = new System.Drawing.Size(201, 20);
            this.txtGpibAddress.TabIndex = 23;
            // 
            // Pm5644Commander
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(674, 289);
            this.Controls.Add(this.grpAddress);
            this.Controls.Add(this.grpBottomText);
            this.Controls.Add(this.grpTopText);
            this.Controls.Add(this.grpClock);
            this.Controls.Add(this.grpPattern);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "Pm5644Commander";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "PM5644 Commander";
            this.Load += new System.EventHandler(this.Pm5644Commander_Load);
            this.grpPattern.ResumeLayout(false);
            this.grpPattern.PerformLayout();
            this.grpClock.ResumeLayout(false);
            this.grpClock.PerformLayout();
            this.grpTopText.ResumeLayout(false);
            this.grpTopText.PerformLayout();
            this.grpBottomText.ResumeLayout(false);
            this.grpBottomText.PerformLayout();
            this.grpAddress.ResumeLayout(false);
            this.grpAddress.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox grpPattern;
        private System.Windows.Forms.ComboBox ddlPattern;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnSetPattern;
        private System.Windows.Forms.GroupBox grpClock;
        private System.Windows.Forms.ComboBox ddlDateFormat;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button btnSetClockMode;
        private System.Windows.Forms.ComboBox ddlClockMode;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button btnSetDateFormat;
        private System.Windows.Forms.Button btnSetTimeFormat;
        private System.Windows.Forms.ComboBox ddlTimeFormat;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox txtClockSpecific;
        private System.Windows.Forms.Button btnSetClock;
        private System.Windows.Forms.RadioButton rbClockNow;
        private System.Windows.Forms.RadioButton rbClockSpecific;
        private System.Windows.Forms.GroupBox grpTopText;
        private System.Windows.Forms.TextBox txtTopText;
        private System.Windows.Forms.RadioButton rbTopTextText;
        private System.Windows.Forms.Button btnSetTopText;
        private System.Windows.Forms.ComboBox ddlTopDemoLogo;
        private System.Windows.Forms.RadioButton rbTopTextDemoLogo;
        private System.Windows.Forms.GroupBox grpBottomText;
        private System.Windows.Forms.ComboBox ddlBottomDemoLogo;
        private System.Windows.Forms.RadioButton rbBottomTextDemoLogo;
        private System.Windows.Forms.TextBox txtBottomText;
        private System.Windows.Forms.RadioButton rbBottomTextText;
        private System.Windows.Forms.Button txtSetBottomText;
        private System.Windows.Forms.GroupBox grpAddress;
        private System.Windows.Forms.TextBox txtGpibAddress;
        private System.Windows.Forms.RadioButton btnSelectCom;
        private System.Windows.Forms.RadioButton btnSelectGpib;
        private System.Windows.Forms.TextBox txtComPort;
    }
}

