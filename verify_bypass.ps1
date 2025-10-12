# Verify SetWindowDisplayAffinity Bypass
# Tests if the driver successfully bypasses display affinity protection

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Drawing;

public class DisplayAffinityTest {
    [DllImport("user32.dll")]
    public static extern bool SetWindowDisplayAffinity(IntPtr hWnd, uint dwAffinity);

    [DllImport("user32.dll")]
    public static extern bool GetWindowDisplayAffinity(IntPtr hWnd, out uint pdwAffinity);

    public const uint WDA_NONE = 0x00000000;
    public const uint WDA_MONITOR = 0x00000001;
    public const uint WDA_EXCLUDEFROMCAPTURE = 0x00000011;
}
"@ -ReferencedAssemblies System.Windows.Forms, System.Drawing

Write-Host "`n[*] SetWindowDisplayAffinity Bypass Verification Tool" -ForegroundColor Cyan
Write-Host "[*] Creating test window..." -ForegroundColor Yellow

# Create a test form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Display Affinity Test Window"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Size = New-Object System.Drawing.Size(350, 250)
$label.Location = New-Object System.Drawing.Point(25, 25)
$label.Font = New-Object System.Drawing.Font("Arial", 12)
$label.Text = "This window is testing SetWindowDisplayAffinity`n`nIf the bypass is working:`n- Screenshots will capture this window`n- Screen recording will show this window`n`nWithout bypass:`n- Window appears black in captures"
$form.Controls.Add($label)

# Show form
$form.Add_Shown({
    $hwnd = $form.Handle
    Write-Host "[*] Test window created (HWND: $hwnd)" -ForegroundColor Green

    # Try to set display affinity (block screenshots)
    Write-Host "`n[*] Attempting to set WDA_EXCLUDEFROMCAPTURE flag..." -ForegroundColor Yellow
    $result = [DisplayAffinityTest]::SetWindowDisplayAffinity($hwnd, [DisplayAffinityTest]::WDA_EXCLUDEFROMCAPTURE)

    if ($result) {
        Write-Host "[+] SetWindowDisplayAffinity returned success" -ForegroundColor Green
    } else {
        Write-Host "[-] SetWindowDisplayAffinity failed" -ForegroundColor Red
    }

    # Check current affinity
    $currentAffinity = 0
    $getResult = [DisplayAffinityTest]::GetWindowDisplayAffinity($hwnd, [ref]$currentAffinity)

    Write-Host "`n[*] Checking current display affinity..." -ForegroundColor Yellow
    Write-Host "[*] Current affinity value: 0x$($currentAffinity.ToString('X8'))" -ForegroundColor Cyan

    if ($currentAffinity -eq 0) {
        Write-Host "`n[+] SUCCESS: Display affinity is 0x00000000!" -ForegroundColor Green
        Write-Host "[+] The bypass is WORKING - screenshots will capture this window" -ForegroundColor Green
        $label.BackColor = [System.Drawing.Color]::LightGreen
        $label.Text += "`n`n✓ BYPASS ACTIVE"
    } else {
        Write-Host "`n[-] Display affinity is still set to 0x$($currentAffinity.ToString('X8'))" -ForegroundColor Red
        Write-Host "[-] The bypass is NOT working" -ForegroundColor Red
        $label.BackColor = [System.Drawing.Color]::LightPink
        $label.Text += "`n`n✗ BYPASS NOT ACTIVE"
    }

    Write-Host "`n[*] Take a screenshot now to verify the bypass" -ForegroundColor Yellow
    Write-Host "[*] Press any key in this console to close the test window" -ForegroundColor Yellow
})

[System.Windows.Forms.Application]::Run($form)