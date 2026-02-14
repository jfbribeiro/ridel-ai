import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ride_report.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  File? _selectedImage;
  String? _selectedService;
  final List<String> _services = ['Uber', 'Bolt', 'Lyft', 'Grab', 'Cabify'];
  final ImagePicker _picker = ImagePicker();

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  // Circle configs: size, opacity, top/bottom, left/right anchors, drift range
  static const int _circleCount = 9;

  @override
  void initState() {
    super.initState();

    final durations = [4200, 5000, 3800, 4600, 5400, 3500, 4800, 5200, 4000];

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

  void _onSubmit() {
    // TODO: Implement submit logic
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Title
                    const Text(
                      'Ridel AI',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Upload button
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

                    // Transparent dropdown
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedService,
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,
                        hint: Text(
                          'Select a service',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        dropdownColor: const Color(0xFFF5F5FA),
                        borderRadius: BorderRadius.circular(16),
                        decoration: InputDecoration(
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
                        selectedItemBuilder: (context) {
                          return _services.map((service) {
                            return Center(
                              child: Text(
                                service,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList();
                        },
                        items: _services.map((service) {
                          return DropdownMenuItem(
                            value: service,
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              service,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedService = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed:
                            (_selectedImage != null && _selectedService != null)
                                ? _onSubmit
                                : null,
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
                          'Get Drivers Feedback',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // "+" button at bottom-left
          Positioned(
            bottom: 24,
            left: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RideReportScreen(),
                  ),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.grey.withValues(alpha: 0.6),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedCircles(double screenWidth) {
    // Each circle: (size, opacity, topOrBottom, anchorValue, driftRange, animIndex)
    // topOrBottom: true = top, false = bottom
    final cx = screenWidth / 2;
    final configs = <_CircleConfig>[
      // Circles that drift across the center / behind UI elements
      _CircleConfig(160, 0.08, top: -40, leftAnchor: -30, drift: cx, index: 0),
      _CircleConfig(200, 0.06, top: 120, rightAnchor: -50, drift: cx * 0.8, index: 1),
      _CircleConfig(180, 0.10, bottom: 200, leftAnchor: -60, drift: cx * 0.9, index: 2),
      _CircleConfig(120, 0.12, bottom: -30, rightAnchor: -40, drift: cx * 0.7, index: 3),
      _CircleConfig(80, 0.15, top: 280, leftAnchor: -20, drift: cx * 1.2, index: 4),
      _CircleConfig(100, 0.09, top: 180, rightAnchor: -30, drift: cx * 0.9, index: 5),
      _CircleConfig(140, 0.07, bottom: 100, leftAnchor: -50, drift: cx * 1.1, index: 6),
      _CircleConfig(70, 0.13, top: 350, rightAnchor: -20, drift: cx, index: 7),
      _CircleConfig(110, 0.11, bottom: 300, leftAnchor: -30, drift: cx * 0.85, index: 8),
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
