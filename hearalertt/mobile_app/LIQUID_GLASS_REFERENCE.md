# Liquid Glass Theme - Quick Reference

## 🎨 Core Components

### GlassCard (Enhanced)
```dart
GlassCard(
  liquidEffect: true,      // Enable liquid mode
  blur: AppTheme.blurMedium,
  glow: true,
  rippleOnTap: true,
  onTap: () {},
  child: content,
)
```

### LiquidGlassContainer
```dart
LiquidGlassContainer(
  blurIntensity: AppTheme.blurStrong,
  flowingGradient: true,
  shimmer: true,
  glow: true,
  child: content,
)
```

### LiquidButton
```dart
LiquidButton(
  text: 'Button',
  icon: Icons.star,
  liquidEffect: true,
  onTap: () {},
)
```

---

## 🌊 Animations

```dart
LiquidGradientFlow() // Flowing gradient
RippleEffect()       // Touch ripple
MorphingContainer()  // Shape transitions
LiquidShimmer()      // Shimmer effect
DepthLayer()         // 3D depth
PulsatingGlow()      // Glow pulse
LiquidLoadingIndicator() // Wave loader
```

---

## 📐 Responsive Utilities

```dart
// Breakpoints
Responsive.isMobile(context)
Responsive.isTablet(context)
Responsive.isDesktop(context)

// Adaptive Values
Responsive.value(context, mobile: 16, tablet: 20, desktop: 24)
Responsive.fontSize(context, 16)
Responsive.spacing(context, 24)
Responsive.blurIntensity(context, 20)

// Layouts
ResponsiveContainer()
ResponsiveGrid()
ResponsiveFlex()
```

---

## 🎭 Theme Tokens

```dart
// Blur Levels
AppTheme.blurSoft     // 10px
AppTheme.blurMedium   // 20px
AppTheme.blurStrong   // 35px
AppTheme.blurLiquid   // 50px

// Durations
AppTheme.liquidFast   // 200ms
AppTheme.liquidMedium // 400ms
AppTheme.liquidSlow   // 600ms
AppTheme.liquidFlow   // 2000ms

// Helpers
AppTheme.liquidOverlay(0.1)
AppTheme.liquidFlow(start: color1, end: color2)
AppTheme.responsiveBlur(context, 20)
```

---

## 🚀 Quick Start

1. **Use GlassCard for containers**:
   ```dart
   GlassCard(liquidEffect: true, child: content)
   ```

2. **Add responsive sizing**:
   ```dart
   padding: Responsive.padding(context, all: 16)
   ```

3. **Use Liquid Buttons**:
   ```dart
   LiquidButton(text: 'Click', onTap: () {})
   ```

4. **Add animated backgrounds**:
   ```dart
   AuroraBackground(animate: true)
   ```

---

## 📱 Responsive Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600-1200px
- **Desktop**: > 1200px

---

## ✨ Key Files

- `lib/theme/app_theme.dart` - Theme tokens
- `lib/widgets/liquid_glass_widgets.dart` - Main components
- `lib/widgets/liquid_animations.dart` - Animations
- `lib/widgets/responsive_layout.dart` - Responsive utilities
- `lib/examples/liquid_glass_showcase.dart` - Live examples
