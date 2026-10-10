import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class SiriNeonOrb extends StatefulWidget {
  final double soundLevel;
  final bool isListening;
  final bool isThinking;
  final VoidCallback? onTap;

  const SiriNeonOrb({
    super.key,
    required this.soundLevel,
    required this.isListening,
    this.isThinking = false,
    this.onTap,
  });

  @override
  State<SiriNeonOrb> createState() => _SiriNeonOrbState();
}

class _SiriNeonOrbState extends State<SiriNeonOrb>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseController]),
        builder: (context, child) {
          final pulse = _pulseController.value;
          final scale = 1.0 + (widget.isListening ? widget.soundLevel * 0.35 + (pulse * 0.08) : pulse * 0.04);

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ambient Glow Aura
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F2FE).withOpacity(widget.isListening ? 0.45 : 0.2),
                          blurRadius: 70,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF0844).withOpacity(widget.isListening ? 0.35 : 0.15),
                          blurRadius: 90,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: const Color(0xFF9B51E0).withOpacity(0.3),
                          blurRadius: 110,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),

                  // Dynamic Orb Canvas Shader & Ring
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: OrbGlassPainter(
                      rotation: _rotationController.value * 2 * pi,
                      pulse: pulse,
                      soundLevel: widget.soundLevel,
                      isListening: widget.isListening,
                    ),
                  ),

                  // Loaded Orb Visual Image (from user upload assets)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(110),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Image.asset(
                        'assets/images/ai_orb_1.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback dynamic generator if asset path issue
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFF00F2FE),
                                  Color(0xFFFF0844),
                                  Color(0xFF7F00FF),
                                  Colors.black,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Center Pause / Voice bars indicator
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                    ),
                    child: Center(
                      child: widget.isListening
                          ? const Icon(Icons.mic, color: Colors.white, size: 20)
                          : const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrbGlassPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double soundLevel;
  final bool isListening;

  OrbGlassPainter({
    required this.rotation,
    required this.pulse,
    required this.soundLevel,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glowing rim
    final rimPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(rotation),
        colors: const [
          Color(0xFF00F2FE),
          Color(0xFF4FACFE),
          Color(0xFFFF0844),
          Color(0xFFFFB199),
          Color(0xFF9B51E0),
          Color(0xFF00F2FE),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isListening ? 4.0 : 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawCircle(center, radius - 2, rimPaint);

    // Cosmic Dust Particles
    final random = Random(42);
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.6);

    for (int i = 0; i < 30; i++) {
      final angle = (i / 30) * 2 * pi + rotation;
      final dist = radius * (0.3 + 0.6 * random.nextDouble());
      final dx = center.dx + cos(angle) * dist;
      final dy = center.dy + sin(angle) * dist;
      canvas.drawCircle(Offset(dx, dy), 1.2 + random.nextDouble() * 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbGlassPainter oldDelegate) => true;
}
