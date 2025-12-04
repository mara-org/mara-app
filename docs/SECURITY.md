# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest | :x:                |

## Reporting a Vulnerability

### Frontend-Specific Security Issues

If you discover a security vulnerability in the Mara mobile app (frontend repository), please report it:

1. **Do NOT** open a public GitHub issue
2. Email security details to: [security@mara-app.com] (to be configured)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Acknowledgment:** Within 48 hours
- **Initial Assessment:** Within 7 days
- **Fix Timeline:** Depends on severity (P0: <24h, P1: <7d, P2: <30d)

## Security Practices

### Code Security

- **No Secrets in Code:** Never commit API keys, passwords, or tokens
- **Use Environment Variables:** Store secrets in GitHub Secrets or environment config
- **Input Validation:** Validate all user inputs
- **HTTPS Only:** All network requests must use HTTPS/TLS

### Dependency Security

- **Regular Updates:** Keep dependencies up to date
- **Vulnerability Scanning:** Dependabot and security PR checks run automatically
- **Critical Updates:** Critical dependency updates block PRs until resolved

### Secrets Management

#### GitHub Secrets Rotation

**Recommended Rotation Schedule:**
- **Production Secrets:** Every 90 days
- **Development Secrets:** Every 180 days
- **After Security Incident:** Immediately

**Secrets to Rotate:**
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `SENTRY_DSN` (if stored as secret)
- `DISCORD_WEBHOOK_*` tokens

**Rotation Process:**
1. Generate new secret values
2. Update GitHub Secrets
3. Test deployment with new secrets
4. Verify old secrets are no longer used
5. Document rotation in security log

### Secure Defaults Enforcement

#### Debug Flags

- All debug flags must be disabled in release builds
- Use `kDebugMode` or `kReleaseMode` to gate debug code
- Never log sensitive data, even in debug mode

#### Network Security

- Enforce HTTPS/TLS for all network requests
- Validate SSL certificates
- Use certificate pinning for critical endpoints (when backend available)

#### Data Storage

- Never store sensitive data in plain text
- Use encrypted storage for sensitive data
- Clear sensitive data when no longer needed

## Security Incident Response

### Frontend-Specific Incidents

**Types:**
- Secrets leak in code
- Vulnerable dependency detected
- Client-side security vulnerability
- Privacy violation

### Response Steps

1. **Immediate Actions:**
   - Rotate compromised secrets immediately
   - Remove sensitive data from code/history if leaked
   - Create security advisory if needed

2. **Assessment:**
   - Determine severity (P0/P1/P2)
   - Identify affected users/versions
   - Assess potential impact

3. **Remediation:**
   - Fix vulnerability
   - Release patch version
   - Update dependencies if needed

4. **Communication:**
   - Notify affected users if necessary
   - Document in security log
   - Post-mortem if P0/P1

### Incident Severity

- **P0 (Critical):** Immediate response, patch within 24h
- **P1 (High):** Urgent, patch within 7 days
- **P2 (Medium):** Important, patch within 30 days
- **P3 (Low):** Normal priority, patch in next release

## Security Scanning

### Automated Scans

- **Dependabot:** Weekly dependency vulnerability scanning
- **CodeQL:** Static analysis for security issues
- **TruffleHog:** Secrets scanning in PRs
- **License Scan:** Weekly license compliance check

### Manual Reviews

- Code reviews required for security-sensitive changes
- Security team review for high-risk changes
- Regular security audits

## Best Practices

### For Developers

1. **Never commit secrets**
2. **Keep dependencies updated**
3. **Validate all inputs**
4. **Use secure defaults**
5. **Follow principle of least privilege**
6. **Review security alerts promptly**

### For Reviewers

1. **Check for secrets in PRs**
2. **Verify dependency updates**
3. **Review security-sensitive code carefully**
4. **Ensure secure defaults**

## Security Resources

- **Security Advisories:** GitHub Security tab
- **Dependency Vulnerabilities:** Dependabot alerts
- **Code Scanning:** CodeQL results
- **Incident Response:** `docs/INCIDENT_RESPONSE.md`

## Contact

- **Security Email:** [security@mara-app.com] (to be configured)
- **Security Team:** [@security-team] (to be configured)

## Disclosure Policy

We follow responsible disclosure:
1. Report vulnerability privately
2. Allow reasonable time for fix
3. Coordinate public disclosure
4. Credit researchers appropriately

