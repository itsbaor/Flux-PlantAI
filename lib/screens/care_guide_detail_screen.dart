import 'package:flutter/material.dart';
import '../models/care_guide.dart';
import '../widgets/app_background.dart';

class CareGuideDetailScreen extends StatefulWidget {
  final CareGuide guide;

  const CareGuideDetailScreen({super.key, required this.guide});

  @override
  State<CareGuideDetailScreen> createState() => _CareGuideDetailScreenState();
}

class _CareGuideDetailScreenState extends State<CareGuideDetailScreen> {
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  double _headerOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.guide.isFavorite;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (offset / 200).clamp(0.0, 1.0);
    });
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'schedule':
        return Icons.schedule;
      case 'water_drop':
        return Icons.water_drop;
      case 'science':
        return Icons.science;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'light_mode':
        return Icons.light_mode;
      case 'category':
        return Icons.category;
      case 'troubleshoot':
        return Icons.troubleshoot;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'format_list_numbered':
        return Icons.format_list_numbered;
      case 'healing':
        return Icons.healing;
      case 'bug_report':
        return Icons.bug_report;
      case 'security':
        return Icons.security;
      case 'medication':
        return Icons.medication;
      case 'event':
        return Icons.event;
      case 'local_florist':
        return Icons.local_florist;
      case 'content_cut':
        return Icons.content_cut;
      case 'eco':
        return Icons.eco;
      case 'call_split':
        return Icons.call_split;
      case 'air':
        return Icons.air;
      default:
        return Icons.article;
    }
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
        return const Color(0xFF90EE90);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero header
                SliverToBoxAdapter(
                  child: _buildHeroHeader(),
                ),
                // Content
                SliverToBoxAdapter(
                  child: _buildContent(),
                ),
              ],
            ),
            // Sticky header
            _buildStickyHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withValues(alpha: _headerOpacity),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: _headerOpacity * 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Opacity(
                    opacity: _headerOpacity,
                    child: Text(
                      widget.guide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: _isFavorite ? const Color(0xFF90EE90) : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getCategoryColor(widget.guide.category).withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                color: _getCategoryColor(widget.guide.category).withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category and difficulty badges - use Wrap to prevent overflow
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        widget.guide.category,
                        _getCategoryColor(widget.guide.category),
                        Icons.local_florist,
                      ),
                      _buildBadge(
                        widget.guide.difficulty,
                        _getDifficultyColor(widget.guide.difficulty),
                        Icons.trending_up,
                      ),
                      _buildBadge(
                        widget.guide.readTime,
                        Colors.white.withValues(alpha: 0.2),
                        Icons.access_time,
                        textColor: Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.guide.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Subtitle
                  if (widget.guide.subtitle.isNotEmpty)
                    Text(
                      widget.guide.subtitle,
                      style: TextStyle(
                        color: _getCategoryColor(widget.guide.category),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  // Description
                  Text(
                    widget.guide.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sections
          ...widget.guide.sections.asMap().entries.map((entry) {
            return _buildSection(entry.value, entry.key);
          }),

          // Tips section
          if (widget.guide.tips.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTipsSection(),
          ],

          // Tags
          if (widget.guide.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(CareGuideSection section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconFromName(section.iconName),
                  color: const Color(0xFF90EE90),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Section content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              section.content,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCA28).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Color(0xFFFFCA28),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pro Tips',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFCA28).withValues(alpha: 0.1),
                const Color(0xFFFFCA28).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFCA28).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: widget.guide.tips.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < widget.guide.tips.length - 1 ? 12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFFFFCA28),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.guide.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(0, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
