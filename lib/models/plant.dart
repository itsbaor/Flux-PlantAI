import 'dart:convert';

/// Complete Plant model for Garden storage
class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String imagePath; // Local image path from scan
  final double confidence;
  final List<String> characteristics;
  final DateTime addedDate;

  // Care information (will be fetched from Gemini)
  final String? wateringFrequency;
  final String? sunlightRequirement;
  final String? soilType;
  final String? fertilizer;
  final List<String>? careInstructions;

  // Health tracking
  final String healthStatus; // excellent, good, fair, poor
  final List<String>? commonIssues;

  // Additional info
  final String? category; // Indoor, Outdoor
  final String? difficulty; // Easy, Medium, Hard
  final int? heightCm;
  final int? waterMl;
  final int? humidityPercent;

  Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imagePath,
    required this.confidence,
    required this.characteristics,
    required this.addedDate,
    this.wateringFrequency,
    this.sunlightRequirement,
    this.soilType,
    this.fertilizer,
    this.careInstructions,
    this.healthStatus = 'good',
    this.commonIssues,
    this.category,
    this.difficulty,
    this.heightCm,
    this.waterMl,
    this.humidityPercent,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'imagePath': imagePath,
      'confidence': confidence,
      'characteristics': characteristics,
      'addedDate': addedDate.toIso8601String(),
      'wateringFrequency': wateringFrequency,
      'sunlightRequirement': sunlightRequirement,
      'soilType': soilType,
      'fertilizer': fertilizer,
      'careInstructions': careInstructions,
      'healthStatus': healthStatus,
      'commonIssues': commonIssues,
      'category': category,
      'difficulty': difficulty,
      'heightCm': heightCm,
      'waterMl': waterMl,
      'humidityPercent': humidityPercent,
    };
  }

  // Create from JSON
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      characteristics: List<String>.from(json['characteristics'] ?? []),
      addedDate: DateTime.parse(json['addedDate'] as String),
      wateringFrequency: json['wateringFrequency'] as String?,
      sunlightRequirement: json['sunlightRequirement'] as String?,
      soilType: json['soilType'] as String?,
      fertilizer: json['fertilizer'] as String?,
      careInstructions: json['careInstructions'] != null
          ? List<String>.from(json['careInstructions'])
          : null,
      healthStatus: json['healthStatus'] as String? ?? 'good',
      commonIssues: json['commonIssues'] != null
          ? List<String>.from(json['commonIssues'])
          : null,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String?,
      heightCm: json['heightCm'] as int?,
      waterMl: json['waterMl'] as int?,
      humidityPercent: json['humidityPercent'] as int?,
    );
  }

  // Convert to string for debugging
  @override
  String toString() {
    return 'Plant(id: $id, name: $name, scientificName: $scientificName)';
  }

  // Copy with method for updates
  Plant copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? description,
    String? imagePath,
    double? confidence,
    List<String>? characteristics,
    DateTime? addedDate,
    String? wateringFrequency,
    String? sunlightRequirement,
    String? soilType,
    String? fertilizer,
    List<String>? careInstructions,
    String? healthStatus,
    List<String>? commonIssues,
    String? category,
    String? difficulty,
    int? heightCm,
    int? waterMl,
    int? humidityPercent,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      confidence: confidence ?? this.confidence,
      characteristics: characteristics ?? this.characteristics,
      addedDate: addedDate ?? this.addedDate,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      sunlightRequirement: sunlightRequirement ?? this.sunlightRequirement,
      soilType: soilType ?? this.soilType,
      fertilizer: fertilizer ?? this.fertilizer,
      careInstructions: careInstructions ?? this.careInstructions,
      healthStatus: healthStatus ?? this.healthStatus,
      commonIssues: commonIssues ?? this.commonIssues,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      heightCm: heightCm ?? this.heightCm,
      waterMl: waterMl ?? this.waterMl,
      humidityPercent: humidityPercent ?? this.humidityPercent,
    );
  }
}

/// Plant care information from Gemini
class PlantCareInfo {
  final String wateringFrequency;
  final String sunlightRequirement;
  final String soilType;
  final String fertilizer;
  final List<String> careInstructions;
  final List<String> commonIssues;
  final String temperatureRange;
  final String humidity;
  final String category;
  final String difficulty;

  PlantCareInfo({
    required this.wateringFrequency,
    required this.sunlightRequirement,
    required this.soilType,
    required this.fertilizer,
    required this.careInstructions,
    required this.commonIssues,
    required this.temperatureRange,
    required this.humidity,
    required this.category,
    required this.difficulty,
  });

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) {
    return PlantCareInfo(
      wateringFrequency: json['wateringFrequency'] ?? 'Unknown',
      sunlightRequirement: json['sunlightRequirement'] ?? 'Unknown',
      soilType: json['soilType'] ?? 'Unknown',
      fertilizer: json['fertilizer'] ?? 'Unknown',
      careInstructions: List<String>.from(json['careInstructions'] ?? []),
      commonIssues: List<String>.from(json['commonIssues'] ?? []),
      temperatureRange: json['temperatureRange'] ?? 'Unknown',
      humidity: json['humidity'] ?? 'Unknown',
      category: json['category'] ?? 'Unknown',
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wateringFrequency': wateringFrequency,
      'sunlightRequirement': sunlightRequirement,
      'soilType': soilType,
      'fertilizer': fertilizer,
      'careInstructions': careInstructions,
      'commonIssues': commonIssues,
      'temperatureRange': temperatureRange,
      'humidity': humidity,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

// Legacy classes for backwards compatibility (if needed)
class TaxonomyItem {
  final String label;
  final String value;

  TaxonomyItem({
    required this.label,
    required this.value,
  });
}

class DiagnosisItem {
  final String name;
  final int percentage;
  final List<String> similarImages;

  DiagnosisItem({
    required this.name,
    required this.percentage,
    required this.similarImages,
  });
}
