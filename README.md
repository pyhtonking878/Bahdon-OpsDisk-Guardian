## Version 1.2 — Scheduled Monitoring & Alerting

BAHDON OpsDisk Guardian v1.2 extends the original Windows PowerShell disk monitoring utility with scheduled execution, historical reporting, and threshold-based alerts.

### New Features

- Daily disk monitoring through Windows Task Scheduler at 7:00 AM.
- Configurable low-space warning threshold (default: 15% free).
- Timestamped CSV reports for historical disk utilization tracking.
- Persistent disk-space alert records.
- Execution logs for operational troubleshooting.
- Custom BAHDON ASCII-art console branding.
- Compatible with Windows PowerShell ISE and Windows PowerShell 5.1.

### Running the Script

```powershell
.\BAHDON-OpsDisk-Guardian-v1.2-ISE.ps1
```

### Installing Daily Monitoring

After reviewing the script and confirming that your Windows execution policy permits it:

```powershell
.\BAHDON-OpsDisk-Guardian-v1.2-ISE.ps1 -InstallSchedule
```

### Checking the Scheduled Task

```powershell
Get-ScheduledTask -TaskName "BAHDON-OpsDiskGuardian-Daily"
```

### Viewing Reports

```powershell
explorer "$env:LOCALAPPDATA\BahdonOps\OpsDiskGuardian"
```

### Testing Low-Space Alerts

```powershell
.\BAHDON-OpsDisk-Guardian-v1.2-ISE.ps1 -Threshold 25
```

### Current Limitations

- The scheduled task requires a compatible Windows environment and appropriate permissions.
- Alerts are written to local files; email notifications are not yet implemented.
- Scheduled monitoring depends on the computer being available to execute the task.
- PowerShell execution policies may require the script to be trusted or signed.

### Roadmap

- Remote Windows Server monitoring
- Email and Microsoft Teams notifications
- Centralized reporting dashboard
- PowerShell Gallery module distribution
- Integration with enterprise monitoring platforms
