# HearAlert - Plan of Work

---

## Detailed Gantt Chart

```mermaid
gantt
    title HearAlert Project Development Timeline
    dateFormat YYYY-MM-DD
    axisFormat %b %d
    todayMarker stroke-width:3px,stroke:#ff0000
    
    section Phase 1: Research & Planning
    Literature Survey              :done, lit, 2025-09-01, 14d
    Existing Apps Analysis         :done, apps, 2025-09-01, 7d
    ML Model Research              :done, mlr, 2025-09-08, 7d
    Deaf User Needs Survey         :done, survey, 2025-09-08, 7d
    Functional Requirements        :done, freq, 2025-09-15, 7d
    Non-Functional Requirements    :done, nfreq, 2025-09-15, 7d
    Use Case Modeling              :done, usecase, 2025-09-22, 5d
    Framework Comparison           :done, frame, 2025-09-27, 4d
    ML Runtime Selection           :done, mlsel, 2025-09-27, 4d
    Package Evaluation             :done, pkg, 2025-10-01, 3d
    Architecture Design            :done, arch, 2025-10-04, 7d
    Database Design                :done, db, 2025-10-04, 5d
    UI/UX Wireframes               :done, wire, 2025-10-09, 5d
    MILESTONE: Planning Complete   :milestone, m1, 2025-10-14, 0d
    
    section Phase 2: Core Development
    Flutter Project Setup          :done, setup, 2025-10-15, 5d
    Android Configuration          :done, android, 2025-10-15, 3d
    iOS Configuration              :done, ios, 2025-10-18, 3d
    Git Repository Setup           :done, git, 2025-10-20, 2d
    Microphone Permission Handler  :done, perm, 2025-10-22, 5d
    Audio Stream Implementation    :done, stream, 2025-10-27, 7d
    Audio Preprocessing            :done, preproc, 2025-11-03, 5d
    TFLite Plugin Configuration    :done, tflite, 2025-11-08, 7d
    YAMNet Model Integration       :done, yamnet, 2025-11-15, 10d
    Label Parsing & Mapping        :done, labels, 2025-11-25, 4d
    Real-time Inference Pipeline   :done, infer, 2025-11-29, 10d
    Confidence Scoring System      :done, conf, 2025-12-09, 5d
    Priority Sound Database        :done, priority, 2025-12-14, 7d
    Confidence Boosting Logic      :done, boost, 2025-12-14, 5d
    MILESTONE: Classification Done :milestone, m2, 2025-12-21, 0d
    
    section Phase 3: Alert System
    Vibration Pattern Research     :done, vibres, 2025-11-15, 5d
    Vibration API Integration      :done, vibapi, 2025-11-20, 5d
    Fire Alarm Pattern             :done, fire, 2025-11-25, 2d
    Vehicle Horn Pattern           :done, horn, 2025-11-27, 2d
    Door Knock Pattern             :done, door, 2025-11-29, 2d
    Baby Cry Pattern               :done, baby, 2025-12-01, 2d
    Glass Breaking Pattern         :done, glass, 2025-12-03, 2d
    Other Alert Patterns           :done, other, 2025-12-05, 3d
    Torch Light API Integration    :done, torch, 2025-12-08, 5d
    Flash Pattern Implementation   :done, flash, 2025-12-13, 3d
    TTS Plugin Setup               :done, ttssetup, 2025-12-16, 3d
    Announcement Templates         :done, announce, 2025-12-19, 3d
    Alert Service Implementation   :done, alertsvc, 2025-12-22, 5d
    Multi-Modal Synchronization    :done, sync, 2025-12-27, 5d
    MILESTONE: Alerts Complete     :milestone, m3, 2026-01-01, 0d
    
    section Phase 4: UI/UX Development
    Color Palette Design           :done, colors, 2025-12-01, 3d
    Typography System              :done, typo, 2025-12-04, 3d
    Liquid Glass Theme             :done, liquid, 2025-12-07, 7d
    Glass Container Widget         :done, glasswid, 2025-12-14, 5d
    Liquid Animations              :done, liquidanim, 2025-12-19, 5d
    Home Screen Implementation     :done, home, 2025-12-24, 7d
    Live Detection Screen          :done, live, 2025-12-31, 5d
    Settings Screen                :done, settings, 2026-01-05, 5d
    History Screen                 :done, history, 2026-01-10, 4d
    High Contrast Mode             :done, contrast, 2026-01-14, 3d
    Large Text Support             :done, largetext, 2026-01-17, 2d
    Deaf Card Widget               :done, deafcard, 2026-01-19, 3d
    Signal Guide Screen            :done, sigguide, 2026-01-22, 3d
    MILESTONE: UI Complete         :milestone, m4, 2026-01-25, 0d
    
    section Phase 5: Advanced Features
    Baby Cry Dataset Collection    :active, babyset, 2025-12-20, 7d
    Baby Cry Model Training        :active, babytrain, 2025-12-27, 10d
    Baby Cry Service Integration   :active, babysvc, 2026-01-06, 7d
    Baby Cry Alert Dialog          :active, babyalert, 2026-01-13, 4d
    Home Mode Profile              :homeprof, 2026-01-17, 5d
    Street Mode Profile            :streetprof, 2026-01-22, 5d
    School Mode Profile            :schoolprof, 2026-01-27, 5d
    Profile Manager                :profmgr, 2026-02-01, 4d
    SOS Button Widget              :sosbtn, 2026-02-05, 3d
    Contact Management Screen      :contacts, 2026-02-08, 4d
    SOS Dispatch Service           :sosdispatch, 2026-02-12, 4d
    MILESTONE: Features Complete   :milestone, m5, 2026-02-16, 0d
    
    section Phase 6: Testing & Deployment
    Service Unit Tests             :servicetests, 2026-01-25, 7d
    Provider Unit Tests            :providertests, 2026-02-01, 5d
    Model Unit Tests               :modeltests, 2026-02-06, 3d
    End-to-End Flow Tests          :e2e, 2026-02-09, 7d
    Android Platform Testing       :androidtest, 2026-02-16, 5d
    iOS Platform Testing           :iostest, 2026-02-16, 5d
    Performance Testing            :perftest, 2026-02-21, 5d
    Deaf User Testing              :deaftest, 2026-02-26, 7d
    Accessibility Audit            :a11y, 2026-03-01, 4d
    Bug Triage & Fixes             :bugfix, 2026-03-05, 7d
    Performance Optimization       :perf, 2026-03-05, 5d
    UI Polish                      :polish, 2026-03-10, 3d
    Play Store Preparation         :playstore, 2026-03-13, 4d
    App Store Preparation          :appstore, 2026-03-13, 4d
    Documentation Finalization     :docs, 2026-03-17, 3d
    MILESTONE: Final Release       :milestone, m7, 2026-03-20, 0d
```

