import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Professional Design System for HearAlert
/// 
/// Features:
/// - Refined Aurora Color Palette (Deep Space + Balanced Neon Accents)
/// - Sophisticated Liquid Glass Tokens
/// - Premium Typography (Space Grotesk + Inter)
/// - Professional Shadow & Glow System
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════
  // REFINED AURORA PALETTE
  // ═══════════════════════════════════════════════════════════════════
  
  // Backgrounds - Refined deep tones with subtle warmth
  static const Color void_ = Color(0xFF06060F);          // Deep space black
  static const Color surface = Color(0xFF0E0E1C);        // Primary surface
  static const Color surfaceElevated = Color(0xFF14142A); // Elevated surface
  static const Color glassLow = Color(0xFF181838);       // Subtle glass tint
  static const Color glassHigh = Color(0xFF222250);      // Stronger glass tint
  
  // Primary - Premium Violet Spectrum
  static const Color primary = Color(0xFF8B5CF6);        // Balanced Violet
  static const Color primaryLight = Color(0xFFA78BFA);   // Light Violet / Glow
  static const Color primaryDark = Color(0xFF6D28D9);    // Deep Violet
  static const Color primaryMuted = Color(0xFF4C1D95);   // Muted Violet
  
  // Secondary - Refined Turquoise & Cyan
  static const Color secondary = Color(0xFF06D6A0);      // Premium Cyan/Turquoise
  static const Color secondaryLight = Color(0xFF6EE7B7); // Light Cyan
  static const Color secondaryDark = Color(0xFF059669);  // Deep Teal
  static const Color secondaryMuted = Color(0xFF065F46); // Muted Teal

  // Accents - Refined Hot Colors
  static const Color accentPink = Color(0xFFEC4899);     // Soft Hot Pink
  static const Color accentYellow = Color(0xFFFBBF24);   // Warm Amber
  static const Color accentOrange = Color(0xFFF97316);   // Vibrant Orange
  
  // Semantic Colors - Refined
  static const Color danger = Color(0xFFEF4444);         // Clear Red
  static const Color warning = Color(0xFFF59E0B);        // Warm Amber
  static const Color success = Color(0xFF10B981);        // Balanced Green
  static const Color info = Color(0xFF0EA5E9);           // Clear Sky Blue
  
  // Text Colors - Better contrast hierarchy
  static const Color textPrimary = Color(0xFFF9FAFB);    // Near White
  static const Color textSecondary = Color(0xFF9CA3AF);  // Balanced Gray
  static const Color textMuted = Color(0xFF6B7280);      // Muted Gray
  static const Color textDisabled = Color(0xFF4B5563);   // Disabled Gray
  
  // ═══════════════════════════════════════════════════════════════════
  // PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // Violet
      Color(0xFFEC4899), // Pink
      Color(0xFFF59E0B), // Amber
      Color(0xFF06D6A0), // Cyan
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.65, 1.0],
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [void_, surface],
  );
  
  // Glass Border Gradient - Premium edge lighting
  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 0.25),
      Color.fromRGBO(255, 255, 255, 0.08),
      Color.fromRGBO(255, 255, 255, 0.03),
      Color.fromRGBO(255, 255, 255, 0.10),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════
  // LIQUID GLASS TOKENS
  // ═══════════════════════════════════════════════════════════════════

  // Blur Strengths
  static const double blurSubtle = 8.0;
  static const double blurStandard = 16.0;
  static const double blurHeavy = 32.0;
  static const double blurExtreme = 48.0;
  
  // Glass Opacities
  static const double opacityGlassLow = 0.04;
  static const double opacityGlassMedium = 0.08;
  static const double opacityGlassHigh = 0.16;
  
  // Border Radii - Refined scale
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusFull = 999.0;
  
  // Spacing Scale - 4px base
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;
  static const double space3XL = 64.0;

  // ═══════════════════════════════════════════════════════════════════
  // ANIMATION TOKENS
  // ═══════════════════════════════════════════════════════════════════

  static const Duration liquidFast = Duration(milliseconds: 200);
  static const Duration liquidMedium = Duration(milliseconds: 400);
  static const Duration liquidSlow = Duration(milliseconds: 800);
  static const Duration liquidSlowExtra = Duration(milliseconds: 1200);

  // ═══════════════════════════════════════════════════════════════════
  // RESPONSIVE UTILITIES
  // ═══════════════════════════════════════════════════════════════════

  static double responsiveBlur(BuildContext context, double baseBlur) {
    double width = MediaQuery.of(context).size.width;
    if (width < 400) return baseBlur * 0.5; // Mobile performance
    if (width < 600) return baseBlur * 0.7;
    return baseBlur;
  }

  static LinearGradient liquidFlow({
    required Color start,
    required Color end,
  }) {
    return LinearGradient(
      colors: [start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PREMIUM GLOW & SHADOW SYSTEM
  // ═══════════════════════════════════════════════════════════════════
  
  // Multi-layer glow for premium depth
  static List<BoxShadow> glow(Color color, {double intensity = 1.0}) => [
    BoxShadow(
      color: color.withOpacity(0.35 * intensity),
      blurRadius: 16,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: color.withOpacity(0.20 * intensity),
      blurRadius: 32,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: color.withOpacity(0.10 * intensity),
      blurRadius: 48,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get neonGlow => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: secondary.withOpacity(0.2),
      blurRadius: 48,
      spreadRadius: -8,
    ),
  ];
  
  // Subtle elevation shadow
  static List<BoxShadow> elevation({double level = 1.0}) => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15 * level),
      blurRadius: 8 * level,
      offset: Offset(0, 2 * level),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08 * level),
      blurRadius: 16 * level,
      offset: Offset(0, 4 * level),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // THEME DATA FACTORY
  // ═══════════════════════════════════════════════════════════════════
  
  static ThemeData create(Color seedColor, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: void_,
      
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accentPink,
        surface: surface,
        onSurface: textPrimary,
        error: danger,
      ),
      
      // Premium Typography
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1.5, color: textPrimary, height: 1.1
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0, color: textPrimary, height: 1.2
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary, height: 1.2
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary, height: 1.4
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: textMuted, height: 1.5
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.5
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.5
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 1.0
        ),
      ),
      
      // Component Themes
      cardTheme: CardThemeData(
        color: glassLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMD)),
        margin: EdgeInsets.zero,
      ),
      
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceSM),
      ),
      
      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSM)),
        ),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withOpacity(0.3);
          return glassHigh;
        }),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: glassHigh,
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.2),
        trackHeight: 4,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LEGACY COMPATIBILITY
  // ═══════════════════════════════════════════════════════════════════
  
  static const Color tectonicVoid = void_;
  static const Color tectonicSurface = surface;
  static const Color tectonicGlass = glassLow;
  static const Color tectonicBlue = secondary;
  static const Color tectonicPurple = primary;
  static const Color primaryNeon = primaryLight;
  static const Color secondaryNeon = secondaryLight;
  static const Color errorNeon = danger;
  static const Color successNeon = success;
  static const Color subtle = Color(0x1FFFFFFF);
  static const Color error = danger;
  static const Color accent = accentPink;
  static const Color elevated = surfaceElevated;
  static const Color tertiary = accentYellow;
  static const double blurStrong = blurHeavy;
  
  static List<BoxShadow> glowShadow(Color color, {double intensity = 1.0}) {
    return glow(color, intensity: intensity);
  }
  
  static List<BoxShadow> softGlow(Color color) {
    return glow(color, intensity: 0.3);
  }
}
