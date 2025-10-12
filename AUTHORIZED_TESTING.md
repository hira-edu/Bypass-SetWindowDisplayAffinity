# Authorized Security Testing Guide

## ⚠️ CRITICAL: Authorization Required

**This guide is ONLY for testing on systems you own or have explicit written authorization to test.**

## Pre-Testing Requirements

### 1. Authorization Documentation
Before any remote deployment, document:
- System ownership proof
- Testing authorization (if corporate owned)
- Scope of testing (which systems, timeframe)
- Purpose: Microsoft vulnerability research
- Data handling procedures

### 2. Testing Environment Setup
```
Test Lab Configuration:
- Isolated network segment
- No production data
- Clear system restoration plan
- Logging enabled for audit trail
```

## Remote Deployment via MeshCentral (Authorized Systems Only)

### Prerequisites
- MeshCentral server you control
- Agent installed on YOUR test systems
- Test signing enabled on target systems
- Administrator credentials

### Method 1: PowerShell Script Deployment

Create deployment script `deploy_driver.ps1`:
```powershell
# AUTHORIZATION CHECK - Modify for your environment
$authorizedSystems = @(
    "TESTVM01",
    "TESTVM02",
    "RESEARCHER-PC"
)

$hostname = $env:COMPUTERNAME
if ($hostname -notin $authorizedSystems) {
    Write-Error "System not authorized for testing"
    exit 1
}

# Log the deployment for audit
$logPath = "C:\TestLogs\driver_deployment.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logPath -Value "$timestamp - Driver deployment initiated on $hostname"

# Enable test signing if needed
$testMode = bcdedit | Select-String "testsigning.*Yes"
if (-not $testMode) {
    bcdedit /set testsigning on
    Add-Content -Path $logPath -Value "$timestamp - Test signing enabled, restart required"
    shutdown /r /t 60 /c "Restarting for driver test mode"
    exit 0
}

# Download driver from your controlled server
$driverUrl = "http://your-internal-server/infinity_hook_pro_max.sys"
$driverPath = "C:\Windows\Temp\infinity_hook_pro_max.sys"
Invoke-WebRequest -Uri $driverUrl -OutFile $driverPath

# Verify hash (IMPORTANT for integrity)
$expectedHash = "8d4c5558acaf01de1af2e0e71392a854"  # Your driver's MD5
$actualHash = (Get-FileHash -Path $driverPath -Algorithm MD5).Hash
if ($actualHash -ne $expectedHash) {
    Write-Error "Driver hash mismatch - possible tampering"
    Remove-Item $driverPath
    exit 1
}

# Create and start service
$serviceName = "InfinityHookTest"
sc.exe create $serviceName type=kernel binPath=$driverPath
sc.exe start $serviceName

# Verify deployment
$status = sc.exe query $serviceName | Select-String "RUNNING"
if ($status) {
    Write-Host "Driver successfully deployed for testing"
    Add-Content -Path $logPath -Value "$timestamp - Driver loaded successfully"
} else {
    Write-Error "Driver failed to load"
    Add-Content -Path $logPath -Value "$timestamp - Driver load failed"
}

# Schedule automatic removal after testing period (e.g., 4 hours)
$removalTime = (Get-Date).AddHours(4).ToString("HH:mm")
schtasks /create /tn "RemoveTestDriver" /tr "sc.exe stop $serviceName && sc.exe delete $serviceName" /sc once /st $removalTime /f
```

### Method 2: MeshCentral Plugin Approach

Create `meshcentral-driver-test.js`:
```javascript
// MeshCentral Plugin for Authorized Driver Testing
// WARNING: Only for systems you own with proper authorization

module.exports.setup = function(parent) {
    const obj = {};

    obj.handleCommand = function(domain, user, command, func) {
        // Verify user authorization
        if (!user.siteadmin || user.name !== 'authorized_researcher') {
            func('Unauthorized for driver testing');
            return;
        }

        if (command.action === 'deployTestDriver') {
            // Check if system is in authorized test list
            const authorizedNodes = ['test-vm-01', 'test-vm-02'];
            if (!authorizedNodes.includes(command.nodeid)) {
                func('Node not authorized for testing');
                return;
            }

            // Log the deployment
            parent.log('Driver deployment', user.name, command.nodeid, new Date());

            // Deploy with time limit
            const deployScript = `
                # Auto-remove after 4 hours
                $stopTime = (Get-Date).AddHours(4)
                # ... deployment code ...
                Register-ScheduledTask -TaskName "AutoRemoveDriver" -Trigger (New-ScheduledTaskTrigger -Once -At $stopTime) -Action (New-ScheduledTaskAction -Execute "sc.exe" -Argument "delete InfinityHookTest")
            `;

            func(null, deployScript);
        }
    };

    return obj;
};
```

