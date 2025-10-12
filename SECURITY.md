# Security Policy

## Responsible Disclosure Statement

This project is maintained for educational and security research purposes. We are committed to responsible disclosure and ethical security research.

## Reporting Security Issues

If you discover security vulnerabilities related to this project or its implementation:

### For Issues in This Driver
- Open a GitHub issue describing the vulnerability
- Include steps to reproduce if applicable
- Suggest fixes or mitigations

### For Windows Kernel Vulnerabilities
- Report directly to Microsoft Security Response Center (MSRC)
- Website: https://msrc.microsoft.com/create-report
- Email: secure@microsoft.com

### For Application-Specific Bypasses
- Report to the affected application vendor
- Follow the vendor's responsible disclosure policy
- Allow reasonable time for patches before public disclosure

## Scope

This project demonstrates:
- Known techniques for bypassing display protection
- Educational kernel programming concepts
- Security research methodologies

## Out of Scope

This project does not:
- Introduce new vulnerabilities
- Exploit zero-day vulnerabilities
- Bypass security without required privileges
- Escalate privileges

## Ethical Use

Users of this software agree to:
- Only test on systems they own or have permission to test
- Report discovered vulnerabilities responsibly
- Not use for malicious purposes
- Comply with all applicable laws

## Known Limitations

- Requires administrative/kernel privileges
- Does not work with Secure Boot enabled
- Detected by most EDR solutions
- May trigger PatchGuard

## Security Best Practices

For defenders:
1. Enable Secure Boot and UEFI
2. Implement driver allowlisting
3. Monitor kernel modifications
4. Use Hypervisor-Protected Code Integrity
5. Deploy EDR with kernel visibility

## Contact

For security-related inquiries only:
- GitHub Issues (public)
- Security researchers may request private communication channels

## Acknowledgments

We thank the security research community for:
- Responsible disclosure practices
- Sharing knowledge ethically
- Building better defenses
- Advancing the field of security

## Legal Notice

This software is provided for educational purposes only. Users are solely responsible for ensuring their use complies with applicable laws and regulations.