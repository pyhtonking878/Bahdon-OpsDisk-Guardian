# BAHDON OpsDisk Guardian v1.2 - Windows PowerShell ISE edition
# Author: Bahdon
# Save as BAHDON-OpsDisk-Guardian-v1.2-ISE.ps1
# Run normally for monitoring. Run with -InstallSchedule to register daily 07:00 task.
[CmdletBinding()]
param(
    [ValidateRange(1,99)][double]$Threshold = 15,
    [switch]$InstallSchedule,
    [switch]$RemoveSchedule,
    [switch]$NoBanner
)
$ErrorActionPreference = 'Stop'
$TaskName = 'BAHDON-OpsDiskGuardian-Daily'
$AppRoot = Join-Path $env:LOCALAPPDATA 'BahdonOps\OpsDiskGuardian'
$ReportsDir = Join-Path $AppRoot 'Reports'
$AlertsDir = Join-Path $AppRoot 'Alerts'
$LogsDir = Join-Path $AppRoot 'Logs'
$InstalledScript = Join-Path $AppRoot 'BAHDON-OpsDisk-Guardian.ps1'

function Show-BahdonBanner {
    $Logo = @'
BBBB   AAA  H   H DDDD   OOO  N   N
B   B A   A H   H D   D O   O NN  N
BBBB  AAAAA HHHHH D   D O   O N N N
B   B A   A H   H D   D O   O N  NN
BBBB  A   A H   H DDDD   OOO  N   N
'@
    Write-Host $Logo -ForegroundColor Cyan
    Write-Host '=========================================================' -ForegroundColor DarkCyan
    Write-Host "         BAHDON'S OPSDISK GUARDIAN v1.2" -ForegroundColor Yellow
    Write-Host '        AUTOMATED DISK SPACE MONITORING' -ForegroundColor White
    Write-Host '=========================================================' -ForegroundColor DarkCyan
    Write-Host ' [MONITOR] [ANALYZE] [REPORT] [ALERT]' -ForegroundColor Green
    Write-Host " Computer: $env:COMPUTERNAME  |  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
    Write-Host ''
}
function Get-BahdonDiskHealth {
    [CmdletBinding()]
    param([ValidateRange(1,99)][double]$Threshold = 15)
    foreach ($volume in @(Get-Volume | Where-Object { $_.DriveLetter -and $_.Size -gt 0 })) {
        $free = [math]::Round(100 * $volume.SizeRemaining / $volume.Size, 1)
        [pscustomobject]@{
            ComputerName = $env:COMPUTERNAME
            DriveLetter = [string]$volume.DriveLetter
            FreePercent = $free
            Status = if ($free -lt $Threshold) { 'LOW SPACE' } else { 'OK' }
            CheckedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        }
    }
}
function Write-BahdonLog {
    param([string]$Message)
    Add-Content -LiteralPath (Join-Path $LogsDir 'OpsDiskGuardian.log') -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message" -Encoding UTF8
}

try {
    foreach ($dir in @($AppRoot, $ReportsDir, $AlertsDir, $LogsDir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not $NoBanner) { Show-BahdonBanner }

    if ($RemoveSchedule) {
        if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "[OK] Scheduled task removed: $TaskName" -ForegroundColor Green
        } else { Write-Host '[INFO] Scheduled task does not exist.' -ForegroundColor Yellow }
        return
    }

    if ($InstallSchedule) {
        if (-not $PSCommandPath) { throw 'Save this script as a .ps1 file before installing the schedule.' }
        Copy-Item -LiteralPath $PSCommandPath -Destination $InstalledScript -Force
        $PowerShellExe = Join-Path $PSHOME 'powershell.exe'
        $Arguments = '-NoProfile -NonInteractive -File "{0}" -NoBanner -Threshold {1}' -f $InstalledScript, $Threshold
        $Action = New-ScheduledTaskAction -Execute $PowerShellExe -Argument $Arguments
        $Trigger = New-ScheduledTaskTrigger -Daily -At '07:00'
        $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
        $Principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force | Out-Null
        Write-Host "[OK] Daily 07:00 task installed: $TaskName" -ForegroundColor Green
        Write-Host "[SCRIPT] $InstalledScript" -ForegroundColor Cyan
        Write-BahdonLog "Scheduled task installed for 07:00, threshold $Threshold%."
        return
    }

    Write-Host '[*] Scanning local disk volumes...' -ForegroundColor Yellow
    $Results = @(Get-BahdonDiskHealth -Threshold $Threshold)
    if ($Results.Count -eq 0) { throw 'No eligible disk volumes were returned.' }
    $Results | Format-Table -AutoSize | Out-String | Write-Host
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    $ReportPath = Join-Path $ReportsDir "DiskHealth-$stamp.csv"
    $Results | Export-Csv -LiteralPath $ReportPath -NoTypeInformation -Encoding UTF8
    Write-BahdonLog "Scan completed: $($Results.Count) volumes. Report: $ReportPath"
    foreach ($disk in $Results) {
        if ($disk.Status -eq 'LOW SPACE') {
            $message = "[ALERT] Drive $($disk.DriveLetter): $($disk.FreePercent)% free (threshold $Threshold%)."
            Write-Host $message -ForegroundColor Red
            Write-BahdonLog $message
            $alertPath = Join-Path $AlertsDir "LowSpace-$($disk.DriveLetter)-$stamp.txt"
            Set-Content -LiteralPath $alertPath -Value $message -Encoding UTF8
        } else {
            Write-Host "[OK] Drive $($disk.DriveLetter): $($disk.FreePercent)% free" -ForegroundColor Green
        }
    }
    Write-Host '[SUCCESS] Disk monitoring completed.' -ForegroundColor Green
    Write-Host "[REPORT] $ReportPath" -ForegroundColor Cyan
    Write-Host 'BUILT BY BAHDON | POWERSHELL OPS' -ForegroundColor Yellow
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path -LiteralPath $LogsDir) { Write-BahdonLog "ERROR: $($_.Exception.Message)" }
    throw
}
