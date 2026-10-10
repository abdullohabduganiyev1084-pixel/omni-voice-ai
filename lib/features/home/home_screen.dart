import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/voice_assistant_service.dart';
import '../../widgets/dynamic_island.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/neon_waveform.dart';
import '../assistant/gemini_assistant_sheet.dart';
import '../assistant/siri_neon_orb.dart';
import '../sidebar/shadcn_sidebar.dart';
import '../youtube_bot/youtube_bot_screen.dart';
import '../call_assistant/call_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const HomeScreen({super.key, this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textCmdController = TextEditingController();

  void _openAssistantSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GeminiAssistantSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceAssistantService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: ShadcnSidebar(
        selectedIndex: 0,
        onItemSelected: (idx) {},
      ),
      body: Stack(
        children: [
          // Background Ambient Aura Glows
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F2FE).withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF0844).withOpacity(isDark ? 0.12 : 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Custom Header: Sidebar Hamburger (Left), Dynamic Island (Center), Theme Switcher (Right)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 3-Lines Hamburger Menu (Left)
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 28),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),

                      // iOS Dynamic Island (Center)
                      Flexible(
                        child: DynamicIslandNotification(
                          title: voice.dynamicIslandText,
                          subtitle: voice.dynamicIslandSubtext,
                          iconType: voice.dynamicIslandIcon,
                          onTap: () {
                            if (voice.assistantMode == AssistantMode.geminiFrame) {
                              _openAssistantSheet();
                            } else {
                              voice.toggleListening();
                            }
                          },
                        ),
                      ),

                      // Light / Dark Mode Toggle (Right)
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 24,
                          color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF1E293B),
                        ),
                        onPressed: widget.onToggleTheme,
                      ),
                    ],
                  ),
                ),

                // Main Interactive Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),

                        // Mode 2: 3D Siri Glowing Neon Orb (User Photos Style)
                        if (voice.assistantMode == AssistantMode.siriNeonOrb) ...[
                          Center(
                            child: SiriNeonOrb(
                              soundLevel: voice.soundLevel,
                              isListening: voice.isListening,
                              isThinking: voice.isThinking,
                              onTap: () => voice.toggleListening(),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Live Waveform
                        NeonWaveform(
                          soundLevel: voice.soundLevel,
                          isListening: voice.isListening,
                          isThinking: voice.isThinking,
                        ),

                        const SizedBox(height: 16),

                        // Assistant Response & Recognized Words Liquid Glass Box
                        LiquidGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: voice.isListening
                                              ? const Color(0xFFFF0844)
                                              : (voice.isThinking ? const Color(0xFFB06AB3) : const Color(0xFF00F2FE)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        voice.isListening
                                            ? 'Eshitmoqda...'
                                            : (voice.isThinking ? 'Tahlil qilinmoqda...' : 'AI Javobi'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00F2FE),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Groq 70B & Gemini',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (voice.lastWords.isNotEmpty) ...[
                                Text(
                                  '"${voice.lastWords}"',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const Divider(height: 16),
                              ],
                              Text(
                                voice.assistantReply,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Quick Control Grid Cards
                        Row(
                          children: [
                            Expanded(
                              child: LiquidGlassCard(
                                padding: const EdgeInsets.all(14),
                                margin: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const YouTubeBotScreen()));
                                },
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.smart_display_rounded, color: Color(0xFFFF0000), size: 28),
                                    SizedBox(height: 8),
                                    Text('YouTube Bot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Daqiqasidan qo\'yish', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LiquidGlassCard(
                                padding: const EdgeInsets.all(14),
                                margin: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CallAssistantScreen()));
                                },
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.phone_in_talk_rounded, color: Color(0xFF00E676), size: 28),
                                    SizedBox(height: 8),
                                    Text('Qo\'ng\'iroqlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('"Answer the call"', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Text Command Input Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textCmdController,
                                  decoration: const InputDecoration(
                                    hintText: 'Yozma buyruq (masalan: YouTube ga kir...)',
                                    hintStyle: TextStyle(fontSize: 13),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      voice.executeCommand(val.trim());
                                      _textCmdController.clear();
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: Color(0xFF00F2FE), size: 20),
                                onPressed: () {
                                  if (_textCmdController.text.trim().isNotEmpty) {
                                    voice.executeCommand(_textCmdController.text.trim());
                                    _textCmdController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Floating AI Master Button
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (voice.assistantMode == AssistantMode.geminiFrame) {
                    _openAssistantSheet();
                  } else {
                    voice.toggleListening();
                  }
                },
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFF9B51E0), Color(0xFFFF0844)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withOpacity(voice.isListening ? 0.8 : 0.4),
                        blurRadius: voice.isListening ? 36 : 24,
                        spreadRadius: voice.isListening ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: voice.isListening
                        ? const Icon(Icons.stop_rounded, color: Colors.white, size: 36)
                        : const Icon(Icons.mic_rounded, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
