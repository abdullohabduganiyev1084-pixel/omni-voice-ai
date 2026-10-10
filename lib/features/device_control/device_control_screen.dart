import 'package:flutter/material.dart';
import '../../core/services/device_controller.dart';
import '../../widgets/liquid_glass_card.dart';

class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  double _volume = 70.0;
  final TextEditingController _clickTextController = TextEditingController();

  void _triggerGlobal(String action, String label) async {
    final res = await DeviceController.performGlobalAction(action);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label bajarildi'),
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  void _launchApp(String appName) async {
    await DeviceController.launchApp(appName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$appName ochilmoqda...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telefon Nazorati', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick System Navigation Buttons
            const Text(
              'Tizim Tugmalari (Accessibility):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSystemBtn(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    onTap: () => _triggerGlobal('home', 'Uy sahifasi'),
                    color: const Color(0xFF00F2FE),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSystemBtn(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onTap: () => _triggerGlobal('back', 'Orqaga'),
                    color: const Color(0xFF9B51E0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSystemBtn(
                    icon: Icons.splitscreen_rounded,
                    label: 'Recents',
                    onTap: () => _triggerGlobal('recents', 'Oxirgi ilovalar'),
                    color: const Color(0xFFFFB199),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSystemBtn(
                    icon: Icons.notifications_active_rounded,
                    label: 'Panel',
                    onTap: () => _triggerGlobal('notifications', 'Bildirishnomalar'),
                    color: const Color(0xFF00E676),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Volume Controller Slider
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ovoz Balandligi:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${_volume.round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _volume,
                    min: 0,
                    max: 100,
                    activeColor: const Color(0xFF00F2FE),
                    onChanged: (val) {
                      setState(() => _volume = val);
                      DeviceController.setVolume(val.round());
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick App Launchers
            const Text(
              'Tezkor Ilovalar:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildAppChip('YouTube', Icons.smart_display, const Color(0xFFFF0000), () => _launchApp('youtube')),
                _buildAppChip('Telegram', Icons.send_rounded, const Color(0xFF2AABEE), () => _launchApp('telegram')),
                _buildAppChip('Kamera', Icons.camera_alt_rounded, const Color(0xFFFF7A00), () => _launchApp('camera')),
                _buildAppChip('Sozlamalar', Icons.settings_rounded, const Color(0xFF9E9E9E), () => _launchApp('settings')),
                _buildAppChip('Telefon', Icons.phone_rounded, const Color(0xFF00E676), () => _launchApp('phone')),
                _buildAppChip('Chrome', Icons.public_rounded, const Color(0xFFFFC107), () => _launchApp('chrome')),
              ],
            ),

            const SizedBox(height: 24),

            // Screen Click Assistant
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ekranda Matnni Topib Bosish (Click Assist):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _clickTextController,
                          decoration: InputDecoration(
                            hintText: 'Masalan: Subscribe, Skip, Ok...',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.touch_app_rounded),
                        onPressed: () {
                          if (_clickTextController.text.isNotEmpty) {
                            DeviceController.clickScreenText(_clickTextController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('"${_clickTextController.text}" bosilmoqda...')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAppChip(String name, IconData icon, Color color, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(name),
      backgroundColor: Colors.white.withOpacity(0.08),
      side: BorderSide(color: Colors.white.withOpacity(0.12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: onTap,
    );
  }
}
