# Performance Guidelines

This document outlines performance best practices and guidelines for the Mara mobile application.

## Overview

Performance is critical for user experience. We aim to maintain:
- **App Cold Start:** P95 < 3 seconds
- **Screen Open Time:** P95 < 2 seconds
- **Frame Rendering:** 60 FPS consistently
- **Memory Usage:** < 200MB typical usage

## Performance Metrics

### SLO Targets

| Metric | Target (P95) | Critical Threshold |
|--------|-------------|-------------------|
| App Cold Start | < 3s | > 5s |
| Chat Screen Open | < 2s | > 4s |
| Screen Render | < 1s | > 2s |
| Memory Usage | < 200MB | > 400MB |

### Measurement

Performance metrics are tracked via:
- **Firebase Analytics:** Custom SLO events (`app_cold_start`, `chat_screen_open`)
- **Sentry Performance:** Transaction monitoring
- **Flutter DevTools:** Profiling and memory analysis

## Best Practices

### Widget Optimization

1. **Use `const` constructors** where possible
   ```dart
   const Text('Hello')  // ✅ Good
   Text('Hello')        // ❌ Avoid
   ```

2. **Minimize widget rebuilds**
   ```dart
   // Use const widgets
   const SizedBox(height: 16)
   
   // Extract widgets to prevent unnecessary rebuilds
   class OptimizedWidget extends StatelessWidget {
     const OptimizedWidget({super.key});
     // ...
   }
   ```

3. **Use `ListView.builder` for long lists**
   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => ItemWidget(items[index]),
   )
   ```

### Image Optimization

1. **Use appropriate image formats**
   - PNG for icons and simple graphics
   - JPEG for photos
   - WebP for complex images (when supported)

2. **Resize images before including in assets**
   - Don't include full-resolution images
   - Use appropriate sizes for display

3. **Lazy load images**
   ```dart
   Image.network(
     url,
     loadingBuilder: (context, child, progress) {
       return progress == null ? child : CircularProgressIndicator();
     },
   )
   ```

### State Management

1. **Use Riverpod efficiently**
   ```dart
   // ✅ Good: Only rebuilds when needed
   final userProvider = StateProvider<User?>((ref) => null);
   
   // ❌ Avoid: Unnecessary rebuilds
   final allDataProvider = StateProvider<AllData>((ref) => AllData());
   ```

2. **Minimize provider scope**
   - Use `ProviderScope` at appropriate level
   - Don't put everything in global scope

### Network Optimization

1. **Cache API responses**
   - Use local cache for offline support
   - Implement cache invalidation strategy

2. **Batch API calls**
   - Combine multiple requests when possible
   - Use pagination for large datasets

3. **Implement retry logic**
   - Use exponential backoff
   - Limit retry attempts

### Memory Management

1. **Dispose resources**
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     _subscription.cancel();
     super.dispose();
   }
   ```

2. **Avoid memory leaks**
   - Don't hold references to large objects
   - Clear caches periodically
   - Use weak references when appropriate

3. **Monitor memory usage**
   - Use Flutter DevTools memory profiler
   - Check for memory leaks in tests

## Performance Testing

### Benchmarks

Run performance benchmarks:
```bash
flutter test test/performance/performance_test.dart
```

### Profiling

1. **Use Flutter DevTools**
   ```bash
   flutter run --profile
   # Open DevTools and use Performance tab
   ```

2. **Analyze frame rendering**
   - Check for jank (frames > 16ms)
   - Identify expensive widgets
   - Optimize hot paths

3. **Memory profiling**
   - Use DevTools Memory tab
   - Check for memory leaks
   - Monitor heap size

## Performance Monitoring

### Production Monitoring

- **Firebase Analytics:** Track SLO metrics
- **Sentry Performance:** Monitor transaction durations
- **Crash Reports:** Identify performance-related crashes

### Alerting

Alerts trigger when:
- App cold start P95 > 3s
- Screen open time P95 > 2s
- Memory usage > 400MB
- Frame rate drops below 55 FPS

## Performance Checklist

Before releasing:

- [ ] App cold start < 3s (P95)
- [ ] All screens open < 2s (P95)
- [ ] No jank in animations
- [ ] Memory usage < 200MB typical
- [ ] Images optimized and cached
- [ ] Network requests batched/cached
- [ ] Widget rebuilds minimized
- [ ] Performance benchmarks pass

## Common Performance Issues

### Issue: Slow App Startup

**Causes:**
- Heavy initialization in `main()`
- Large asset loading
- Synchronous network calls

**Solutions:**
- Lazy load heavy resources
- Use async initialization
- Optimize asset sizes

### Issue: Janky Animations

**Causes:**
- Expensive widget rebuilds
- Heavy computations on UI thread
- Large widget trees

**Solutions:**
- Use `RepaintBoundary` widgets
- Move computations off UI thread
- Optimize widget tree depth

### Issue: High Memory Usage

**Causes:**
- Memory leaks
- Large image caches
- Unclosed streams/controllers

**Solutions:**
- Properly dispose resources
- Limit cache sizes
- Use memory profiler to identify leaks

## Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Performance Monitoring](https://docs.flutter.dev/perf/monitoring)
- [Frontend SLOs](FRONTEND_SLOS.md)

---

**Last Updated:** December 2025

