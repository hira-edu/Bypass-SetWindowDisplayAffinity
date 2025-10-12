# SetWindowDisplayAffinity Bypass - Security Research Tool

## ⚖️ Legal Notice & Disclaimer

**THIS SOFTWARE IS PROVIDED FOR EDUCATIONAL AND SECURITY RESEARCH PURPOSES ONLY**

By downloading, compiling, or using this software, you acknowledge and agree that:

1. **Authorized Use Only**: This tool may only be used on systems you own or have explicit written permission to test
2. **Research Purpose**: This project is intended solely for security research, education, and improving defensive capabilities
3. **Compliance Required**: You are responsible for complying with all applicable local, state, and federal laws
4. **No Warranty**: This software is provided "AS IS" without warranty of any kind
5. **Assumption of Risk**: Use of this software is at your own risk and responsibility

## 🎓 Educational Purpose

This project demonstrates:
- Windows kernel driver development techniques
- System call hooking mechanisms
- Security boundary interactions in Windows
- Display protection bypass methods for security analysis

## ✅ Legitimate Use Cases

### Security Research
- Understanding Windows display protection mechanisms
- Testing screenshot prevention bypasses in controlled environments
- Developing detection methods for similar techniques
- Vulnerability research and responsible disclosure

### Software Development
- Testing applications that implement display protection
- Quality assurance for DRM-protected content systems
- Debugging screenshot-restricted applications
- Automated testing of protected UI elements

### Digital Forensics
- Lawful investigation with proper authorization
- Evidence collection from protected displays
- Incident response requiring full system visibility
- Authorized penetration testing engagements

## ⛔ Prohibited Uses

**DO NOT use this tool for:**
- Circumventing DRM or copyright protection systems
- Unauthorized screenshots of protected content
- Violating terms of service of any application or service
- Any activity that violates privacy laws or regulations
- Commercial piracy or content theft
- Unauthorized surveillance or monitoring

## 📋 Technical Overview

This kernel driver demonstrates how `SetWindowDisplayAffinity` protection can be bypassed at the kernel level by hooking the `NtUserSetWindowDisplayAffinity` system call and forcing the display affinity flags to `0x00000000`.

### How It Works
1. Loads as a kernel driver using Windows service infrastructure
2. Hooks system calls via Circular Kernel Context Logger (CKCL)
3. Intercepts `NtUserSetWindowDisplayAffinity` calls
4. Modifies protection flags to disable screenshot prevention
5. Returns control to original system call

### Build Status
[![Build Windows Driver](https://github.com/hira-edu/Bypass-SetWindowDisplayAffinity/actions/workflows/build.yml/badge.svg)](https://github.com/hira-edu/Bypass-SetWindowDisplayAffinity/actions/workflows/build.yml)

## 🔧 Installation

### Prerequisites
- Windows 10/11 x64
- Administrator privileges
- Test Mode or disabled Driver Signature Enforcement

### Quick Start
```batch
# Enable test mode (one-time, requires restart)
bcdedit /set testsigning on

# Load driver
load_driver.bat

# Verify bypass is working
powershell -ExecutionPolicy Bypass .\verify_bypass.ps1
```

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)

## 🛡️ Detection & Mitigation

### For Security Teams
To detect this or similar bypasses:
- Monitor for test signing mode: `bcdedit | findstr testsigning`
- Check for unsigned kernel drivers: `driverquery /si | findstr "FALSE"`
- Audit system call hooks via WPA/ETW
- Implement kernel patch protection monitoring
- Use EDR solutions with kernel-level visibility

### Defensive Recommendations
1. Enable Secure Boot and UEFI
2. Implement driver allowlisting via WDAC
3. Monitor for kernel modifications
4. Use Hypervisor-Protected Code Integrity (HVCI)
5. Deploy kernel-level security solutions

## 📚 Academic References

This research builds upon:
- "Windows Kernel Programming" by Pavel Yosifovich
- "Rootkits and Bootkits" by Alex Matrosov et al.
- Microsoft's documentation on Windows display protection
- CVE research on kernel-level bypasses

## ⚠️ Security Considerations

**Impact on System Security:**
- Reduces overall system security posture
- May trigger PatchGuard on certain configurations
- Could conflict with anti-cheat systems
- Leaves forensic artifacts in event logs

**Responsible Disclosure:**
- This technique has been known since Windows 10 introduction
- Microsoft is aware of kernel-level bypass possibilities
- Requires administrative/kernel privileges (not a privilege escalation)

## 📄 License & Attribution

This project is provided for educational purposes. Users are solely responsible for their use of this software.

**Original Research**: TopSoftdeveloper
**Fork Maintainer**: hira-edu
**Build Automation**: GitHub Actions CI/CD

## 🤝 Ethical Guidelines

As security researchers, we commit to:
- **Responsible Disclosure**: Report vulnerabilities to vendors
- **Ethical Use**: Only test on authorized systems
- **Knowledge Sharing**: Educate the community about security
- **Defensive Focus**: Help build better protections

## 📞 Contact & Support

For security research inquiries only:
- Open an issue for technical questions
- Do NOT request help for unauthorized activities
- Consult legal counsel if unsure about usage legality

## 🚨 Final Warning

**MISUSE OF THIS SOFTWARE MAY RESULT IN:**
- Criminal prosecution
- Civil liability
- Termination of employment
- Academic disciplinary action
- Permanent ban from platforms/services

**By using this software, you accept full responsibility for your actions and agree to use it only for lawful, authorized security research and educational purposes.**

---

*This project is maintained for academic and security research purposes. The maintainers do not condone or support any illegal activities.*