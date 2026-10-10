import 'dart:math';
import 'package:flutter/material.dart';

class NeonWaveform extends StatefulWidget {
  final double soundLevel; // 0.0 to 1.0
  final bool isListening;
  final bool isThinking;
  final Color primaryColor;
  final Color secondaryColor;

  const NeonWaveform({
    super.key,
    required this.soundLevel,
    required this.isListening,
    this.isThinking = false,
    this.primaryColor = const Color(0xFF00F2FE),
    this.secondaryColor = const Color(0xFF9B51E0),
  });

  @override
  State<NeonWaveform> createState() => _NeonWaveformState();
}

class _NeonWaveformState extends State<NeonWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 80),
          painter: WaveformPainter(
            animationValue: _animController.value,
            soundLevel: widget.soundLevel,
            isListening: widget.isListening,
            isThinking: widget.isThinking,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final double soundLevel;
  final bool isListening;
  final bool isThinking;
  final Color primaryColor;
  final Color secondaryColor;

  WaveformPainter({
    required this.animationValue,
    required this.soundLevel,
    required this.isListening,
    required this.isThinking,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 28;
    final spacing = size.width / barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * spacing + spacing / 2;

      double waveHeight = 6.0;

      if (isListening) {
        final frequency = (i / barCount) * pi * 2;
        final dynamicWave = sin(frequency + animationValue * pi * 4);
        waveHeight = 8.0 + (soundLevel * 35.0 * (1 + dynamicWave.abs()));
      } else if (isThinking) {
        final wave = sin((i / 4.0) + animationValue * pi * 4);
        waveHeight = 10.0 + (wave.abs() * 26.0);
      } else {
        final wave = sin((i / 6.0) + animationValue * pi * 2);
        waveHeight = 4.0 + (wave.abs() * 6.0);
      }

      final topY = centerY - waveHeight;
      final bottomY = centerY + waveHeight;

      final t = i / barCount;
      final barColor = Color.lerp(primaryColor, secondaryColor, t)!;

      final paint = Paint()
        ..color = barColor.withOpacity(isListening ? 0.9 : 0.6)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, isListening ? 3 : 1);

      canvas.drawLine(Offset(x, topY), Offset(x, bottomY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) => true;
}
