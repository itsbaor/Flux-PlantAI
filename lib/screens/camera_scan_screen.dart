import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'identification_results_screen.dart';
import 'diagnosis_report_screen.dart';
import '../services/permission_service.dart';

class CameraScanScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const CameraScanScreen({
    super.key,
    this.onClose,
  });

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isIdentifyMode = true;
  String? _permissionError;
  final ImagePicker _imagePicker = ImagePicker();

  // Animation controllers
  late AnimationController _scanLineController;
  late AnimationController _fadeInController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    final result = await PermissionService.requestCameraPermission();

    if (!mounted) return;

    if (result == PermissionResult.granted) {
      await _initializeCamera();
    } else if (result == PermissionResult.permanentlyDenied) {
      setState(() {
        _permissionError = 'Camera permission is required. Please enable it in Settings.';
      });
      // Wait for the next frame to ensure UI is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPermissionDialog(
            'Camera Permission Required',
            'Camera access is required to scan plants. Please enable it in your device settings.',
            isPermanentlyDenied: true,
          );
        }
      });
    } else {
      setState(() {
        _permissionError = 'Camera permission was denied.';
      });
      // Wait for the next frame to ensure UI is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPermissionDialog(
            'Camera Permission Required',
            'Camera access is required to scan plants.',
            isPermanentlyDenied: false,
          );
        }
      });
    }
  }

  void _initializeAnimations() {
    // Scanning line animation
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(
      begin: -0.4,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));

    // Fade in animation
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    ));

    _fadeInController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _fadeInController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      _navigateToResults(image.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Request photo library permission
      final result = await PermissionService.requestPhotoLibraryPermission();

      if (!mounted) return;

      if (result == PermissionResult.granted) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          _navigateToResults(image.path);
        }
      } else if (result == PermissionResult.permanentlyDenied) {
        _showPermissionDialog(
          'Photos Permission Required',
          'Photo library access is required to select plant images. Please enable it in your device settings.',
          isPermanentlyDenied: true,
        );
      } else {
        if (mounted) {
          PermissionService.showErrorDialog(
            context,
            'Permission Denied',
            'Photos permission is required to select images from your gallery.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        PermissionService.showErrorDialog(
          context,
          'Error',
          'Failed to pick image from gallery. Please try again.',
        );
      }
    }
  }

  void _showPermissionDialog(String title, String message, {required bool isPermanentlyDenied}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (isPermanentlyDenied) {
                  await openAppSettings();
                } else {
                  // Try requesting permission again
                  setState(() {
                    _permissionError = null;
                  });
                  await _requestPermissionsAndInitialize();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90EE90),
                foregroundColor: Colors.black,
              ),
              child: Text(isPermanentlyDenied ? 'Open Settings' : 'Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToResults(String imagePath) {
    if (_isIdentifyMode) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              IdentificationResultsScreen(imagePath: imagePath),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DiagnosisReportScreen(imagePath: imagePath),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Permission Error or Camera Preview
          if (_permissionError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _permissionError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Open Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF90EE90),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF90EE90),
              ),
            ),

          // Only show overlays when there's no permission error
          if (_permissionError == null) ...[
            // Fade in overlay
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Column(
                children: [
                  // Top Bar
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _AnimatedIconButton(
                            icon: Icons.close,
                            onPressed: () {
                              // Call onClose immediately, let dispose() handle cleanup
                              if (widget.onClose != null) {
                                widget.onClose!();
                              } else {
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                          ),
                          _AnimatedIconButton(
                            icon: Icons.flash_off,
                            onPressed: () {
                              // Toggle flash
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Camera Frame Overlay with Animation
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instruction Text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF90EE90).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.center_focus_strong,
                          color: Color(0xFF90EE90),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Position plant in center',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Frame with Corners
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glass Frame Background
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                          ),

                          // Corner Accents
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: MediaQuery.of(context).size.width * 0.95,
                            child: Stack(
                              children: [
                                // Top Left
                                Positioned(
                                  top: -2,
                                  left: -2,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                        left: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                // Top Right
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                        right: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                // Bottom Left
                                Positioned(
                                  bottom: -2,
                                  left: -2,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                        left: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                // Bottom Right
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                        right: BorderSide(
                                          color: const Color(0xFF90EE90),
                                          width: 4,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Animated Scanning Line
                          Transform.translate(
                            offset: Offset(
                              0,
                              _scanLineAnimation.value *
                                  MediaQuery.of(context).size.width *
                                  0.95,
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF90EE90),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF90EE90).withValues(alpha: 0.6),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Hint Text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Ensure good lighting for best results',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Controls with Fade Animation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _fadeInController,
                    curve: Curves.easeOut,
                  )),
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mode Buttons with Animation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimatedModeButton(
                              text: 'Identify',
                              isSelected: _isIdentifyMode,
                              onTap: () {
                                setState(() {
                                  _isIdentifyMode = true;
                                });
                              },
                            ),
                            const SizedBox(width: 20),
                            _AnimatedModeButton(
                              text: 'Diagnose',
                              isSelected: !_isIdentifyMode,
                              onTap: () {
                                setState(() {
                                  _isIdentifyMode = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Gallery Button
                            _AnimatedActionButton(
                              icon: Icons.photo_library,
                              onPressed: _pickFromGallery,
                            ),

                            // Capture Button
                            _AnimatedCaptureButton(
                              onPressed: _takePicture,
                            ),

                            // Placeholder for symmetry
                            const SizedBox(width: 50),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Show close button when there's a permission error
          if (_permissionError != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _AnimatedIconButton(
                    icon: Icons.close,
                    onPressed: () {
                      if (widget.onClose != null) {
                        widget.onClose!();
                      } else {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ),
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

// Animated Mode Button
class _AnimatedModeButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedModeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedModeButton> createState() => _AnimatedModeButtonState();
}

class _AnimatedModeButtonState extends State<_AnimatedModeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF90EE90)
                : Colors.transparent,
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF90EE90)
                  : Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isSelected ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Animated Action Button (Gallery)
class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
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
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Animated Capture Button
class _AnimatedCaptureButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedCaptureButton({
    required this.onPressed,
  });

  @override
  State<_AnimatedCaptureButton> createState() => _AnimatedCaptureButtonState();
}

class _AnimatedCaptureButtonState extends State<_AnimatedCaptureButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
