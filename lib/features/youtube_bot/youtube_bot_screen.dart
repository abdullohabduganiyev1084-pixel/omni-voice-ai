import 'package:flutter/material.dart';
import '../../core/services/device_controller.dart';
import '../../widgets/liquid_glass_card.dart';

class YouTubeBotScreen extends StatefulWidget {
  const YouTubeBotScreen({super.key});

  @override
  State<YouTubeBotScreen> createState() => _YouTubeBotScreenState();
}

class _YouTubeBotScreenState extends State<YouTubeBotScreen> {
  final TextEditingController _queryController = TextEditingController(text: 'Lofi hip hop chill beats');
  int _targetMinutes = 5;
  int _targetSeconds = 0;
  bool _isLoading = false;

  void _launchYouTube() async {
    setState(() => _isLoading = true);
    final totalSeconds = (_targetMinutes * 60) + _targetSeconds;
    await DeviceController.openYouTube(
      query: _queryController.text.trim(),
      timeSeconds: totalSeconds,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('YouTube ochilmoqda: ${_queryController.text} (${_targetMinutes}m ${_targetSeconds}s)'),
          backgroundColor: const Color(0xFFFF0000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Smart Bot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YouTube Hero Card
            LiquidGlassCard(
              borderGradient: const LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFFFF7A00)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF0000).withOpacity(0.2),
                    ),
                    child: const Icon(Icons.smart_display_rounded, color: Color(0xFFFF0000), size: 36),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aniq Daqiqadan Boshlash',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ovozli yoki yozma buyruq orqali videoni xohlagan sekundidan oching.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Video Name or Search Query Input
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Nomi yoki Havolasi:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: 'Masalan: Dasturlash darslari, Uzbek music...',
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00F2FE)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Minute & Second Picker Card
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Boshlanish Vaqti (Minut va Sekund):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Minutes Control
                      Column(
                        children: [
                          const Text('Minut', style: TextStyle(fontSize: 13, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton.filledTonal(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (_targetMinutes > 0) setState(() => _targetMinutes--);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '$_targetMinutes min',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.add),
                                onPressed: () => setState(() => _targetMinutes++),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Quick Preset Chips
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [0, 1, 2, 5, 10, 15, 30].map((m) {
                      return ChoiceChip(
                        label: Text('$m-daqiqa'),
                        selected: _targetMinutes == m,
                        onSelected: (sel) {
                          if (sel) setState(() => _targetMinutes = m);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Launch Button
            LiquidGlassCard(
              padding: EdgeInsets.zero,
              onTap: _isLoading ? null : _launchYouTube,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF0000), Color(0xFFFF5252), Color(0xFFFF7A00)],
                  ),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'YouTube da Ko\'rsatilgan Vaqtdan Qo\'yish',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Voice Command Examples
            const Text(
              'Ovozli Buyruqlar Namunasi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildCommandSample('"YouTube ga kirib lofi musiqani 5-minutiga qo\'y"'),
            _buildCommandSample('"Yutubdan Flutter darsini 10-daqiqasidan och"'),
            _buildCommandSample('"Qidiruv: Yangiliklar 2026"'),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandSample(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, size: 16, color: Color(0xFF00F2FE)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
