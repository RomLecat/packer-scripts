$ErrorActionPreference = "Stop"

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force
# Set main NIC to private
$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private
# Disable Windows Firewall
Set-NetFirewallProfile -All -Enabled False

# Enable WinRM service
Enable-PSRemoting -SkipNetworkProfileCheck -Force
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "{ipAddress}"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
Restart-Service -Name WinRM

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0
