import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:mobile_app/providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_app/screens/app_scaffold.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/liquid_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: "Sound\nIntelligence",
      subtitle: "ADVANCED AI RECOGNITION",
      description: "Experience cutting-edge technology that identifies 50+ environmental sounds in real-time, keeping you connected to your surroundings.",
      icon: LucideIcons.brainCircuit,
      color: AppTheme.primary,
      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
    ),
    _OnboardingSlide(
      title: "Instant\nAlerts",
      subtitle: "VISUAL & HAPTIC FEEDBACK",
      description: "Get immediate multi-sensory notifications for critical events — fire alarms, door knocks, baby cries, and more.",
      icon: LucideIcons.bell,
      color: AppTheme.secondary,
      gradientColors: [const Color(0xFF06D6A0), const Color(0xFF0EA5E9)],
    ),
    _OnboardingSlide(
      title: "Complete\nHistory",
      subtitle: "DETAILED EVENT LOGGING",
      description: "Never miss what happened. Review past sound events with timestamps and confidence levels anytime you need.",
      icon: LucideIcons.history,
      color: AppTheme.success,
      gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.read<SettingsProvider>().completeOnboarding();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AppScaffold(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.void_,
      body: Stack(
        children: [
          // Animated background
          const LiquidBackground(subtle: true),
          
          // Floating accent orbs based on current page
          _buildFloatingOrbs(),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar with skip
                _buildTopBar(),
                
                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _buildSlide(_slides[index], index),
                  ),
                ),
                
                // Bottom Controls
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.ear, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                "HearAlert",
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Skip button
          GestureDetector(
            onTap: _finishOnboarding,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.glassLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                "Skip",
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrbs() {
    final slide = _slides[_currentPage];
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Primary accent orb
        AnimatedPositioned(
          duration: AppTheme.liquidSlow,
          curve: Curves.easeOutCubic,
          top: size.height * 0.15,
          right: -size.width * 0.15,
          child: AnimatedContainer(
            duration: AppTheme.liquidMedium,
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  slide.color.withOpacity(0.25),
                  slide.color.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(_OnboardingSlide slide, int index) {
    final isActive = index == _currentPage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          
          // Icon with gradient background
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.glow(slide.color, intensity: 0.7),
            ),
            child: Icon(slide.icon, color: Colors.white, size: 32),
          ).animate(target: isActive ? 1 : 0)
           .fadeIn(duration: 400.ms)
           .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack),
          
          const SizedBox(height: 36),
          
          // Title
          Text(
            slide.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.05,
              letterSpacing: -1.5,
            ),
          ).animate(target: isActive ? 1 : 0)
           .fadeIn(duration: 350.ms, delay: 50.ms)
           .slideX(begin: -0.08, end: 0),
          
          const SizedBox(height: 16),
          
          // Subtitle badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              slide.subtitle,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ).animate(target: isActive ? 1 : 0).fadeIn(duration: 300.ms, delay: 100.ms),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            slide.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ).animate(target: isActive ? 1 : 0).fadeIn(duration: 350.ms, delay: 150.ms),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final slide = _slides[_currentPage];
    final isLastPage = _currentPage == _slides.length - 1;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Indicators
          Row(
            children: List.generate(_slides.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: isActive 
                      ? LinearGradient(colors: slide.gradientColors)
                      : null,
                  color: isActive ? null : AppTheme.glassHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          // Next/Start Button
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: isLastPage ? 28 : 20, 
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: slide.gradientColors),
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.glow(slide.color, intensity: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastPage ? "Get Started" : "Next",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastPage ? LucideIcons.rocket : LucideIcons.arrowRight,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}
