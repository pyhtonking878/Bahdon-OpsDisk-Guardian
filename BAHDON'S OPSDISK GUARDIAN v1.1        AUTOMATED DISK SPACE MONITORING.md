# ==========================================================
# BAHDON'S OPSDISK GUARDIAN v1.1
# Automated Disk Space Monitoring
# Created by Bahdon | Copyright 2026
# ==========================================================

function Show-BahdonBanner {
    Clear-Host

    $Logo = @'
 ____    _    _   _ ____   ___  _   _
| __ )  / \  | | | |  _ \ / _ \| \ | |
|  _ \ / _ \ | |_| | | | | | | |  \| |
| |_) / ___ \|  _  | |_| | |_| | |\  |
|____/_/   \_\_| |_|____/ \___/|_| \_|
'@

    Write-Host $Logo -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor DarkCyan
    Write-Host "         BAHDON'S OPSDISK GUARDIAN v1.1" -ForegroundColor Yellow
    Write-Host "       AUTOMATED DISK SPACE MONITORING" -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  [MONITOR]  [ANALYZE]  [REPORT]  [PROTECT]" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Creator   : BAHDON" -ForegroundColor Cyan
    Write-Host "  Computer  : $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "  Date      : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host ""
}

function Get-BahdonDiskHealth {

    param(
        [ValidateRange(1,99)]
        [double]$Threshold = 15
    )

    Get-Volume |
        Where-Object {
            $_.DriveLetter -and $_.Size -gt 0
        } |
        Select-Object `
            @{Name='ComputerName';Expression={$env:COMPUTERNAME}},
            DriveLetter,
            @{Name='FreePercent';Expression={
                [math]::Round(
                    ($_.SizeRemaining / $_.Size) * 100, 1
                )
            }},
            @{Name='Status';Expression={
                if ((($_.SizeRemaining / $_.Size) * 100) -lt $Threshold) {
                    'LOW SPACE'
                }
                else {
                    'OK'
                }
            }},
            @{Name='CheckedAt';Expression={
                Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            }}
}

# Initialize themed console
Show-BahdonBanner

# Create command shortcut
Set-Alias -Name bahdoncheck -Value Get-BahdonDiskHealth

# Run monitoring
Write-Host "[*] Scanning local disk volumes..." -ForegroundColor Yellow
Write-Host ""

$Results = @(bahdoncheck)

Write-Host "================ DISK HEALTH =================" -ForegroundColor Cyan

$Results | Format-Table -AutoSize

# Display alerts
foreach ($Disk in $Results) {
    if ($Disk.Status -eq 'LOW SPACE') {
        Write-Host "[ALERT] Drive $($Disk.DriveLetter): LOW SPACE!" -ForegroundColor Red
    }
    else {
        Write-Host "[OK] Drive $($Disk.DriveLetter): Healthy" -ForegroundColor Green
    }
}

# Export CSV report
$ReportPath = Join-Path $env:TEMP 'Bahdon-OpsDisk-Health.csv'

$Results | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "[SUCCESS] Disk monitoring completed." -ForegroundColor Green
Write-Host "[REPORT] $ReportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "====================================================" -ForegroundColor DarkCyan
Write-Host "         BUILT BY BAHDON | POWERSHELL OPS" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor DarkCyan
