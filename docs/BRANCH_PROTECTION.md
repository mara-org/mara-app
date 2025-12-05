# Branch Protection Configuration

This document describes the branch protection rules for the Mara app repository and how to configure them in GitHub.

## Overview

Branch protection ensures code quality and prevents accidental changes to the main branch. All changes must go through pull requests with code owner approval.

## Required Branch Protection Rules

### Main Branch Protection

The `main` branch must have the following protection rules enabled:

#### 1. Require Pull Request Reviews

- ✅ **Required:** At least 1 approval
- ✅ **Dismiss stale reviews:** When new commits are pushed
- ✅ **Require review from CODEOWNERS:** Enforced
- ✅ **Restrict who can dismiss reviews:** Repository admins only

#### 2. Require Status Checks

Required status checks must pass before merging:
- `Mara CI – Multi Platform` (all platforms)
- `Mara CI – Code Duplication Detection`
- `Mara QA – Accessibility Tests`
- `Mara QA – Localization Tests`
- `Mara QA – Deep Link Tests`

#### 3. Require Branch to be Up to Date

- ✅ **Require branches to be up to date before merging**

#### 4. Require CODEOWNERS Review

- ✅ **Require review from CODEOWNERS**
- This ensures changes to protected paths require owner approval

#### 5. Restrict Pushes

- ✅ **Do not allow bypassing the above settings**
- ✅ **Do not allow force pushes**
- ✅ **Do not allow deletions**

#### 6. File Size Restrictions

- ✅ **Restrict pushes that create files larger than 100 MB**

## Configuration Steps

### Step 1: Navigate to Settings

1. Go to repository on GitHub
2. Click **Settings** tab
3. Click **Branches** in left sidebar

### Step 2: Add Branch Protection Rule

1. Click **Add rule** or **Edit** existing rule for `main`
2. Configure rules as described above
3. Click **Create** or **Save changes**

### Step 3: Verify Configuration

1. Create a test PR to `main`
2. Verify CODEOWNERS are automatically requested
3. Verify status checks are required
4. Verify merge is blocked until approved

## CODEOWNERS Enforcement

The `.github/CODEOWNERS` file defines code owners for different paths:

- `/lib/core/` → `@justAbdulaziz10`
- `/lib/features/auth/` → `@justAbdulaziz10`
- `/lib/features/chat/` → `@justAbdulaziz10`
- `/test/` → `@justAbdulaziz10` and `@gqnxx`
- `/.github/` → `@justAbdulaziz10` and `@gqnxx`

When a PR modifies files in these paths, the code owners are automatically requested for review.

## Status Checks

### Required Checks

These checks must pass before merging:

1. **Mara CI – Multi Platform**
   - Code formatting
   - Static analysis
   - Tests (Android, iOS, Web)
   - Coverage checks

2. **Mara CI – Code Duplication Detection**
   - Code duplication < 7%

3. **Mara QA – Accessibility Tests**
   - Accessibility compliance

4. **Mara QA – Localization Tests**
   - Translation completeness
   - RTL layout validation

5. **Mara QA – Deep Link Tests**
   - Deep link functionality

### Optional Checks

These checks provide information but don't block merging:
- Documentation CI
- Performance benchmarks
- Security scans (non-blocking)

## Workflow

### Standard PR Process

1. **Create PR** to `main` branch
2. **CODEOWNERS** automatically requested
3. **Status checks** run automatically
4. **Review** by code owners
5. **Approve** when ready
6. **Merge** (squash or merge commit)

### Emergency Process

For critical hotfixes:
1. Create PR with `[HOTFIX]` prefix
2. Request expedited review
3. All status checks must still pass
4. CODEOWNERS approval still required

## Troubleshooting

### Issue: CODEOWNERS not being requested

**Check:**
- Branch protection rule enabled
- CODEOWNERS file syntax correct
- File paths match CODEOWNERS patterns

### Issue: Status checks not running

**Check:**
- Workflow files are valid
- Workflows are enabled
- Branch protection configured correctly

### Issue: Can't merge PR

**Check:**
- All required status checks passed
- CODEOWNERS approved
- Branch is up to date
- No merge conflicts

## Best Practices

1. **Keep CODEOWNERS updated**
   - Add new owners when needed
   - Remove inactive owners
   - Keep paths accurate

2. **Review PRs promptly**
   - Respond within 24 hours
   - Provide constructive feedback
   - Approve when ready

3. **Keep PRs small**
   - Easier to review
   - Faster to merge
   - Lower risk

4. **Use descriptive PR titles**
   - Clear what changed
   - Include issue number if applicable

## Related Documentation

- [CODEOWNERS](../.github/CODEOWNERS)
- [Contributing Guide](../CONTRIBUTING.md)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)

---

**Last Updated:** December 2025

