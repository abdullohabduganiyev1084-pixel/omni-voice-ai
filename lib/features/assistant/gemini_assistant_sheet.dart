import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/voice_assistant_service.dart';
import '../../widgets/neon_waveform.dart';

class GeminiAssistantSheet extends StatelessWidget {
  const GeminiAssistantSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceAssistantService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xEB0A0D14) : const Color(0xEBFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF00F2FE).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F2FE).withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Gemini Glow Frame Header
                Row(
                  children: [
                    Image.asset(
                      'assets/images/app_logo.jpg',
                      width: 44,
                      height: 44,
                      errorBuilder: (c, e, s) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F2FE), Color(0xFF9B51E0)],
                          ),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gemini Live Assistant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            voice.isListening
                                ? 'Tinglamoqda...'
                                : (voice.isThinking ? 'O\'ylamoqda...' : 'Tayyor'),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF00F2FE).withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Live Audio Waveform
                NeonWaveform(
                  soundLevel: voice.soundLevel,
                  isListening: voice.isListening,
                  isThinking: voice.isThinking,
                ),

                const SizedBox(height: 16),

                // User input or Assistant response box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (voice.lastWords.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.mic, size: 14, color: Color(0xFF00F2FE)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                voice.lastWords,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                      ],
                      Text(
                        voice.assistantReply,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Action Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        context,
                        '▶️ YouTube: Lofi 5-minutiga',
                        () => voice.executeCommand('YouTube ga kirib lofi musiqani 5-minutiga qo\'y'),
                      ),
                      _buildChip(
                        context,
                        '📞 "Answer the call"',
                        () => voice.executeCommand('Answer the call'),
                      ),
                      _buildChip(
                        context,
                        '📱 Telegramni och',
                        () => voice.executeCommand('Telegramni och'),
                      ),
                      _buildChip(
                        context,
                        '🏠 Home sahifa',
                        () => voice.executeCommand('Uy sahifasiga o\'t'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main Mic Trigger Button
                GestureDetector(
                  onTap: () => voice.toggleListening(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFF9B51E0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F2FE).withOpacity(voice.isListening ? 0.6 : 0.3),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      voice.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.white.withOpacity(0.08),
        side: BorderSide(color: Colors.white.withOpacity(0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: onTap,
      ),
    );
  }
}
