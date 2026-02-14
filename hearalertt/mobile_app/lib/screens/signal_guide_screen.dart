import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/widgets/liquid_background.dart';

class SignalGuideScreen extends StatelessWidget {
  const SignalGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LiquidGlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: 12,
            onTap: () => Navigator.pop(context),
            child: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary, size: 20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Signal Guide",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          const LiquidBackground(subtle: true),
          SafeArea(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    const signals = [
      _SignalInfo(
        title: "Fire Alarm",
        icon: LucideIcons.flame,
        color: AppTheme.danger,
        vibrationPattern: "Long • Long • Long",
        flashPattern: "Rapid continuous",
        description: "Urgent alert for fire or smoke detection",
      ),
      _SignalInfo(
        title: "Door Knock",
        icon: LucideIcons.doorOpen,
        color: AppTheme.warning,
        vibrationPattern: "Short • Short • Pause",
        flashPattern: "Double flash",
        description: "Someone is at your door",
      ),
      _SignalInfo(
        title: "Baby Cry",
        icon: LucideIcons.baby,
        color: AppTheme.accentPink,
        vibrationPattern: "Pulse • Pulse • Pulse",
        flashPattern: "Gentle pulse",
        description: "Baby needs attention",
      ),
      _SignalInfo(
        title: "Glass Break",
        icon: LucideIcons.glassWater,
        color: AppTheme.danger,
        vibrationPattern: "Sharp • Sharp • Long",
        flashPattern: "Strobe effect",
        description: "Glass breaking detected",
      ),
      _SignalInfo(
        title: "Vehicle Horn",
        icon: LucideIcons.megaphone,
        color: AppTheme.secondary,
        vibrationPattern: "Medium • Medium",
        flashPattern: "Double flash",
        description: "Vehicle horn nearby",
      ),
      _SignalInfo(
        title: "Dog Bark",
        icon: LucideIcons.dog,
        color: AppTheme.info,
        vibrationPattern: "Short bursts",
        flashPattern: "Quick blinks",
        description: "Dog barking detected",
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        return _SignalCard(signal: signal, index: index);
      },
    );
  }
}

class _SignalInfo {
  final String title;
  final IconData icon;
  final Color color;
  final String vibrationPattern;
  final String flashPattern;
  final String description;

  const _SignalInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.vibrationPattern,
    required this.flashPattern,
    required this.description,
  });
}

class _SignalCard extends StatelessWidget {
  final _SignalInfo signal;
  final int index;

  const _SignalCard({required this.signal, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: signal.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(signal.icon, color: signal.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signal.title,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    signal.description,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PatternChip(
                        icon: LucideIcons.vibrate,
                        text: signal.vibrationPattern,
                      ),
                      _PatternChip(
                        icon: LucideIcons.flashlight,
                        text: signal.flashPattern,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (40 * index).ms).fadeIn().slideY(begin: 0.06, end: 0);
  }
}

class _PatternChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PatternChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.glassHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
