# Deployment Guide

This document describes the deployment process for the Mara mobile application.

## Overview

The Mara app uses a multi-environment deployment strategy:
- **Staging**: Pre-production testing environment
- **Production**: Live production environment

All deployments are **frontend-only** - backend code lives in a separate repository.

## Deployment Workflows

### Staging Deployment

**Workflow:** `.github/workflows/staging-deploy.yml`

**Triggers:**
- Push to `main` branch
- Push to `staging` branch
- Manual trigger via `workflow_dispatch`

**Process:**
1. Builds staging APK and AAB with `ENVIRONMENT=staging`
2. Uploads artifacts with version: `{version}-staging-{timestamp}`
3. Artifacts available for download from GitHub Actions
4. Can be distributed via Firebase App Distribution or internal track

**Access:**
- Artifacts: GitHub Actions → Workflow runs → Artifacts
- Distribution: Configure Firebase App Distribution or internal distribution channel

### Production Deployment

**Workflow:** `.github/workflows/frontend-deploy.yml`

**Triggers:**
- Push to `main` branch
- Semantic version tags (`v*.*.*`)
- Manual trigger via `workflow_dispatch`

**Process:**
1. Builds production APK and AAB
2. Optionally signs artifacts if signing secrets are configured
3. Uploads artifacts with versioned names
4. Requires manual approval (GitHub Environments)

**Access:**
- Artifacts: GitHub Actions → Workflow runs → Artifacts
- Production releases: GitHub Releases (when release automation is used)

### PR Preview Builds

**Workflow:** `.github/workflows/pr-preview-deploy.yml`

**Triggers:**
- PR opened, updated, or reopened
- Only for non-draft PRs

**Process:**
1. Builds debug APK for testing
2. Uploads as artifact
3. Comments on PR with download link

**Purpose:**
- Allows reviewers to test changes before merge
- Lightweight debug builds (not for production)

## Deployment Promotion Flow

```
main branch → Staging Deployment → Manual Testing → Production Deployment
```

### Step-by-Step Promotion

1. **Code Merged to Main**
   - Staging deployment automatically triggers
   - Staging build artifacts available for testing

2. **Staging Testing**
   - Download staging APK/AAB from artifacts
   - Test critical flows
   - Verify no regressions

3. **Production Deployment**
   - Manual approval required (GitHub Environments)
   - Navigate to Actions → Production deployment → Review and approve
   - Production build is created and signed (if configured)

4. **Release**
   - Release automation workflow creates GitHub release
   - Version tag created automatically
   - Changelog generated from commits

## Rollback Process

**Workflow:** `.github/workflows/rollback.yml`

**When to Use:**
- Critical bugs discovered in production
- Performance regressions
- Security issues

**How to Rollback:**

1. **Manual Trigger:**
   - Go to Actions → Rollback workflow
   - Click "Run workflow"
   - Enter:
     - Version tag or commit SHA to rollback to (e.g., `v1.0.0` or `abc1234`)
     - Reason for rollback

2. **Process:**
   - Workflow checks out the specified version
   - Builds APK/AAB from that version
   - Uploads rollback artifacts
   - Creates rollback summary

3. **Deploy Rollback:**
   - Download rollback artifacts
   - Deploy via Firebase App Distribution or Play Store
   - Document rollback in incident report

## Deployment Approval Gates

### GitHub Environments

Production deployments use GitHub Environments for approval gates:

**Configuration (Manual Setup Required):**

1. Go to Repository Settings → Environments
2. Create/configure `production` environment
3. Add required reviewers
4. Configure protection rules:
   - Required reviewers: 1-2 approvers
   - Wait timer: 0 minutes (or as needed)
   - Deployment branches: `main` only

**Approval Process:**

1. Production deployment workflow runs
2. Workflow pauses at `environment: production` step
3. Required reviewers receive notification
4. Reviewers approve or reject deployment
5. Workflow continues or cancels based on approval

## Signing Configuration

### Android Signing

Production builds can be signed if the following secrets are configured:

- `ANDROID_KEYSTORE_BASE64`: Base64-encoded keystore file
- `ANDROID_KEY_ALIAS`: Key alias name
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password
- `ANDROID_KEY_PASSWORD`: Key password

**Setup:**

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore mara-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mara
   ```

2. Encode keystore:
   ```bash
   base64 -i mara-release-key.jks -o keystore-base64.txt
   ```

3. Add secrets to GitHub:
   - Repository Settings → Secrets and variables → Actions
   - Add each secret with the values above

**Note:** If secrets are not configured, builds will still succeed but won't be signed.

## Post-Deployment Validation

### Smoke Tests

After deployment, smoke tests automatically run:

**Workflow:** `.github/workflows/smoke-tests.yml`

**Tests:**
- Static analysis passes
- Critical unit tests pass
- Build validation (dry-run)

**Purpose:**
- Quick validation that deployment didn't break basic functionality
- Fast feedback loop

## Release Notes

### Automatic Changelog Generation

**Script:** `scripts/generate-changelog.sh`

**Process:**
- Analyzes git commit history
- Categorizes commits (Added, Changed, Fixed, Removed)
- Updates `CHANGELOG.md`

**Conventional Commits:**
- `feat:` → Added
- `fix:` → Fixed
- `chore:` → Changed
- `refactor:` → Changed

### Release Automation

**Workflow:** `.github/workflows/release-automation.yml`

**Features:**
- Automatic version bumping (patch/minor/major)
- Changelog generation
- Git tag creation
- GitHub release creation

**Version Bumping:**
- `feat:` commits → minor version bump
- `fix:` commits → patch version bump
- `breaking:` commits → major version bump

## DORA Metrics

**Workflow:** `.github/workflows/dora-metrics.yml`

**Metrics Tracked:**
- Deployment frequency (deployments per day)
- Change failure rate (% of failed deployments)
- Lead time (time from commit to deploy) - requires enhancement
- Mean time to recovery (MTTR) - requires incident tracking

**Report Location:** `docs/metrics/dora-metrics.md`

**Update Frequency:** Daily (scheduled workflow)

## Troubleshooting

### Deployment Fails

1. **Check workflow logs:**
   - GitHub Actions → Failed workflow run
   - Review error messages

2. **Common Issues:**
   - Flutter version mismatch
   - Missing dependencies
   - Build configuration errors
   - Signing secrets misconfigured

3. **Fix and Retry:**
   - Fix issues in code
   - Push fixes to branch
   - Workflow will re-run automatically

### Artifacts Not Available

- Check artifact retention period (default: 90 days)
- Verify workflow completed successfully
- Check artifact upload step in workflow logs

### Signing Issues

- Verify all signing secrets are configured
- Check keystore format (must be base64 encoded)
- Ensure key alias matches exactly
- Review signing step logs for specific errors

## Best Practices

1. **Always test in staging first**
2. **Review changelog before production deployment**
3. **Use semantic versioning for releases**
4. **Document rollbacks in incident reports**
5. **Monitor DORA metrics for improvement opportunities**
6. **Keep deployment artifacts for at least 90 days**

## Related Documentation

- [Architecture](ARCHITECTURE.md): System architecture overview
- [Incident Response](INCIDENT_RESPONSE.md): Incident handling procedures
- [Frontend SLOs](FRONTEND_SLOS.md): Service level objectives
- [README](../README.md): Project overview

