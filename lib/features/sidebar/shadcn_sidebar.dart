import 'dart:ui';
import 'package:flutter/material.dart';
import '../ai_brain/ai_brain_screen.dart';
import '../call_assistant/call_assistant_screen.dart';
import '../device_control/device_control_screen.dart';
import '../settings/settings_screen.dart';
import '../youtube_bot/youtube_bot_screen.dart';

class ShadcnSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ShadcnSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xF2090C12) : const Color(0xF2F8FAFC),
          border: Border(
            right: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shadcn Sidebar Header / Brand
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00F2FE).withOpacity(0.3),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/app_logo.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome, color: Color(0xFF00F2FE)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Omni Voice AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Groq & Gemini Pro',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF00F2FE),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                    height: 1,
                  ),

                  const SizedBox(height: 12),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildSectionLabel('ASOSIY BOSHQARUV'),
                        _buildNavItem(
                          context,
                          index: 0,
                          icon: Icons.graphic_eq_rounded,
                          title: 'Voice Hub (Asosiy)',
                          onTap: () {
                            onItemSelected(0);
                            Navigator.pop(context);
                          },
                        ),
                        _buildNavItem(
                          context,
                          index: 1,
                          icon: Icons.smart_display_rounded,
                          title: 'YouTube Smart Bot',
                          accentColor: const Color(0xFFFF0000),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const YouTubeBotScreen()));
                          },
                        ),
                        _buildNavItem(
                          context,
                          index: 2,
                          icon: Icons.phone_in_talk_rounded,
                          title: 'Qo\'ng\'iroq Assisti',
                          accentColor: const Color(0xFF00E676),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CallAssistantScreen()));
                          },
                        ),
                        _buildNavItem(
                          context,
                          index: 3,
                          icon: Icons.tune_rounded,
                          title: 'Telefon Nazorati',
                          accentColor: const Color(0xFFFFB199),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceControlScreen()));
                          },
                        ),

                        const SizedBox(height: 16),
                        _buildSectionLabel('AI & SOZLAMALAR'),

                        _buildNavItem(
                          context,
                          index: 4,
                          icon: Icons.psychology_rounded,
                          title: 'AI Miya & Modellar',
                          accentColor: const Color(0xFF9B51E0),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AiBrainScreen()));
                          },
                        ),
                        _buildNavItem(
                          context,
                          index: 5,
                          icon: Icons.settings_suggest_rounded,
                          title: 'Dizayn & Sozlamalar',
                          accentColor: const Color(0xFF4FACFE),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom User / System Badge
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt, color: Color(0xFF00F2FE), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ultra-Fast LPUs',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Llama 3.3 70B & Gemini 2.0',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? const Color(0xFF00F2FE);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: accent.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? accent : (isDark ? Colors.white70 : Colors.black87),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? accent : (isDark ? Colors.white : Colors.black),
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
