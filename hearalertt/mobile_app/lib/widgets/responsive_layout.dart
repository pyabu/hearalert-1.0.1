import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities
class Responsive {
  // Breakpoints
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  /// Check if screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Check if screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Responsive.desktop) return desktop ?? tablet ?? mobile;
    if (width >= Responsive.tablet) return tablet ?? mobile;
    return mobile;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double base) {
    return value(
      context,
      mobile: base * 0.95,
      tablet: base * 1.05,
      desktop: base * 1.15,
    );
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double base) {
    return value(
      context,
      mobile: base,
      tablet: base * 1.2,
      desktop: base * 1.5,
    );
  }

  /// Get responsive padding
  static EdgeInsets padding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(spacing(context, all));
    }
    return EdgeInsets.symmetric(
      horizontal: spacing(context, horizontal ?? 16),
      vertical: spacing(context, vertical ?? 16),
    );
  }

  /// Get responsive blur intensity
  static double blurIntensity(BuildContext context, double base) {
    // Reduce blur on smaller screens for better clarity
    return isMobile(context) ? base * 0.7 : base;
  }

  /// Get orientation-aware value
  static T orientation<T>(
    BuildContext context, {
    required T portrait,
    required T landscape,
  }) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? portrait
        : landscape;
  }

  /// Minimum touch target size (44x44dp for accessibility)
  static const double minTouchTarget = 44.0;

  /// Ensure widget meets minimum touch target requirements
  static Widget touchTarget({
    required Widget child,
    double minSize = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}

/// Responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? Responsive.padding(context, all: 16),
      constraints: maxWidth != null
          ? BoxConstraints(maxWidth: maxWidth!)
          : null,
      child: child,
    );
  }
}

/// Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.value(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio ?? 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive row/column that switches based on screen size
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool switchOnTablet;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.switchOnTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final useColumn = switchOnTablet
        ? (Responsive.isMobile(context) || Responsive.isTablet(context))
        : Responsive.isMobile(context);

    if (useColumn) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
