import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceController {
  static const MethodChannel _channel = MethodChannel('com.omni.voice_ai/system_control');

  static Function(String state, String number)? onCallStateChanged;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onCallStateChanged') {
        final Map<dynamic, dynamic> args = call.arguments;
        final state = args['state'] as String? ?? 'IDLE';
        final number = args['number'] as String? ?? 'Noma\'lum';
        onCallStateChanged?.call(state, number);
      }
    });
  }

  /// Qo'ng'iroqqa ovoz orqali javob berish
  static Future<bool> answerCall() async {
    try {
      final bool? res = await _channel.invokeMethod('answerCall');
      return res ?? false;
    } catch (e) {
      debugPrint('DeviceController.answerCall error: $e');
      return false;
    }
  }

  /// Qo'ng'iroqni rad etish / tugatish
  static Future<bool> endCall() async {
    try {
      final bool? res = await _channel.invokeMethod('endCall');
      return res ?? false;
    } catch (e) {
      debugPrint('DeviceController.endCall error: $e');
      return false;
    }
  }

  /// YouTube videoni ochish va ko'rsatilgan daqiqa/sekunddan boshlash
  static Future<bool> openYouTube({String? query, String? videoId, int timeSeconds = 0}) async {
    try {
      // 1. Agar Android native channel mavjud bo'lsa
      if (!kIsWeb) {
        final bool? res = await _channel.invokeMethod('openYouTubeAtTime', {
          'query': query,
          'videoId': videoId,
          'timeSeconds': timeSeconds,
        });
        if (res == true) return true;
      }

      // 2. Fallback: url_launcher orqali ochish
      String urlStr;
      if (videoId != null && videoId.isNotEmpty) {
        urlStr = 'https://www.youtube.com/watch?v=$videoId&t=${timeSeconds}s';
      } else if (query != null && query.isNotEmpty) {
        urlStr = 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';
      } else {
        urlStr = 'https://www.youtube.com';
      }

      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('DeviceController.openYouTube error: $e');
      return false;
    }
  }

  /// Ilovalarni ishga tushirish (Telegram, YouTube, Settings, Camera, va boshqalar)
  static Future<bool> launchApp(String appNameOrPackage) async {
    try {
      if (!kIsWeb) {
        final bool? res = await _channel.invokeMethod('launchApp', {
          'packageName': appNameOrPackage,
        });
        if (res == true) return true;
      }
      return false;
    } catch (e) {
      debugPrint('DeviceController.launchApp error: $e');
      return false;
    }
  }

  /// Global tizim amallari (Home, Back, Recents, Notifications, Scroll)
  static Future<bool> performGlobalAction(String action) async {
    try {
      if (!kIsWeb) {
        final bool? res = await _channel.invokeMethod('performGlobalAction', {
          'action': action,
        });
        return res ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('DeviceController.performGlobalAction error: $e');
      return false;
    }
  }

  /// Ekranda ko'ringan matn ustiga bosish (Accessibility)
  static Future<bool> clickScreenText(String text) async {
    try {
      if (!kIsWeb) {
        final bool? res = await _channel.invokeMethod('clickScreenText', {
          'text': text,
        });
        return res ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('DeviceController.clickScreenText error: $e');
      return false;
    }
  }

  /// Ovoz balandligini o'rnatish (0 - 100%)
  static Future<bool> setVolume(int level) async {
    try {
      if (!kIsWeb) {
        final bool? res = await _channel.invokeMethod('setVolume', {
          'level': level,
        });
        return res ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('DeviceController.setVolume error: $e');
      return false;
    }
  }

  /// Accessibility xizmati yoqilganligini tekshirish
  static Future<bool> isAccessibilityEnabled() async {
    try {
      if (!kIsWeb) {
        final bool? res = await _channel.invokeMethod('isAccessibilityEnabled');
        return res ?? false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Accessibility sozlamalari sahifasini ochish
  static Future<void> openAccessibilitySettings() async {
    try {
      if (!kIsWeb) {
        await _channel.invokeMethod('openAccessibilitySettings');
      }
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }
}
