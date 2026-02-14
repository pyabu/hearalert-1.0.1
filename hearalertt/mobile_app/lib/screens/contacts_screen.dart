import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/widgets/liquid_background.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

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
        title: Text(
          "Emergency Contacts",
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          const LiquidBackground(subtle: true),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Hero Card
                  LiquidGlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.glow(AppTheme.primary, intensity: 0.6),
                          ),
                          child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Trusted Contacts",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "They will receive SMS alerts when fire alarms or critical sounds are detected.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.glow(AppTheme.primary, intensity: 0.4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Add Contact",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 28),
                  
                  // Section Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 14),
                      child: Text(
                        "YOUR CONTACTS",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  
                  // Contact Items
                  _buildContactItem("Mom", "+1 (555) 123-4567", "Family", 0),
                  const SizedBox(height: 12),
                  _buildContactItem("Emergency Services", "911", "Service", 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String name, String phone, String relation, int index) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.glassHigh, AppTheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      phone,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        relation,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: LucideIcons.phone,
                color: AppTheme.success,
                onTap: () {},
              ),
              const SizedBox(width: 6),
              _ActionButton(
                icon: LucideIcons.trash2,
                color: AppTheme.danger,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: (80 * index).ms).fadeIn().slideX(begin: 0.03, end: 0);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
