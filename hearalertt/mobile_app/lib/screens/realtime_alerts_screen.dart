import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';

class RealtimeAlertsScreen extends StatelessWidget {
  const RealtimeAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: 28),
                _buildMainControls(context),
                const SizedBox(height: 32),
                _buildTestSoundsSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Controls",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Manage alerts and test sounds",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.04, end: 0);
  }

  Widget _buildMainControls(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FlashlightCard()),
        const SizedBox(width: 14),
        Expanded(child: _ListeningCard()),
        const SizedBox(width: 14),
        Expanded(child: _ScreenAlertsCard()),
      ],
    );
  }

  Widget _buildTestSoundsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TEST SOUNDS",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: const [
            _TestCard(label: "Fire Alarm", icon: LucideIcons.flame, color: AppTheme.danger),
            _TestCard(label: "Door Knock", icon: LucideIcons.doorOpen, color: AppTheme.warning),
            _TestCard(label: "Glass Break", icon: LucideIcons.glassWater, color: AppTheme.danger),
            _TestCard(label: "Doorbell", icon: LucideIcons.bellRing, color: AppTheme.warning),
            _TestCard(label: "Baby Cry", icon: LucideIcons.baby, color: AppTheme.accentPink),
            _TestCard(label: "Vehicle Horn", icon: LucideIcons.megaphone, color: AppTheme.secondary),
            _TestCard(label: "Dog Bark", icon: LucideIcons.dog, color: AppTheme.info),
            _TestCard(label: "Phone Ring", icon: LucideIcons.phone, color: AppTheme.info),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }
}

class _FlashlightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SoundProvider, bool>(
      selector: (_, p) => p.flashlightEnabled,
      builder: (context, enabled, _) {
        return LiquidGlassContainer(
          onTap: () => context.read<SoundProvider>().toggleFlashlight(),
          padding: const EdgeInsets.all(18),
          glow: enabled,
          glowColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: (enabled ? AppTheme.secondary : AppTheme.textMuted).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  enabled ? LucideIcons.zap : LucideIcons.zapOff,
                  color: enabled ? AppTheme.secondary : AppTheme.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Flashlight",
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                enabled ? "Enabled" : "Disabled",
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 80.ms).scale(begin: const Offset(0.96, 0.96));
  }
}

class _ListeningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SoundProvider, bool>(
      selector: (_, p) => p.isListening,
      builder: (context, listening, _) {
        return LiquidGlassContainer(
          onTap: () => context.read<SoundProvider>().toggleListening(),
          padding: const EdgeInsets.all(18),
          glow: listening,
          glowColor: AppTheme.success,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: (listening ? AppTheme.success : AppTheme.textMuted).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  listening ? LucideIcons.mic : LucideIcons.micOff,
                  color: listening ? AppTheme.success : AppTheme.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Listening",
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                listening ? "Active" : "Paused",
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 120.ms).scale(begin: const Offset(0.96, 0.96));
  }
}

class _TestCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TestCard({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      onTap: () => context.read<SoundProvider>().simulateEvent(label),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenAlertsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SoundProvider, bool>(
      selector: (_, p) => p.screenAlertsEnabled,
      builder: (context, enabled, _) {
        return LiquidGlassContainer(
          onTap: () => context.read<SoundProvider>().toggleScreenAlerts(),
          padding: const EdgeInsets.all(18),
          glow: enabled,
          glowColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: (enabled ? AppTheme.primary : AppTheme.textMuted).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  enabled ? LucideIcons.monitor : LucideIcons.monitorOff,
                  color: enabled ? AppTheme.primary : AppTheme.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Screen Alerts",
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                enabled ? "On" : "Off",
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 160.ms).scale(begin: const Offset(0.96, 0.96));
  }
}
