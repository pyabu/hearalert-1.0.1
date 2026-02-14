import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/settings_provider.dart';
import 'package:mobile_app/screens/app_scaffold.dart';
import 'package:mobile_app/screens/onboarding_screen.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Artificial delay for branding impact or loading time
    final minSplashDuration = 2500.ms;
    final startTime = DateTime.now();

    // Initialize Settings (async config loading)
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.init();

    // Ensure splash stays for at least min duration
    final elapsedTime = DateTime.now().difference(startTime);
    final remainingTime = minSplashDuration - elapsedTime;
    if (remainingTime > Duration.zero) {
      await Future.delayed(remainingTime);
    }

    if (!mounted) return;

    // Navigate based on onboarding state
    final targetScreen = settingsProvider.onboardingCompleted
        ? const AppScaffold()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, animation, __, child) {
          // Pop-out animation (Scale + Fade)
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ).drive(Tween(begin: 0.8, end: 1.0)),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: 800.ms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Content (Icon, Name, Loader)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 40,
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms)
                 .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack, duration: 800.ms)
                 .then(delay: 200.ms)
                 .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.2))
                 .animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .boxShadow(
                    begin: BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20, blurStyle: BlurStyle.outer),
                    end: BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 50, blurStyle: BlurStyle.outer),
                    duration: 2000.ms,
                 ),
                 
                 const SizedBox(height: 32),
                 
                 // App Name
                 Text(
                   "HearAlert",
                   style: GoogleFonts.spaceGrotesk(
                     fontSize: 36,
                     fontWeight: FontWeight.bold,
                     color: Colors.white,
                     letterSpacing: -1.0,
                   ),
                 ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                 
                 const SizedBox(height: 48),
                 
                 // "Flash Pulse" Loader
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: List.generate(5, (index) {
                 return Container(
                   margin: const EdgeInsets.symmetric(horizontal: 8),
                   width: 10,
                   height: 10,
                   decoration: BoxDecoration(
                     color: AppTheme.primary,
                     shape: BoxShape.circle,
                     boxShadow: [
                       BoxShadow(
                         color: AppTheme.primary.withOpacity(0.5),
                         blurRadius: 5,
                         spreadRadius: 1,
                       )
                     ],
                   ),
                 ).animate(
                   onPlay: (controller) => controller.repeat(),
                   delay: (index * 200).ms,
                 ).scale(
                   begin: const Offset(1.0, 1.0),
                   end: const Offset(1.5, 1.5),
                   duration: 300.ms,
                   curve: Curves.easeInOut,
                 ).then().scale(
                    begin: const Offset(1.5, 1.5),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.easeInOut,
                 ).tint(
                   color: Colors.white,
                   duration: 300.ms,
                 ).then().tint(
                   color: AppTheme.primary,
                   duration: 300.ms,
                 );
               }),
             ),
             
             const SizedBox(height: 48),
              ],
            ),
          ),
          
          // Version Number at Bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Version 1.1",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(delay: 1000.ms),
            ),
          ),
        ],
      ),
    );
  }
}
