class PlantIdentification {
  final String name;
  final String scientificName;
  final String description;
  final String imageUrl;
  final double confidence;
  final List<String> characteristics;

  PlantIdentification({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.confidence,
    required this.characteristics,
  });

  factory PlantIdentification.fromJson(Map<String, dynamic> json) {
    return PlantIdentification(
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      characteristics: (json['characteristics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'imageUrl': imageUrl,
      'confidence': confidence,
      'characteristics': characteristics,
    };
  }
}