---

## Gantt Chart Legend

| Symbol | Meaning |
|--------|---------|
| ✅ `done` | Completed tasks (green) |
| 🔄 `active` | Currently in progress (blue) |
| 📋 No tag | Planned/upcoming (gray) |
| 🎯 `milestone` | Key project milestones (diamond) |

---

## Project Timeline Overview

| Phase | Duration | Timeline | Status |
|-------|----------|----------|--------|
| Phase 1: Research & Planning | 6 weeks | Sep 2025 - Oct 2025 | ✅ Completed |
| Phase 2: Core Development | 9 weeks | Oct 2025 - Dec 2025 | ✅ Completed |
| Phase 3: Alert System | 5 weeks | Nov 2025 - Dec 2025 | ✅ Completed |
| Phase 4: UI/UX Development | 5 weeks | Dec 2025 - Jan 2026 | ✅ Completed |
| Phase 5: Advanced Features | 5 weeks | Dec 2025 - Jan 2026 | 🔄 In Progress |
| Phase 6: Testing & Deployment | 7 weeks | Jan 2026 - Mar 2026 | 📋 Planned |

---

## Phase 1: Research & Planning (6 Weeks)

### Week 1-2: Literature Survey
| Task | Details | Deliverable |
|------|---------|-------------|
| Study existing accessibility apps | Analyze Sound Alert, Visualfy, Braci | Comparison report |
| Research audio ML models | YAMNet, VGGish, AudioSet | Model selection document |
| Survey deaf user needs | Interviews, forums, accessibility guidelines | User requirements list |

### Week 3-4: Requirement Analysis
| Task | Details | Deliverable |
|------|---------|-------------|
| Functional requirements | Sound detection, alerts, UI features | SRS document |
| Non-functional requirements | Performance, latency, battery usage | NFR specification |
| Use case modeling | User interactions, edge cases | Use case diagrams |

### Week 5: Technology Stack Selection
| Task | Details | Deliverable |
|------|---------|-------------|
| Framework comparison | Flutter vs React Native vs Native | Framework decision |
| ML runtime selection | TFLite vs CoreML vs PyTorch Mobile | ML stack decision |
| Package evaluation | Audio, vibration, UI libraries | Dependency list |

