import 'package:flutter/material.dart';
import '../../core/services/device_controller.dart';
import '../../widgets/liquid_glass_card.dart';

class CallAssistantScreen extends StatefulWidget {
  const CallAssistantScreen({super.key});

  @override
  State<CallAssistantScreen> createState() => _CallAssistantScreenState();
}

class _CallAssistantScreenState extends State<CallAssistantScreen> {
  bool _autoAnswerEnabled = true;
  bool _voiceTriggerEnabled = true;
  String _currentCallState = 'IDLE (Qo\'ng\'iroq yo\'q)';
  String _callerNumber = '';

  @override
  void initState() {
    super.initState();
    DeviceController.onCallStateChanged = (state, number) {
      if (mounted) {
        setState(() {
          _currentCallState = state;
          _callerNumber = number;
        });
      }
    };
  }

  void _testAnswerCall() async {
    final success = await DeviceController.answerCall();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Qo\'ng\'iroqqa javob berildi!' : 'Javob berish buyrug\'i bajarildi'),
          backgroundColor: const Color(0xFF00E676),
        ),
      );
    }
  }

  void _testEndCall() async {
    final success = await DeviceController.endCall();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Qo\'ng\'iroq yakunlandi' : 'Qo\'ng\'iroq rad etildi'),
          backgroundColor: const Color(0xFFFF0844),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qo\'ng\'iroq Assisti', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Status Card
            LiquidGlassCard(
              borderGradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00F2FE)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E676).withOpacity(0.2),
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF00E676), size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ovozli Qo\'ng\'iroq Boshqaruvi',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Holat: $_currentCallState ${_callerNumber.isNotEmpty ? "($_callerNumber)" : ""}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _currentCallState.contains('RINGING')
                                ? const Color(0xFFFF0844)
                                : const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Switches
            LiquidGlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Ovozli "Answer the call" buyrug\'i', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Qo\'ng\'iroq bo\'lganda ovoz orqali javob berishni yoqish'),
                    value: _voiceTriggerEnabled,
                    activeColor: const Color(0xFF00E676),
                    onChanged: (val) => setState(() => _voiceTriggerEnabled = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Avtomatik E\'lon Qilish', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Kim qo\'ng\'iroq qilayotganini baland ovozda o\'qib berish'),
                    value: _autoAnswerEnabled,
                    activeColor: const Color(0xFF00F2FE),
                    onChanged: (val) => setState(() => _autoAnswerEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Interactive Test Actions
            const Text(
              'Test Buyruqlari:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: LiquidGlassCard(
                    padding: EdgeInsets.zero,
                    onTap: _testAnswerCall,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Answer the Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LiquidGlassCard(
                    padding: EdgeInsets.zero,
                    onTap: _testEndCall,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0844), Color(0xFFFFB199)],
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_end, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Decline / End', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sample Voice Commands
            const Text(
              'Qo\'llab-quvvatlanuvchi Ovozli So\'zlar:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildSampleChip('"Answer the call" (Inglizcha)'),
            _buildSampleChip('"Qo\'ng\'iroqqa javob ber" (O\'zbekcha)'),
            _buildSampleChip('"Go\'shakni ko\'tar"'),
            _buildSampleChip('"Rad et" / "Go\'shakni qo\'y"'),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleChip(String text) {
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
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF00E676)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
