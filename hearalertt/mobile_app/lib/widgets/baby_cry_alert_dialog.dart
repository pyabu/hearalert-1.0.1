import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/baby_cry_models.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/theme/app_theme.dart';

/// Full-screen baby cry alert dialog with liquid glass theme
class BabyCryAlertDialog extends StatelessWidget {
  final BabyCryPrediction prediction;
  
  const BabyCryAlertDialog({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiquidGlassContainer(
            blurStrength: 40,
            opacity: 0.2,
            border: true,
            glow: true,
            glowColor: _getPriorityColor(),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _getPriorityColor().withOpacity(0.5),
                        _getPriorityColor().withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.glow(_getPriorityColor(), intensity: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      prediction.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Category Label
                Text(
                  prediction.label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    shadows: AppTheme.glow(_getPriorityColor()),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Message
                Text(
                  prediction.message,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Confidence
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.glassLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(prediction.confidence * 100).toStringAsFixed(0)}% Match',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: LiquidGlassContainer(
                        onTap: () {
                          context.read<SoundProvider>().clearBabyCryAlert();
                          Navigator.of(context).pop();
                        },
                        opacity: 0.1,
                        child: Center(
                          child: Text(
                            "DISMISS",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LiquidGlassContainer(
                        onTap: () {
                          context.read<SoundProvider>().clearBabyCryAlert();
                          Navigator.of(context).pop();
                        },
                        tint: _getPriorityColor(),
                        opacity: 0.3,
                        glow: true,
                        glowColor: _getPriorityColor(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.check, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "ACKNOWLEDGE",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    if (prediction.isHighPriority) return AppTheme.danger;
    if (prediction.isMediumPriority) return AppTheme.warning;
    return AppTheme.info;
  }
}