### Week 6: System Design
| Task | Details | Deliverable |
|------|---------|-------------|
| Architecture design | Layered architecture, provider pattern | Architecture document |
| Database design | Priority sounds, user settings | Data model |
| UI/UX wireframes | Screen layouts, navigation flow | Wireframe mockups |

---

## Phase 2: Core Development (9 Weeks)

### Week 7: Project Setup
| Task | Details | Deliverable |
|------|---------|-------------|
| Flutter project initialization | Create project, configure build | Base project |
| Android/iOS configuration | Permissions, app icons, splash | Platform configs |
| Git repository setup | Branching strategy, .gitignore | Version control |

### Week 8-9: Audio Capture Module
| Task | Details | Deliverable |
|------|---------|-------------|
| Microphone permission handling | Runtime permissions, error handling | Permission service |
| Audio stream implementation | 16kHz sampling, buffering | mic_stream integration |
| Audio preprocessing | Normalization, windowing | Audio pipeline |

### Week 10-12: ML Model Integration
| Task | Details | Deliverable |
|------|---------|-------------|
| TFLite Flutter setup | Plugin configuration, model loading | TFLite service |
| YAMNet model integration | Input preprocessing, inference | Classification engine |
| Label parsing | CSV labels, category mapping | Label mapper |

### Week 13-14: Sound Classification Engine
| Task | Details | Deliverable |
|------|---------|-------------|
| Real-time inference pipeline | Buffer → Process → Classify | Classification stream |
| Confidence scoring | Threshold filtering, top-K results | Score processor |
| Classification result model | Data structures, stream output | ClassificationResult class |

### Week 15: Priority Sound Database
| Task | Details | Deliverable |
|------|---------|-------------|
| Priority sound catalog | 38+ sounds, categories, thresholds | priority_sounds.dart |
| Confidence boosting logic | Category-based score enhancement | Boost algorithm |
| Sound categorization | Emergency, warning, info types | Type classifier |

---

## Phase 3: Alert System (5 Weeks)

### Week 16-17: Vibration Pattern Design
| Task | Details | Deliverable |
|------|---------|-------------|
| Pattern research | SOS, morse, intuitive patterns | Pattern catalog |
| Vibration API integration | Custom patterns, intensity control | Vibration service |
| Category-specific patterns | 12 unique alert patterns | Pattern implementation |

**Vibration Pattern Specifications:**
| Sound Type | Pattern (ms) | Description |
|------------|--------------|-------------|
| Fire Alarm | [100,100]×3 + [300,100]×3 + [100,100]×3 | SOS strobe |
| Vehicle Horn | [500,200,500,200,500] | Long warning |
| Door Knock | [100,50,100,300,100,50,100] | Double tap |
| Baby Cry | [200,100,200,100,200] | Gentle pulse |
| Glass Breaking | [50,30]×10 | Sharp jitter |

### Week 18: Flashlight Alert Module
| Task | Details | Deliverable |
|------|---------|-------------|
| Torch API integration | On/off control, strobe patterns | torch_light service |
| Flash pattern design | Synchronized with vibration | Flash patterns |
| Error handling | Device capability detection | Fallback logic |

### Week 19: TTS Integration
| Task | Details | Deliverable |
|------|---------|-------------|
| flutter_tts setup | Voice configuration, rate/pitch | TTS service |
| Announcement templates | Sound-specific messages | Message templates |
| Queue management | Non-blocking announcements | Announcement queue |

### Week 20: Multi-Modal Synchronization
| Task | Details | Deliverable |
|------|---------|-------------|
| Alert service design | Unified alert trigger | AlertService class |
| Parallel execution | Concurrent vibration + flash + TTS | Async coordination |
| Settings integration | User preferences, enable/disable | Settings binding |

---

## Phase 4: UI/UX Development (5 Weeks)

### Week 21-22: Theme Development
| Task | Details | Deliverable |
|------|---------|-------------|
| Liquid Glass design system | Color palette, typography, spacing | app_theme.dart |
| Glassmorphism widgets | Blur, transparency, borders | glass_container.dart |
| Animation system | Liquid flow, wave effects | liquid_animations.dart |

### Week 23-24: Screen Implementation
| Task | Details | Deliverable |
|------|---------|-------------|
| Home screen | Dashboard, quick actions, status | home_screen.dart |
| Live detection screen | Waveform, real-time results | live_detection_screen.dart |
| Settings screen | Preferences, customization | settings_screen.dart |
| History screen | Alert log, timeline view | history_screen.dart |

