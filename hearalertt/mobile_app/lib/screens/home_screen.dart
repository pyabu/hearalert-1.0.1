import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/widgets/deaf_accessibility.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showDeafCard = false;
  late AnimationController _pulseController;
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main scrollable content
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 56),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildMainVisualizer(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildPrioritySection(),
                  const SizedBox(height: 28),
                  _buildMainOrb(),
                  const SizedBox(height: 28),
                  _buildRecentActivity(),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),

        // Deaf overlay
        if (_showDeafCard) _buildDeafOverlay(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SOUND INTELLIGENCE",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Active Listening",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Live status indicator
        Selector<SoundProvider, bool>(
          selector: (_, p) => p.isListening,
          builder: (context, isListening, _) {
            return LiquidGlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderRadius: 20,
              blurStrength: 12,
              opacity: 0.15,
              tint: isListening ? AppTheme.success : AppTheme.glassLow,
              glow: isListening,
              glowColor: AppTheme.success,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isListening ? AppTheme.success : AppTheme.textMuted,
                      shape: BoxShape.circle,
                      boxShadow: isListening 
                          ? [BoxShadow(color: AppTheme.success, blurRadius: 8)] 
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isListening ? "LIVE" : "OFF",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isListening ? Colors.white : AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildMainVisualizer() {
    return Selector<SoundProvider, ({double amplitude, bool isListening, SoundEvent? event})>(
      selector: (_, p) => (amplitude: p.amplitude, isListening: p.isListening, event: p.lastEvent),
      builder: (context, data, _) {
        final color = data.event?.isEmergency == true 
            ? AppTheme.danger 
            : data.isListening ? AppTheme.primary : AppTheme.glassHigh;
            
        return LiquidGlassContainer(
          height: 160,
          width: double.infinity,
          borderRadius: 24,
          opacity: 0.08,
          blurStrength: 32,
          border: true,
          glow: data.isListening,
          glowColor: color,
          child: Stack(
            children: [
              // Ambient pulse when listening
              if (data.isListening)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.7 + (data.amplitude * 0.4),
                        colors: [
                          color.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modern waveform visualization
                    SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(14, (i) {
                          final rawHeight = data.isListening 
                              ? 10 + (data.amplitude * 35 * ((i % 4) + 1).clamp(1, 3)) 
                              : 6.0;
                          final barHeight = rawHeight.clamp(6.0, 52.0);
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 80 + (i * 15)),
                            width: 4,
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: data.isListening
                                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: data.event != null
                          ? Text(
                              data.event!.label.toUpperCase(),
                              key: ValueKey(data.event!.label),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            )
                          : Text(
                              data.isListening ? "LISTENING..." : "PAUSED",
                              key: ValueKey("status-${data.isListening}"),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "QUICK ACTIONS",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionCard(LucideIcons.zap, "Flash", AppTheme.accentYellow),
            const SizedBox(width: 14),
            _buildActionCard(LucideIcons.vibrate, "Vibrate", AppTheme.accentPink),
            const SizedBox(width: 14),
            _buildActionCard(
              LucideIcons.ear, 
              "Deaf Card", 
              AppTheme.info,
              onTap: () => setState(() => _showDeafCard = true),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Test Alert Row - for testing the alert system
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionCard(
              LucideIcons.dog, 
              "Test Dog", 
              const Color(0xFFD4A373),
              onTap: () => context.read<SoundProvider>().simulateEvent('Dog Bark'),
            ),
            const SizedBox(width: 14),
            _buildActionCard(
              LucideIcons.bell, 
              "Test Door", 
              const Color(0xFF8B4513),
              onTap: () => context.read<SoundProvider>().simulateEvent('Door Knock'),
            ),
            const SizedBox(width: 14),
            _buildActionCard(
              LucideIcons.siren, 
              "Test Siren", 
              const Color(0xFFEF4444),
              onTap: () => context.read<SoundProvider>().simulateEvent('Emergency Siren'),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
  
  Widget _buildActionCard(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.3),
                        color.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: 100.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PRIORITY ZONES",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildPriorityChip("Home", LucideIcons.home, true),
            const SizedBox(width: 10),
            _buildPriorityChip("Street", LucideIcons.car, false),
            const SizedBox(width: 10),
            _buildPriorityChip("Office", LucideIcons.briefcase, false),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
  
  Widget _buildPriorityChip(String label, IconData icon, bool selected) {
    final color = selected ? AppTheme.primary : AppTheme.glassHigh;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: selected 
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primary.withOpacity(0.25),
                        AppTheme.secondary.withOpacity(0.1),
                      ],
                    )
                  : null,
              color: selected ? null : AppTheme.glassLow.withOpacity(0.08),
              border: Border.all(
                color: selected 
                    ? AppTheme.primary.withOpacity(0.4) 
                    : Colors.white.withOpacity(0.08),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected 
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon, 
                  color: selected ? AppTheme.primaryLight : AppTheme.textMuted,
                  size: 22,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppTheme.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: 150.ms)
      .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
  }

  Widget _buildMainOrb() {
    return Center(
      child: Selector<SoundProvider, bool>(
        selector: (_, p) => p.isListening,
        builder: (context, isListening, _) {
          return GestureDetector(
            onTap: () => context.read<SoundProvider>().toggleListening(),
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final scale = isListening ? 1.0 + (_orbController.value * 0.02) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isListening
                            ? [AppTheme.primaryLight, AppTheme.primaryDark]
                            : [AppTheme.glassHigh, AppTheme.surface],
                      ),
                      boxShadow: isListening 
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.5), 
                                blurRadius: 40, 
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: AppTheme.secondary.withOpacity(0.2), 
                                blurRadius: 80, 
                                spreadRadius: 16,
                              ),
                            ]
                          : [BoxShadow(color: Colors.black26, blurRadius: 16)],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect when active
                        if (isListening)
                          ...List.generate(2, (i) => Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2 - (i * 0.1)),
                                width: 1,
                              ),
                            ),
                          ).animate(onPlay: (c) => c.repeat())
                            .scale(
                              begin: const Offset(1, 1), 
                              end: Offset(1.2 + (i * 0.15), 1.2 + (i * 0.15)),
                              delay: Duration(milliseconds: i * 400),
                              duration: const Duration(milliseconds: 1500),
                            )
                            .fadeOut(delay: Duration(milliseconds: i * 400), duration: 1500.ms)),
                            
                        Icon(
                          isListening ? LucideIcons.mic : LucideIcons.micOff,
                          size: 44,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RECENT DETECTIONS",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        Selector<SoundProvider, List<SoundEvent>>(
          selector: (_, p) => p.recentEvents,
          builder: (context, events, _) {
            if (events.isEmpty) {
              return LiquidGlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "No sounds detected yet",
                    style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ),
              );
            }
            return Column(
              children: events.take(3).map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LiquidGlassContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(LucideIcons.activity, color: AppTheme.secondary, size: 16),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          event.label,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        "${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}",
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildDeafOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showDeafCard = false),
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: LiquidGlassContainer(
              width: MediaQuery.of(context).size.width * 0.9,
              blurStrength: 40,
              opacity: 0.15,
              borderRadius: 28,
              padding: EdgeInsets.zero,
              child: DeafCommunicationCard(
                onClose: () => setState(() => _showDeafCard = false),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
