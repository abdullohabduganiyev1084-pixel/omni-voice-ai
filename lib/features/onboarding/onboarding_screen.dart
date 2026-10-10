import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_card.dart';
import '../permissions/permission_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Omni Voice AI',
      'subtitle': 'Telefoningizni to\'liq ovoz bilan boshqaring. Groq Llama 3.3 va Google Gemini bilan quvvatlangan eng tezkor assistent.',
      'image': 'assets/images/app_logo.jpg',
      'highlight': 'Ultra-tez AI',
    },
    {
      'title': 'YouTube Smart Bot',
      'subtitle': 'Istalgan videoni ayting, AI uni YouTube da ochib xohlagan daqiqa va sekundidan boshlab qo\'yadi.',
      'image': 'assets/images/ai_orb_1.png',
      'highlight': 'Daqiqasigacha aniq',
    },
    {
      'title': 'Ovozli Qo\'ng\'iroqlar',
      'subtitle': 'Kiruvchi qo\'ng\'iroq kelganda shunchaki "Answer the call" deng, AI avtomatik javob beradi.',
      'image': 'assets/images/ai_orb_2.png',
      'highlight': 'Hands-free nazorat',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F2FE).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF0844).withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: TextButton(
                      onPressed: () => _goToPermissions(context),
                      child: Text(
                        'O\'tkazib yuborish',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Slide Pager
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glowing Hero Asset
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00F2FE).withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110),
                                child: Image.asset(
                                  slide['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.auto_awesome,
                                    size: 100,
                                    color: Color(0xFF00F2FE),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F2FE).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00F2FE).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                slide['highlight']!,
                                style: const TextStyle(
                                  color: Color(0xFF00F2FE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              slide['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Subtitle
                            Text(
                              slide['subtitle']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicator & Get Started Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == i
                                  ? const Color(0xFF00F2FE)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Main "Get Started" Action Button
                      LiquidGlassCard(
                        padding: EdgeInsets.zero,
                        color: Colors.transparent,
                        onTap: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _goToPermissions(context);
                          }
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
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _slides.length - 1 ? 'Get Started' : 'Davom etish',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToPermissions(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PermissionSetupScreen()),
    );
  }
}
