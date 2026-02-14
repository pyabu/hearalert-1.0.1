import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/config/realtime_alert_config.dart';

/// Sound category configurations for visual alerts
class _AlertConfig {
  final IconData icon;
  final Color color;
  final String category;
  final String displayMessage;
  final bool isEmergency;

  const _AlertConfig({
    required this.icon,
    required this.color,
    required this.category,
    this.displayMessage = '',
    this.isEmergency = false,
  });
}

/// Full-screen alert overlay widget that displays when sounds are detected
class ScreenAlertOverlay extends StatelessWidget {
  const ScreenAlertOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundProvider>(
      builder: (context, provider, _) {
        final event = provider.lastEvent;
        
        if (event == null || !provider.screenAlertsEnabled) {
          return const SizedBox.shrink();
        }
        
        return _AlertOverlayContent(event: event);
      },
    );
  }
}

class _AlertOverlayContent extends StatefulWidget {
  final SoundEvent event;

  const _AlertOverlayContent({required this.event});

  @override
  State<_AlertOverlayContent> createState() => _AlertOverlayContentState();
}

class _AlertOverlayContentState extends State<_AlertOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  _AlertConfig _getAlertConfig(String label) {
    final lower = label.toLowerCase();
    
    // Try to get from the new realtime alert database first
    final alertConfig = RealtimeAlertDatabase.getAlertByLabel(label);
    if (alertConfig != null) {
      return _AlertConfig(
        icon: _getIconForCategory(alertConfig.soundId),
        color: Color(alertConfig.colorHex),
        category: alertConfig.shortMessage.toUpperCase(),
        displayMessage: alertConfig.alertMessage,
        isEmergency: alertConfig.priority == AlertPriority.critical,
      );
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // CRITICAL PRIORITY - Emergency Alerts
    // ═══════════════════════════════════════════════════════════════════
    if (lower.contains('fire') || lower.contains('smoke') || lower.contains('alarm')) {
      return const _AlertConfig(
        icon: LucideIcons.flame,
        color: Color(0xFFEF4444),
        category: 'FIRE ALARM',
        displayMessage: '🔥 FIRE ALARM! Evacuate immediately!',
        isEmergency: true,
      );
    }
    if (lower.contains('siren') || lower.contains('ambulance') || lower.contains('police')) {
      return const _AlertConfig(
        icon: LucideIcons.siren,
        color: Color(0xFFFF4444),
        category: 'EMERGENCY',
        displayMessage: '🚨 Emergency vehicle approaching!',
        isEmergency: true,
      );
    }
    if (lower.contains('glass') || lower.contains('break') || lower.contains('shatter')) {
      return const _AlertConfig(
        icon: LucideIcons.shieldAlert,
        color: Color(0xFFEF4444),
        category: 'SECURITY',
        displayMessage: '💔 Glass breaking detected!',
        isEmergency: true,
      );
    }
    if (lower.contains('gunshot') || lower.contains('firework') || lower.contains('explosion')) {
      return const _AlertConfig(
        icon: LucideIcons.alertTriangle,
        color: Color(0xFFDC143C),
        category: 'DANGER',
        displayMessage: '💥 Loud bang detected!',
        isEmergency: true,
      );
    }
    if (lower.contains('scream') || lower.contains('shout') || lower.contains('distress')) {
      return const _AlertConfig(
        icon: LucideIcons.helpCircle,
        color: Color(0xFFEF4444),
        category: 'DISTRESS',
        displayMessage: '⚠️ Human distress detected!',
        isEmergency: true,
      );
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // HIGH PRIORITY - Safety & Important Alerts  
    // ═══════════════════════════════════════════════════════════════════
    if (lower.contains('baby') || lower.contains('cry') || lower.contains('infant')) {
      return const _AlertConfig(
        icon: LucideIcons.baby,
        color: Color(0xFFFF6B9D),
        category: 'BABY CRYING',
        displayMessage: '👶 Baby is crying!',
      );
    }
    if (lower.contains('knock') || lower.contains('door')) {
      return const _AlertConfig(
        icon: LucideIcons.doorOpen,
        color: Color(0xFF8B4513),
        category: 'DOOR KNOCKED',
        displayMessage: '🚪 Someone is knocking!',
      );
    }
    if (lower.contains('doorbell') || lower.contains('bell') || lower.contains('ding')) {
      return const _AlertConfig(
        icon: LucideIcons.bellRing,
        color: Color(0xFF32CD32),
        category: 'DOORBELL',
        displayMessage: '🔔 Doorbell ringing!',
      );
    }
    if (lower.contains('horn') || lower.contains('honk')) {
      return const _AlertConfig(
        icon: LucideIcons.car,
        color: Color(0xFFFFD700),
        category: 'CAR HORN',
        displayMessage: '🚗 Car horn detected!',
      );
    }
    if (lower.contains('train')) {
      return const _AlertConfig(
        icon: LucideIcons.train,
        color: Color(0xFF8B4513),
        category: 'TRAIN',
        displayMessage: '🚂 Train approaching!',
      );
    }
    if (lower.contains('traffic') || lower.contains('vehicle') || lower.contains('engine')) {
      return const _AlertConfig(
        icon: LucideIcons.car,
        color: Color(0xFF808080),
        category: 'TRAFFIC',
        displayMessage: '🚦 Heavy traffic nearby',
      );
    }
    if (lower.contains('speech') || lower.contains('voice') || lower.contains('talking')) {
      return const _AlertConfig(
        icon: LucideIcons.mic,
        color: Color(0xFF6B5B95),
        category: 'VOICE DETECTED',
        displayMessage: '🗣️ Someone is speaking!',
      );
    }
    if (lower.contains('creak') || lower.contains('squeak') || lower.contains('hinge')) {
      return const _AlertConfig(
        icon: LucideIcons.doorOpen,
        color: Color(0xFFA0522D),
        category: 'DOOR OPENING',
        displayMessage: '🚪 Door opening detected!',
      );
    }
    if (lower.contains('chainsaw') || lower.contains('power tool') || lower.contains('saw')) {
      return const _AlertConfig(
        icon: LucideIcons.wrench,
        color: Color(0xFFFF4500),
        category: 'POWER TOOLS',
        displayMessage: '⚡ Power tools detected!',
      );
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MEDIUM PRIORITY - Informational Alerts
    // ═══════════════════════════════════════════════════════════════════
    if (lower.contains('phone') || lower.contains('ring') || lower.contains('telephone')) {
      return const _AlertConfig(
        icon: LucideIcons.phone,
        color: Color(0xFF1E90FF),
        category: 'PHONE RINGING',
        displayMessage: '📱 Phone is ringing!',
      );
    }
    if (lower.contains('dog') || lower.contains('bark')) {
      return const _AlertConfig(
        icon: LucideIcons.dog,
        color: Color(0xFFA0522D),
        category: 'DOG BARKING',
        displayMessage: '🐕 Dog barking detected!',
      );
    }
    if (lower.contains('thunder') || lower.contains('storm')) {
      return const _AlertConfig(
        icon: LucideIcons.cloudLightning,
        color: Color(0xFF4169E1),
        category: 'THUNDER',
        displayMessage: '⛈️ Thunder detected!',
      );
    }
    if (lower.contains('cough')) {
      return const _AlertConfig(
        icon: LucideIcons.heart,
        color: Color(0xFFFF7F50),
        category: 'COUGHING',
        displayMessage: '😷 Coughing detected!',
      );
    }
    if (lower.contains('breath') || lower.contains('snor')) {
      return const _AlertConfig(
        icon: LucideIcons.wind,
        color: Color(0xFF87CEEB),
        category: 'BREATHING',
        displayMessage: '😮‍💨 Heavy breathing/snoring detected!',
      );
    }
    if (lower.contains('helicopter')) {
      return const _AlertConfig(
        icon: LucideIcons.plane,
        color: Color(0xFF708090),
        category: 'HELICOPTER',
        displayMessage: '🚁 Helicopter nearby!',
      );
    }
    if (lower.contains('footstep') || lower.contains('walking') || lower.contains('step')) {
      return const _AlertConfig(
        icon: LucideIcons.footprints,
        color: Color(0xFF8B4513),
        category: 'FOOTSTEPS',
        displayMessage: '👣 Footsteps approaching!',
      );
    }
    if (lower.contains('washing') || lower.contains('washer') || lower.contains('laundry')) {
      return const _AlertConfig(
        icon: LucideIcons.home,
        color: Color(0xFF4682B4),
        category: 'WASHER',
        displayMessage: '🧺 Washing machine running!',
      );
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // LOW PRIORITY - Ambient Alerts
    // ═══════════════════════════════════════════════════════════════════
    if (lower.contains('cat') || lower.contains('meow')) {
      return const _AlertConfig(
        icon: LucideIcons.cat,
        color: Color(0xFFDDA0DD),
        category: 'CAT',
        displayMessage: '🐱 Cat meowing!',
      );
    }
    if (lower.contains('vacuum') || lower.contains('hoover')) {
      return const _AlertConfig(
        icon: LucideIcons.sparkles,
        color: Color(0xFF708090),
        category: 'VACUUM',
        displayMessage: '🧹 Vacuum cleaner running!',
      );
    }
    if (lower.contains('airplane') || lower.contains('plane') || lower.contains('jet')) {
      return const _AlertConfig(
        icon: LucideIcons.plane,
        color: Color(0xFF4169E1),
        category: 'AIRPLANE',
        displayMessage: '✈️ Airplane overhead!',
      );
    }
    if (lower.contains('keyboard') || lower.contains('typing') || lower.contains('click')) {
      return const _AlertConfig(
        icon: LucideIcons.keyboard,
        color: Color(0xFF2F4F4F),
        category: 'TYPING',
        displayMessage: '⌨️ Keyboard typing detected!',
      );
    }
    if (lower.contains('clock') || lower.contains('tick')) {
      return const _AlertConfig(
        icon: LucideIcons.clock,
        color: Color(0xFFDAA520),
        category: 'CLOCK',
        displayMessage: '🕐 Clock ticking!',
      );
    }
    if (lower.contains('bird') || lower.contains('chirp')) {
      return const _AlertConfig(
        icon: LucideIcons.bird,
        color: Color(0xFF10B981),
        category: 'BIRD',
        displayMessage: '🐦 Bird chirping!',
      );
    }
    if (lower.contains('snake') || lower.contains('rattle')) {
      return const _AlertConfig(
        icon: LucideIcons.alertOctagon,
        color: Color(0xFFEF4444),
        category: 'DANGER',
        displayMessage: '🐍 Snake detected! Stay alert!',
        isEmergency: true,
      );
    }
    
    // Default
    return const _AlertConfig(
      icon: LucideIcons.volume2,
      color: Color(0xFF8B5CF6),
      category: 'SOUND DETECTED',
      displayMessage: '🔊 Sound detected nearby',
    );
  }
  
  IconData _getIconForCategory(String soundId) {
    switch (soundId) {
      case 'baby_cry': return LucideIcons.baby;
      case 'car_horn': return LucideIcons.car;
      case 'siren': return LucideIcons.siren;
      case 'fire_alarm': return LucideIcons.flame;
      case 'gunshot_firework': return LucideIcons.alertTriangle;
      case 'train': return LucideIcons.train;
      case 'glass_breaking': return LucideIcons.shieldAlert;
      case 'traffic': return LucideIcons.car;
      case 'door_knock': return LucideIcons.doorOpen;
      case 'doorbell': return LucideIcons.bellRing;
      case 'speech': return LucideIcons.mic;
      case 'door_creaking': return LucideIcons.doorOpen;
      case 'chainsaw': return LucideIcons.wrench;
      case 'phone_ring': return LucideIcons.phone;
      case 'dog_bark': return LucideIcons.dog;
      case 'thunderstorm': return LucideIcons.cloudLightning;
      case 'coughing': return LucideIcons.heart;
      case 'breathing': return LucideIcons.wind;
      case 'helicopter': return LucideIcons.plane;
      case 'footsteps': return LucideIcons.footprints;
      case 'washing_machine': return LucideIcons.home;
      case 'cat_meow': return LucideIcons.cat;
      case 'vacuum_cleaner': return LucideIcons.sparkles;
      case 'airplane': return LucideIcons.plane;
      case 'keyboard_typing': return LucideIcons.keyboard;
      case 'clock_tick': return LucideIcons.clock;
      default: return LucideIcons.volume2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig(widget.event.label);
    final size = MediaQuery.of(context).size;
    
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              border: Border.all(
                color: config.color.withOpacity(
                  config.isEmergency ? _pulseAnimation.value : 0.6,
                ),
                width: config.isEmergency ? 6 : 4,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: config.color.withOpacity(0.5)),
                  ),
                  child: Text(
                    config.category,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: config.color,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),
                
                const SizedBox(height: 32),
                
                // Main Icon with Glow
                _AnimatedAlertIcon(
                  icon: config.icon,
                  color: config.color,
                  isEmergency: config.isEmergency,
                ),
                
                const SizedBox(height: 32),
                
                // Sound Label - Show displayMessage if available
                Text(
                  config.displayMessage.isNotEmpty 
                      ? config.displayMessage 
                      : widget.event.label.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: config.displayMessage.isNotEmpty ? 28 : 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ).animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.1),
                
                // Show raw label as subtitle for context
                if (config.displayMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.event.label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 130.ms),
                
                const SizedBox(height: 16),
                
                // Confidence Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.glassLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.activity, color: config.color, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${(widget.event.confidence * 100).toStringAsFixed(0)}% Confidence',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 150.ms),
                
                const SizedBox(height: 48),
                
                // Action Button
                LiquidGlassContainer(
                  onTap: () {
                    context.read<SoundProvider>().clearAlert();
                  },
                  tint: config.color,
                  opacity: 0.3,
                  glow: true,
                  glowColor: config.color,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        "DISMISS",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.2),
                
                const SizedBox(height: 24),
                
                // Timestamp
                Text(
                  _formatTime(widget.event.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ).animate()
                  .fadeIn(delay: 250.ms),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1));
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return 'Detected at $hour:$minute:$second';
  }
}

/// Animated icon with pulsing glow effect
class _AnimatedAlertIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool isEmergency;

  const _AnimatedAlertIcon({
    required this.icon,
    required this.color,
    required this.isEmergency,
  });

  @override
  State<_AnimatedAlertIcon> createState() => _AnimatedAlertIconState();
}

class _AnimatedAlertIconState extends State<_AnimatedAlertIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isEmergency ? 500 : 1200),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isEmergency ? 1.15 : 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: widget.isEmergency ? 0.8 : 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(_glowAnimation.value),
                  widget.color.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_glowAnimation.value * 0.6),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        );
      },
    );
  }
}
