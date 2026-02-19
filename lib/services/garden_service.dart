import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/plant.dart';
import '../models/plant_identification.dart';

/// Service to manage user's garden (plant collection)
class GardenService {
  static const String _gardenKey = 'user_garden_plants';
  static final GardenService _instance = GardenService._internal();
  final Uuid _uuid = const Uuid();

  factory GardenService() {
    return _instance;
  }

  GardenService._internal();

  /// Get all plants in garden
  Future<List<Plant>> getAllPlants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantsJson = prefs.getString(_gardenKey);

      if (plantsJson == null || plantsJson.isEmpty) {
        return [];
      }

      final List<dynamic> plantsList = jsonDecode(plantsJson);
      return plantsList.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      print('Error loading plants: $e');
      return [];
    }
  }

  /// Copy image from temporary to permanent storage
  Future<String> _copyImageToPermanentStorage(String tempImagePath) async {
    try {
      final tempFile = File(tempImagePath);
      if (!await tempFile.exists()) {
        return tempImagePath; // Return original if file doesn't exist
      }

      // Get application documents directory (permanent storage)
      final appDir = await getApplicationDocumentsDirectory();
      final plantsDir = Directory('${appDir.path}/plant_images');

      // Create directory if it doesn't exist
      if (!await plantsDir.exists()) {
        await plantsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = tempImagePath.split('.').last;
      final newFileName = 'plant_$timestamp.$extension';
      final newPath = '${plantsDir.path}/$newFileName';

      // Copy file to permanent storage
      await tempFile.copy(newPath);

      return newPath;
    } catch (e) {
      print('Error copying image: $e');
      return tempImagePath; // Return original path on error
    }
  }

  /// Add a plant to garden from identification result
  Future<bool> addPlantFromIdentification({
    required PlantIdentification identification,
    required String imagePath,
    PlantCareInfo? careInfo,
  }) async {
    try {
      // Copy image to permanent storage
      final permanentImagePath = await _copyImageToPermanentStorage(imagePath);

      final plant = Plant(
        id: _uuid.v4(),
        name: identification.name,
        scientificName: identification.scientificName,
        description: identification.description,
        imagePath: permanentImagePath,
        confidence: identification.confidence,
        characteristics: identification.characteristics,
        addedDate: DateTime.now(),
        wateringFrequency: careInfo?.wateringFrequency,
        sunlightRequirement: careInfo?.sunlightRequirement,
        soilType: careInfo?.soilType,
        fertilizer: careInfo?.fertilizer,
        careInstructions: careInfo?.careInstructions,
        commonIssues: careInfo?.commonIssues,
        category: careInfo?.category,
        difficulty: careInfo?.difficulty,
      );

      return await addPlant(plant);
    } catch (e) {
      print('Error adding plant from identification: $e');
      return false;
    }
  }

  /// Add a plant to garden
  Future<bool> addPlant(Plant plant) async {
    try {
      final plants = await getAllPlants();

      // Check if plant already exists
      final exists = plants.any((p) =>
        p.name.toLowerCase() == plant.name.toLowerCase() &&
        p.scientificName.toLowerCase() == plant.scientificName.toLowerCase()
      );

      if (exists) {
        print('Plant already exists in garden');
        return false;
      }

      plants.add(plant);
      return await _savePlants(plants);
    } catch (e) {
      print('Error adding plant: $e');
      return false;
    }
  }

  /// Remove a plant from garden
  Future<bool> removePlant(String plantId) async {
    try {
      final plants = await getAllPlants();
      final plantToRemove = plants.firstWhere(
        (plant) => plant.id == plantId,
        orElse: () => throw Exception('Plant not found'),
      );

      // Delete image file if it's in our permanent storage
      if (plantToRemove.imagePath.contains('plant_images')) {
        try {
          final imageFile = File(plantToRemove.imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          print('Error deleting plant image: $e');
        }
      }

      plants.removeWhere((plant) => plant.id == plantId);
      return await _savePlants(plants);
    } catch (e) {
      print('Error removing plant: $e');
      return false;
    }
  }

  /// Update a plant in garden
  Future<bool> updatePlant(Plant updatedPlant) async {
    try {
      final plants = await getAllPlants();
      final index = plants.indexWhere((plant) => plant.id == updatedPlant.id);

      if (index == -1) {
        return false;
      }

      plants[index] = updatedPlant;
      return await _savePlants(plants);
    } catch (e) {
      print('Error updating plant: $e');
      return false;
    }
  }

  /// Get a specific plant by ID
  Future<Plant?> getPlantById(String plantId) async {
    try {
      final plants = await getAllPlants();
      return plants.firstWhere(
        (plant) => plant.id == plantId,
        orElse: () => throw Exception('Plant not found'),
      );
    } catch (e) {
      print('Error getting plant: $e');
      return null;
    }
  }

  /// Check if a plant exists in garden
  Future<bool> plantExists(String name, String scientificName) async {
    try {
      final plants = await getAllPlants();
      return plants.any((p) =>
        p.name.toLowerCase() == name.toLowerCase() &&
        p.scientificName.toLowerCase() == scientificName.toLowerCase()
      );
    } catch (e) {
      print('Error checking plant exists: $e');
      return false;
    }
  }

  /// Get plants count
  Future<int> getPlantsCount() async {
    final plants = await getAllPlants();
    return plants.length;
  }

  /// Get plants by category
  Future<List<Plant>> getPlantsByCategory(String category) async {
    final plants = await getAllPlants();
    return plants.where((plant) => plant.category == category).toList();
  }

  /// Get plants by health status
  Future<List<Plant>> getPlantsByHealthStatus(String status) async {
    final plants = await getAllPlants();
    return plants.where((plant) => plant.healthStatus == status).toList();
  }

  /// Search plants by name
  Future<List<Plant>> searchPlants(String query) async {
    final plants = await getAllPlants();
    final lowerQuery = query.toLowerCase();

    return plants.where((plant) =>
      plant.name.toLowerCase().contains(lowerQuery) ||
      plant.scientificName.toLowerCase().contains(lowerQuery) ||
      plant.characteristics.any((c) => c.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  /// Clear all plants from garden
  Future<bool> clearGarden() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_gardenKey);
    } catch (e) {
      print('Error clearing garden: $e');
      return false;
    }
  }

  /// Save plants to storage (private helper)
  Future<bool> _savePlants(List<Plant> plants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantsJson = jsonEncode(plants.map((p) => p.toJson()).toList());
      return await prefs.setString(_gardenKey, plantsJson);
    } catch (e) {
      print('Error saving plants: $e');
      return false;
    }
  }

  /// Get garden statistics
  Future<Map<String, dynamic>> getGardenStats() async {
    final plants = await getAllPlants();

    return {
      'totalPlants': plants.length,
      'healthyPlants': plants.where((p) => p.healthStatus == 'excellent' || p.healthStatus == 'good').length,
      'needsAttention': plants.where((p) => p.healthStatus == 'fair' || p.healthStatus == 'poor').length,
      'categories': {
        'indoor': plants.where((p) => p.category == 'Indoor').length,
        'outdoor': plants.where((p) => p.category == 'Outdoor').length,
      },
      'difficulty': {
        'easy': plants.where((p) => p.difficulty == 'Easy').length,
        'medium': plants.where((p) => p.difficulty == 'Medium').length,
        'hard': plants.where((p) => p.difficulty == 'Hard').length,
      },
    };
  }
}
