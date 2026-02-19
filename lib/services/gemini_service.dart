import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart' as google_ai;
import '../config/api_config.dart';
import '../models/plant_identification.dart';
import '../models/health_issue.dart';
import '../models/plant.dart';

class GeminiService {
  late final dynamic _model; // Can be either google_ai or firebase_ai model

  GeminiService() {
    // OPTION 1: Use Google AI with API key directly (CURRENT - works immediately)
    // No need to enable Firebase AI API
    // Using gemini-2.5-flash (latest stable model in v1beta)
    _model = google_ai.GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiConfig.geminiApiKey,
    );

    // OPTION 2: Use Firebase AI (RECOMMENDED for production)
    // Requires enabling Firebase AI Logic API first:
    // https://console.developers.google.com/apis/api/firebasevertexai.googleapis.com/overview?project=723817855478
    // Uncomment below and comment out Option 1 after enabling the API:
    //
    // _model = firebase_ai.FirebaseAI.googleAI().generativeModel(
    //   model: 'gemini-2.5-flash',
    // );
  }

  /// Identify plant species from image
  Future<List<PlantIdentification>> identifyPlant(String imagePath) async {
    try {
      // Read image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for plant identification
      final prompt = '''
Analyze this plant image and provide detailed identification information.

Return a JSON response with exactly 3 possible plant identifications, ordered by confidence level (highest first).

Format (MUST BE VALID JSON):
{
  "identifications": [
    {
      "name": "Common name of the plant",
      "scientificName": "Scientific name (genus species)",
      "description": "Brief description of the plant (max 100 characters)",
      "confidence": 0.95,
      "characteristics": ["characteristic1", "characteristic2", "characteristic3"]
    }
  ]
}

Requirements:
- Provide exactly 3 identifications
- Confidence values should be between 0.0 and 1.0
- First identification should have highest confidence
- Include 3-5 key characteristics for each plant
- Keep descriptions concise and informative
''';

      final content = [
        google_ai.Content.multi([
          google_ai.TextPart(prompt),
          google_ai.DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate response
      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse JSON response
      return _parseIdentificationResponse(responseText);
    } catch (e) {
      // Log error and rethrow
      rethrow;
    }
  }

  /// Diagnose plant health issues from image
  Future<PlantDiagnosisReport> diagnosePlant(String imagePath) async {
    try {
      // Read image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for plant diagnosis
      final prompt = '''
Analyze this plant image and diagnose any health issues.

Return a JSON response with plant health diagnosis information.

Format (MUST BE VALID JSON):
{
  "plantName": "Identified plant name",
  "overallHealth": "excellent|good|fair|poor",
  "issues": [
    {
      "name": "Issue name",
      "description": "Brief description of the issue",
      "percentage": 75,
      "severity": "low|medium|high",
      "solutions": ["solution1", "solution2", "solution3"]
    }
  ]
}

Requirements:
- Identify 1-4 main health issues (or state healthy if none)
- Percentage represents likelihood/severity (0-100)
- Severity must be: "low" (<20%), "medium" (20-60%), or "high" (>60%)
- Provide 3-5 practical solutions for each issue
- Order issues by severity (highest first)
''';

      final content = [
        google_ai.Content.multi([
          google_ai.TextPart(prompt),
          google_ai.DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate response
      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse JSON response
      return _parseDiagnosisResponse(responseText);
    } catch (e) {
      // Log error and rethrow
      rethrow;
    }
  }

  /// Parse identification response from Gemini
  List<PlantIdentification> _parseIdentificationResponse(String responseText) {
    try {
      // Extract JSON from markdown code blocks if present
      String jsonText = responseText;
      if (responseText.contains('```json')) {
        final startIndex = responseText.indexOf('```json') + 7;
        final endIndex = responseText.lastIndexOf('```');
        jsonText = responseText.substring(startIndex, endIndex).trim();
      } else if (responseText.contains('```')) {
        final startIndex = responseText.indexOf('```') + 3;
        final endIndex = responseText.lastIndexOf('```');
        jsonText = responseText.substring(startIndex, endIndex).trim();
      }

      // Parse JSON
      final jsonData = parseJson(jsonText);
      final List<dynamic> identificationsJson = jsonData['identifications'] ?? [];

      return identificationsJson.map((json) {
        return PlantIdentification(
          name: json['name'] ?? 'Unknown Plant',
          scientificName: json['scientificName'] ?? 'Unknown',
          description: json['description'] ?? '',
          imageUrl: '',
          confidence: (json['confidence'] ?? 0.0).toDouble(),
          characteristics: List<String>.from(json['characteristics'] ?? []),
        );
      }).toList();
    } catch (e) {
      // Return mock data on parsing error
      return _getMockIdentifications();
    }
  }

  /// Parse diagnosis response from Gemini
  PlantDiagnosisReport _parseDiagnosisResponse(String responseText) {
    try {
      // Extract JSON from markdown code blocks if present
      String jsonText = responseText;
      if (responseText.contains('```json')) {
        final startIndex = responseText.indexOf('```json') + 7;
        final endIndex = responseText.lastIndexOf('```');
        jsonText = responseText.substring(startIndex, endIndex).trim();
      } else if (responseText.contains('```')) {
        final startIndex = responseText.indexOf('```') + 3;
        final endIndex = responseText.lastIndexOf('```');
        jsonText = responseText.substring(startIndex, endIndex).trim();
      }

      // Parse JSON
      final jsonData = parseJson(jsonText);
      final List<dynamic> issuesJson = jsonData['issues'] ?? [];

      final issues = issuesJson.map((json) {
        return HealthIssue(
          name: json['name'] ?? 'Unknown Issue',
          description: json['description'] ?? '',
          percentage: (json['percentage'] ?? 0).toInt(),
          imageUrls: [],
          severity: json['severity'] ?? 'medium',
          solutions: List<String>.from(json['solutions'] ?? []),
        );
      }).toList();

      return PlantDiagnosisReport(
        plantName: jsonData['plantName'] ?? 'Unknown Plant',
        overallHealth: jsonData['overallHealth'] ?? 'fair',
        issues: issues,
      );
    } catch (e) {
      // Return mock data on parsing error
      return _getMockDiagnosis();
    }
  }

  /// Parse JSON string to Map
  Map<String, dynamic> parseJson(String jsonText) {
    try {
      return jsonDecode(jsonText) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  /// Mock data for identification (fallback)
  List<PlantIdentification> _getMockIdentifications() {
    return [
      PlantIdentification(
        name: 'Italian Aster',
        scientificName: 'Aster amellus',
        description: 'Commonly known as Fiddle Leaf Figs in South East Asia',
        imageUrl: '',
        confidence: 0.95,
        characteristics: ['Megachiloda', 'Aster amellus', 'Leaf'],
      ),
      PlantIdentification(
        name: 'Tropical plant',
        scientificName: 'Ficus lyrata',
        description: 'Commonly known as Fiddle Leaf Figs in South East Asia',
        imageUrl: '',
        confidence: 0.85,
        characteristics: ['Megachiloda', 'Aster amellus', 'Leaf'],
      ),
      PlantIdentification(
        name: 'Tropical plant',
        scientificName: 'Monstera deliciosa',
        description: 'Commonly known as Fiddle Leaf Figs in South East Asia',
        imageUrl: '',
        confidence: 0.75,
        characteristics: ['Megachiloda', 'Aster amellus', 'Leaf'],
      ),
    ];
  }

  /// Mock data for diagnosis (fallback)
  PlantDiagnosisReport _getMockDiagnosis() {
    return PlantDiagnosisReport(
      plantName: 'Ginkgo',
      overallHealth: 'fair',
      issues: [
        HealthIssue(
          name: 'Armillaria root rot',
          description: 'Similar Images',
          percentage: 4,
          imageUrls: [],
          severity: 'low',
          solutions: [
            'Remove infected roots',
            'Improve drainage',
            'Apply fungicide',
          ],
        ),
        HealthIssue(
          name: 'water excess or uneven watering',
          description: 'Similar Images',
          percentage: 75,
          imageUrls: [],
          severity: 'high',
          solutions: [
            'Adjust watering schedule',
            'Check soil moisture',
            'Ensure proper drainage',
          ],
        ),
        HealthIssue(
          name: 'mechanical damage',
          description: 'Similar Images',
          percentage: 50,
          imageUrls: [],
          severity: 'medium',
          solutions: [
            'Protect from physical damage',
            'Prune damaged areas',
            'Monitor for infections',
          ],
        ),
      ],
    );
  }

  /// Get plant care information from Gemini
  Future<PlantCareInfo> getPlantCareInfo(String plantName, String scientificName) async {
    try {
      final prompt = '''
Provide comprehensive care instructions for the plant: $plantName ($scientificName).

Return a JSON response with detailed care information.

Format (MUST BE VALID JSON):
{
  "wateringFrequency": "How often to water (e.g., 'Every 2-3 days', 'Weekly')",
  "sunlightRequirement": "Sunlight needs (e.g., 'Full Sun', 'Partial Shade', 'Low Light')",
  "soilType": "Best soil type (e.g., 'Well-draining potting mix', 'Sandy soil')",
  "fertilizer": "Fertilizer recommendations (e.g., 'Monthly during growing season')",
  "careInstructions": ["instruction1", "instruction2", "instruction3", "instruction4", "instruction5"],
  "commonIssues": ["issue1", "issue2", "issue3"],
  "temperatureRange": "Ideal temperature (e.g., '18-24°C', '65-75°F')",
  "humidity": "Humidity requirements (e.g., 'High', 'Moderate', 'Low')",
  "category": "Indoor or Outdoor",
  "difficulty": "Easy, Medium, or Hard"
}

Requirements:
- Provide 5-7 specific care instructions
- List 3-5 common issues to watch for
- Be specific and practical
- Use beginner-friendly language
''';

      final content = [
        google_ai.Content.text(prompt),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      return _parseCareInfoResponse(responseText);
    } catch (e) {
      print('Error getting plant care info: $e');
      // Return default care info
      return PlantCareInfo(
        wateringFrequency: 'Every 2-3 days',
        sunlightRequirement: 'Bright indirect light',
        soilType: 'Well-draining potting mix',
        fertilizer: 'Monthly during growing season',
        careInstructions: [
          'Check soil moisture before watering',
          'Ensure good drainage',
          'Keep away from drafts',
          'Wipe leaves occasionally',
          'Monitor for pests',
        ],
        commonIssues: [
          'Yellowing leaves from overwatering',
          'Brown tips from low humidity',
          'Pests like aphids or mealybugs',
        ],
        temperatureRange: '18-24°C (65-75°F)',
        humidity: 'Moderate (40-60%)',
        category: 'Indoor',
        difficulty: 'Medium',
      );
    }
  }

  /// Parse care info response from Gemini
  PlantCareInfo _parseCareInfoResponse(String responseText) {
    try {
      // Extract JSON from markdown code blocks if present
      String jsonText = responseText;
      if (responseText.contains('```json')) {
        final startIndex = responseText.indexOf('```json') + 7;
        final endIndex = responseText.lastIndexOf('```');
        jsonText = responseText.substring(startIndex, endIndex).trim();
      } else if (responseText.contains('```')) {
        final startIndex = responseText.indexOf('```') + 3;
        final endIndex = responseText.lastIndexOf('```');
        jsonText = responseText.substring(startIndex, endIndex).trim();
      }

      // Parse JSON
      final jsonData = parseJson(jsonText);
      return PlantCareInfo.fromJson(jsonData);
    } catch (e) {
      print('Error parsing care info: $e');
      // Return default care info
      return PlantCareInfo(
        wateringFrequency: 'Every 2-3 days',
        sunlightRequirement: 'Bright indirect light',
        soilType: 'Well-draining potting mix',
        fertilizer: 'Monthly during growing season',
        careInstructions: [
          'Check soil moisture before watering',
          'Ensure good drainage',
          'Keep away from drafts',
          'Wipe leaves occasionally',
          'Monitor for pests',
        ],
        commonIssues: [
          'Yellowing leaves from overwatering',
          'Brown tips from low humidity',
          'Pests like aphids or mealybugs',
        ],
        temperatureRange: '18-24°C (65-75°F)',
        humidity: 'Moderate (40-60%)',
        category: 'Indoor',
        difficulty: 'Medium',
      );
    }
  }
}
