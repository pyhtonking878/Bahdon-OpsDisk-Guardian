# BAHDON's OpsDisk Guardian v1.1

**Automated Windows Disk Space Monitoring & Reporting**

A PowerShell automation project developed by Bahdon to help Windows system administrators monitor disk utilization, identify low disk space, and generate operational health reports.

## Features

- Monitors local Windows disk volumes.
- Calculates available disk space as a percentage.
- Detects low disk space using a configurable 15% threshold.
- Displays color-coded alerts in PowerShell.
- Generates CSV health reports.
- Includes a custom BAHDON ASCII-art console logo.
- Supports reusable PowerShell functions.

## Technologies

- Windows PowerShell
- Windows Storage Cmdlets (`Get-Volume`)
- PowerShell functions and aliases
- CSV reporting (`Export-Csv`)
- Windows system administration

## Installation

1. Download `Bahdon-OpsDisk-Guardian.ps1` from this repository.
2. Open Windows PowerShell on a compatible Windows system.
3. Navigate to the directory containing the script.
4. Run:

```powershell
.\Bahdon-OpsDisk-Guardian.ps1
```

## Example Output

```text
BAHDON'S OPSDISK GUARDIAN v1.1
AUTOMATED DISK SPACE MONITORING

[MONITOR] [ANALYZE] [REPORT] [PROTECT]

ComputerName  DriveLetter  FreePercent  Status
THELAPTOP     C            20.8         OK

[OK] Drive C: Healthy
[SUCCESS] Disk monitoring completed.
```

*Example output shown for demonstration purposes.*

## Reporting

The script exports disk health information to:

```text
%TEMP%\Bahdon-OpsDisk-Health.csv
```

The report contains the computer name, drive letter, free space percentage, health status, and check timestamp.

## Current Limitations

- Monitoring runs when the script is executed.
- Automatic scheduling is not yet configured.
- CSV reports are overwritten on subsequent runs.
- Windows-specific storage cmdlets are required.

## Future Improvements

- Windows Task Scheduler integration
- Automatic low-disk-space notifications
- Historical disk utilization reporting
- Remote Windows Server monitoring
- PowerShell module packaging

## Author

**Bahdon**

PowerShell Automation | Windows System Administration | Infrastructure Monitoring

Copyright © 2026 Bahdon.
