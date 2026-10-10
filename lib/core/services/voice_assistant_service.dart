import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'ai_service.dart';
import 'device_controller.dart';

enum AssistantMode {
  geminiFrame, // 1-rejim: Gemini Liquid Panel & Floating Bottom Frame
  siriNeonOrb  // 2-rejim: 3D Siri Glowing Neon Orb (foydalanuvchi rasmlaridagi)
}

class VoiceAssistantService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isThinking = false;
  bool _isSpeaking = false;
  bool _isSpeechAvailable = false;
  double _soundLevel = 0.0;
  String _lastWords = '';
  String _assistantReply = 'Salom! Men sizning ovozli aqlli assistentingizman.';
  String _dynamicIslandText = 'AI Tayyor';
  String _dynamicIslandSubtext = 'Buyruq berish uchun bosing';
  IconDataDynamic _dynamicIslandIcon = IconDataDynamic.sparkle;

  AssistantMode _assistantMode = AssistantMode.siriNeonOrb;
  final List<Map<String, dynamic>> _history = [];

  bool get isListening => _isListening;
  bool get isThinking => _isThinking;
  bool get isSpeaking => _isSpeaking;
  double get soundLevel => _soundLevel;
  String get lastWords => _lastWords;
  String get assistantReply => _assistantReply;
  String get dynamicIslandText => _dynamicIslandText;
  String get dynamicIslandSubtext => _dynamicIslandSubtext;
  IconDataDynamic get dynamicIslandIcon => _dynamicIslandIcon;
  AssistantMode get assistantMode => _assistantMode;
  List<Map<String, dynamic>> get history => _history;

  VoiceAssistantService() {
    _initTts();
    _initStt();
    DeviceController.initialize();
    DeviceController.onCallStateChanged = (state, number) {
      if (state == 'RINGING') {
        _setDynamicIsland('Kiruvchi qo\'ng\'iroq', '$number qo\'ng\'iroq qilmoqda', IconDataDynamic.phone);
        speak('Sizga $number dan qo\'ng\'iroq bo\'lmoqda. Javob berish uchun Answer the call deng.');
      } else if (state == 'IDLE') {
        _setDynamicIsland('AI Tayyor', 'Buyruq berish uchun bosing', IconDataDynamic.sparkle);
      }
    };
  }

  void setAssistantMode(AssistantMode mode) {
    _assistantMode = mode;
    notifyListeners();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('uz-UZ');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        _setDynamicIsland('AI Gapirmoqda', 'Javob berilmoqda...', IconDataDynamic.sound);
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _setDynamicIsland('AI Tayyor', 'Buyruq berish uchun bosing', IconDataDynamic.sparkle);
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('TTS Init error: $e');
    }
  }

  Future<void> _initStt() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (errorNotification) {
          debugPrint('STT Error: ${errorNotification.errorMsg}');
          _isListening = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('STT Init error: $e');
      _isSpeechAvailable = false;
    }
  }

  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }

    _lastWords = '';
    _isListening = true;
    _setDynamicIsland('Tinglanmoqda...', 'Buyruqni ayting', IconDataDynamic.mic);
    notifyListeners();

    if (_isSpeechAvailable) {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          notifyListeners();

          if (result.finalResult && _lastWords.trim().isNotEmpty) {
            _handleFinalSpeech(_lastWords);
          }
        },
        onSoundLevelChange: (level) {
          // Normalize sound level from 0 to 1
          _soundLevel = (level.clamp(-2.0, 10.0) + 2.0) / 12.0;
          notifyListeners();
        },
        localeId: 'uz_UZ',
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: false,
      );
    } else {
      // Fallback agar mikrafon emulyatorda bo'lmasa demo mock
      Future.delayed(const Duration(seconds: 3), () {
        if (_isListening) {
          _lastWords = 'YouTube ga kirib 5-minutiga qo\'y';
          _handleFinalSpeech(_lastWords);
        }
      });
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
    notifyListeners();
  }

  /// Qo'lda yozilgan yoki ovozdan kelgan matnni qayta ishlash
  Future<void> executeCommand(String text) async {
    _lastWords = text;
    await _handleFinalSpeech(text);
  }

  Future<void> _handleFinalSpeech(String text) async {
    await stopListening();
    _isThinking = true;
    _setDynamicIsland('AI O\'ylamoqda...', 'Mantiqiy tahlil qilinmoqda', IconDataDynamic.brain);
    notifyListeners();

    try {
      final result = await AiService.processCommand(text);

      _isThinking = false;
      _assistantReply = result.speechText;

      // Tarixga qo'shish
      _history.insert(0, {
        'user': text,
        'reply': result.speechText,
        'action': result.action,
        'params': result.params,
        'time': DateTime.now(),
        'latency': result.latencyMs,
      });

      // Tizim amalini bajarish
      await _executeAction(result.action, result.params);

      // AI Ovoz bilan gapiradi
      await speak(result.speechText);
    } catch (e) {
      _isThinking = false;
      _assistantReply = 'Xatolik yuz berdi: $e';
      notifyListeners();
      await speak('Kechirasiz, buyruqni bajarishda xatolik yuz berdi.');
    }
  }

  Future<void> _executeAction(String action, Map<String, dynamic> params) async {
    switch (action) {
      case 'YOUTUBE_OPEN':
        final query = params['query'] as String?;
        final videoId = params['videoId'] as String?;
        final timeSeconds = params['timeSeconds'] as int? ?? 0;
        _setDynamicIsland('YouTube ochilmoqda', '$query (${timeSeconds}s)', IconDataDynamic.youtube);
        await DeviceController.openYouTube(query: query, videoId: videoId, timeSeconds: timeSeconds);
        break;

      case 'ANSWER_CALL':
        _setDynamicIsland('Qo\'ng\'iroq qabul qilindi', 'Ulanmoqda...', IconDataDynamic.phone);
        await DeviceController.answerCall();
        break;

      case 'END_CALL':
        _setDynamicIsland('Qo\'ng\'iroq yakunlandi', '', IconDataDynamic.phone);
        await DeviceController.endCall();
        break;

      case 'LAUNCH_APP':
        final appName = params['appName'] as String? ?? '';
        _setDynamicIsland('Ilova ochilmoqda', appName, IconDataDynamic.app);
        await DeviceController.launchApp(appName);
        break;

      case 'GLOBAL_NAV':
        final type = params['type'] as String? ?? 'back';
        _setDynamicIsland('Tizim amali', type, IconDataDynamic.system);
        await DeviceController.performGlobalAction(type);
        break;

      case 'VOLUME':
        final level = params['level'] as int? ?? 50;
        _setDynamicIsland('Ovoz balandligi', '$level%', IconDataDynamic.sound);
        await DeviceController.setVolume(level);
        break;

      case 'CLICK_TEXT':
        final targetText = params['text'] as String? ?? '';
        _setDynamicIsland('Tugma bosilmoqda', targetText, IconDataDynamic.sparkle);
        await DeviceController.clickScreenText(targetText);
        break;

      case 'CHAT':
      default:
        break;
    }
  }

  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak error: $e');
    }
  }

  void _setDynamicIsland(String title, String subtitle, IconDataDynamic icon) {
    _dynamicIslandText = title;
    _dynamicIslandSubtext = subtitle;
    _dynamicIslandIcon = icon;
    notifyListeners();
  }
}

enum IconDataDynamic { sparkle, mic, brain, sound, phone, youtube, app, system }
