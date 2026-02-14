import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/glass_container.dart';

/// "I'm Deaf" Communication Card - Shows a clear message to others
class DeafCommunicationCard extends StatelessWidget {
  final VoidCallback? onClose;
  
  const DeafCommunicationCard({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.glowShadow(AppTheme.info, intensity: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          if (onClose != null)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                ),
              ),
            ),
          
          // Deaf Symbol
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.ear,
              color: Color(0xFF1E40AF),
              size: 48,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Main Text - Large and Clear
          Text(
            "I'm Deaf",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Please communicate by:",
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Communication Methods
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _CommunicationChip(icon: LucideIcons.penTool, label: "Writing"),
              _CommunicationChip(icon: LucideIcons.smartphone, label: "Typing"),
              _CommunicationChip(icon: LucideIcons.hand, label: "Gestures"),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Thank You
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Thank you for your patience 💙",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}

class _CommunicationChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CommunicationChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF1E40AF), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF1E40AF),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Emergency SOS Button with countdown
class EmergencySOSButton extends StatefulWidget {
  final VoidCallback onActivate;
  
  const EmergencySOSButton({super.key, required this.onActivate});

  @override
  State<EmergencySOSButton> createState() => _EmergencySOSButtonState();
}

class _EmergencySOSButtonState extends State<EmergencySOSButton> {
  bool _isPressed = false;
  int _countdown = 3;
  
  void _startCountdown() {
    setState(() {
      _isPressed = true;
      _countdown = 3;
    });
    _countDown();
  }
  
  void _countDown() async {
    while (_isPressed && _countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isPressed && mounted) {
        setState(() => _countdown--);
      }
    }
    if (_isPressed && _countdown == 0 && mounted) {
      widget.onActivate();
      setState(() => _isPressed = false);
    }
  }
  
  void _cancelCountdown() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startCountdown(),
      onTapUp: (_) => _cancelCountdown(),
      onTapCancel: _cancelCountdown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: _isPressed ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPressed 
                ? [const Color(0xFFDC2626), const Color(0xFFB91C1C)]
                : [AppTheme.error, AppTheme.error.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(_isPressed ? 0.6 : 0.4),
              blurRadius: _isPressed ? 30 : 20,
              spreadRadius: _isPressed ? 5 : 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPressed ? LucideIcons.loader : LucideIcons.alertTriangle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _isPressed ? "Release to cancel" : "HOLD FOR SOS",
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            if (_isPressed) ...[
              const SizedBox(height: 12),
              Text(
                "Sending in $_countdown...",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Visual Sound Indicator - Large animated display
class VisualSoundIndicator extends StatelessWidget {
  final double amplitude;
  final bool isListening;
  final String? detectedSound;
  final String? soundType; // 'emergency', 'warning', 'info'

  const VisualSoundIndicator({
    super.key,
    required this.amplitude,
    required this.isListening,
    this.detectedSound,
    this.soundType,
  });

  @override
  Widget build(BuildContext context) {
    Color indicatorColor = AppTheme.primary;
    if (soundType == 'emergency') indicatorColor = AppTheme.error;
    if (soundType == 'warning') indicatorColor = AppTheme.warning;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            indicatorColor.withOpacity(0.15),
            indicatorColor.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: indicatorColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Sound Level Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final barHeight = 20.0 + (amplitude * 60 * (1 - (index - 3).abs() / 4));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: barHeight.clamp(8.0, 80.0),
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(
                target: isListening ? 1 : 0,
              ).scale(
                begin: const Offset(1, 0.3),
                end: const Offset(1, 1),
                duration: 200.ms,
              );
            }),
          ),
          
          const SizedBox(height: 20),
          
          // Status Text
          Text(
            detectedSound?.toUpperCase() ?? (isListening ? "LISTENING..." : "PAUSED"),
            style: GoogleFonts.spaceGrotesk(
              fontSize: detectedSound != null ? 24 : 16,
              fontWeight: FontWeight.w700,
              color: indicatorColor,
              letterSpacing: 2,
            ),
          ),
          
          if (detectedSound != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: indicatorColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                soundType == 'emergency' ? "⚠️ URGENT - TAKE ACTION" : "DETECTED",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: indicatorColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Priority Mode Selector (Home, Street, Work modes)
class PriorityModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  const PriorityModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      const _PriorityMode('home', LucideIcons.home, 'Home',
          'Baby cries, Door knocks, Alarms'),
      const _PriorityMode('street', LucideIcons.car, 'Street',
          'Vehicle horns, Sirens, Traffic'),
      const _PriorityMode('work', LucideIcons.briefcase, 'Work',
          'Alarms, Conversations, Phones'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.filter, color: AppTheme.textMuted, size: 16),
            const SizedBox(width: 8),
            Text(
              "PRIORITY MODE",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: modes.map((mode) {
            final isSelected = selectedMode == mode.id;
            return Expanded(
              child: GestureDetector(
                onTap: () => onModeChanged(mode.id),
                child: Container(
                  margin: EdgeInsets.only(right: mode.id != 'work' ? 8 : 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primary.withOpacity(0.15)
                        : AppTheme.elevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.subtle,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        mode.icon,
                        color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mode.label,
                        style: GoogleFonts.inter(
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedMode.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            modes.firstWhere((m) => m.id == selectedMode).description,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _PriorityMode {
  final String id;
  final IconData icon;
  final String label;
  final String description;

  const _PriorityMode(this.id, this.icon, this.label, this.description);
}

/// Quick Action FAB for Deaf Card
class DeafCardFAB extends StatelessWidget {
  final VoidCallback onTap;

  const DeafCardFAB({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: AppTheme.glowShadow(AppTheme.info),
        ),
        child: const Icon(
          LucideIcons.ear,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

/// Accessibility Settings Section
class AccessibilitySettingsSection extends StatelessWidget {
  final bool highContrast;
  final bool largeText;
  final bool screenFlash;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onScreenFlashChanged;

  const AccessibilitySettingsSection({
    super.key,
    required this.highContrast,
    required this.largeText,
    required this.screenFlash,
    required this.onHighContrastChanged,
    required this.onLargeTextChanged,
    required this.onScreenFlashChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AccessibilityTile(
            icon: LucideIcons.contrast,
            title: "High Contrast",
            subtitle: "Increase visual clarity",
            value: highContrast,
            onChanged: onHighContrastChanged,
          ),
          const Divider(color: AppTheme.subtle, height: 24),
          _AccessibilityTile(
            icon: LucideIcons.type,
            title: "Large Text",
            subtitle: "Bigger fonts throughout",
            value: largeText,
            onChanged: onLargeTextChanged,
          ),
          const Divider(color: AppTheme.subtle, height: 24),
          _AccessibilityTile(
            icon: LucideIcons.smartphone,
            title: "Screen Flash",
            subtitle: "Flash screen on alerts",
            value: screenFlash,
            onChanged: onScreenFlashChanged,
          ),
        ],
      ),
    );
  }
}

class _AccessibilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AccessibilityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
      ],
    );
  }
}
