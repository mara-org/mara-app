# On-Call Runbook

## Overview

This document describes on-call responsibilities and procedures for the Mara mobile application frontend repository.

**Scope:** Frontend-only incidents (app crashes, UI issues, client-side performance, CI/CD failures)

**Note:** Backend incidents are handled by the backend team in a separate repository.

## On-Call Rotation

### Current Status

**Not yet implemented** - Manual on-call rotation recommended

### Recommended Setup

- **Rotation:** Weekly (Monday to Monday)
- **Primary On-Call:** 1 engineer
- **Backup On-Call:** 1 engineer (for escalation)
- **Coverage:** 24/7 (adjust based on team size)

### Tools

- **PagerDuty / Opsgenie:** For on-call scheduling (to be configured)
- **Discord:** `#mara-alerts` for incident notifications
- **GitHub:** Issues and PRs for tracking

## On-Call Responsibilities

### Primary On-Call

- **Monitor:** Discord alerts, Sentry/Firebase dashboards, CI failures
- **Respond:** Acknowledge incidents within 15 minutes
- **Investigate:** Use observability dashboards to diagnose issues
- **Escalate:** Contact backup on-call or team lead if needed
- **Document:** Update incident logs and post-mortems

### Backup On-Call

- **Support:** Assist primary on-call when needed
- **Escalation:** Take over if primary unavailable
- **Review:** Review incident response after resolution

## Incident Types (Frontend Scope)

### P0 - Critical (Immediate Response)

**Examples:**
- App crashes affecting >10% of users
- Complete CI/CD pipeline failure blocking all deployments
- Security vulnerability in production code
- Data loss or corruption

**Response Time:** < 15 minutes
**Escalation:** Immediate to team lead

### P1 - High (Urgent)

**Examples:**
- App crashes affecting <10% of users
- Critical feature broken (sign-in, chat)
- Performance degradation (>50% slower)
- CI failures blocking specific deployments

**Response Time:** < 1 hour
**Escalation:** If not resolved in 1 hour

### P2 - Medium (Important)

**Examples:**
- Non-critical feature broken
- Minor performance issues
- CI warnings (non-blocking)
- UI glitches

**Response Time:** < 4 hours
**Escalation:** Normal business hours

### P3 - Low (Normal)

**Examples:**
- Cosmetic issues
- Documentation errors
- Minor UI improvements needed

**Response Time:** Next business day
**Escalation:** Not needed

## On-Call Workflow

### 1. Incident Detection

**Sources:**
- Discord `#mara-alerts` channel
- Sentry error alerts
- Firebase Crashlytics alerts
- GitHub Actions failures
- User reports (via support channels)

### 2. Acknowledge

- **Post in Discord:** "Investigating [incident description]"
- **Assign yourself:** In GitHub issue (if created)
- **Set status:** "Investigating" or "Working on it"

### 3. Investigate

**Use Observability Dashboards:**

- **Sentry:** Filter by error type, screen, feature
- **Firebase Crashlytics:** Check crash-free users, affected versions
- **Firebase Analytics:** Check SLO metrics (sign-in success, chat start)
- **GitHub Actions:** Review CI/CD logs

**Check:**
- Recent deployments
- Recent code changes
- Dependency updates
- Error patterns

### 4. Mitigate

**Immediate Actions:**
- Rollback deployment if needed (use rollback workflow)
- Disable feature flag if available
- Communicate status to team

**Fix:**
- Create hotfix branch
- Implement fix
- Test thoroughly
- Deploy via staging → production

### 5. Resolve

- **Verify:** Confirm incident is resolved
- **Monitor:** Watch for 15-30 minutes
- **Update:** Post resolution in Discord
- **Document:** Create/update incident log

### 6. Post-Mortem

- **Schedule:** Within 48 hours for P0/P1
- **Document:** Root cause, timeline, impact, lessons learned
- **Action Items:** Track improvements

## Escalation Path

```
Primary On-Call → Backup On-Call → Team Lead → Engineering Manager → CTO
```

**Escalation Triggers:**
- P0 incident not resolved in 30 minutes
- P1 incident not resolved in 2 hours
- Need additional expertise
- Security incident

## Handoff Procedures

### End of Shift

1. **Review:** Check for unresolved incidents
2. **Document:** Update incident logs
3. **Handoff:** Brief next on-call engineer
4. **Status:** Post handoff summary in Discord

### Handoff Checklist

- [ ] All P0/P1 incidents resolved or escalated
- [ ] Incident logs updated
- [ ] Next on-call engineer notified
- [ ] Handoff summary posted

## Tools & Access

### Required Access

- **GitHub:** Repository access, ability to merge/deploy
- **Sentry:** Error tracking dashboard access
- **Firebase:** Crashlytics and Analytics access
- **Discord:** `#mara-alerts` channel access

### Useful Commands

```bash
# Check recent deployments
gh run list --workflow="frontend-deploy.yml" --limit=10

# View CI logs
gh run view <run-id> --log

# Check error rates
# (Use Sentry/Firebase dashboards)

# Rollback deployment
# Use GitHub Actions → Rollback workflow
```

## Incident Response Templates

### Acknowledgment Message

```
🔍 Investigating: [Brief description]
- Severity: P0/P1/P2/P3
- Affected: [Users/Features]
- Started: [Time]
- On-Call: @[username]
```

### Status Update

```
📊 Status Update: [Incident]
- Current: [Status]
- Progress: [What's been done]
- ETA: [Estimated resolution time]
```

### Resolution Message

```
✅ Resolved: [Incident]
- Duration: [Time]
- Root Cause: [Brief description]
- Fix: [What was done]
- Post-Mortem: [Link if available]
```

## Best Practices

1. **Stay Calm:** Take a deep breath, follow the process
2. **Communicate:** Keep team informed of status
3. **Document:** Write down what you're doing
4. **Ask for Help:** Don't hesitate to escalate
5. **Learn:** Review incidents to improve

## Resources

- **Incident Response:** `docs/INCIDENT_RESPONSE.md`
- **Frontend SLOs:** `docs/FRONTEND_SLOS.md`
- **Architecture:** `docs/ARCHITECTURE.md`
- **Deployment:** `docs/DEPLOYMENT.md`

## Contact Information

- **Team Discord:** [Your Discord Server]
- **On-Call Schedule:** [Link to schedule]
- **Emergency Contact:** [To be configured]

---

**Last Updated:** December 2024
**Next Review:** January 2025

