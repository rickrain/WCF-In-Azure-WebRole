# Install TCP Activation to support netTcpBinding.
Import-Module ServerManager
Install-WindowsFeature -Name AS-TCP-Activation

# Add TCP to site bindings.
# Assume the fist website is for my WebRole.
import-module WebAdministration
$site = Get-WebSite | Select-Object -First(1)
Set-Alias appcmd $env:windir\system32\inetsrv\appcmd.exe
appcmd set site ""$site.Name"" "-+bindings.[protocol='net.tcp',bindingInformation='808:*']"

# Enable net.tcp on protocol.
$appName = $site.Name + "/"
appcmd set app $appName "/enabledProtocols:http,net.tcp"
