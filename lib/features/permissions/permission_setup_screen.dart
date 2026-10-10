import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/device_controller.dart';
import '../../widgets/liquid_glass_card.dart';
import '../home/home_screen.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _micGranted = false;
  bool _phoneGranted = false;
  bool _accessibilityGranted = false;
  bool _overlayGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final mic = await Permission.microphone.isGranted;
    final phone = await Permission.phone.isGranted;
    final overlay = await Permission.systemAlertWindow.isGranted;
    final access = await DeviceController.isAccessibilityEnabled();

    if (mounted) {
      setState(() {
        _micGranted = mic;
        _phoneGranted = phone;
        _overlayGranted = overlay;
        _accessibilityGranted = access;
      });
    }
  }

  Future<void> _requestMic() async {
    final status = await Permission.microphone.request();
    setState(() => _micGranted = status.isGranted);
  }

  Future<void> _requestPhone() async {
    final status = await Permission.phone.request();
    setState(() => _phoneGranted = status.isGranted);
  }

  Future<void> _requestOverlay() async {
    final status = await Permission.systemAlertWindow.request();
    setState(() => _overlayGranted = status.isGranted);
  }

  Future<void> _requestAccessibility() async {
    await DeviceController.openAccessibilitySettings();
    await Future.delayed(const Duration(seconds: 1));
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Row(
                children: [
                  Image.asset(
                    'assets/images/app_logo.jpg',
                    width: 38,
                    height: 38,
                    errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome, color: Color(0xFF00F2FE)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tizim Ruxsatlari',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'AI telefonni to\'liq boshqarishi, YouTube videolarni qo\'yishi va qo\'ng\'iroqlarga javob berishi uchun quyidagi ruxsatlarni bering:',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Permission Cards List
              Expanded(
                child: ListView(
                  children: [
                    _buildPermissionItem(
                      icon: Icons.mic_rounded,
                      title: 'Mikrofon va Ovoz',
                      desc: 'Ovozli buyruqlaringizni real vaqtda eshitish uchun.',
                      isGranted: _micGranted,
                      onTap: _requestMic,
                      accent: const Color(0xFF00F2FE),
                    ),
                    _buildPermissionItem(
                      icon: Icons.accessibility_new_rounded,
                      title: 'Accessibility Xizmati',
                      desc: 'YouTube, ilovalarni ochish va ekranni avtomatik bosish uchun.',
                      isGranted: _accessibilityGranted,
                      onTap: _requestAccessibility,
                      accent: const Color(0xFF9B51E0),
                    ),
                    _buildPermissionItem(
                      icon: Icons.phone_in_talk_rounded,
                      title: 'Qo\'ng\'iroqlarni Boshqarish',
                      desc: '"Answer the call" ovozli buyrug\'i bilan qo\'ng\'iroqni ochish uchun.',
                      isGranted: _phoneGranted,
                      onTap: _requestPhone,
                      accent: const Color(0xFF00E676),
                    ),
                    _buildPermissionItem(
                      icon: Icons.picture_in_picture_alt_rounded,
                      title: 'Boshqa Ilovalar Ustida Ko\'rinish',
                      desc: 'Gemini va Siri kabi suzuvchi AI orolini ko\'rsatish uchun.',
                      isGranted: _overlayGranted,
                      onTap: _requestOverlay,
                      accent: const Color(0xFFFF0844),
                    ),
                  ],
                ),
              ),

              // Enter App Button
              LiquidGlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFF9B51E0)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Ilovaga Kirish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isGranted,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isGranted ? const Color(0xFF00E676).withOpacity(0.2) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isGranted ? const Color(0xFF00E676) : Colors.white24,
              ),
            ),
            child: Text(
              isGranted ? 'Ruxsat berildi' : 'Yoqish',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isGranted ? const Color(0xFF00E676) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
