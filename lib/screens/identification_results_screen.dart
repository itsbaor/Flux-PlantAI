import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import '../models/plant_identification.dart';
import '../models/plant.dart';
import '../services/gemini_service.dart';
import '../services/garden_service.dart';
import '../config/app_theme.dart';

class IdentificationResultsScreen extends StatefulWidget {
  final String imagePath;

  const IdentificationResultsScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<IdentificationResultsScreen> createState() =>
      _IdentificationResultsScreenState();
}

class _IdentificationResultsScreenState
    extends State<IdentificationResultsScreen>
    with TickerProviderStateMixin {
  List<PlantIdentification> _identifications = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  final GeminiService _geminiService = GeminiService();
  final GardenService _gardenService = GardenService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _performIdentification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _performIdentification() async {
    try {
      final identifications = await _geminiService.identifyPlant(widget.imagePath);

      if (mounted) {
        setState(() {
          _identifications = identifications;
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      debugPrint('Error performing identification: $e');
      if (mounted) {
        setState(() {
          _identifications = [];
          _isLoading = false;
        });
        _showErrorSnackBar(context, 'Failed to identify plant. Please try again.');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppTheme.spaceM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.spaceM),
      ),
    );
  }

  Future<void> _shareResults() async {
    if (_identifications.isEmpty) return;

    final topResult = _identifications.first;
    final shareText = '''
🌱 Plant Identification Results

Plant: ${topResult.name}
Scientific Name: ${topResult.scientificName}
Confidence: ${(topResult.confidence * 100).toInt()}%

${topResult.description}

Identified with Plant AI
''';

    await Share.shareXFiles(
      [XFile(widget.imagePath)],
      text: shareText,
    );
  }

  Future<void> _addToGarden(PlantIdentification plant) async {
    // Check if already exists
    final exists = await _gardenService.plantExists(plant.name, plant.scientificName);

    if (exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: AppTheme.spaceM),
              const Expanded(
                child: Text('This plant is already in your garden!'),
              ),
            ],
          ),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          margin: const EdgeInsets.all(AppTheme.spaceM),
        ),
      );
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: AppTheme.frostedGlass(
          blur: 20,
          opacity: 0.15,
          borderRadius: AppTheme.radiusLarge,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: AppTheme.spaceL),
                Text(
                  'Fetching care info...',
                  style: AppTheme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch care info from Gemini
      final careInfo = await _geminiService.getPlantCareInfo(
        plant.name,
        plant.scientificName,
      );

      // Add to garden
      final success = await _gardenService.addPlantFromIdentification(
        identification: plant,
        imagePath: widget.imagePath,
        careInfo: careInfo,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppTheme.spaceM),
                Expanded(
                  child: Text('${plant.name} added to your garden!'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            margin: const EdgeInsets.all(AppTheme.spaceM),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to My Garden (index 1)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Failed to add plant to garden');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar with Glass Effect
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GlassIconButton(
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Plant Identification',
                        style: AppTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _GlassIconButton(
                        icon: Icons.share_rounded,
                        onPressed: () => _shareResults(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spaceL),

                // Image Preview with Glassmorphism Frame
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.85, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: scale.clamp(0.0, 1.0),
                        child: AppTheme.frostedGlass(
                          blur: 15,
                          opacity: 0.15,
                          borderRadius: AppTheme.radiusXLarge,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.85,
                            padding: const EdgeInsets.all(AppTheme.spaceS),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusXLarge - 8,
                              ),
                              child: Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppTheme.spaceXL),

                // Results Header
                if (!_isLoading && _identifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceM,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spaceS),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceM),
                        Text(
                          '${_identifications.length} Possible Matches',
                          style: AppTheme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppTheme.spaceM),

                // Results List
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _buildResultsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spaceXL),
          Text(
            'Analyzing plant...',
            style: AppTheme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            'Powered by Gemini 2.5 Flash',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryGreenLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_identifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spaceL),
            Text(
              'No plants identified',
              style: AppTheme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              'Try taking a clearer photo',
              style: AppTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceM,
            vertical: AppTheme.spaceS,
          ),
          itemCount: _identifications.length,
          itemBuilder: (context, index) {
            final delay = index * 0.12;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay,
                  delay + 0.6,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: _buildGlassResultCard(
                  _identifications[index],
                  index,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlassResultCard(PlantIdentification plant, int index) {
    final isTopResult = index == 0;
    final confidencePercent = (plant.confidence * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: AppTheme.frostedGlass(
        blur: 20,
        opacity: 0.15,
        borderRadius: AppTheme.radiusLarge,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceM),
          decoration: isTopResult
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.primaryGreen,
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Rank Badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isTopResult
                          ? AppTheme.primaryGradient
                          : LinearGradient(
                              colors: [
                                AppTheme.textSecondary.withValues(alpha: 0.3),
                                AppTheme.textSecondary.withValues(alpha: 0.2),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: isTopResult
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppTheme.spaceM),

                  // Plant Name & Scientific Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plant.name,
                                style: AppTheme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isTopResult
                                      ? AppTheme.primaryGreenLight
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (isTopResult)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Best Match',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceXS),
                        Text(
                          plant.scientificName,
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spaceM),

              // Confidence Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confidence',
                        style: AppTheme.textTheme.labelMedium,
                      ),
                      Text(
                        '$confidencePercent%',
                        style: AppTheme.textTheme.labelMedium?.copyWith(
                          color: isTopResult
                              ? AppTheme.primaryGreenLight
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceS),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: plant.confidence),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor:
                              AppTheme.textSecondary.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation(
                            isTopResult
                                ? AppTheme.primaryGreen
                                : AppTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spaceM),

              // Description
              if (plant.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
                  child: Text(
                    plant.description,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Characteristics
              if (plant.characteristics.isNotEmpty)
                Wrap(
                  spacing: AppTheme.spaceS,
                  runSpacing: AppTheme.spaceS,
                  children: plant.characteristics.take(4).map((char) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isTopResult
                            ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                            : AppTheme.textSecondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: isTopResult
                              ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        char,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isTopResult
                              ? AppTheme.primaryGreenLight
                              : AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: AppTheme.spaceM),

              // Action Button
              _GlassButton(
                onPressed: () => _addToGarden(plant),
                label: 'Add to Garden',
                icon: Icons.add_rounded,
                isPrimary: isTopResult,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Glass Icon Button Widget
class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: AppTheme.animationFast,
        child: AppTheme.frostedGlass(
          blur: 15,
          opacity: 0.15,
          borderRadius: AppTheme.radiusMedium,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

// Glass Button Widget
class _GlassButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isPrimary;

  const _GlassButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppTheme.animationFast,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: widget.isPrimary
              ? BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : AppTheme.glassCard(borderRadius: AppTheme.radiusMedium),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spaceS),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
