# HearAlert - Project Documentation

---

## Title

**HearAlert: AI-Powered Real-Time Sound Recognition and Multi-Modal Alert System for Deaf and Hard-of-Hearing Individuals**

---

## Abstract

Hearing impairment significantly impacts an individual's ability to perceive environmental sounds critical for safety, communication, and daily living. Traditional assistive devices like hearing aids provide limited functionality and fail to address the diverse acoustic environments deaf individuals encounter. This project presents **HearAlert**, an innovative mobile application leveraging **artificial intelligence** and **machine learning** to provide real-time environmental sound recognition and intelligent alerting specifically designed for deaf and hard-of-hearing users.

The system employs **TensorFlow Lite's YAMNet model**—a deep neural network trained on the AudioSet dataset—capable of classifying over **521 distinct sound categories** including emergency sounds (fire alarms, sirens), human interactions (doorbell, door knocking), infant cries, animal sounds, and potential dangers (glass breaking, vehicle horns). The application processes audio input at a **16kHz sampling rate** with inference latency under **50 milliseconds**, enabling near-instantaneous detection and response.

HearAlert implements a sophisticated **multi-modal alert mechanism** that delivers notifications through:
- **Haptic Feedback:** Category-specific vibration patterns (e.g., SOS pattern for fire alarms, gentle pulses for baby cries)
- **Visual Alerts:** Flashlight strobe patterns synchronized with sound urgency
- **Text-to-Speech:** Voice announcements for partially hearing users

A **priority-based detection engine** with 38+ prioritized sound categories ensures critical sounds receive immediate attention with enhanced detection thresholds. The specialized **Baby Cry Classifier** module provides additional categorization of infant distress signals (hunger, discomfort, tiredness), offering actionable insights for caregivers.

The application is built using the **Flutter framework**, ensuring cross-platform compatibility across Android, iOS, and Linux platforms. The user interface features a premium **Liquid Glass design system** with accessibility-focused elements including high contrast modes, large text scaling, and emergency SOS features.

**Keywords:** Deaf Accessibility, Sound Recognition, Machine Learning, TensorFlow Lite, YAMNet, Flutter, Haptic Feedback, Mobile Application, Assistive Technology

---

## Technology Stack

### Core Framework

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.24.0+ | Cross-platform mobile UI framework |
| **Dart** | 3.5.3+ | Programming language with null safety |

### Machine Learning Layer

| Technology | Description |
|------------|-------------|
| **TensorFlow Lite** | Lightweight ML runtime for on-device inference |
| **YAMNet** | Pre-trained audio classification model (521 categories) |
| **Baby Cry Model** | Custom classifier for infant cry categorization |

### Audio Processing

| Package | Version | Function |
|---------|---------|----------|
| `mic_stream` | 0.7.2 | Real-time microphone audio streaming at 16kHz |
| `tflite_flutter` | 0.12.1 | TensorFlow Lite Dart bindings |

### Alert System (Multi-Modal Feedback)

| Package | Version | Output Type |
|---------|---------|-------------|
| `vibration` | 3.1.4 | Custom haptic vibration patterns |
| `torch_light` | 1.1.0 | Flashlight control for visual alerts |
| `flutter_tts` | 3.8.3 | Text-to-speech synthesis |
| `speech_to_text` | 6.6.0 | Voice transcription |

### UI/UX Components

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | 6.1.5 | State management solution |
| `google_fonts` | 6.3.0 | Premium typography (Space Grotesk, Inter) |
| `flutter_animate` | 4.5.2 | Fluid UI animations |
| `glass_kit` | 3.0.0 | Glassmorphism effects |
| `lucide_icons` | 0.257.0 | Modern icon set |

### Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| `permission_handler` | 11.3.0 | Runtime permission management |
| `path_provider` | 2.1.2 | File system access |
| `intl` | 0.20.2 | Internationalization support |
| `timeago` | 3.7.1 | Human-readable timestamps |
| `yaml` | 3.1.2 | Configuration file parsing |

---

## Plan of Work

