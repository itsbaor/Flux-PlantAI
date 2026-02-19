class HealthIssue {
  final String name;
  final String description;
  final double percentage;
  final List<String> imageUrls;
  final String severity; // 'low', 'medium', 'high'
  final List<String> solutions;

  HealthIssue({
    required this.name,
    required this.description,
    required this.percentage,
    required this.imageUrls,
    required this.severity,
    required this.solutions,
  });

  factory HealthIssue.fromJson(Map<String, dynamic> json) {
    return HealthIssue(
      name: json['name'] as String,
      description: json['description'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      severity: json['severity'] as String,
      solutions: (json['solutions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'percentage': percentage,
      'imageUrls': imageUrls,
      'severity': severity,
      'solutions': solutions,
    };
  }
}

class PlantDiagnosisReport {
  final String plantName;
  final List<HealthIssue> issues;
  final String overallHealth; // 'excellent', 'good', 'fair', 'poor'

  PlantDiagnosisReport({
    required this.plantName,
    required this.issues,
    required this.overallHealth,
  });

  factory PlantDiagnosisReport.fromJson(Map<String, dynamic> json) {
    return PlantDiagnosisReport(
      plantName: json['plantName'] as String,
      issues: (json['issues'] as List<dynamic>)
          .map((e) => HealthIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallHealth: json['overallHealth'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantName': plantName,
      'issues': issues.map((e) => e.toJson()).toList(),
      'overallHealth': overallHealth,
    };
  }
}
