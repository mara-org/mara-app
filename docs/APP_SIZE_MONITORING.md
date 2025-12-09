# App Size Monitoring

## Overview

App Size Monitoring automatically tracks APK and AAB file sizes and alerts when size increases exceed configured thresholds. This helps prevent app bloat and ensures optimal download sizes for users.

## How It Works

The monitoring script (`scripts/monitor-app-size.sh`) runs during CI/CD builds and:

1. **Measures** current APK/AAB sizes
2. **Compares** against baseline sizes from previous builds
3. **Alerts** if size increases exceed thresholds:
   - Percentage increase threshold (default: 5%)
   - Absolute increase threshold (default: 10 MB)
4. **Reports** size information in PR comments and workflow outputs

## Configuration

### Thresholds

Default thresholds can be overridden:

```bash
bash scripts/monitor-app-size.sh [APK_PATH] [AAB_PATH] [PERCENT_THRESHOLD] [ABSOLUTE_MB_THRESHOLD]
```

**Default Values:**
- Percentage threshold: 5%
- Absolute threshold: 10 MB

### Baseline Sizes

Baseline sizes are stored from previous successful builds. For the first run, baseline is 0 (no comparison).

**Future Enhancement:** Store baseline in GitHub Actions cache or artifacts for comparison across builds.

## Usage

### Manual Execution

```bash
# Monitor current build
bash scripts/monitor-app-size.sh

# With custom thresholds
bash scripts/monitor-app-size.sh \
  build/app/outputs/flutter-apk/app-release.apk \
  build/app/outputs/bundle/release/app-release.aab \
  5 \  # 5% increase threshold
  10   # 10 MB absolute threshold
```

### CI/CD Integration

The monitoring runs automatically in:
- `.github/workflows/app-size-monitoring.yml` - Standalone monitoring workflow
- `.github/workflows/frontend-deploy.yml` - Integrated into deployment workflow

## Workflow Behavior

### On Pull Requests
- Builds APK/AAB
- Monitors size
- Comments on PR with size information
- **Does not block merge** (warning only)

### On Main Branch
- Builds APK/AAB
- Monitors size
- Alerts if thresholds exceeded
- **Can block deployment** if configured

## Alerts

When size increases exceed thresholds, the script:
1. Outputs alert messages
2. Provides recommendations
3. Exits with error code (can block CI/CD)

### Recommendations Provided

- Review recent dependency additions
- Check for large assets or images
- Analyze bundle composition (run bundle analysis)
- Consider code splitting or lazy loading

## Example Output

```
📦 Monitoring app size...
✅ APK found: 25.50 MB
✅ AAB found: 18.30 MB

📊 APK Size Analysis:
  Current: 25.50 MB
  Baseline: 24.00 MB
  Change: 1.50 MB (6.25%)

⚠️  ALERT: APK size increased by 6.25% (threshold: 5%)
❌ App size monitoring failed. Size increase exceeds thresholds.
```

## Best Practices

1. **Monitor Regularly**: Run on every build to catch size increases early
2. **Set Appropriate Thresholds**: Adjust based on your app's size and update frequency
3. **Investigate Increases**: When alerts trigger, use bundle analysis to identify causes
4. **Track Trends**: Monitor size trends over time to identify gradual bloat

## Related Tools

- **Bundle Analysis** (`scripts/analyze-bundle-size.sh`) - Detailed bundle composition analysis
- **Bundle Analysis Workflow** (`.github/workflows/bundle-analysis.yml`) - Automated bundle analysis

## Troubleshooting

### "No build artifacts found"
- Ensure the app has been built: `flutter build apk --release`
- Check that build paths are correct

### "Baseline not found"
- First run: Baseline is 0, no comparison performed
- Subsequent runs: Baseline should be stored from previous builds

### False Positives
- Large feature additions may legitimately increase size
- Review the change and adjust thresholds if needed
- Use bundle analysis to understand what's taking space

## Future Enhancements

- [ ] Store baseline sizes in GitHub Actions cache
- [ ] Track size trends over time
- [ ] Generate size trend charts
- [ ] Compare against industry benchmarks
- [ ] Per-feature size tracking

