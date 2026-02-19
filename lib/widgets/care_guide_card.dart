import 'package:flutter/material.dart';
import '../models/care_guide.dart';
import '../screens/care_guide_detail_screen.dart';

class CareGuideCard extends StatefulWidget {
  final CareGuide guide;
  final bool isLarge;

  const CareGuideCard({
    super.key,
    required this.guide,
    this.isLarge = false,
  });

  @override
  State<CareGuideCard> createState() => _CareGuideCardState();
}

class _CareGuideCardState extends State<CareGuideCard>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.guide.isFavorite;
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _favoriteAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    _favoriteController.forward(from: 0);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'watering':
        return const Color(0xFF42A5F5);
      case 'light':
        return const Color(0xFFFFCA28);
      case 'maintenance':
        return const Color(0xFF66BB6A);
      case 'health':
        return const Color(0xFFEF5350);
      case 'nutrition':
        return const Color(0xFFAB47BC);
      case 'advanced':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFF90EE90);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'watering':
        return Icons.water_drop;
      case 'light':
        return Icons.light_mode;
      case 'maintenance':
        return Icons.build;
      case 'health':
        return Icons.favorite;
      case 'nutrition':
        return Icons.eco;
      case 'advanced':
        return Icons.school;
      default:
        return Icons.local_florist;
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareGuideDetailScreen(guide: widget.guide),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        width: widget.isLarge ? double.infinity : 180,
        height: widget.isLarge ? 280 : 240,
        margin: EdgeInsets.only(right: widget.isLarge ? 0 : 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF151515),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getCategoryColor(widget.guide.category).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getCategoryColor(widget.guide.category).withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with overlay
              Stack(
                children: [
                  // Background gradient with icon
                  Container(
                    height: widget.isLarge ? 120 : 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(widget.guide.category).withValues(alpha: 0.3),
                          _getCategoryColor(widget.guide.category).withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Pattern overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPainter(
                              color: _getCategoryColor(widget.guide.category).withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        // Category icon
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(widget.isLarge ? 14 : 10),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(widget.guide.category).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(widget.guide.category),
                              size: widget.isLarge ? 28 : 22,
                              color: _getCategoryColor(widget.guide.category),
                            ),
                          ),
                        ),
                        // Gradient overlay at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 30,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF1E1E1E),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(widget.guide.category).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.guide.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedBuilder(
                      animation: _favoriteAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _favoriteAnimation.value,
                          child: GestureDetector(
                            onTap: _toggleFavorite,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                                color: isFavorite ? const Color(0xFF90EE90) : Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Content section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(widget.isLarge ? 14 : 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.guide.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isLarge ? 16 : 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.guide.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.guide.subtitle,
                          style: TextStyle(
                            color: _getCategoryColor(widget.guide.category),
                            fontSize: widget.isLarge ? 12 : 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      // Description
                      Expanded(
                        child: Text(
                          widget.guide.description,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: widget.isLarge ? 12 : 10,
                            height: 1.3,
                          ),
                          maxLines: widget.isLarge ? 3 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Footer with meta info
                      Row(
                        children: [
                          // Read time
                          Flexible(
                            child: _buildMetaChip(
                              Icons.access_time,
                              widget.guide.readTime,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Difficulty
                          Flexible(
                            child: _buildMetaChip(
                              Icons.trending_up,
                              widget.guide.difficulty,
                              color: _getDifficultyColor(widget.guide.difficulty),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Read more arrow
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF90EE90),
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text, {Color? color}) {
    final chipColor = color ?? Colors.grey.shade500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: chipColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFFA726);
      case 'advanced':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }
}

// Custom painter for grid pattern
class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