### Method 3: Controlled Batch Deployment

For multiple test systems, create `batch_deploy.bat`:
```batch
@echo off
REM Batch deployment for authorized test systems only

set TEST_SYSTEMS=TESTVM01 TESTVM02 TESTVM03
set MESHCENTRAL_SERVER=your-mesh-server.local

for %%S in (%TEST_SYSTEMS%) do (
    echo Deploying to authorized system: %%S
    meshctrl.exe runcommand --id %%S --run "powershell -File deploy_driver.ps1"
    echo Deployment logged for %%S
    timeout /t 5 >nul
)

echo Batch deployment complete - check logs for status
```

## Safety Controls

### Automatic Removal
Always include automatic removal after testing:
```powershell
# PowerShell - Auto-remove after X hours
$hours = 4
$removeTime = (Get-Date).AddHours($hours)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"sc.exe stop InfinityHookTest; sc.exe delete InfinityHookTest; Remove-Item C:\Windows\Temp\infinity_hook_pro_max.sys`""
$trigger = New-ScheduledTaskTrigger -Once -At $removeTime
Register-ScheduledTask -TaskName "AutoRemoveTestDriver" -Action $action -Trigger $trigger
```

### Deployment Logging
Maintain comprehensive logs:
```powershell
function Log-Deployment {
    param($Action, $Result)
    $log = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Hostname = $env:COMPUTERNAME
        User = $env:USERNAME
        Action = $Action
        Result = $Result
        Purpose = "Microsoft Security Research"
    }
    $log | ConvertTo-Json | Add-Content "C:\SecurityResearch\deployment.jsonl"
}
```

## Microsoft Vulnerability Reporting

### Prepare Your Report
1. **Test Results Documentation**
   - Affected Windows versions
   - Steps to reproduce
   - Impact assessment
   - Suggested mitigations

2. **Proof of Concept**
   - Minimal code to demonstrate issue
   - Clear reproduction steps
   - Expected vs actual behavior

3. **Submit to Microsoft**
   - Portal: https://msrc.microsoft.com/create-report
   - Include CVE request if applicable
   - Follow coordinated disclosure timeline

### Report Template
```markdown
# SetWindowDisplayAffinity Kernel Bypass Vulnerability

## Summary
Kernel-level bypass of SetWindowDisplayAffinity protection via system call hooking.

## Affected Products
- Windows 10 Version: [versions tested]
- Windows 11 Version: [versions tested]

## Impact
- CVSS Score: [calculate]
- Allows screenshot capture of protected windows
- Requires local admin/kernel access

## Technical Details
[Detailed technical explanation]

## Proof of Concept
[Minimal PoC code]

## Mitigation
- Enable HVCI
- Implement kernel patch protection
- [Other recommendations]

## Disclosure Timeline
- Discovery Date: [date]
- Vendor Notification: [date]
- Planned Disclosure: [date + 90 days]
```

## Important Reminders

⚠️ **NEVER deploy without:**
- Written authorization
- Isolated test environment
- Automatic removal mechanism
- Comprehensive logging
- Clear restoration plan

⚠️ **STOP deployment if:**
- You don't own the systems
- Production environment
- No authorization documentation
- Unclear about legality

## Legal Compliance Checklist

- [ ] Systems are owned by me or my organization
- [ ] Written authorization obtained (if corporate)
- [ ] Test environment isolated from production
- [ ] Automatic removal configured
- [ ] Logging enabled for audit trail
- [ ] Microsoft reporting process understood
- [ ] Legal counsel consulted if needed
- [ ] No unauthorized access will occur
- [ ] All testing within scope defined
- [ ] Data protection measures in place