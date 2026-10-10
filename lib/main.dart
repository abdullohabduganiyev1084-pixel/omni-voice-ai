import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/voice_assistant_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmniVoiceAiApp());
}

class OmniVoiceAiApp extends StatefulWidget {
  const OmniVoiceAiApp({super.key});

  @override
  State<OmniVoiceAiApp> createState() => _OmniVoiceAiAppState();
}

class _OmniVoiceAiAppState extends State<OmniVoiceAiApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceAssistantService()),
      ],
      child: MaterialApp(
        title: 'Omni Voice AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: _themeMode,
        home: const OnboardingScreen(),
      ),
    );
  }
}
