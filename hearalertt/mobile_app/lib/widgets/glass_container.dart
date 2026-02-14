import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';

/// Premium Glass Container with modern frosted effect and liquid animations
class GlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final bool glow;
  final Color? glowColor;
  final VoidCallback? onTap;
  final bool liquidEffect;
  final bool rippleOnTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 25.0,  // Increased for stronger glass effect
    this.opacity = 0.12,  // Increased for more visible frosted glass
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.gradient,
    this.glow = false,
    this.glowColor,
    this.onTap,
    this.liquidEffect = true,  // ENABLED BY DEFAULT for liquid theme
    this.rippleOnTap = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),  // Increased for smoother liquid flow
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.rippleOnTap) {
      _rippleController.forward(from: 0.0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLG);
    final effectiveColor = widget.color ?? Colors.white;
    final responsiveBlur = AppTheme.responsiveBlur(context, widget.blur);
    
    Widget content = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.liquidEffect ? responsiveBlur * 1.5 : responsiveBlur,
          sigmaY: widget.liquidEffect ? responsiveBlur * 1.5 : responsiveBlur,
        ),
        child: AnimatedContainer(
          duration: AppTheme.liquidFast,
          curve: Curves.easeInOutCubic,
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(AppTheme.spaceMD),
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            color: effectiveColor.withOpacity(widget.opacity),
            gradient: widget.gradient ?? (widget.liquidEffect 
              ? AppTheme.liquidFlow(
                  start: effectiveColor,
                  end: effectiveColor.withOpacity(0.5),
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveColor.withOpacity(widget.opacity + 0.05),
                    effectiveColor.withOpacity(widget.opacity),
                  ],
                )),
            border: Border.all(
              color: widget.liquidEffect
                  ? Colors.white.withOpacity(0.3)  // Increased from 0.2
                  : Colors.white.withOpacity(0.15), // Increased from 0.1
              width: widget.liquidEffect ? 2 : 1.5,  // Increased width
            ),
            boxShadow: widget.glow ? [
              BoxShadow(
                color: (widget.glowColor ?? AppTheme.primary).withOpacity(0.4),
                blurRadius: 28,
                spreadRadius: -3,
              ),
              if (widget.liquidEffect)
                BoxShadow(
                  color: (widget.glowColor ?? AppTheme.primary).withOpacity(0.15),
                  blurRadius: 45,
                  spreadRadius: -1,
                ),
            ] : [
              // Add subtle shadow even without glow for depth
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: _handleTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: content,
      );
    }

    if (widget.margin != null) {
      content = Padding(padding: widget.margin!, child: content);
    }

    return content;
  }
}

/// Legacy compatibility wrapper
class TectonicGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Gradient? borderGradient;
  final bool isGlowing;
  final bool frosted;

  const TectonicGlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.08,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.borderGradient,
    this.isGlowing = false,
    this.frosted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: frosted ? blur + 10 : blur,
      opacity: frosted ? opacity + 0.05 : opacity,
      width: width,
      height: height,
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      glow: isGlowing,
      child: child,
    );
  }
}

/// Gradient Button with glow effect
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Gradient? gradient;
  final IconData? icon;
  final bool loading;
  final double? width;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradient,
    this.icon,
    this.loading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient ?? AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.glow(AppTheme.primary, intensity: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Indicator Pill
class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final bool active;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.text,
    required this.color,
    this.active = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: active ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? color : AppTheme.textMuted,
                shape: BoxShape.circle,
                boxShadow: active ? [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 6,
                  ),
                ] : null,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
