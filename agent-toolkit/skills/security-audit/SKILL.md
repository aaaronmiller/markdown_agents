---
name: security-audit
description: Security assessment, vulnerability detection, and remediation guidelines. Use when: security, vulnerability, audit, CVE, exploit.
---

# Security Audit Skill

## OWASP Top 10 Checklist

- [ ] Injection (SQL, NoSQL, Command)
- [ ] Broken Authentication
- [ ] Sensitive Data Exposure
- [ ] XML External Entities (XXE)
- [ ] Broken Access Control
- [ ] Security Misconfiguration
- [ ] Cross-Site Scripting (XSS)
- [ ] Insecure Deserialization
- [ ] Using Components with Known Vulnerabilities
- [ ] Insufficient Logging & Monitoring

## Quick Checks

### Input Validation
- Validate ALL user inputs
- Use allowlists, not denylists
- Sanitize before storage/display

### Authentication
- Use bcrypt/argon2 for passwords
- Implement rate limiting on login
- Use secure session management
- Enforce strong password policies

### Authorization
- Principle of least privilege
- Check permissions on every request
- Never trust client-side validation

### Data Protection
- Encrypt sensitive data at rest
- Use HTTPS for all connections
- Secure API keys/secrets
- Implement proper key rotation

## Common Vulnerabilities

**SQL Injection**: Use parameterized queries
**XSS**: Sanitize output, use CSP headers
**CSRF**: Use CSRF tokens
**Path Traversal**: Validate file paths
**Insecure Direct Object References**: Check authorization

## Remediation Priority

1. **Critical**: Remote code execution, SQL injection
2. **High**: Authentication bypass, data exposure
3. **Medium**: XSS, CSRF
4. **Low**: Information disclosure
