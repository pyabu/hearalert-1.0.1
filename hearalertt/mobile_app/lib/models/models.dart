class SoundEvent {
  final String id;
  final String label;
  final double confidence;
  final DateTime timestamp;
  final String type; // 'emergency', 'warning', 'info'

  SoundEvent({
    required this.id,
    required this.label,
    required this.confidence,
    required this.timestamp,
    required this.type,
  });
  
  bool get isEmergency => type == 'emergency';
}

class Contact {
  final String name;
  final String phone;
  final String relation;

  Contact({required this.name, required this.phone, required this.relation});

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relation': relation,
  };

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phone: json['phone'],
      relation: json['relation'],
    );
  }
}

enum VibrationIntensity { low, medium, high }