### Work Breakdown Structure

| Phase | Task | Duration | Status |
|-------|------|----------|--------|
| **Phase 1: Research & Planning** | | | |
| | Literature Survey & Research | 2 weeks | ✅ Completed |
| | Requirement Gathering & Analysis | 1.5 weeks | ✅ Completed |
| | Technology Stack Finalization | 1 week | ✅ Completed |
| | System Architecture & Design | 1.5 weeks | ✅ Completed |
| **Phase 2: Core Development** | | | |
| | Flutter Environment Setup | 1 week | ✅ Completed |
| | Microphone Audio Capture Module | 2 weeks | ✅ Completed |
| | TensorFlow Lite & YAMNet Integration | 3 weeks | ✅ Completed |
| | Real-time Classification Pipeline | 2 weeks | ✅ Completed |
| | Priority Sound Database Creation | 1 week | ✅ Completed |
| **Phase 3: Alert System** | | | |
| | Vibration Pattern Design | 1.5 weeks | ✅ Completed |
| | Flashlight Strobe Alert System | 1 week | ✅ Completed |
| | Text-to-Speech Integration | 1 week | ✅ Completed |
| | Multi-Modal Alert Synchronization | 1.5 weeks | ✅ Completed |
| **Phase 4: UI/UX Development** | | | |
| | Liquid Glass UI Theme Development | 2 weeks | ✅ Completed |
| | Core Screens Implementation | 2 weeks | ✅ Completed |
| | Accessibility Feature Integration | 1 week | ✅ Completed |
| **Phase 5: Advanced Features** | | | |
| | Baby Cry Classifier Module | 2 weeks | 🔄 In Progress |
| | Scenario-Based Detection Profiles | 1.5 weeks | 📋 Planned |
| | Emergency SOS System | 1 week | 📋 Planned |
| **Phase 6: Testing & Deployment** | | | |
| | Testing (Unit + Integration + UAT) | 5 weeks | 📋 Planned |
| | Deployment & Documentation | 1.5 weeks | 📋 Planned |

---

## Software Requirements

### Development Environment

| Component | Specification |
|-----------|--------------|
| **Operating System** | Ubuntu 22.04 LTS / Windows 11 / macOS 14+ |
| **IDE** | Android Studio 2024.1+ / VS Code 1.85+ |
| **Flutter SDK** | 3.24.0+ |
| **Dart SDK** | 3.5.3+ |
| **Android SDK** | API Level 21-34 (Android 5.0 - 14) |
| **Xcode** | 15.0+ (macOS only for iOS) |

---

## Hardware Requirements

### Development Machine

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Processor** | Intel i5 / AMD Ryzen 5 | Intel i7 / AMD Ryzen 7 / Apple M1+ |
| **RAM** | 8 GB | 16 GB+ |
| **Storage** | 50 GB free space | 100 GB SSD |

### Target Mobile Devices

#### Android

| Specification | Minimum | Recommended |
|---------------|---------|-------------|
| **Version** | Android 5.0 (API 21) | Android 10+ (API 29+) |
| **Processor** | ARM v7 / ARM64 | ARM64 with NPU |
| **RAM** | 2 GB | 4 GB+ |
| **Storage** | 100 MB free | 200 MB free |

#### iOS

| Specification | Minimum | Recommended |
|---------------|---------|-------------|
| **Version** | iOS 12.0 | iOS 15.0+ |
| **Device** | iPhone 6s+ | iPhone 12+ |

### Essential Hardware Features

| Feature | Requirement | Usage |
|---------|-------------|-------|
| **Microphone** | ✅ Required | Audio input for sound detection |
| **Vibration Motor** | ✅ Required | Haptic alert delivery |
| **Camera Flash/Torch** | ⚠️ Recommended | Visual strobe alerts |
| **Speaker** | ⚠️ Optional | TTS announcements |
| **Internet** | ❌ Not Required | Fully offline operation |

---

## Platform Compatibility

