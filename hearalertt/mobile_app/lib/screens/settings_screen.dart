import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/providers/settings_provider.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/widgets/deaf_accessibility.dart';
import 'package:mobile_app/screens/signal_guide_screen.dart';
import 'package:mobile_app/screens/contacts_screen.dart';
import 'package:mobile_app/models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state removed in favor of SettingsProvider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  
                  // Accessibility Section
                  _buildSectionHeader("Accessibility", LucideIcons.accessibility),
                  const SizedBox(height: 14),
                  Consumer<SettingsProvider>(
                    builder: (_, s, __) => LiquidGlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      child: AccessibilitySettingsSection(
                        highContrast: s.highContrast,
                        largeText: s.largeText,
                        screenFlash: s.screenFlash,
                        onHighContrastChanged: s.setHighContrast,
                        onLargeTextChanged: s.setLargeText,
                        onScreenFlashChanged: s.setScreenFlash,
                      ),
                    ),
                  ).animate().fadeIn(delay: 80.ms),
                  
                  const SizedBox(height: 28),
                  
                  // Detection Section
                  _buildSectionHeader("Detection", LucideIcons.radar),
                  const SizedBox(height: 14),
                  LiquidGlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _SensitivitySlider(),
                        const _Divider(),
                        const _ToggleTile(
                          icon: LucideIcons.bell,
                          title: "Notifications",
                          subtitle: "Push notifications for events",
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  
                  const SizedBox(height: 28),
                  
                  // Feedback Section
                  _buildSectionHeader("Feedback", LucideIcons.zap),
                  const SizedBox(height: 14),
                  LiquidGlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Column(
                      children: [
                        _VibrationSelector(),
                        _Divider(),
                        _FlashlightToggle(),
                      ],
                    ),
                  ).animate().fadeIn(delay: 220.ms),
                  
                  const SizedBox(height: 28),
                  
                  // Emergency Section
                  _buildSectionHeader("Emergency", LucideIcons.shieldAlert),
                  const SizedBox(height: 14),
                  LiquidGlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: LucideIcons.users,
                          title: "Emergency Contacts",
                          subtitle: "Setup SOS contacts",
                          badge: Consumer<SettingsProvider>(
                            builder: (_, s, __) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${s.sosContacts.length}",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLight,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ContactsScreen()),
                          ),
                        ),
                        const _Divider(),
                        _ActionTile(
                          icon: LucideIcons.messageSquare,
                          title: "SOS Message",
                          subtitle: "Edit emergency text",
                          onTap: () => _showSosMessageDialog(context),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 290.ms),

                  const SizedBox(height: 28),
                  
                  // Help Section
                  _buildSectionHeader("Help", LucideIcons.helpCircle),
                  const SizedBox(height: 14),
                  LiquidGlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: LucideIcons.bookOpen,
                          title: "Signal Guide",
                          subtitle: "Vibration patterns guide",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignalGuideScreen()),
                          ),
                        ),
                        const _Divider(),
                        _ActionTile(
                          icon: LucideIcons.testTube,
                          title: "Test Alerts",
                          subtitle: "Simulate detections",
                          onTap: () => _showTestMenu(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 360.ms),
                  
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Settings",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        LiquidGlassContainer(
          padding: const EdgeInsets.all(10),
          blurStrength: 16,
          opacity: 0.08,
          borderRadius: 12,
          child: const Icon(LucideIcons.settings2, color: AppTheme.textMuted, size: 20),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.04, end: 0);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.secondary, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
  
  void _showTestMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: LiquidGlassContainer(
          blurStrength: 24,
          opacity: 0.15,
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Sound to Test",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TestChip("Baby Cry", LucideIcons.baby, AppTheme.warning),
                  _TestChip("Fire Alarm", LucideIcons.flame, AppTheme.danger),
                  _TestChip("Doorbell", LucideIcons.bell, AppTheme.info),
                  _TestChip("Glass Break", LucideIcons.shieldAlert, AppTheme.danger),
                  _TestChip("Dog Bark", LucideIcons.dog, AppTheme.warning),
                  _TestChip("Car Horn", LucideIcons.car, AppTheme.warning),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  void _showSosMessageDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: settings.sosMessage);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text("Edit SOS Message", style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.subtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
            filled: true,
            fillColor: AppTheme.glassLow,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              settings.setSosMessage(controller.text);
              Navigator.pop(context);
            },
            child: Text(
              "Save", 
              style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(color: Colors.white.withOpacity(0.08), height: 1);
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? badge;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.glassHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[badge!, const SizedBox(width: 8)],
          const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ToggleTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, s, __) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.glassHigh.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: Switch(
          value: s.notificationsEnabled,
          onChanged: s.toggleNotifications,
          activeColor: AppTheme.primary,
        ),
      ),
    );
  }
}

class _SensitivitySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, s, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.glassHigh.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.gauge, color: AppTheme.textSecondary, size: 18),
                ),
                const SizedBox(width: 14),
                Text(
                  "Sensitivity",
                  style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${(s.sensitivity * 100).toInt()}%",
                    style: GoogleFonts.inter(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: s.sensitivity,
                onChanged: s.setSensitivity,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.glassHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VibrationSelector extends StatelessWidget {
  const _VibrationSelector();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, s, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.glassHigh.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.vibrate, color: AppTheme.textSecondary, size: 18),
                ),
                const SizedBox(width: 14),
                Text(
                  "Vibration Intensity",
                  style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<VibrationIntensity>(
                segments: [
                  ButtonSegment(value: VibrationIntensity.low, label: Text("Low")),
                  ButtonSegment(value: VibrationIntensity.medium, label: Text("Med")),
                  ButtonSegment(value: VibrationIntensity.high, label: Text("High")),
                ],
                selected: {s.vibrationIntensity},
                onSelectionChanged: (v) => s.setVibrationIntensity(v.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) => 
                    states.contains(WidgetState.selected) ? AppTheme.primary : AppTheme.glassHigh),
                  foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected) ? Colors.white : AppTheme.textSecondary),
                  side: WidgetStateProperty.all(BorderSide(color: AppTheme.glassHigh)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashlightToggle extends StatelessWidget {
  const _FlashlightToggle();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SoundProvider>(
      builder: (_, p, __) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.glassHigh.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.flashlight, color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(
          "Flashlight Alerts",
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
        ),
        trailing: Switch(
          value: p.flashlightEnabled,
          onChanged: (_) => p.toggleFlashlight(),
          activeColor: AppTheme.secondary,
        ),
      ),
    );
  }
}

class _TestChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  
  const _TestChip(this.label, this.icon, this.color);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.read<SoundProvider>().simulateEvent(label);
      },
      child: LiquidGlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        opacity: 0.12,
        tint: color,
        border: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
