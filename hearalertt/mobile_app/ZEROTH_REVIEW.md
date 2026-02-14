# Zeroth Review Document

---

## Title

**"HearAlert: AI-Powered Real-Time Sound Recognition and Multi-Modal Alert System for Deaf and Hard-of-Hearing Individuals"**

---

## Abstract

Hearing impairment significantly impacts an individual's ability to perceive environmental sounds critical for safety, communication, and daily living. Traditional assistive devices like hearing aids provide limited functionality and fail to address the diverse acoustic environments deaf individuals encounter. This project presents **HearAlert**, an innovative mobile application leveraging **"Artificial intelligence and machine learning"** to provide real-time environmental sound recognition and intelligent alerting specifically designed for deaf and hard-of-hearing users.

The system employs **TensorFlow Lite's YAMNet model** —a deep neural network trained on the AudioSet dataset—capable of classifying over **more than 500 distinct sound categories** including emergency sounds (fire alarms, sirens), human interactions (doorbell, door knocking), infant cries, animal sounds, and potential dangers (glass breaking, vehicle horns). The application processes audio input at **16kHz sampling rate** with inference latency under **(50 milliseconds)**, enabling near-instantaneous detection and response.

HearAlert implements a sophisticated **multi-modal alert mechanism** that delivers notifications through:

- **Haptic Feedback:** Category-specific vibration patterns (e.g., SOS pattern for fire alarms, gentle pulses for baby cries)
- **Visual Alerts:** Flashlight strobe patterns synchronized with sound urgency.
- **Text-to-Speech:** Voice announcements for partially hearing users.

A **priority-based detection engine** with 38+ prioritized sound categories ensures critical sounds receive immediate attention with enhanced detection thresholds. The specialized **Baby Cry Classifier** module provides additional categorization of infant distress signals (hunger, discomfort, tiredness), offering actionable insights for caregivers.

---

## Plan of Work

### Gantt Chart Overview

| Phase | Description | Duration | Timeline |
|-------|-------------|----------|----------|
| Phase 1 | Research & Planning | 6 weeks | Sep - Oct 2025 |
| Phase 2 | Core Development | 9 weeks | Oct - Dec 2025 |
| Phase 3 | Alert System | 5 weeks | Nov - Jan 2026 |
| Phase 4 | UI/UX Development | 5 weeks | Dec - Jan 2026 |
| Phase 5 | Advanced Features | 5 weeks | Dec - Feb 2026 |
| Phase 6 | Testing & Deployment | 7 weeks | Jan - Mar 2026 |

---

### Work Breakdown Structure

#### Phase 1: Research & Planning

| Task | Description | Deliverable |
|------|-------------|-------------|
| Literature Survey | Study existing accessibility apps, research audio ML models | Comparison report |
| Requirement Analysis | Functional and non-functional requirements gathering | SRS document |
| Tech Stack Selection | Framework comparison, ML runtime selection | Technology decision |
| System Design | Architecture design, database design, UI wireframes | Design document |

---

#### Phase 2: Core Development

| Task | Description | Deliverable |
|------|-------------|-------------|
| Project Setup | Flutter project initialization, platform configuration | Base project |
| Audio Capture | Microphone stream implementation at 16kHz | Audio pipeline |
| ML Integration | TensorFlow Lite and YAMNet model integration | Classification engine |
| Classification Engine | Real-time inference pipeline implementation | Sound classifier |
| Priority Database | 38+ prioritized sounds with confidence boosting | Priority database |

---

#### Phase 3: Alert System

| Task | Description | Deliverable |
|------|-------------|-------------|
| Vibration Patterns | Category-specific patterns with exact millisecond specifications | Vibration service |
| Flashlight Alerts | Torch API integration, strobe pattern implementation | Flash service |
| TTS Integration | Text-to-speech setup, announcement templates | TTS service |
| Multi-Modal Sync | Synchronized alert delivery across all modalities | Alert service |

