import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/screens/settings_screen.dart';
import 'package:mobile_app/screens/history_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_glass_container.dart';
import 'package:mobile_app/widgets/liquid_background.dart';
import 'package:mobile_app/screens/realtime_alerts_screen.dart';
import 'package:mobile_app/widgets/screen_alert_overlay.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SoundProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    RealtimeAlertsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(LucideIcons.home, "Home"),
    _NavItem(LucideIcons.radar, "Monitor"),
    _NavItem(LucideIcons.history, "History"),
    _NavItem(LucideIcons.settings, "Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.void_,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Global organic background
          const LiquidBackground(),
          
          // Main content with page transitions
          AnimatedSwitcher(
            duration: AppTheme.liquidMedium,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: IndexedStack(
              key: ValueKey(_currentIndex),
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPremiumNavBar(),
        ),
        const ScreenAlertOverlay(),
      ],
    );
  }

  Widget _buildPremiumNavBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: LiquidGlassContainer(
        height: 56,
        blurStrength: 24,
        opacity: 0.12,
        borderRadius: 20,
        border: true,
        enablePressEffect: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(_navItems[index], index);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.liquidMedium,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12, 
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.primary.withOpacity(0.08),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          border: isSelected 
              ? Border.all(color: AppTheme.primary.withOpacity(0.25), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppTheme.primaryLight : AppTheme.textMuted,
              size: 20,
            ),
            AnimatedSize(
              duration: AppTheme.liquidMedium,
              curve: Curves.easeOutCubic,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: isSelected 
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          item.label,
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  
  const _NavItem(this.icon, this.label);
}
