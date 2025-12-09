# Bundle Analysis

## Overview

Bundle Analysis provides detailed insights into Flutter app bundle composition, identifying large components, assets, and dependencies. This helps optimize app size and identify optimization opportunities.

## How It Works

The bundle analyzer (`scripts/analyze-bundle-size.sh`) extracts and analyzes APK/AAB files to:

1. **Extract** APK/AAB contents (they're ZIP files)
2. **Analyze** different components:
   - Native libraries (lib/)
   - Assets and images
   - Flutter assets
   - Dart code (classes.dex)
   - Resources (res/)
3. **Identify** large files and directories
4. **Generate** recommendations for optimization

## Usage

### Manual Execution

```bash
# Analyze current build
bash scripts/analyze-bundle-size.sh

# With custom paths
bash scripts/analyze-bundle-size.sh \
  build/app/outputs/flutter-apk/app-release.apk \
  build/app/outputs/bundle/release/app-release.aab \
  bundle-analysis-report.md
```

### CI/CD Integration

The analysis runs automatically in:
- `.github/workflows/bundle-analysis.yml` - Standalone analysis workflow
- Runs on PRs and main branch pushes
- Comments on PRs with analysis summary
- Uploads full report as artifact

## Analysis Components

### 1. Native Libraries (lib/)

Analyzes native libraries (.so files) for different architectures:
- arm64-v8a
- armeabi-v7a
- x86_64

**What to Look For:**
- Large native libraries (>5MB)
- Unused architectures (if supporting only specific devices)

### 2. Assets and Images

Analyzes all assets in the app:
- Images (PNG, JPEG, WebP)
- Fonts
- Other static files

**What to Look For:**
- Large images (>1MB)
- Unoptimized formats (use WebP when possible)
- Duplicate assets

### 3. Flutter Assets (flutter_assets/)

Analyzes Flutter-specific assets:
- Kernel snapshots
- Asset manifests
- Font files

**What to Look For:**
- Large font files
- Unused assets

### 4. Dart Code (classes.dex)

Analyzes compiled Dart code:
- Single DEX file (small apps)
- Multiple DEX files (multidex - apps >65K methods)

**What to Look For:**
- Multidex indicates large codebase
- Consider code splitting for large features

### 5. Resources (res/)

Analyzes Android resources:
- Images (drawable/)
- Layouts (layout/)
- Values (values/)

**What to Look For:**
- Large drawable resources
- Unused resources

### 6. Project Assets

Analyzes assets in the `assets/` directory:
- Identifies largest files
- Lists files >100KB

## Report Output

The script generates a markdown report (`bundle-analysis-report.md`) with:

1. **Summary** - Total sizes
2. **Recommendations** - Optimization suggestions
3. **Detailed Analysis** - Component breakdown

### Example Report Structure

```markdown
# Bundle Size Analysis Report

## Summary
- APK Size: 25.50 MB
- AAB Size: 18.30 MB

## Recommendations
- ⚠️ Found 3 large asset(s) (>1MB). Consider optimizing images.
- ⚠️ Multiple DEX files detected. Consider code splitting.

## Detailed Analysis
[Component breakdown...]
```

## Optimization Recommendations

### Large Assets (>1MB)

**Action:**
1. Optimize images (compress, use WebP)
2. Use vector graphics when possible
3. Lazy load large assets
4. Consider CDN for very large assets

### Multiple DEX Files (Multidex)

**Action:**
1. Remove unused dependencies
2. Use ProGuard/R8 code shrinking
3. Consider code splitting
4. Split large features into separate modules

### Large Native Libraries

**Action:**
1. Check if all architectures are needed
2. Use App Bundle (AAB) for Play Store (smaller downloads)
3. Consider dynamic feature modules

### Large Resources

**Action:**
1. Remove unused resources
2. Optimize drawable resources
3. Use vector drawables when possible

## Best Practices

1. **Run Regularly**: Analyze bundle after significant changes
2. **Compare Over Time**: Track bundle composition trends
3. **Set Size Budgets**: Define maximum sizes for components
4. **Automate**: Use CI/CD to catch size increases early

## Integration with Size Monitoring

Bundle analysis complements app size monitoring:

- **Size Monitoring**: Detects when size increases
- **Bundle Analysis**: Identifies what's causing the increase

**Workflow:**
1. Size monitoring alerts on increase
2. Run bundle analysis to identify cause
3. Optimize identified components
4. Verify size reduction

## Example Workflow

```bash
# 1. Build the app
flutter build apk --release

# 2. Monitor size
bash scripts/monitor-app-size.sh

# 3. If size increased, analyze bundle
bash scripts/analyze-bundle-size.sh

# 4. Review report
cat bundle-analysis-report.md

# 5. Optimize based on recommendations
# (e.g., compress images, remove unused dependencies)

# 6. Rebuild and verify
flutter build apk --release
bash scripts/monitor-app-size.sh
```

## Troubleshooting

### "Failed to extract APK/AAB"
- Ensure the file is a valid APK/AAB
- Check file permissions
- Verify unzip is available

### "No build artifacts found"
- Build the app first: `flutter build apk --release`
- Check build output paths

### Analysis takes too long
- Large apps may take several minutes
- Consider analyzing only APK or AAB (not both)

## Related Documentation

- [App Size Monitoring](APP_SIZE_MONITORING.md) - Size monitoring guide
- [Performance Guidelines](PERFORMANCE.md) - Performance optimization
- [Flutter Performance](https://docs.flutter.dev/perf) - Official Flutter performance guide

## Future Enhancements

- [ ] Visual bundle composition charts
- [ ] Size trend tracking
- [ ] Per-feature size breakdown
- [ ] Dependency size analysis
- [ ] Automated optimization suggestions
- [ ] Integration with Flutter DevTools

