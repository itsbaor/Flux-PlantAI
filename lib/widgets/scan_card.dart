import 'package:flutter/material.dart';

class ScanCard extends StatefulWidget {
  final VoidCallback onTap;

  const ScanCard({super.key, required this.onTap});

  @override
  State<ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<ScanCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanLineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the scan icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scan line animation
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            // Main card with glassmorphism
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A3D2E).withValues(alpha: 0.9),
                    const Color(0xFF0D2818).withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF90EE90).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFF90EE90),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Identify Your\nPlant',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Scan to identify species and\nget care recommendations',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Scan button
                        _buildScanButton(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right - Animated scan frame
                  _buildScanFrame(),
                ],
              ),
            ),
            // Decorative elements
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF90EE90),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF90EE90).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF90EE90),
            Color(0xFF5DBB63),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90EE90).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF0D2818),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Scan Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2818),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scanLineAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF90EE90).withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Corner brackets
                ..._buildCornerBrackets(),
                // Scan line
                Positioned(
                  top: 10 + (_scanLineAnimation.value * 86),
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF90EE90).withValues(alpha: 0.8),
                          const Color(0xFF90EE90),
                          const Color(0xFF90EE90).withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF90EE90).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Plant icon
                Center(
                  child: Icon(
                    Icons.eco_rounded,
                    size: 40,
                    color: const Color(0xFF90EE90).withValues(alpha: 0.6),
                  ),
                ),
                // Grid pattern
                ..._buildGridPattern(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerBrackets() {
    const bracketColor = Color(0xFF90EE90);
    const bracketLength = 20.0;
    const bracketWidth = 3.0;

    return [
      // Top left
      Positioned(
        top: 8,
        left: 8,
        child: Container(
          width: bracketLength,
          height: bracketWidth,
          color: bracketColor,
        ),
      ),
      Positioned(
        top: 8,
        left: 8,
        child: Container(
          width: bracketWidth,
          height: bracketLength,
          color: bracketColor,
        ),
      ),
      // Top right
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          width: bracketLength,
          height: bracketWidth,
          color: bracketColor,
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          width: bracketWidth,
          height: bracketLength,
          color: bracketColor,
        ),
      ),
      // Bottom left
      Positioned(
        bottom: 8,
        left: 8,
        child: Container(
          width: bracketLength,
          height: bracketWidth,
          color: bracketColor,
        ),
      ),
      Positioned(
        bottom: 8,
        left: 8,
        child: Container(
          width: bracketWidth,
          height: bracketLength,
          color: bracketColor,
        ),
      ),
      // Bottom right
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          width: bracketLength,
          height: bracketWidth,
          color: bracketColor,
        ),
      ),
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          width: bracketWidth,
          height: bracketLength,
          color: bracketColor,
        ),
      ),
    ];
  }

  List<Widget> _buildGridPattern() {
    return [
      // Horizontal lines
      Positioned(
        top: 36,
        left: 25,
        right: 25,
        child: Container(
          height: 1,
          color: const Color(0xFF90EE90).withValues(alpha: 0.15),
        ),
      ),
      Positioned(
        top: 72,
        left: 25,
        right: 25,
        child: Container(
          height: 1,
          color: const Color(0xFF90EE90).withValues(alpha: 0.15),
        ),
      ),
      // Vertical lines
      Positioned(
        left: 36,
        top: 25,
        bottom: 25,
        child: Container(
          width: 1,
          color: const Color(0xFF90EE90).withValues(alpha: 0.15),
        ),
      ),
      Positioned(
        right: 36,
        top: 25,
        bottom: 25,
        child: Container(
          width: 1,
          color: const Color(0xFF90EE90).withValues(alpha: 0.15),
        ),
      ),
    ];
  }
}
