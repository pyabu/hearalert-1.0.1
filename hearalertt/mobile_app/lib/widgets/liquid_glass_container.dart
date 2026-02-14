import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';

/// Premium Liquid Glass Container with refined frosted glass effect
/// 
/// Features:
/// - Multi-layer backdrop blur
/// - Subtle inner glow
/// - Premium border gradient
/// - Smooth press animations
/// - Optimized performance
class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurStrength;
  final double opacity;
  final bool glow;
  final Color? glowColor;
  final bool border;
  final Color? tint;
  final VoidCallback? onTap;
  final bool enablePressEffect;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppTheme.spaceMD),
    this.margin,
    this.borderRadius = AppTheme.radiusMD,
    this.blurStrength = AppTheme.blurStandard,
    this.opacity = AppTheme.opacityGlassMedium,
    this.glow = false,
    this.glowColor,
    this.border = true,
    this.tint,
    this.onTap,
    this.enablePressEffect = true,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enablePressEffect || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enablePressEffect) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enablePressEffect) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBlur = AppTheme.responsiveBlur(context, widget.blurStrength);
    final effectiveTint = widget.tint ?? AppTheme.glassLow;
    
    Widget content = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      child: widget.child,
    );

    // Wrap with InkWell if tappable
    if (widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          highlightColor: AppTheme.primary.withOpacity(0.08),
          splashColor: AppTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: content,
        ),
      );
    }

    Widget glassContainer = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.glow 
            ? AppTheme.glow(widget.glowColor ?? AppTheme.primary, intensity: 0.5) 
            : AppTheme.elevation(level: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            decoration: BoxDecoration(
              color: effectiveTint.withOpacity(widget.opacity),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.border 
                  ? Border.all(
                      color: Colors.white.withOpacity(_isPressed ? 0.18 : 0.12), 
                      width: 1.0,
                    ) 
                  : null,
            ),
            child: Stack(
              children: [
                // Premium top-left light reflection
                if (widget.border)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.borderRadius),
                          topRight: Radius.circular(widget.borderRadius),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.7],
                        ),
                      ),
                    ),
                  ),
                
                // Content
                content,
              ],
            ),
          ),
        ),
      ),
    );

    // Apply press animation
    if (widget.onTap != null && widget.enablePressEffect) {
      glassContainer = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: glassContainer,
        ),
      );
    }

    return glassContainer;
  }
}
