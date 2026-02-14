// Priority Sound Configuration for Real-time Detection
// Maps YAMNet class indices to priority levels and alert types

/// Priority levels: 1 = Highest (Emergency), 5 = Lowest (Info)
enum SoundPriority { critical, high, medium, low, info }

/// Alert severity determines vibration intensity and flash pattern
enum AlertSeverity { emergency, warning, attention, info }

class PrioritySound {
  final int yamnetIndex;
  final String displayName;
  final SoundPriority priority;
  final AlertSeverity severity;
  final double confidenceBoost; // Multiplier for confidence
  final double minThreshold; // Minimum confidence to trigger
  final List<String> keywords; // Alternative match keywords

  const PrioritySound({
    required this.yamnetIndex,
    required this.displayName,
    required this.priority,
    required this.severity,
    this.confidenceBoost = 1.0,
    this.minThreshold = 0.15,
    this.keywords = const [],
  });
}

/// Centralized priority sounds database
class PrioritySoundsDatabase {
  static const List<PrioritySound> sounds = [
    // ═══════════════════════════════════════════════════════════════════
    // EMERGENCY SOUNDS - Immediate attention required
    // ═══════════════════════════════════════════════════════════════════
    
    // Fire & Smoke Alarms
    PrioritySound(
      yamnetIndex: 394,
      displayName: "Fire Alarm",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.5,
      minThreshold: 0.10,
      keywords: ['fire', 'alarm', 'smoke'],
    ),
    PrioritySound(
      yamnetIndex: 393,
      displayName: "Smoke Detector",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.5,
      minThreshold: 0.10,
      keywords: ['smoke', 'detector'],
    ),
    PrioritySound(
      yamnetIndex: 292,
      displayName: "Fire",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.5,
      minThreshold: 0.12,
      keywords: ['fire', 'burning'],
    ),
    PrioritySound(
      yamnetIndex: 391,
      displayName: "Civil Defense Siren",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.5,
      minThreshold: 0.10,
      keywords: ['civil defense', 'air raid'],
    ),
    PrioritySound(
      yamnetIndex: 316,
      displayName: "Emergency Vehicle",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['emergency', 'emergency vehicle'],
    ),
    PrioritySound(
      yamnetIndex: 395,
      displayName: "Foghorn",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.2,
      minThreshold: 0.15,
      keywords: ['foghorn'],
    ),
    
    // Glass Breaking - Security threat
    PrioritySound(
      yamnetIndex: 464,
      displayName: "Breaking",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['break', 'breaking'],
    ),
    PrioritySound(
      yamnetIndex: 437,
      displayName: "Shatter",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['shatter', 'glass'],
    ),
    PrioritySound(
      yamnetIndex: 435,
      displayName: "Glass",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['glass'],
    ),
    PrioritySound(
      yamnetIndex: 463,
      displayName: "Smash/Crash",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['smash', 'crash'],
    ),
    
    // Sirens
    PrioritySound(
      yamnetIndex: 390,
      displayName: "Siren",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['siren'],
    ),
    PrioritySound(
      yamnetIndex: 317,
      displayName: "Police Siren",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['police'],
    ),
    PrioritySound(
      yamnetIndex: 318,
      displayName: "Ambulance",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['ambulance'],
    ),
    PrioritySound(
      yamnetIndex: 319,
      displayName: "Fire Engine",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['fire engine', 'fire truck'],
    ),
    
    // Human Distress
    PrioritySound(
      yamnetIndex: 11,
      displayName: "Screaming",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['scream', 'screaming'],
    ),
    
    // ═══════════════════════════════════════════════════════════════════
    // HIGH PRIORITY - Needs prompt attention
    // ═══════════════════════════════════════════════════════════════════
    
    // ─────────────────────────────────────────────────────────────────────
    // DOOR & KNOCK SOUNDS - Comprehensive
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 353,
      displayName: "Knock",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['knock', 'knocking'],
    ),
    PrioritySound(
      yamnetIndex: 348,
      displayName: "Door",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.2,
      minThreshold: 0.15,
      keywords: ['door'],
    ),
    PrioritySound(
      yamnetIndex: 349,
      displayName: "Doorbell",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['doorbell'],
    ),
    PrioritySound(
      yamnetIndex: 350,
      displayName: "Ding-dong",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['ding', 'dong', 'ding-dong'],
    ),
    PrioritySound(
      yamnetIndex: 351,
      displayName: "Sliding Door",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['sliding door'],
    ),
    PrioritySound(
      yamnetIndex: 344,
      displayName: "Engine Knocking",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['engine knocking'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // BELLS - Various types
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 195,
      displayName: "Bell",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['bell'],
    ),
    PrioritySound(
      yamnetIndex: 196,
      displayName: "Church Bell",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['church bell'],
    ),
    PrioritySound(
      yamnetIndex: 197,
      displayName: "Jingle Bell",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['jingle bell'],
    ),
    PrioritySound(
      yamnetIndex: 198,
      displayName: "Bicycle Bell",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['bicycle bell'],
    ),
    PrioritySound(
      yamnetIndex: 173,
      displayName: "Tubular Bells",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['tubular bells'],
    ),
    
    // Baby Cry
    PrioritySound(
      yamnetIndex: 20,
      displayName: "Baby Cry",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['baby', 'cry', 'infant'],
    ),
    PrioritySound(
      yamnetIndex: 19,
      displayName: "Crying",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.2,
      minThreshold: 0.15,
      keywords: ['crying', 'sobbing'],
    ),
    PrioritySound(
      yamnetIndex: 14,
      displayName: "Baby Laughter",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['baby laughter'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // VEHICLE SOUNDS - Comprehensive
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 294,
      displayName: "Vehicle",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['vehicle'],
    ),
    PrioritySound(
      yamnetIndex: 300,
      displayName: "Motor Vehicle",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['motor vehicle', 'road'],
    ),
    PrioritySound(
      yamnetIndex: 301,
      displayName: "Car",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['car'],
    ),
    PrioritySound(
      yamnetIndex: 302,
      displayName: "Car Horn",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.3,
      minThreshold: 0.12,
      keywords: ['horn', 'honk', 'car horn', 'honking'],
    ),
    PrioritySound(
      yamnetIndex: 304,
      displayName: "Car Alarm",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['car alarm'],
    ),
    PrioritySound(
      yamnetIndex: 308,
      displayName: "Car Passing By",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['car passing'],
    ),
    PrioritySound(
      yamnetIndex: 309,
      displayName: "Race Car",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['race car', 'racing'],
    ),
    PrioritySound(
      yamnetIndex: 310,
      displayName: "Truck",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['truck'],
    ),
    PrioritySound(
      yamnetIndex: 312,
      displayName: "Air Horn / Truck Horn",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['air horn', 'truck horn'],
    ),
    PrioritySound(
      yamnetIndex: 314,
      displayName: "Ice Cream Truck",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['ice cream'],
    ),
    PrioritySound(
      yamnetIndex: 325,
      displayName: "Train Horn",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['train horn', 'train'],
    ),
    PrioritySound(
      yamnetIndex: 326,
      displayName: "Train",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['train', 'railroad'],
    ),
    PrioritySound(
      yamnetIndex: 295,
      displayName: "Boat",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['boat', 'water vehicle'],
    ),
    
    // ═══════════════════════════════════════════════════════════════════
    // MEDIUM PRIORITY - Awareness sounds
    // ═══════════════════════════════════════════════════════════════════
    
    // ─────────────────────────────────────────────────────────────────────
    // DOGS
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 69,
      displayName: "Dog",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.5,
      minThreshold: 0.08,
      keywords: ['dog'],
    ),
    PrioritySound(
      yamnetIndex: 70,
      displayName: "Dog Bark",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.5,
      minThreshold: 0.08,
      keywords: ['bark', 'barking'],
    ),
    PrioritySound(
      yamnetIndex: 72,
      displayName: "Howl",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.18,
      keywords: ['howl'],
    ),
    PrioritySound(
      yamnetIndex: 74,
      displayName: "Growling",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['growl', 'growling'],
    ),
    PrioritySound(
      yamnetIndex: 75,
      displayName: "Dog Whimper",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['whimper'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // CATS - Enhanced Detection
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 76,
      displayName: "Cat",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['cat', 'feline', 'kitty', 'kitten'],
    ),
    PrioritySound(
      yamnetIndex: 77,
      displayName: "Purr",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['purr', 'purring', 'cat purr'],
    ),
    PrioritySound(
      yamnetIndex: 78,
      displayName: "Meow",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['meow', 'mew', 'meowing', 'cat cry', 'cat call'],
    ),
    PrioritySound(
      yamnetIndex: 79,
      displayName: "Cat Hiss",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['hiss', 'hissing', 'cat hiss', 'angry cat'],
    ),
    PrioritySound(
      yamnetIndex: 80,
      displayName: "Caterwaul",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['caterwaul', 'caterwauling', 'cat fight', 'cat scream', 'yowl', 'yowling'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // HORSES
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 82,
      displayName: "Horse",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['horse'],
    ),
    PrioritySound(
      yamnetIndex: 83,
      displayName: "Clip-clop",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['clip-clop', 'hooves'],
    ),
    PrioritySound(
      yamnetIndex: 84,
      displayName: "Neigh",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['neigh', 'whinny'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // CATTLE / COWS
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 85,
      displayName: "Cattle",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['cattle', 'bovine'],
    ),
    PrioritySound(
      yamnetIndex: 86,
      displayName: "Moo",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.18,
      keywords: ['moo', 'cow'],
    ),
    PrioritySound(
      yamnetIndex: 87,
      displayName: "Cowbell",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['cowbell'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // PIGS
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 88,
      displayName: "Pig",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['pig'],
    ),
    PrioritySound(
      yamnetIndex: 89,
      displayName: "Oink",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.18,
      keywords: ['oink'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // GOATS & SHEEP
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 90,
      displayName: "Goat",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['goat'],
    ),
    PrioritySound(
      yamnetIndex: 91,
      displayName: "Bleat",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.18,
      keywords: ['bleat'],
    ),
    PrioritySound(
      yamnetIndex: 92,
      displayName: "Sheep",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['sheep'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // POULTRY (Chickens, Ducks, Geese, Turkey)
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 93,
      displayName: "Fowl",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['fowl'],
    ),
    PrioritySound(
      yamnetIndex: 94,
      displayName: "Chicken/Rooster",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['chicken', 'rooster'],
    ),
    PrioritySound(
      yamnetIndex: 95,
      displayName: "Cluck",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['cluck'],
    ),
    PrioritySound(
      yamnetIndex: 96,
      displayName: "Cock-a-doodle-doo",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.15,
      keywords: ['crow', 'cock-a-doodle'],
    ),
    PrioritySound(
      yamnetIndex: 97,
      displayName: "Turkey",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['turkey'],
    ),
    PrioritySound(
      yamnetIndex: 98,
      displayName: "Gobble",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['gobble'],
    ),
    PrioritySound(
      yamnetIndex: 99,
      displayName: "Duck",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['duck'],
    ),
    PrioritySound(
      yamnetIndex: 100,
      displayName: "Quack",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.18,
      keywords: ['quack'],
    ),
    PrioritySound(
      yamnetIndex: 101,
      displayName: "Goose",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['goose'],
    ),
    PrioritySound(
      yamnetIndex: 102,
      displayName: "Goose Honk",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.1,
      minThreshold: 0.18,
      keywords: ['honk'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // WILD ANIMALS (Lions, Tigers, etc.)
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 104,
      displayName: "Roaring Cats",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['lion', 'tiger'],
    ),
    PrioritySound(
      yamnetIndex: 105,
      displayName: "Roar",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['roar'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // BIRDS
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 106,
      displayName: "Bird",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['bird'],
    ),
    PrioritySound(
      yamnetIndex: 107,
      displayName: "Bird Song",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['bird call', 'bird song'],
    ),
    PrioritySound(
      yamnetIndex: 108,
      displayName: "Chirp/Tweet",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['chirp', 'tweet'],
    ),
    PrioritySound(
      yamnetIndex: 109,
      displayName: "Squawk",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['squawk'],
    ),
    PrioritySound(
      yamnetIndex: 110,
      displayName: "Pigeon/Dove",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['pigeon', 'dove'],
    ),
    PrioritySound(
      yamnetIndex: 111,
      displayName: "Coo",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['coo'],
    ),
    PrioritySound(
      yamnetIndex: 112,
      displayName: "Crow",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['crow'],
    ),
    PrioritySound(
      yamnetIndex: 113,
      displayName: "Caw",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['caw'],
    ),
    PrioritySound(
      yamnetIndex: 114,
      displayName: "Owl",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['owl'],
    ),
    PrioritySound(
      yamnetIndex: 115,
      displayName: "Hoot",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['hoot'],
    ),
    PrioritySound(
      yamnetIndex: 116,
      displayName: "Bird Flight",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['flapping', 'wings'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // WOLVES / CANIDAE
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 117,
      displayName: "Wolves",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.3,
      minThreshold: 0.15,
      keywords: ['wolf', 'wolves'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // RODENTS
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 118,
      displayName: "Rodents",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['rodent', 'rat', 'mice'],
    ),
    PrioritySound(
      yamnetIndex: 119,
      displayName: "Mouse",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['mouse'],
    ),
    PrioritySound(
      yamnetIndex: 120,
      displayName: "Patter",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.25,
      keywords: ['patter'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // INSECTS
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 121,
      displayName: "Insect",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['insect'],
    ),
    PrioritySound(
      yamnetIndex: 122,
      displayName: "Cricket",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['cricket'],
    ),
    PrioritySound(
      yamnetIndex: 123,
      displayName: "Mosquito",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['mosquito'],
    ),
    PrioritySound(
      yamnetIndex: 124,
      displayName: "Fly",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.25,
      keywords: ['fly', 'housefly'],
    ),
    PrioritySound(
      yamnetIndex: 125,
      displayName: "Buzz",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.1,
      minThreshold: 0.20,
      keywords: ['buzz', 'buzzing'],
    ),
    PrioritySound(
      yamnetIndex: 126,
      displayName: "Bee/Wasp",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['bee', 'wasp'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // AMPHIBIANS & REPTILES
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 127,
      displayName: "Frog",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['frog'],
    ),
    PrioritySound(
      yamnetIndex: 128,
      displayName: "Croak",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.20,
      keywords: ['croak'],
    ),
    PrioritySound(
      yamnetIndex: 129,
      displayName: "Snake",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['snake'],
    ),
    PrioritySound(
      yamnetIndex: 130,
      displayName: "Rattle",
      priority: SoundPriority.high,
      severity: AlertSeverity.warning,
      confidenceBoost: 1.4,
      minThreshold: 0.12,
      keywords: ['rattle', 'rattlesnake'],
    ),
    
    // ─────────────────────────────────────────────────────────────────────
    // MARINE LIFE
    // ─────────────────────────────────────────────────────────────────────
    PrioritySound(
      yamnetIndex: 131,
      displayName: "Whale",
      priority: SoundPriority.low,
      severity: AlertSeverity.info,
      confidenceBoost: 1.0,
      minThreshold: 0.22,
      keywords: ['whale'],
    ),
    
    // Telephone
    PrioritySound(
      yamnetIndex: 384,
      displayName: "Telephone Ring",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['telephone', 'ring', 'phone'],
    ),
    PrioritySound(
      yamnetIndex: 385,
      displayName: "Ringtone",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['ringtone'],
    ),
    
    // Alarms & Bells
    PrioritySound(
      yamnetIndex: 382,
      displayName: "Alarm",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.15,
      keywords: ['alarm'],
    ),
    PrioritySound(
      yamnetIndex: 389,
      displayName: "Alarm Clock",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.18,
      keywords: ['alarm clock'],
    ),
    
    // Shout
    PrioritySound(
      yamnetIndex: 6,
      displayName: "Shout",
      priority: SoundPriority.medium,
      severity: AlertSeverity.attention,
      confidenceBoost: 1.2,
      minThreshold: 0.15,
      keywords: ['shout', 'yell'],
    ),
    
    // Explosion
    PrioritySound(
      yamnetIndex: 420,
      displayName: "Explosion",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.5,
      minThreshold: 0.10,
      keywords: ['explosion', 'blast'],
    ),
    
    // Gunshot
    PrioritySound(
      yamnetIndex: 421,
      displayName: "Gunshot",
      priority: SoundPriority.critical,
      severity: AlertSeverity.emergency,
      confidenceBoost: 1.5,
      minThreshold: 0.10,
      keywords: ['gunshot', 'gunfire'],
    ),
  ];

  /// Get priority sound by YAMNet index
  static PrioritySound? getByIndex(int index) {
    try {
      return sounds.firstWhere((s) => s.yamnetIndex == index);
    } catch (_) {
      return null;
    }
  }

  /// Get priority sound by keyword match
  static PrioritySound? getByKeyword(String label) {
    final lower = label.toLowerCase();
    for (final sound in sounds) {
      for (final keyword in sound.keywords) {
        if (lower.contains(keyword)) {
          return sound;
        }
      }
    }
    return null;
  }

  /// Check if a sound at given index is priority
  static bool isPriority(int index) => getByIndex(index) != null;

  /// Get all indices that are priority sounds
  static Set<int> get priorityIndices => sounds.map((s) => s.yamnetIndex).toSet();

  /// Get sounds by severity
  static List<PrioritySound> getBySeverity(AlertSeverity severity) {
    return sounds.where((s) => s.severity == severity).toList();
  }
  
  /// Get sounds by priority level
  static List<PrioritySound> getByPriority(SoundPriority priority) {
    return sounds.where((s) => s.priority == priority).toList();
  }

  /// Get throttle duration based on priority
  static Duration getThrottleDuration(SoundPriority priority) {
    switch (priority) {
      case SoundPriority.critical:
        return const Duration(milliseconds: 800);
      case SoundPriority.high:
        return const Duration(milliseconds: 1500);
      case SoundPriority.medium:
        return const Duration(seconds: 2);
      case SoundPriority.low:
        return const Duration(seconds: 3);
      case SoundPriority.info:
        return const Duration(seconds: 4);
    }
  }
}