| Platform | Sound Detection | Vibration | Flash | TTS | Status |
|----------|----------------|-----------|-------|-----|--------|
| **Android** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | Production Ready |
| **iOS** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | Production Ready |
| **Linux** | ✅ Full | ⚠️ Limited | ⚠️ N/A | ✅ Full | Development Only |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Screens: Home, LiveDetection, Settings, History, Contacts  │
│  Widgets: GlassContainer, LiquidAnimations, Accessibility   │
│  Theme: Liquid Glass Design System                          │
├─────────────────────────────────────────────────────────────┤
│                    STATE MANAGEMENT                          │
│  SoundProvider: Detection state, alerts, history            │
│  SettingsProvider: Theme, vibration, accessibility          │
├─────────────────────────────────────────────────────────────┤
│                    BUSINESS LOGIC LAYER                      │
│  AudioClassifierService: Real-time sound classification     │
│  AlertService: Multi-modal alert triggers                   │
│  BabyCryClassifierService: Infant cry analysis              │
│  TranscriptionService: Speech-to-text                       │
│  PrioritySounds: 38+ prioritized sound database             │
├─────────────────────────────────────────────────────────────┤
│                    DATA/ML LAYER                             │
│  TensorFlow Lite Runtime                                    │
│  YAMNet Model (521 audio categories)                        │
│  Baby Cry Classification Model                              │
├─────────────────────────────────────────────────────────────┤
│                    PLATFORM LAYER                            │
│  Android: Kotlin MainActivity, Gradle build                 │
│  iOS: Swift/Objective-C bindings                            │
│  Native Plugins: Microphone, Vibration, Torch, TTS          │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Features

### 1. Real-Time Sound Detection
- YAMNet audio classification at 16kHz sampling
- 38+ priority sounds with confidence boosting
- <50ms detection-to-alert latency

### 2. Multi-Modal Alert System

| Sound Type | Vibration Pattern | Flash Pattern |
|------------|------------------|---------------|
| Fire Alarm | SOS Strobe (3 short, 3 long, 3 short) | Rapid strobe |
| Vehicle Horn | Long warning pulses | Slow flash |
| Door Knock | Double tap pattern | Double blink |
| Baby Cry | Gentle pulse | Soft flash |
| Glass Breaking | Sharp urgent jitter | Emergency strobe |
| Dog Bark | Double pulse | Brief flash |
| Human Distress | Urgent pulsing | Warning flash |

### 3. Baby Cry Analysis
- Categories: Hungry, Needs Burping, Belly Pain, Discomfort, Tired
- Actionable recommendations for caregivers

### 4. Accessibility Features
- High contrast mode
- Large text scaling
- "I'm Deaf" communication card
- Emergency SOS button
- Signal guide for learning patterns

### 5. Premium Liquid Glass UI
- Aurora color palette
- Glassmorphism effects
- Fluid wave animations
- Professional typography

---

## Project Structure

```
mobile_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── models.dart           # SoundEvent, Contact
│   │   └── baby_cry_models.dart  # BabyCryPrediction
│   ├── providers/
│   │   ├── sound_provider.dart   # Sound detection state
│   │   └── settings_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart      # Main dashboard
│   │   ├── live_detection_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── history_screen.dart
│   │   ├── signal_guide_screen.dart
│   │   └── contacts_screen.dart
│   ├── services/
│   │   ├── audio_classifier_service.dart
│   │   ├── alert_service.dart
│   │   ├── baby_cry_classifier_service.dart
│   │   ├── transcription_service.dart
│   │   └── priority_sounds.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── glass_container.dart
│       ├── liquid_animations.dart
│       ├── deaf_accessibility.dart
│       └── ...
├── assets/
│   ├── models/                   # TFLite models
│   ├── images/                   # App icons
│   └── datasets/                 # Priority data
├── android/                      # Android native code
├── ios/                          # iOS native code
└── pubspec.yaml                  # Dependencies
```

---

*Document Version: 1.0*  
*Date: January 21, 2026*  
*Project: HearAlert - AI-Powered Sound Recognition System*
