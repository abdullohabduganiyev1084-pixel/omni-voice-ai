import 'package:flutter/material.dart';
import '../../core/constants/api_keys.dart';
import '../../core/services/ai_service.dart';
import '../../widgets/liquid_glass_card.dart';

class AiBrainScreen extends StatefulWidget {
  const AiBrainScreen({super.key});

  @override
  State<AiBrainScreen> createState() => _AiBrainScreenState();
}

class _AiBrainScreenState extends State<AiBrainScreen> {
  AiProvider _provider = AiService.activeProvider;
  String _selectedGroqModel = AiService.groqModel;
  String _selectedGeminiModel = AiService.geminiModel;
  int? _testLatency;
  String? _testOutput;
  bool _isTesting = false;

  void _runBenchmark() async {
    setState(() {
      _isTesting = true;
      _testLatency = null;
      _testOutput = null;
    });

    try {
      final res = await AiService.processCommand('YouTube da lofi musiqani 5-minutiga qo\'y');
      setState(() {
        _testLatency = res.latencyMs;
        _testOutput = '${res.speechText}\n\n[Action: ${res.action}, Params: ${res.params}]';
      });
    } catch (e) {
      setState(() {
        _testOutput = 'Xatolik: $e';
      });
    } finally {
      setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Miya & Modellar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Engine Card
            LiquidGlassCard(
              borderGradient: const LinearGradient(
                colors: [Color(0xFF00F2FE), Color(0xFF9B51E0)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00F2FE).withOpacity(0.2),
                        ),
                        child: const Icon(Icons.psychology_rounded, color: Color(0xFF00F2FE), size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Asosiy AI Dvigateli',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _provider == AiProvider.groq ? 'Groq (Ultra-Fast LPUs)' : 'Google Gemini (Multimodal)',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF00F2FE)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<AiProvider>(
                    segments: const [
                      ButtonSegment(
                        value: AiProvider.groq,
                        label: Text('Groq AI ⚡'),
                        icon: Icon(Icons.bolt_rounded),
                      ),
                      ButtonSegment(
                        value: AiProvider.gemini,
                        label: Text('Gemini 🌟'),
                        icon: Icon(Icons.auto_awesome_rounded),
                      ),
                    ],
                    selected: {_provider},
                    onSelectionChanged: (set) {
                      setState(() {
                        _provider = set.first;
                        AiService.activeProvider = _provider;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Model Selection
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _provider == AiProvider.groq ? 'Groq Modeli:' : 'Google Gemini Modeli:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  if (_provider == AiProvider.groq) ...[
                    RadioListTile<String>(
                      title: const Text('Llama 3.3 70B Versatile (Tavsiya etiladi)'),
                      subtitle: const Text('Ultra-kuchli va murakkab buyruqlarni mukammal tushunadi'),
                      value: ApiKeys.defaultGroqModel,
                      groupValue: _selectedGroqModel,
                      activeColor: const Color(0xFF00F2FE),
                      onChanged: (val) {
                        setState(() {
                          _selectedGroqModel = val!;
                          AiService.groqModel = val;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Llama 3.1 8B Instant'),
                      subtitle: const Text('Eng yuqori tezlik, 50ms latensiya'),
                      value: ApiKeys.fastGroqModel,
                      groupValue: _selectedGroqModel,
                      activeColor: const Color(0xFF00F2FE),
                      onChanged: (val) {
                        setState(() {
                          _selectedGroqModel = val!;
                          AiService.groqModel = val;
                        });
                      },
                    ),
                  ] else ...[
                    RadioListTile<String>(
                      title: const Text('Gemini 2.0 Flash (Eng oxirgi model)'),
                      subtitle: const Text('Google-ning eng yangi tezkor multimodal modeli'),
                      value: ApiKeys.defaultGeminiModel,
                      groupValue: _selectedGeminiModel,
                      activeColor: const Color(0xFF9B51E0),
                      onChanged: (val) {
                        setState(() {
                          _selectedGeminiModel = val!;
                          AiService.geminiModel = val;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Gemini 1.5 Pro'),
                      subtitle: const Text('Katta kontekst va chuqur mantiq'),
                      value: ApiKeys.proGeminiModel,
                      groupValue: _selectedGeminiModel,
                      activeColor: const Color(0xFF9B51E0),
                      onChanged: (val) {
                        setState(() {
                          _selectedGeminiModel = val!;
                          AiService.geminiModel = val;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Speed & Benchmark Test
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tezlik va Javob Sinovi (Benchmark):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isTesting ? null : _runBenchmark,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F2FE),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: _isTesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.speed_rounded),
                    label: Text(_isTesting ? 'Sinov bajarilmoqda...' : 'Tezlikni Sinash (Latensiya)'),
                  ),
                  if (_testLatency != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFF00E676)),
                        const SizedBox(width: 8),
                        Text(
                          'Javob vaqti: $_testLatency ms',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676), fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _testOutput ?? '',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
