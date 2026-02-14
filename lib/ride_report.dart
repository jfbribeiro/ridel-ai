import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RideReportScreen extends StatefulWidget {
  const RideReportScreen({super.key});

  @override
  State<RideReportScreen> createState() => _RideReportScreenState();
}

class _RideReportScreenState extends State<RideReportScreen>
    with TickerProviderStateMixin {
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();
  double _driverRating = 5;
  bool _ratingTouched = false;
  final ImagePicker _picker = ImagePicker();

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const int _circleCount = 5;

  @override
  void initState() {
    super.initState();

    final durations = [4200, 5000, 3800, 4600, 5400];

    _controllers = List.generate(_circleCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durations[i]),
      )..repeat(reverse: true);
    });

    _animations = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeInOut);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  bool get _canSubmit =>
      _selectedImage != null &&
      _descriptionController.text.trim().isNotEmpty &&
      _ratingTouched;

  void _onSubmit() {
    // TODO: Implement submit logic
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _selectedImage != null;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Animated floating blue circles
          ..._buildAnimatedCircles(screenWidth),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Title
                    const Text(
                      'Report a Ride',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Upload screenshot button
                    GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: hasImage
                              ? Colors.blue.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasImage
                                ? Colors.blue.withValues(alpha: 0.3)
                                : const Color(0xFFD0D0D8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasImage)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            else
                              Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.grey[600],
                                size: 22,
                              ),
                            const SizedBox(width: 10),
                            Text(
                              hasImage
                                  ? 'Screenshot Uploaded'
                                  : 'Upload Screenshot',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: hasImage
                                    ? Colors.blue[700]
                                    : const Color(0xFF4A4A5A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Description text field
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Describe your ride...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.6),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D8),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D8),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.blue.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Driver rating slider
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          Text(
                            'Driver Rating: ${_driverRating.round()}/10',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _ratingTouched
                                  ? Colors.blue[700]
                                  : const Color(0xFF4A4A5A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: Colors.blue[400],
                              inactiveTrackColor:
                                  Colors.blue.withValues(alpha: 0.15),
                              thumbColor: Colors.blue[600],
                              overlayColor:
                                  Colors.blue.withValues(alpha: 0.12),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _driverRating,
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: _driverRating.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _driverRating = value;
                                  _ratingTouched = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          disabledBackgroundColor:
                              Colors.blue.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.blue.withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedCircles(double screenWidth) {
    final cx = screenWidth / 2;
    final configs = <_CircleConfig>[
      _CircleConfig(140, 0.08, top: -30, leftAnchor: -40, drift: cx * 0.8, index: 0),
      _CircleConfig(180, 0.06, top: 150, rightAnchor: -60, drift: cx * 0.7, index: 1),
      _CircleConfig(100, 0.10, bottom: 180, leftAnchor: -30, drift: cx * 0.9, index: 2),
      _CircleConfig(120, 0.12, bottom: -20, rightAnchor: -40, drift: cx * 0.6, index: 3),
      _CircleConfig(90, 0.09, top: 320, leftAnchor: -20, drift: cx, index: 4),
    ];

    return configs.map((cfg) {
      return AnimatedBuilder(
        animation: _animations[cfg.index],
        builder: (context, child) {
          final offset = _animations[cfg.index].value * cfg.drift;
          return Positioned(
            top: cfg.top,
            bottom: cfg.bottom,
            left: cfg.leftAnchor != null ? cfg.leftAnchor! + offset : null,
            right: cfg.rightAnchor != null ? cfg.rightAnchor! + offset : null,
            child: child!,
          );
        },
        child: Container(
          width: cfg.size,
          height: cfg.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: cfg.opacity),
          ),
        ),
      );
    }).toList();
  }
}

class _CircleConfig {
  final double size;
  final double opacity;
  final double? top;
  final double? bottom;
  final double? leftAnchor;
  final double? rightAnchor;
  final double drift;
  final int index;

  _CircleConfig(
    this.size,
    this.opacity, {
    this.top,
    this.bottom,
    this.leftAnchor,
    this.rightAnchor,
    required this.drift,
    required this.index,
  });
}