**Vibration Pattern Specifications:**

| Sound Type | Pattern (milliseconds) | Description |
|------------|------------------------|-------------|
| Fire Alarm | [100,100]×3 + [300,100]×3 + [100,100]×3 | SOS strobe pattern |
| Vehicle Horn | [500,200,500,200,500] | Long warning pulses |
| Door Knock | [100,50,100,300,100,50,100] | Double tap pattern |
| Baby Cry | [200,100,200,100,200] | Gentle pulse |
| Glass Breaking | [50,30]×10 | Sharp urgent jitter |

---

#### Phase 4: UI/UX Development

| Task | Description | Deliverable |
|------|-------------|-------------|
| Liquid Glass Theme | Color palette, typography, glassmorphism effects | Theme system |
| Screen Implementations | Home, Live Detection, Settings, History screens | All screens |
| Accessibility Features | High contrast, large text, deaf card, signal guide | Accessibility widgets |

---

#### Phase 5: Advanced Features

| Task | Description | Deliverable |
|------|-------------|-------------|
| Baby Cry Classifier | Custom ML model for infant cry categorization | Baby cry service |
| Scenario Profiles | Home, Street, School detection modes | Profile manager |
| Emergency SOS | One-tap emergency trigger with contact alerts | SOS system |

---

#### Phase 6: Testing & Deployment

| Task | Description | Deliverable |
|------|-------------|-------------|
| Unit Testing | Service, provider, and model unit tests | Test suite |
| Integration Testing | End-to-end flow, platform testing | Test reports |
| UAT Testing | Deaf user testing, accessibility audit | UAT report |
| Bug Fixes | Critical fixes, performance optimization | Stable build |
| Final Release | Play Store and App Store submission | Production app |

---

## Development Environment & Component Specification

| Component | Specification |
|-----------|---------------|
| Operating System | Ubuntu 22.04 LTS / Windows 11 / macOS 14+ |
| IDE | Android Studio 2024.1+ / VS Code 1.85+ |
| Flutter SDK | 3.24.0+ |
| Dart SDK | 3.5.3+ |
| Android SDK | API Level 21-34 (Android 5.0 - 14) |
| Xcode | 15.0+ (macOS only for iOS) |

---

## Hardware Requirements

### Development Machine

| Component | Minimum Requirement | Recommended Requirement |
|-----------|---------------------|-------------------------|
| Processor | Intel i5 / AMD Ryzen 5 | Intel i7 / AMD Ryzen 7 / Apple M1 or above |
| RAM | 8 GB | 16 GB or above |
| Storage | 50 GB free space | 100 GB SSD |

---

## Target Mobile Devices

### Android Requirements

| Specification | Minimum Requirement | Recommended Requirement |
|---------------|---------------------|-------------------------|
| Android Version | Android 5.0 (API Level 21) | Android 10 or above (API Level 29+) |
| Processor | ARM v7 / ARM64 | ARM64 with Neural Processing Unit |
| RAM | 2 GB | 4 GB or above |
| Storage | 100 MB free space | 200 MB free space |

### iOS Requirements

| Specification | Minimum Requirement | Recommended Requirement |
|---------------|---------------------|-------------------------|
| iOS Version | iOS 12.0 | iOS 15.0 or above |
| Device Model | iPhone 6s or newer | iPhone 12 or newer |

---

## Essential Hardware Features

| Hardware Feature | Requirement Status | Usage |
|------------------|-------------------|-------|
| Microphone | ✅ Required | Audio input for sound detection |
| Vibration Motor | ✅ Required | Haptic alert delivery |
| Camera Flash / Torch | ⚠️ Recommended | Visual strobe alerts |
| Speaker | ⚡ Optional | Text-to-speech announcements |
| Internet Connectivity | ❌ Not Required | Fully offline operation |

---

*Document Version: 1.0*  
*Date: January 22, 2026*  
*Project: HearAlert - AI-Powered Sound Recognition System*
