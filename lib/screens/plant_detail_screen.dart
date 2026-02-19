import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/plant.dart';
import '../widgets/app_background.dart';
import '../config/app_theme.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({
    super.key,
    required this.plant,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  int _selectedTab = 0;
  bool _isLoading = true;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Preload image and data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Preload the image
    final file = File(widget.plant.imagePath);
    if (file.existsSync()) {
      final imageProvider = FileImage(file);
      try {
        await precacheImage(imageProvider, context);
      } catch (_) {
        // Ignore error if image can't be loaded
      }
    }

    // Small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _imageLoaded = true;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildActionCircle(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _sharePlant() async {
    final plant = widget.plant;
    final shareText = '''
🌱 ${plant.name}
Scientific Name: ${plant.scientificName}

${plant.description ?? ''}

Health Status: ${plant.healthStatus}
Difficulty: ${plant.difficulty ?? 'Medium'}

Shared from Plant AI
''';

    await Share.shareXFiles(
      [XFile(plant.imagePath)],
      text: shareText,
    );
  }

  Color _getDifficultyColor() {
    final difficulty = widget.plant.difficulty?.toLowerCase() ?? 'medium';
    switch (difficulty) {
      case 'easy':
        return AppTheme.successGreen;
      case 'medium':
        return AppTheme.warningOrange;
      case 'hard':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getHealthColor() {
    final health = widget.plant.healthStatus.toLowerCase();
    switch (health) {
      case 'excellent':
        return AppTheme.successGreen;
      case 'good':
        return Colors.lightGreen;
      case 'fair':
        return AppTheme.warningOrange;
      case 'poor':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = 400.0;
    final headerHeight = imageHeight - _scrollOffset.clamp(0.0, imageHeight - 100);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated plant icon with pulse effect
              _PulsingWidget(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading plant details...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Parallax Header
              SliverAppBar(
  expandedHeight: imageHeight,
  pinned: true,
  backgroundColor: Colors.black, // Màu nền khi thu nhỏ
  elevation: 0,
  leading: Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.3), // Chỉ dùng màu nền nhẹ, không dùng Blur
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  actions: [
    _buildActionCircle(
      Icons.favorite_border_rounded,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Added to favorites!'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    ),
    _buildActionCircle(
      Icons.share_rounded,
      onPressed: _sharePlant,
    ),
  ],
  flexibleSpace: FlexibleSpaceBar(
    background: Stack(
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: Offset(0, _scrollOffset * 0.5),
          child: _buildPlantImage(),
        ),
        // Gradient này làm ảnh trong hơn (giảm alpha từ 0.9 xuống 0.5)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.5), 
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
          ),
        ),
        // Giữ lại phần Info Overlay...
      ],
    ),
  ),
),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  selectedTab: _selectedTab,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),
              ),

              // Content with solid background
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.backgroundDark,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTabContent(),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge() {
    final confidencePercent = (widget.plant.confidence * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 14,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            '$confidencePercent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantImage() {
    final file = File(widget.plant.imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.3),
            AppTheme.primaryGreenDark.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.eco_rounded,
          size: 120,
          color: AppTheme.primaryGreenLight,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildCareTab();
      case 2:
        return _buildHealthTab();
      default:
        return _buildOverviewTab();
    }
  }

  // OVERVIEW TAB
  Widget _buildOverviewTab() {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsCards(),

          const SizedBox(height: 24),

          // Description Section
          _buildSectionHeader('About', Icons.info_rounded),
          const SizedBox(height: 12),
          _buildGlassCard(
            child: Text(
              widget.plant.description,
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.textPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Characteristics
          if (widget.plant.characteristics.isNotEmpty) ...[
            _buildSectionHeader('Key Features', Icons.star_rounded),
            const SizedBox(height: 12),
            _buildCharacteristicsGrid(),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            label: 'Added',
            value: dateFormat.format(widget.plant.addedDate),
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_rounded,
            label: 'Health',
            value: widget.plant.healthStatus,
            color: _getHealthColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacteristicsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.plant.characteristics.map((char) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, animValue, child) {
            return Transform.scale(
              scale: animValue,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.2),
                      AppTheme.primaryGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      char,
                      style: const TextStyle(
                        color: AppTheme.primaryGreenLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // CARE TAB
  Widget _buildCareTab() {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Care Requirements
          _buildSectionHeader('Care Requirements', Icons.spa_rounded),
          const SizedBox(height: 12),
          _buildCareRequirementsGrid(),

          const SizedBox(height: 24),

          // Care Instructions
          if (widget.plant.careInstructions != null &&
              widget.plant.careInstructions!.isNotEmpty) ...[
            _buildSectionHeader('Step-by-Step Guide', Icons.format_list_numbered_rounded),
            const SizedBox(height: 12),
            _buildCareInstructionsTimeline(),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCareRequirementsGrid() {
    final requirements = <Map<String, dynamic>>[
      if (widget.plant.wateringFrequency != null)
        {
          'icon': Icons.water_drop_rounded,
          'title': 'Watering',
          'value': widget.plant.wateringFrequency!,
          'color': Colors.blue,
        },
      if (widget.plant.sunlightRequirement != null)
        {
          'icon': Icons.wb_sunny_rounded,
          'title': 'Sunlight',
          'value': widget.plant.sunlightRequirement!,
          'color': Colors.orange,
        },
      if (widget.plant.soilType != null)
        {
          'icon': Icons.grass_rounded,
          'title': 'Soil',
          'value': widget.plant.soilType!,
          'color': Colors.brown,
        },
      if (widget.plant.fertilizer != null)
        {
          'icon': Icons.eco_rounded,
          'title': 'Fertilizer',
          'value': widget.plant.fertilizer!,
          'color': AppTheme.primaryGreen,
        },
    ];

    return Column(
      children: requirements.asMap().entries.map((entry) {
        final index = entry.key;
        final req = entry.value;
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, animValue, child) {
            return Transform.translate(
              offset: Offset(30 * (1 - animValue), 0),
              child: Opacity(
                opacity: animValue.clamp(0.0, 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        req['color'].withValues(alpha: 0.1),
                        req['color'].withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: req['color'].withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                req['color'].withValues(alpha: 0.3),
                                req['color'].withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: req['color'].withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            req['icon'],
                            color: req['color'],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req['title'],
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                req['value'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: req['color'].withValues(alpha: 0.5),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCareInstructionsTimeline() {
    return Column(
      children: widget.plant.careInstructions!.asMap().entries.map((entry) {
        final index = entry.key;
        final instruction = entry.value;
        final isLast = index == widget.plant.careInstructions!.length - 1;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Transform.translate(
              offset: Offset(20 * (1 - animValue), 0),
              child: Opacity(
                opacity: animValue.clamp(0.0, 1.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.primaryGreen,
                                  AppTheme.primaryGreen.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryGreen.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                instruction,
                                style: AppTheme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppTheme.primaryGreen.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // HEALTH TAB
  Widget _buildHealthTab() {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Status Card
          _buildHealthStatusCard(),

          const SizedBox(height: 24),

          // Common Issues
          if (widget.plant.commonIssues != null &&
              widget.plant.commonIssues!.isNotEmpty) ...[
            _buildSectionHeader('Watch Out For', Icons.warning_amber_rounded),
            const SizedBox(height: 12),
            _buildCommonIssuesList(),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.9 + (animValue * 0.1),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getHealthColor().withValues(alpha: 0.2),
                    _getHealthColor().withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getHealthColor().withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getHealthColor().withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Heart Icon with Animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.8, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getHealthColor(),
                                _getHealthColor().withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getHealthColor().withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Status Text
                  Text(
                    widget.plant.healthStatus.toUpperCase(),
                    style: TextStyle(
                      color: _getHealthColor(),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Plant Health Status',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress Indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween(begin: 0.0, end: _getHealthPercentage()),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(_getHealthColor()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getHealthPercentage() {
    switch (widget.plant.healthStatus.toLowerCase()) {
      case 'excellent':
        return 1.0;
      case 'good':
        return 0.8;
      case 'fair':
        return 0.6;
      case 'poor':
        return 0.4;
      default:
        return 0.5;
    }
  }

  Widget _buildCommonIssuesList() {
    return Column(
      children: widget.plant.commonIssues!.asMap().entries.map((entry) {
        final index = entry.key;
        final issue = entry.value;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Transform.translate(
              offset: Offset(20 * (1 - animValue), 0),
              child: Opacity(
                opacity: animValue.clamp(0.0, 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warningOrange.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: AppTheme.warningOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          issue,
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// Custom Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedTab;
  final Function(int) onTabChanged;

  _TabBarDelegate({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
  return Container(
    // Thay đổi ở đây: Dùng màu nền đặc, không có hiệu ứng kính mờ
    color: AppTheme.backgroundDark, 
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          const SizedBox(width: 12),
          _buildTab('Care', 1),
          const SizedBox(width: 12),
          _buildTab('Health', 2),
        ],
      ),
    ),
  );
}

  Widget _buildTab(String text, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return selectedTab != oldDelegate.selectedTab;
  }
}

// Pulsing animation widget for loading indicator
class _PulsingWidget extends StatefulWidget {
  final Widget child;

  const _PulsingWidget({required this.child});

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
