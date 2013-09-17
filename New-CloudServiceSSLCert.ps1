# The filename prefix to use when creating the .cer and .pvk files.
# The filenames will have "CA" appended to them to indicate these are the
# certificates for the self-signed Certificate Authority.
$caSubjectName = "[YOUR SELF-SIGNED ROOT AUTHORITY NAME]"

# The cloud service name to create a test certificate for.
$serviceName = "[YOUR CLOUD SERVICE NAME]"

# The data center location where the cloud service is (or will be) deployed to.
# This is only used to create the cloud service if it does not already exist.
# Use Get-AzureLocation to find a list of locations available for your subscription.
$serviceLocation = "West US"

# Path to makecert.exe.
$makeCertPath = "C:\Program Files (x86)\Windows Kits\8.1\bin\x86\makecert.exe"

##
## Script Starts Here
##

# The script has been tested on Powershell 3.0
Set-StrictMode -Version 3

# Following modifies the Write-Verbose behavior to turn the messages on globally for this session
$VerbosePreference = "Continue"

# Check if Windows Azure Powershell is avaiable
if ((Get-Module -ListAvailable Azure) -eq $null)
{
    throw "Windows Azure Powershell not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools"
}

# Make sure the makecert tool exists.
if (!(Test-Path -path $makeCertPath))
{
    throw "Unable to find makecert.exe.  Update the makeCertPath variable to point to the correct location."
}

# Make sure a default Azure subscription is set.
if ((Get-AzureSubscription -Default -ErrorAction SilentlyContinue) -eq $null)
{
    throw "A default Azure Subscription needs to be configured.  See this blog for instructions " +
          "to configure the Windows Azure PowerShell Cmdlets with your subscription. " +
          "http://michaelwasham.com/windows-azure-powershell-reference-guide/getting-started-with-windows-azure-powershell"
}

$workingDir = (Get-Location).Path

$caCert = Get-ChildItem -Path Cert:\CurrentUser\Root -Recurse |
              Where-Object { $_.Subject -eq "CN=$caSubjectName" } |
              Select-Object -Last(1)

# Create the self-signed root certificate authority if it doesn't already exist.
if ($caCert -eq $null)
{
    Write-Verbose "Creating Self-Signed Root Certificate Authority."

    # Prepare to invoke the process
    $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processStartInfo.FileName = (Get-Command $makeCertPath).Definition
    $processStartInfo.WorkingDirectory = $workingDir
    $processStartInfo.Arguments = ("-n ""CN={0}"" -r -ss Root -sk {0}" -f $caSubjectName)
    $processStartInfo.UseShellExecute = $false

    # Execute makecert.exe
    $processStartInfo.RedirectStandardOutput = $true
    $processStartInfo.RedirectStandardInput = $true
    $process = [System.Diagnostics.Process]::Start($processStartInfo)
    $process.WaitForExit()
}

#
# BEGIN: Create a Test Certificate using the self-signed root CA.
#

# Prepare to execute makecert.exe
$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$processStartInfo.FileName = $makeCertPath
$processStartInfo.WorkingDirectory = $workingDir
$processStartInfo.Arguments = ("-n ""CN={0}.cloudapp.net"" -is Root -in {1} -sky exchange -pe -ss My" -f $serviceName, $caSubjectName)
$processStartInfo.UseShellExecute = $false

# Execute makecert.exe
$processStartInfo.RedirectStandardOutput = $true
$processStartInfo.RedirectStandardInput = $true
$process = [System.Diagnostics.Process]::Start($processStartInfo)
$process.WaitForExit()

#
# END: Create a Test Certificate using the self-signed root CA.
#

$certStoreMy   = "Cert:\CurrentUser\My"
$cert = Get-ChildItem -Path $certStoreMy -Recurse | 
            Where-Object { $_.Subject -eq ("CN={0}.cloudapp.net" -f $serviceName) } |
            Select-Object -Last(1)
$certPath = "{0}\{1}" -f ($certStoreMy, $cert.Thumbprint)

# Create the cloud service if it does not already exist.
$cloudService = Get-AzureService -ServiceName $serviceName -ErrorAction SilentlyContinue
if ($cloudService -eq $null)
{
    Write-Verbose ("Creating cloud service '{0}'." -f $serviceName)
    New-AzureService -ServiceName $serviceName -Location $serviceLocation
}

# Upload the certificate to the cloud service certificates collection in Azure.
Write-Verbose ("Uploading certificate for '{0}.cloudapp.net' to Windows Azure." -f $serviceName)
Add-AzureCertificate -ServiceName $serviceName -CertToDeploy (Get-Item $certPath)

# Finished. 
$dnsName = ("{0}.cloudapp.net" -f $serviceName)
Write-Verbose ("Successfully created and uploaded test certificate for {0}." -f $dnsName)
Write-Verbose ("Use thumbprint '{0}' to configure SSL for your cloud service endpoint in Visual Studio." -f $cert.Thumbprint)
