import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/sound_provider.dart';
import 'package:mobile_app/providers/settings_provider.dart';
import 'package:mobile_app/screens/splash_screen.dart';
import 'package:mobile_app/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, SoundProvider>(
          create: (_) => SoundProvider(),
          update: (_, settings, soundProvider) => soundProvider!..updateSettings(settings),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'HearAlert',
          debugShowCheckedModeBanner: false,
          // Use the dynamic theme generator
          theme: AppTheme.create(settings.accentColor, Brightness.light),
          darkTheme: AppTheme.create(settings.accentColor, Brightness.dark),
          themeMode: settings.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
