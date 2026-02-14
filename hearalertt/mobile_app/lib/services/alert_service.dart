import 'package:vibration/vibration.dart';
import 'dart:io';
import 'package:torch_light/torch_light.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer';
import 'package:mobile_app/models/models.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isFlashing = false;

  Future<void> initialize() async {
     log("AlertService initialized");
     try {
       await _flutterTts.setLanguage("en-US");
       await _flutterTts.setSpeechRate(0.5);
       await _flutterTts.setVolume(1.0);
       await _flutterTts.setPitch(1.0);
     } catch (e) {
       log("TTS Initialization failed (likely not supported on this platform): $e");
     }
       
       if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
         return; // Skip hardware checks on desktop
       }
  }

  /// 1. Fire Alarm: Urgent SOS / Strobe
  Future<void> triggerFireAlarm({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Fire Alarm Detected");
    // Flash: Rapid Strobe (50ms on/off) for 5 seconds
    if (withFlash) _triggerFlashlightPattern(duration: 5000, flashDelay: 50);

    if (await Vibration.hasVibrator()) {
       // SOS Pattern: ... --- ...
       _vibrateWithIntensity(
         pattern: [0, 100, 100, 100, 100, 100, 200, 300, 200, 300, 200, 300, 200, 100, 100, 100, 100, 100],
         intensity: intensity,
       );
    }
  }

  /// 2. Vehicle Horn: Long Warning Pulses
  Future<void> triggerVehicleHorn({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Car Horn Detected");
    // Flash: Slow Blink (500ms)
    if (withFlash) _triggerFlashlightPattern(duration: 4000, flashDelay: 500);

    if (await Vibration.hasVibrator()) {
       // Pattern: Long_____Long_____
       _vibrateWithIntensity(pattern: [0, 1000, 500, 1000, 500, 1000], intensity: intensity);
    }
  }

  /// 3. Door Knock: Distinctive Double Tap Pattern
  Future<void> triggerDoorKnock({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Door Knock Detected");
    // Flash: Two distinct blinks (knock-knock)
    if (withFlash) {
       _triggerFlashlightPattern(duration: 1500, flashDelay: 150); 
    }

    if (await Vibration.hasVibrator()) {
       // Pattern: Knock-Knock (pause) Knock-Knock - distinct double-tap feel
       // [wait, vib, wait, vib, pause, vib, wait, vib]
       _vibrateWithIntensity(pattern: [0, 120, 80, 120, 300, 120, 80, 120], intensity: intensity);
    }
  }

  /// 4. Baby Cry: Small Vibration (Gentle)
  Future<void> triggerBabyCry({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Baby Crying Detected");
    // Flash: Gentle pulse
    if (withFlash) _triggerFlashlightPattern(duration: 5000, flashDelay: 800);

    if (await Vibration.hasVibrator()) {
       // Pattern: Small, gentle pulses (Low intensity if supported, otherwise short duration)
       // [wait, vibrate, wait, vibrate]
       _vibrateWithIntensity(pattern: [0, 50, 100, 50], intensity: intensity);
    }
  }

  /// 5. Glass Breaking: Sharp Urgent Jitter (Security Alert!)
  Future<void> triggerGlassBreaking({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Glass Break Detected");
    // Flash: Rapid strobe to indicate urgency
    if (withFlash) _triggerFlashlightPattern(duration: 3000, flashDelay: 40);

    if (await Vibration.hasVibrator()) {
       // Pattern: Sharp rapid jitters (like glass shattering)
       // Followed by a longer alert pulse
       _vibrateWithIntensity(pattern: [
         0, 40, 30, 40, 30, 40, 30, 40, 30, 40,  // Initial sharp jitters
         100, // Brief pause
         300, // Long alert pulse
         100, // Brief pause  
         40, 30, 40, 30, 40, 30, 40,  // More jitters
       ], intensity: intensity);
    }
  }
  
  /// 6. Dog Bark: Double Pulse (Woof-Woof)
  Future<void> triggerDogBark({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Dog Barking Detected");
    if (withFlash) _triggerFlashlightPattern(duration: 2000, flashDelay: 200);

    if (await Vibration.hasVibrator()) {
       // Pattern: Medium-Medium
       _vibrateWithIntensity(pattern: [0, 200, 100, 200], intensity: intensity);
    }
  }

  /// 7. Human Distress: Urgent Pulsing (Scream/Shout)
  Future<void> triggerHumanDistress({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Human Distress Detected");
    if (withFlash) _triggerFlashlightPattern(duration: 4000, flashDelay: 100);

    if (await Vibration.hasVibrator()) {
       // Pattern: Long-Short-Long (Urgent)
       _vibrateWithIntensity(pattern: [0, 500, 200, 500, 200, 500], intensity: intensity);
    }
  }

  /// 8. Doorbell: Pleasant chime pattern
  Future<void> triggerDoorbell({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Doorbell Ring Detected");
    // Flash: Two gentle blinks
    if (withFlash) _triggerFlashlightPattern(duration: 1200, flashDelay: 200);

    if (await Vibration.hasVibrator()) {
       // Pattern: Ding-Dong (melodic feel)
       _vibrateWithIntensity(pattern: [0, 150, 150, 250], intensity: intensity);
    }
  }

  /// 9. Explosion/Gunshot: Maximum urgency!
  Future<void> triggerExplosion({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Danger Detected! Take Cover!");
    // Flash: Intense rapid strobe
    if (withFlash) _triggerFlashlightPattern(duration: 5000, flashDelay: 30);

    if (await Vibration.hasVibrator()) {
       // Pattern: Intense SOS-like emergency
       _vibrateWithIntensity(pattern: [
         0, 100, 50, 100, 50, 100, // S
         150, 300, 100, 300, 100, 300, // O
         150, 100, 50, 100, 50, 100, // S
         200, 500, // Final long alert
       ], intensity: intensity);
    }
  }

  /// 10. Telephone Ring
  Future<void> triggerPhoneRing({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Phone Ringing");
    if (withFlash) _triggerFlashlightPattern(duration: 3000, flashDelay: 300);

    if (await Vibration.hasVibrator()) {
       // Pattern: Ring-Ring (telephone cadence)
       _vibrateWithIntensity(pattern: [0, 200, 100, 200, 500, 200, 100, 200], intensity: intensity);
    }
  }

  /// 11. Animal detected (cat, horse, etc.)
  Future<void> triggerAnimalAlert({bool withFlash = false, String animalName = 'Animal', VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("$animalName Detected nearby");
    if (withFlash) _triggerFlashlightPattern(duration: 2000, flashDelay: 400);

    if (await Vibration.hasVibrator()) {
       // Pattern: Medium alert pulses
       _vibrateWithIntensity(pattern: [0, 200, 150, 200, 150, 200], intensity: intensity);
    }
  }

  /// 12. Snake/Dangerous animal
  Future<void> triggerDangerousAnimal({bool withFlash = false, String animalName = 'Danger', VibrationIntensity intensity = VibrationIntensity.high}) async {
    _speak("Warning! $animalName detected!");
    if (withFlash) _triggerFlashlightPattern(duration: 4000, flashDelay: 100);

    if (await Vibration.hasVibrator()) {
       // Pattern: Urgent warning
       _vibrateWithIntensity(pattern: [0, 300, 100, 300, 100, 500, 200, 500], intensity: intensity);
    }
  }

  /// Generic fallback - ALWAYS vibrates for deaf users
  Future<void> triggerGenericInfo({bool withFlash = false, VibrationIntensity intensity = VibrationIntensity.high}) async {
    if (withFlash) _triggerFlashlightPattern(duration: 1500, flashDelay: 300);
    if (await Vibration.hasVibrator()) {
      _vibrateWithIntensity(pattern: [0, 150, 100, 150], intensity: intensity);  // Double tap
    }
  }

  Future<void> _triggerFlashlightPattern({required int duration, required int flashDelay}) async {
      if (_isFlashing) return;
      _isFlashing = true;
      
      final end = DateTime.now().add(Duration(milliseconds: duration));
      
      try {
        while (DateTime.now().isBefore(end)) {
             try { await TorchLight.enableTorch(); } catch (_) {}
             await Future.delayed(Duration(milliseconds: flashDelay));
             try { await TorchLight.disableTorch(); } catch (_) {}
             await Future.delayed(Duration(milliseconds: flashDelay));
        }
      } catch (e) {
          log("Flashlight error: $e");
      } finally {
          _isFlashing = false;
          try { await TorchLight.disableTorch(); } catch (_) {}
      }
  }

  Future<void> _speak(String text) async {
      try {
          await _flutterTts.speak(text);
      } catch (e) {
          log("TTS Error: $e");
      }
  }
  
  /// Custom alert with dynamic vibration pattern and message
  Future<void> triggerCustomAlert({
    required String message,
    required List<int> vibrationPattern,
    bool withFlash = false,
    int flashDuration = 3000,
    int flashDelay = 200,
    VibrationIntensity intensity = VibrationIntensity.high,
  }) async {
    _speak(message);
    
    if (withFlash) {
      _triggerFlashlightPattern(duration: flashDuration, flashDelay: flashDelay);
    }
    
    if (await Vibration.hasVibrator()) {
      _vibrateWithIntensity(pattern: vibrationPattern, intensity: intensity);
    }
  }

  void _vibrateWithIntensity({required List<int> pattern, required VibrationIntensity intensity}) {
    // Calculate amplitude based on intensity setting
    int amplitude = 255; // High (default)
    if (intensity == VibrationIntensity.medium) amplitude = 128;
    if (intensity == VibrationIntensity.low) amplitude = 60;
    
    // Construct intensities list matching pattern length
    // Pattern is [wait, vibrate, wait, vibrate...]
    // corresponding intensities: [0, amp, 0, amp...]
    List<int> intensities = [];
    for (int i = 0; i < pattern.length; i++) {
      if (i % 2 == 0) {
        intensities.add(0); // Wait phase -> 0 amplitude
      } else {
        intensities.add(amplitude); // Vibrate phase -> calculated amplitude
      }
    }

    if (pattern.isNotEmpty) {
      Vibration.vibrate(pattern: pattern, intensities: intensities);
    }
  }
}
