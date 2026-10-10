import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/services/voice_assistant_service.dart';

class DynamicIslandNotification extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconDataDynamic iconType;
  final bool isExpanded;
  final VoidCallback? onTap;

  const DynamicIslandNotification({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconType,
    this.isExpanded = false,
    this.onTap,
  });

  IconData _getIcon() {
    switch (iconType) {
      case IconDataDynamic.mic:
        return Icons.mic_rounded;
      case IconDataDynamic.brain:
        return Icons.psychology_rounded;
      case IconDataDynamic.sound:
        return Icons.volume_up_rounded;
      case IconDataDynamic.phone:
        return Icons.phone_in_talk_rounded;
      case IconDataDynamic.youtube:
        return Icons.smart_display_rounded;
      case IconDataDynamic.app:
        return Icons.apps_rounded;
      case IconDataDynamic.system:
        return Icons.tune_rounded;
      case IconDataDynamic.sparkle:
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getAccentColor() {
    switch (iconType) {
      case IconDataDynamic.mic:
        return const Color(0xFFFF0844);
      case IconDataDynamic.brain:
        return const Color(0xFFB06AB3);
      case IconDataDynamic.sound:
        return const Color(0xFF00E676);
      case IconDataDynamic.phone:
        return const Color(0xFF00E676);
      case IconDataDynamic.youtube:
        return const Color(0xFFFF0000);
      case IconDataDynamic.app:
        return const Color(0xFF4FACFE);
      case IconDataDynamic.system:
      case IconDataDynamic.sparkle:
      default:
        return const Color(0xFF00F2FE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getAccentColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        constraints: BoxConstraints(
          minWidth: 160,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          minHeight: 44,
        ),
        decoration: BoxDecoration(
          color: const Color(0xE6000000), // iOS Dynamic Island Deep Black
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.25),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.3), accent.withOpacity(0.05)],
                ),
              ),
              child: Icon(
                _getIcon(),
                color: accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),

            // Dynamic Text
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Pulsing live indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                boxShadow: [
                  BoxShadow(
                    color: accent,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
