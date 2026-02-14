import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/glass_container.dart';
import 'package:mobile_app/widgets/baby_cry_alert_dialog.dart';
import 'package:mobile_app/models/models.dart';

class LiveDetectionScreen extends StatefulWidget {
  const LiveDetectionScreen({super.key});

  @override
  State<LiveDetectionScreen> createState() => _LiveDetectionScreenState();
}

class _LiveDetectionScreenState extends State<LiveDetectionScreen> with TickerProviderStateMixin {
  late AnimationController _radarController;
  DateTime? _lastBabyCryAlertShown;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    // Listen for baby cry detections and show alert
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SoundProvider>().addListener(_checkForBabyCryAlert);
    });
  }
  
  void _checkForBabyCryAlert() {
    final soundProvider = context.read<SoundProvider>();
    final lastDetection = soundProvider.lastBabyCryDetection;
    
    if (lastDetection != null && mounted) {
      // Only show if this is a new alert (different timestamp)
      if (_lastBabyCryAlertShown != lastDetection.timestamp) {
        _lastBabyCryAlertShown = lastDetection.timestamp;
        
        // Show alert dialog
        showDialog(
          context: context,
          barrierDismissible: !lastDetection.isHighPriority,
          builder: (context) => BabyCryAlertDialog(prediction: lastDetection),
        );
      }
    }
  }

  @override
  void dispose() {
    context.read<SoundProvider>().removeListener(_checkForBabyCryAlert);
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.void_,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(decoration: const BoxDecoration(gradient: AppTheme.surfaceGradient)),
          
          // Ambient Glow
          _buildAmbientGlow(),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildVisualizerArea()),
                _buildWaveform(),
                _buildControlDock(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow() {
    return Selector<SoundProvider, SoundEvent?>(
      selector: (_, p) => p.lastEvent,
      builder: (context, event, _) {
        Color glowColor = AppTheme.primary;
        if (event?.type == 'emergency') glowColor = AppTheme.error;
        if (event?.type == 'warning') glowColor = AppTheme.warning;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                glowColor.withOpacity(event != null ? 0.15 : 0.05),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.radar, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Live Monitor",
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Selector<SoundProvider, bool>(
                    selector: (_, p) => p.isListening,
                    builder: (context, isListening, _) {
                      return Text(
                        isListening ? "Actively scanning..." : "Standby mode",
                        style: GoogleFonts.inter(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Selector<SoundProvider, bool>(
              selector: (_, p) => p.isListening,
              builder: (context, isListening, _) {
                return StatusPill(
                  text: isListening ? "LIVE" : "OFF",
                  color: isListening ? AppTheme.success : AppTheme.textMuted,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizerArea() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Radar Visualization
        Selector<SoundProvider, ({bool isListening, double amplitude})>(
          selector: (_, p) => (isListening: p.isListening, amplitude: p.amplitude),
          builder: (context, data, _) {
            return AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadarPainter(
                    animationValue: _radarController.value,
                    isActive: data.isListening,
                    amplitude: data.amplitude,
                  ),
                  size: const Size(300, 300),
                );
              },
            );
          },
        ),
        
        // Center Content
        Selector<SoundProvider, ({SoundEvent? event, bool isListening})>(
          selector: (_, p) => (event: p.lastEvent, isListening: p.isListening),
          builder: (context, data, _) {
            if (data.event != null) {
              return _buildDetectedEvent(data.event!);
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data.isListening ? LucideIcons.waves : LucideIcons.radio,
                  color: AppTheme.textMuted,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  data.isListening ? "SCANNING" : "READY",
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetectedEvent(SoundEvent event) {
    Color color = AppTheme.primary;
    if (event.type == 'emergency') color = AppTheme.error;
    if (event.type == 'warning') color = AppTheme.warning;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow(color, intensity: 1.2),
          ),
          child: Icon(_getIconForLabel(event.label), color: Colors.white, size: 40),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 600.ms),
        const SizedBox(height: 20),
        Text(
          event.label.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${(event.confidence * 100).toInt()}% CONFIDENCE",
          style: GoogleFonts.inter(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    ).animate().fadeIn().scale(curve: Curves.easeOutBack);
  }

  IconData _getIconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('fire') || l.contains('smoke')) return LucideIcons.flame;
    if (l.contains('baby') || l.contains('cry')) return LucideIcons.baby;
    if (l.contains('glass')) return LucideIcons.glassWater;
    if (l.contains('alarm')) return LucideIcons.bellRing;
    if (l.contains('horn') || l.contains('siren')) return LucideIcons.megaphone;
    if (l.contains('knock') || l.contains('door')) return LucideIcons.doorOpen;
    if (l.contains('dog')) return LucideIcons.dog;
    return LucideIcons.activity;
  }

  Widget _buildWaveform() {
    return Selector<SoundProvider, ({List<double> data, bool isListening})>(
      selector: (_, p) => (data: p.waveformData, isListening: p.isListening),
      builder: (context, state, _) {
        if (!state.isListening) return const SizedBox(height: 80);
        
        return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomPaint(
            painter: _WaveformPainter(data: state.data),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildControlDock() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        borderRadius: BorderRadius.circular(28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DockButton(
              icon: LucideIcons.zap,
              label: "Flash",
              isActive: context.select<SoundProvider, bool>((p) => p.flashlightEnabled),
              onTap: () => context.read<SoundProvider>().toggleFlashlight(),
            ),
            // Baby cry detection is now always active automatically
            _MainToggle(),
            _DockButton(
              icon: LucideIcons.trash2,
              label: "Clear",
              isActive: false,
              onTap: () => context.read<SoundProvider>().clearHistory(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SoundProvider, bool>(
      selector: (_, p) => p.isListening,
      builder: (context, isListening, _) {
        return GestureDetector(
          onTap: () => context.read<SoundProvider>().toggleListening(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: isListening ? AppTheme.accentGradient : null,
              color: isListening ? null : AppTheme.elevated,
              shape: BoxShape.circle,
              boxShadow: isListening ? AppTheme.glowShadow(AppTheme.secondary, intensity: 0.8) : null,
              border: Border.all(
                color: isListening ? Colors.transparent : AppTheme.subtle,
                width: 2,
              ),
            ),
            child: Icon(
              isListening ? LucideIcons.pause : LucideIcons.power,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DockButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.secondary : AppTheme.textMuted,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;
  final double amplitude;

  _RadarPainter({
    required this.animationValue,
    required this.isActive,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Static rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.subtle;

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * (i / 4), ringPaint);
    }

    // Crosshairs
    canvas.drawLine(
      Offset(center.dx - 15, center.dy),
      Offset(center.dx + 15, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 15),
      ringPaint,
    );

    if (!isActive) return;

    // Active sweep
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.secondary.withOpacity(1.0 - animationValue);

    canvas.drawCircle(center, maxRadius * animationValue, sweepPaint);

    // Amplitude pulse
    final amplitudePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.primary.withOpacity(0.5 * amplitude);

    canvas.drawCircle(center, maxRadius * 0.6 * (1 + amplitude * 0.3), amplitudePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isActive != isActive ||
      oldDelegate.amplitude != amplitude;
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;

  _WaveformPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppTheme.secondary.withOpacity(0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final centerY = size.height / 2;
    final widthPerSample = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      double val = data[i].abs();
      double h = val * size.height * 1.5;
      if (h < 2) h = 2;
      if (h > size.height) h = size.height;

      final x = i * widthPerSample;
      canvas.drawLine(Offset(x, centerY - h / 2), Offset(x, centerY + h / 2), glowPaint);
      canvas.drawLine(Offset(x, centerY - h / 2), Offset(x, centerY + h / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => oldDelegate.data != data;
}
