import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import '../models/health_issue.dart';
import '../services/gemini_service.dart';

class DiagnosisReportScreen extends StatefulWidget {
  final String imagePath;

  const DiagnosisReportScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<DiagnosisReportScreen> createState() => _DiagnosisReportScreenState();
}

class _DiagnosisReportScreenState extends State<DiagnosisReportScreen>
    with TickerProviderStateMixin {
  PlantDiagnosisReport? _report;
  bool _isLoading = true;
  late AnimationController _slideController;
  late AnimationController _cardController;
  late Animation<Offset> _slideAnimation;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _performDiagnosis();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _performDiagnosis() async {
    try {
      // Call Gemini API to diagnose plant
      final report = await _geminiService.diagnosePlant(widget.imagePath);

      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
          _slideController.forward();
          _cardController.forward();
        });
      }
    } catch (e) {
      debugPrint('Error performing diagnosis: $e');
      // Show error and use fallback data
      if (mounted) {
        setState(() {
          _report = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to diagnose plant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToGarden() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plant added to your garden!'),
        backgroundColor: Color(0xFF90EE90),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getSeverityColor(double percentage) {
    if (percentage < 20) {
      return const Color(0xFF90EE90);
    } else if (percentage < 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.3, 0.8],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AnimatedIconButton(
                        icon: Icons.close,
                        onPressed: () => Navigator.pop(context),
                      ),
                      _AnimatedIconButton(
                        icon: Icons.info_outline,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Powered by Gemini AI'),
                              backgroundColor: Color(0xFF90EE90),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Image Preview with Frame - Animated Scale
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.8, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: scale,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                              image: FileImage(File(widget.imagePath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Report Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF90EE90),
                          ),
                        )
                      : SlideTransition(
                          position: _slideAnimation,
                          child: _buildReport(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReport() {
    if (_report == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Report Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          '${_report!.plantName} Report',
                          style: const TextStyle(
                            color: Color(0xFF90EE90),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Issues List
          Expanded(
            child: AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _report!.issues.length,
                  itemBuilder: (context, index) {
                    final delay = index * 0.2;
                    final animation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: _cardController,
                        curve: Interval(
                          delay,
                          delay + 0.6,
                          curve: Curves.easeOut,
                        ),
                      ),
                    );

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: _buildIssueCard(
                          _report!.issues[index],
                          animation,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Add to Garden Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: SizedBox(
                      width: double.infinity,
                      child: _AnimatedAddButton(
                        onPressed: _addToGarden,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(HealthIssue issue, Animation<double> animation) {
    final severityColor = _getSeverityColor(issue.percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animated Percentage Circle
              SizedBox(
                width: 80,
                height: 80,
                child: AnimatedCircularPercentage(
                  percentage: issue.percentage,
                  color: severityColor,
                  animation: animation,
                ),
              ),

              const SizedBox(width: 16),

              // Issue Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      issue.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Example Images with staggered animation
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.local_florist,
                            color: Colors.grey[500],
                            size: 40,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Icon Button
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
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
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// Animated Add Button
class _AnimatedAddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedAddButton({
    required this.onPressed,
  });

  @override
  State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton> {
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
        duration: const Duration(milliseconds: 100),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF90EE90),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: _isPressed ? 2 : 6,
          ),
          child: const Text(
            'Add to garden',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Animated Circular Percentage Widget
class AnimatedCircularPercentage extends StatelessWidget {
  final double percentage;
  final Color color;
  final Animation<double> animation;

  const AnimatedCircularPercentage({
    super.key,
    required this.percentage,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animatedPercentage = percentage * animation.value;
        return CustomPaint(
          painter: CircularPercentagePainter(
            percentage: animatedPercentage,
            color: color,
          ),
          child: Center(
            child: TweenAnimationBuilder<int>(
              duration: const Duration(milliseconds: 800),
              tween: IntTween(begin: 0, end: percentage.toInt()),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Text(
                  '$value%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter for Circular Percentage Indicator
class CircularPercentagePainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircularPercentagePainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius - 4, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularPercentagePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color;
  }
}