### Week 25: Accessibility Features
| Task | Details | Deliverable |
|------|---------|-------------|
| High contrast mode | Dark/light themes, color blindness | Accessibility settings |
| Large text support | Scalable typography | Text scaling |
| Deaf card widget | "I'm Deaf" communication card | deaf_accessibility.dart |
| Signal guide | Pattern learning, demonstrations | signal_guide_screen.dart |

---

## Phase 5: Advanced Features (5 Weeks)

### Week 26-27: Baby Cry Classifier 🔄
| Task | Details | Deliverable |
|------|---------|-------------|
| Custom model training | Baby cry dataset, categories | baby_cry_model.tflite |
| Service implementation | Detection, categorization | baby_cry_classifier_service.dart |
| Alert dialog | Specialized UI for baby alerts | baby_cry_alert_dialog.dart |

**Baby Cry Categories:**
| ID | Category | Recommendation |
|----|----------|----------------|
| 0 | Hungry | Try feeding the baby |
| 1 | Needs Burping | Gently pat the baby's back |
| 2 | Belly Pain | Check for discomfort, try tummy massage |
| 3 | Discomfort | Check diaper, clothing, temperature |
| 4 | Tired | Create calm environment, try rocking |

### Week 28-29: Scenario Profiles 📋
| Task | Details | Deliverable |
|------|---------|-------------|
| Home mode | Doorbell, baby, appliances priority | Home profile |
| Street mode | Traffic, horns, danger priority | Street profile |
| School mode | Bells, announcements priority | School profile |
| Profile switching | Quick toggle, auto-detection | Profile manager |

### Week 30: Emergency SOS 📋
| Task | Details | Deliverable |
|------|---------|-------------|
| SOS button | One-tap emergency trigger | SOS widget |
| Contact management | Emergency contacts list | contacts_screen.dart |
| Alert dispatch | SMS/notification to contacts | SOS service |

---

## Phase 6: Testing & Deployment (7 Weeks)

### Week 31-32: Unit Testing
| Task | Details | Deliverable |
|------|---------|-------------|
| Service tests | AudioClassifier, Alert, BabyCry | Service test suite |
| Provider tests | SoundProvider, SettingsProvider | Provider test suite |
| Model tests | Data class validation | Model test suite |

### Week 33-34: Integration Testing
| Task | Details | Deliverable |
|------|---------|-------------|
| End-to-end flow | Detection → Alert pipeline | E2E test suite |
| Platform testing | Android, iOS, Linux | Platform reports |
| Performance testing | Latency, battery, memory | Performance report |

### Week 35-36: User Acceptance Testing
| Task | Details | Deliverable |
|------|---------|-------------|
| Deaf user testing | Real-world usage feedback | UAT report |
| Accessibility audit | WCAG compliance check | Audit report |
| Bug triage | Issue categorization, priority | Bug tracker |

### Week 37: Bug Fixes & Optimization
| Task | Details | Deliverable |
|------|---------|-------------|
| Critical bug fixes | UAT findings, crashes | Patched release |
| Performance optimization | Battery, memory, latency | Optimized build |
| UI polish | Animation smoothness, edge cases | Final UI |

### Week 38: Deployment 🎉
| Task | Details | Deliverable |
|------|---------|-------------|
| Play Store submission | APK signing, store listing | Android release |
| App Store submission | iOS build, review process | iOS release |
| Documentation | User manual, API docs | Final documentation |

---

## Milestones Summary

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| M1: Project Setup Complete | Oct 7, 2025 | ✅ |
| M2: Audio Classification Working | Nov 15, 2025 | ✅ |
| M3: Alert System Complete | Dec 20, 2025 | ✅ |
| M4: UI/UX Complete | Jan 10, 2026 | ✅ |
| M5: Advanced Features Complete | Feb 1, 2026 | 🔄 |
| M6: Testing Complete | Mar 1, 2026 | 📋 |
| M7: Final Release | Mar 15, 2026 | 📋 |

---

## Team Responsibilities

| Role | Responsibilities |
|------|------------------|
| Developer | Flutter development, ML integration, testing |
| UI/UX Designer | Liquid Glass design, accessibility features |
| ML Engineer | Model training, optimization, deployment |
| QA Tester | Test cases, UAT coordination, bug tracking |

---

*Document Version: 1.0*  
*Last Updated: January 21, 2026*
