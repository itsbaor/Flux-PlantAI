import 'package:flutter/material.dart';
import 'dart:io';
import '../models/plant.dart';

class PlantListCard extends StatefulWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantListCard({
    super.key,
    required this.plant,
    this.onTap,
  });

  @override
  State<PlantListCard> createState() => _PlantListCardState();
}

class _PlantListCardState extends State<PlantListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getHealthColor() {
    switch (widget.plant.healthStatus?.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF4CAF50);
      case 'good':
        return const Color(0xFF8BC34A);
      case 'fair':
        return const Color(0xFFFF9800);
      case 'poor':
        return const Color(0xFFf44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _getHealthLabel() {
    switch (widget.plant.healthStatus?.toLowerCase()) {
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Needs Care';
      case 'poor':
        return 'Critical';
      default:
        return 'Healthy';
    }
  }

  Color _getDifficultyColor() {
    switch (widget.plant.difficulty?.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFf44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1E1E),
                const Color(0xFF151515),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getHealthColor().withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getHealthColor().withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Plant Image with health indicator
                Stack(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _getHealthColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: _buildImage(),
                      ),
                    ),
                    // Category badge
                    if (widget.plant.category != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.plant.category == 'Indoor'
                                ? Icons.home_rounded
                                : Icons.park_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Plant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and health indicator row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.plant.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Health indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getHealthColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getHealthColor().withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.plant.healthStatus == 'excellent' ||
                                          widget.plant.healthStatus == 'good'
                                      ? Icons.check_circle
                                      : Icons.warning_amber_rounded,
                                  color: _getHealthColor(),
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getHealthLabel(),
                                  style: TextStyle(
                                    color: _getHealthColor(),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Scientific name
                      Text(
                        widget.plant.scientificName,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Bottom row with tags
                      Row(
                        children: [
                          // Difficulty badge
                          if (widget.plant.difficulty != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor().withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getDifficultyColor().withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                widget.plant.difficulty!,
                                style: TextStyle(
                                  color: _getDifficultyColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (widget.plant.category != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.plant.category == 'Indoor'
                                        ? Icons.home_rounded
                                        : Icons.park_rounded,
                                    color: Colors.grey[400],
                                    size: 10,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.plant.category!,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Arrow button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90EE90).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF90EE90),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final file = File(widget.plant.imagePath);
    if (widget.plant.imagePath.isNotEmpty && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getHealthColor().withOpacity(0.2),
            _getHealthColor().withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getHealthColor().withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.eco_rounded,
            size: 24,
            color: _getHealthColor(),
          ),
        ),
      ),
    );
  }
}
