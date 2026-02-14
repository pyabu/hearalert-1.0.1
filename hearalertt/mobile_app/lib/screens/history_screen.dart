import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/models/models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(child: _buildEventsList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "History",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Selector<SoundProvider, int>(
                  selector: (_, p) => p.history.length,
                  builder: (context, count, _) {
                    return Text(
                      "$count event${count != 1 ? 's' : ''} recorded",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          LiquidGlassContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: 14,
            onTap: () => context.read<SoundProvider>().clearHistory(),
            child: const Icon(LucideIcons.trash2, color: AppTheme.textMuted, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.04, end: 0);
  }

  Widget _buildEventsList() {
    return Selector<SoundProvider, List<SoundEvent>>(
      selector: (_, p) => p.history,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
          physics: const BouncingScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _EventTile(event: event, index: index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassContainer(
            padding: const EdgeInsets.all(28),
            borderRadius: 100,
            child: const Icon(
              LucideIcons.inbox,
              color: AppTheme.textMuted,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No events yet",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sound events will appear here",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _EventTile extends StatelessWidget {
  final SoundEvent event;
  final int index;

  const _EventTile({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    final isEmergency = event.type == 'emergency';
    final isWarning = event.type == 'warning';
    final color = isEmergency ? AppTheme.danger : (isWarning ? AppTheme.warning : AppTheme.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(16),
        glow: isEmergency,
        glowColor: AppTheme.danger,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForEvent(event.label),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
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
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${(event.confidence * 100).toInt()}%",
                          style: GoogleFonts.inter(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(event.timestamp),
                    style: GoogleFonts.inter(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (25 * index).ms).fadeIn().slideX(begin: 0.02, end: 0);
  }

  IconData _getIconForEvent(String label) {
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return isToday ? "Today at $timeStr" : "${time.month}/${time.day} at $timeStr";
  }
}
