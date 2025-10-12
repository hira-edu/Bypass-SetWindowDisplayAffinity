# SetWindowDisplayAffinity Bypass - Deployment Guide

## Quick Start

### Method 1: Test Mode (Recommended for Research)
```batch
# Run as Administrator
load_driver.bat
# Select option 1 (first time) then restart
# After restart, run again and select option 2
```

### Method 2: KDU (No Signature Required)
```batch
# Download KDU from https://github.com/hfiref0x/KDU
kdu -prv 1 -map infinity_hook_pro_max.sys
```

## Deployment Methods Comparison

| Method | Signature Required | Persistence | Detection Risk | Use Case |
|--------|-------------------|-------------|----------------|----------|
| **Test Mode + SC** | No (test mode) | Yes | Low | Development/Research |
| **KDU** | No | No (session) | Medium | Quick Testing |
| **Signed Driver** | Yes (EV cert) | Yes | Very Low | Production |
| **DSE Disabled** | No | No (boot) | High | Emergency Only |

## Step-by-Step Instructions

### Standard Deployment (Test Mode)

1. **Enable Test Signing** (one-time setup)
```batch
bcdedit /set testsigning on
# Restart required
```

2. **Load Driver**
```batch
sc create InfinityHook type=kernel binPath="C:\path\to\infinity_hook_pro_max.sys"
sc start InfinityHook
```

3. **Verify Bypass**
```powershell
.\verify_bypass.ps1
```

### KDU Method (No Restart)

1. **Download KDU**
   - Get from: https://github.com/hfiref0x/KDU/releases
   - Extract to same folder as driver

2. **Map Driver**
```batch
# List available providers
kdu -list

# Use provider 1 (CVE-2015-2291)
kdu -prv 1 -map infinity_hook_pro_max.sys
```

3. **Note**: Driver unloads on reboot with KDU

### Production Deployment (EV Certificate)

1. **Sign Driver**
```batch
signtool sign /v /ac "CrossCert.cer" /s MY /n "Your Company" /t http://timestamp.digicert.com infinity_hook_pro_max.sys
```

2. **Install Normally**
```batch
pnputil /add-driver infinity_hook_pro_max.inf /install
```

## Verification

### Check if Driver Loaded
```batch
# Query service
sc query InfinityHook

# Check kernel modules
driverquery | findstr infinity

# System event log
wevtutil qe System /q:"*[System[Provider[@Name='Service Control Manager']]]" /f:text
```

### Test Bypass
```powershell
# Run verification script
powershell -ExecutionPolicy Bypass .\verify_bypass.ps1

# Manual test:
# 1. Open any app with screenshot protection (Discord, Netflix, etc.)
# 2. Take screenshot
# 3. If content visible = bypass working
```

## Troubleshooting

### "System error 577" - Cannot verify digital signature
**Solution**: Enable test mode or use KDU

### "System error 1275" - Driver blocked by policy
**Solution**: Disable Secure Boot in BIOS

### Driver loads but bypass not working
**Possible causes**:
- PatchGuard triggered (check Event Viewer)
- Incompatible Windows version
- Another security driver interfering

### Blue Screen (BSOD)
**Recovery**:
1. Boot to Safe Mode
2. Delete driver: `sc delete InfinityHook`
3. Remove file from system32\drivers

## Security Considerations

⚠️ **WARNING**: Loading unsigned kernel drivers:
- Reduces system security
- May trigger antivirus alerts
- Could violate organizational policies
- Use only in isolated test environments

## Automated Deployment Script

```powershell
# Full deployment script
$driverPath = ".\build-artifacts\infinity_hook_pro_max.sys"

# Check admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrator rights required"
    exit 1
}

# Check test mode
$testMode = bcdedit | Select-String "testsigning.*Yes"
if (-not $testMode) {
    Write-Host "Enabling test mode..." -ForegroundColor Yellow
    bcdedit /set testsigning on
    Write-Host "Please restart and run again" -ForegroundColor Red
    exit 0
}

# Load driver
Write-Host "Loading driver..." -ForegroundColor Green
sc.exe create InfinityHook type=kernel binPath=$driverPath
sc.exe start InfinityHook

# Verify
$status = sc.exe query InfinityHook | Select-String "RUNNING"
if ($status) {
    Write-Host "✓ Driver loaded successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Driver failed to load" -ForegroundColor Red
}
```

## Uninstall

```batch
# Stop and remove driver
sc stop InfinityHook
sc delete InfinityHook

# Disable test mode (optional)
bcdedit /set testsigning off

# Delete driver file
del C:\Windows\System32\drivers\infinity_hook_pro_max.sys
```