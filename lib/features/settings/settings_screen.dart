import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_keys.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/voice_assistant_service.dart';
import '../../widgets/liquid_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _groqController = TextEditingController(text: AiService.customGroqKey);
  final TextEditingController _geminiController = TextEditingController(text: AiService.customGeminiKey);

  void _saveKeys() {
    AiService.customGroqKey = _groqController.text.trim();
    AiService.customGeminiKey = _geminiController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API Kalitlar saqlandi!'),
        backgroundColor: Color(0xFF00E676),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceAssistantService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar & API', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Assistant Visual Mode Selector
            const Text(
              'AI Assistent Rejimi & Animatsiyasi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            LiquidGlassCard(
              child: Column(
                children: [
                  RadioListTile<AssistantMode>(
                    title: const Text('2-Rejim: Siri Glowing Neon Orb (Tavsiya)'),
                    subtitle: const Text('3D rang-barang shisha shar, zarrachalar va neon nur animatsiyasi'),
                    value: AssistantMode.siriNeonOrb,
                    groupValue: voice.assistantMode,
                    activeColor: const Color(0xFF00F2FE),
                    onChanged: (mode) {
                      if (mode != null) voice.setAssistantMode(mode);
                    },
                  ),
                  const Divider(),
                  RadioListTile<AssistantMode>(
                    title: const Text('1-Rejim: Gemini Live Assistant Frame'),
                    subtitle: const Text('Pastdan chiquvchi to\'lqinli liquid glass panel'),
                    value: AssistantMode.geminiFrame,
                    groupValue: voice.assistantMode,
                    activeColor: const Color(0xFF9B51E0),
                    onChanged: (mode) {
                      if (mode != null) voice.setAssistantMode(mode);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // API Keys Management
            const Text(
              'API Kalitlari:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Groq API Key:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _groqController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'gsk_...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      suffixIcon: const Icon(Icons.bolt, color: Color(0xFF00F2FE)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Gemini API Key:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _geminiController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'AQ.Ab8...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      suffixIcon: const Icon(Icons.auto_awesome, color: Color(0xFF9B51E0)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveKeys,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F2FE),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Kalitlarni Saqlash', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // GitHub APK Build Guide Card
            const Text(
              'GitHub Actions orqali APK olish:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            LiquidGlassCard(
              borderGradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00F2FE)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_upload_rounded, color: Color(0xFF00E676)),
                      SizedBox(width: 10),
                      Text('Avtomatik APK Yig\'ish (CI/CD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ushbu loyiha ichida ".github/workflows/build_apk.yml" mavjud. Loyihani GitHub-ga yuklasangiz, avtomatik ravishda Release APK (.apk) fayli "Actions" bo\'limida tayyor bo\'ladi!',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '1. git add .\n2. git commit -m "Deploy Omni Voice AI"\n3. git push origin main\n4. GitHub -> Actions -> Artifacts -> APK yuklab olish',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF00F2FE)),
                    ),
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
