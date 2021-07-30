$ErrorActionPreference = "Stop"

Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
