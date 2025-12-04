# Mara Design System

This document describes the design system used in the Mara mobile application, aligned with the Figma design system.

## Overview

The Mara app follows a consistent design system for colors, typography, spacing, and components to ensure a cohesive user experience.

## Colors

### Primary Colors

- **Primary Blue:** `#0EA5C6` - Main brand color
- **Primary Blue Dark:** `#10A9CC` - Darker variant
- **Background:** `#FFFFFF` - Main background
- **Surface:** `#F8F9FA` - Card/surface background

### Semantic Colors

- **Success:** Green tones for success states
- **Error:** Red tones for error states
- **Warning:** Orange/yellow tones for warnings
- **Info:** Blue tones for informational messages

### Usage

Colors are defined in `lib/core/theme/app_theme.dart`. Use theme colors rather than hardcoded values.

## Typography

### Font Families

- **Primary:** System default (San Francisco on iOS, Roboto on Android)
- **Monospace:** For code or technical content

### Font Sizes

- **Display:** Large headings (24-32sp)
- **Headline:** Section headings (20-24sp)
- **Title:** Screen titles (18-20sp)
- **Body:** Regular text (14-16sp)
- **Caption:** Small text (12-14sp)
- **Label:** Button labels (14-16sp)

### Font Weights

- **Regular:** 400
- **Medium:** 500
- **Semi-Bold:** 600
- **Bold:** 700

## Spacing

### Standard Spacing Scale

- **XS:** 4dp
- **S:** 8dp
- **M:** 16dp
- **L:** 24dp
- **XL:** 32dp
- **XXL:** 48dp

### Usage

Use consistent spacing throughout the app. Prefer theme spacing constants over magic numbers.

## Components

### Buttons

- **Primary Button:** Filled button with primary color
- **Secondary Button:** Outlined button
- **Text Button:** Text-only button
- **Icon Button:** Icon-only button

### Cards

- **Elevation:** 2dp for standard cards
- **Border Radius:** 8-12dp
- **Padding:** 16dp

### Input Fields

- **Height:** 48-56dp
- **Border Radius:** 8dp
- **Padding:** 16dp horizontal

### Navigation

- **Bottom Navigation:** Fixed at bottom, 56dp height
- **App Bar:** Standard Material AppBar
- **Drawer:** Side navigation drawer

## Icons

### Icon Library

- **Material Symbols Icons:** Primary icon library
- **Custom Icons:** Located in `assets/icons/`

### Icon Sizes

- **Small:** 16-20dp
- **Medium:** 24dp
- **Large:** 32-40dp

## Accessibility

### Text Contrast

- Ensure WCAG AA contrast ratios (4.5:1 for normal text)
- Test with accessibility tools

### Touch Targets

- Minimum touch target: 44x44dp (iOS) / 48x48dp (Android)
- Adequate spacing between interactive elements

### Screen Reader Support

- Use semantic labels
- Provide meaningful descriptions
- Test with screen readers

## Responsive Design

### Breakpoints

- **Mobile:** < 600dp width
- **Tablet:** 600-840dp width
- **Desktop:** > 840dp width (if supported)

### Layout Guidelines

- Use `MediaQuery` for responsive layouts
- Test on multiple screen sizes
- Support both portrait and landscape (where applicable)

## Dark Mode

### Color Scheme

- Dark mode colors defined in theme
- Ensure sufficient contrast in dark mode
- Test all screens in both light and dark modes

## Localization

### Supported Languages

- English (en)
- Arabic (ar) - RTL support

### RTL Considerations

- Use `Directionality` widget where needed
- Test layouts in RTL languages
- Ensure icons and images flip appropriately

## Animation

### Duration

- **Fast:** 150-200ms
- **Normal:** 250-300ms
- **Slow:** 400-500ms

### Easing

- **Standard:** `Curves.easeInOut`
- **Enter:** `Curves.easeOut`
- **Exit:** `Curves.easeIn`

## Implementation

### Theme Usage

```dart
// Use theme colors
Theme.of(context).colorScheme.primary

// Use theme text styles
Theme.of(context).textTheme.headlineSmall

// Use theme spacing
Theme.of(context).spacing.medium
```

### Component Guidelines

- Reuse existing components from `lib/core/widgets/`
- Create new components following existing patterns
- Document component usage and props

## Resources

- **Figma Design System:** [Link to Figma file]
- **Material Design:** https://material.io/design
- **Flutter Material Components:** https://flutter.dev/docs/development/ui/widgets/material

## Updates

This design system is a living document. Update it when:
- New components are added
- Design patterns change
- New guidelines are established

