using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.Diagnostics;
using Microsoft.WindowsAzure.ServiceRuntime;
using System.IO;
using System.Diagnostics;

namespace Calculator.WebRole
{
    public class WebRole : RoleEntryPoint
    {
        public override bool OnStart()
        {
            // To enable the AzureLocalStorageTraceListner, uncomment relevent section in the web.config  
            DiagnosticMonitorConfiguration diagnosticConfig = DiagnosticMonitor.GetDefaultInitialConfiguration();
            diagnosticConfig.Directories.ScheduledTransferPeriod = TimeSpan.FromMinutes(1);
            diagnosticConfig.Directories.DataSources.Add(AzureLocalStorageTraceListener.GetLogDirectory());

            // For information on handling configuration changes
            // see the MSDN topic at http://go.microsoft.com/fwlink/?LinkId=166357.

            var startInfo = new ProcessStartInfo()
            {
                FileName = "powershell.exe",
                Arguments = @"..\Startup\RoleStart.ps1",
                RedirectStandardOutput = true,
                UseShellExecute = false
            };

            var writer = new StreamWriter("out.txt");
            var process = Process.Start(startInfo);
            process.WaitForExit();
            writer.Write(process.StandardOutput.ReadToEnd());
            writer.Close();

            return base.OnStart();
        }
    }
}
