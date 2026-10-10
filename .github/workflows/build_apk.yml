import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

enum AiProvider { groq, gemini }

class AiCommandResult {
  final String action;
  final Map<String, dynamic> params;
  final String speechText;
  final String rawResponse;
  final int latencyMs;

  AiCommandResult({
    required this.action,
    required this.params,
    required this.speechText,
    required this.rawResponse,
    required this.latencyMs,
  });
}

class AiService {
  static AiProvider activeProvider = AiProvider.groq;
  static String groqModel = ApiKeys.defaultGroqModel;
  static String geminiModel = ApiKeys.defaultGeminiModel;
  static String customGroqKey = ApiKeys.groqApiKey;
  static String customGeminiKey = ApiKeys.geminiApiKey;

  static const String systemInstruction = '''
Siz "Omni Voice AI" - foydalanuvchining telefonini to'liq ovoz orqali boshqaruvchi eng aqlli va tezkor sun'iy intellektsiz.
Foydalanuvchi sizga ovozli yoki yozma buyruq beradi. Siz uning niyatini tushunib, doimo quyidagi QAT'IY JSON formatida javob berishingiz SHART:

{
  "action": "ACTION_NAME",
  "params": { ... },
  "speech": "Foydalanuvchiga ovoz bilan aytiladigan o'zbekcha qisqa, xushmuomala javob"
}

Mumkin bo'lgan ACTION_NAME va params turlari:
1. "YOUTUBE_OPEN":
   - "query": "qidirilayotgan mavzu yoki video nomi"
   - "videoId": "agar aniq video ID bo'lsa yoki bo'sh"
   - "timeSeconds": sekundlar soni (masalan: 5-minut bo'lsa 300, 2-minut bo'lsa 120, 0 agar boshidan)

2. "ANSWER_CALL":
   - params: {}
   - speech: "Qo'ng'iroqqa javob berildi."

3. "END_CALL":
   - params: {}
   - speech: "Qo'ng'iroq tugatildi."

4. "LAUNCH_APP":
   - "appName": "youtube", "telegram", "camera", "settings", "chrome", "phone"
   - speech: "Ilova ochilmoqda."

5. "GLOBAL_NAV":
   - "type": "home" | "back" | "recents" | "notifications" | "scroll_down" | "scroll_up"

6. "VOLUME":
   - "level": 0 dan 100 gacha raqam

7. "CLICK_TEXT":
   - "text": "bosilishi kerak bo'lgan tugma matni"

8. "CHAT":
   - params: {}
   - speech: "Foydalanuvchiga to'g'ridan-to'g'ri qisqa javob."
''';

  static Future<AiCommandResult> processCommand(String userVoiceInput) async {
    final stopwatch = Stopwatch()..start();

    try {
      if (activeProvider == AiProvider.groq) {
        return await _callGroq(userVoiceInput, stopwatch);
      } else {
        return await _callGemini(userVoiceInput, stopwatch);
      }
    } catch (e) {
      debugPrint('AI Processing error: $e');
      try {
        if (activeProvider == AiProvider.groq) {
          return await _callGemini(userVoiceInput, stopwatch);
        } else {
          return await _callGroq(userVoiceInput, stopwatch);
        }
      } catch (fallbackErr) {
        stopwatch.stop();
        return _localHeuristicFallback(userVoiceInput, stopwatch.elapsedMilliseconds);
      }
    }
  }

  static Future<AiCommandResult> _callGroq(String prompt, Stopwatch sw) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customGroqKey',
      },
      body: jsonEncode({
        'model': groqModel,
        'messages': [
          {'role': 'system', 'content': systemInstruction},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.2,
        'max_tokens': 500,
        'response_format': {'type': 'json_object'},
      }),
    ).timeout(const Duration(seconds: 7));

    sw.stop();

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'] as String;
      return _parseJsonResponse(content, sw.elapsedMilliseconds);
    } else {
      throw Exception('Groq API status ${response.statusCode}: ${response.body}');
    }
  }

  static Future<AiCommandResult> _callGemini(String prompt, Stopwatch sw) async {
    final cleanKey = customGeminiKey.trim();
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$cleanKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
        }
      }),
    ).timeout(const Duration(seconds: 8));

    sw.stop();

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return _parseJsonResponse(content, sw.elapsedMilliseconds);
    } else {
      throw Exception('Gemini API status ${response.statusCode}: ${response.body}');
    }
  }

  static AiCommandResult _parseJsonResponse(String rawJson, int latency) {
    try {
      var cleaned = rawJson.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      }
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return AiCommandResult(
        action: parsed['action'] ?? 'CHAT',
        params: parsed['params'] is Map<String, dynamic> ? parsed['params'] : {},
        speechText: parsed['speech'] ?? 'Buyruq qabul qilindi.',
        rawResponse: rawJson,
        latencyMs: latency,
      );
    } catch (e) {
      return AiCommandResult(
        action: 'CHAT',
        params: {},
        speechText: rawJson,
        rawResponse: rawJson,
        latencyMs: latency,
      );
    }
  }

  static AiCommandResult _localHeuristicFallback(String input, int latency) {
    final lower = input.toLowerCase();

    if (lower.contains('youtube') || lower.contains('yutub') || lower.contains('video') || lower.contains('qo\'y')) {
      int seconds = 0;
      final minMatch = RegExp(r'(\d+)\s*(?:minut|daqiqa|min)').firstMatch(lower);
      if (minMatch != null) {
        seconds = (int.tryParse(minMatch.group(1) ?? '0') ?? 0) * 60;
      }

      String query = input
          .replaceAll('youtube', '')
          .replaceAll('yutub', '')
          .replaceAll('videoni', '')
          .replaceAll('qo\'y', '')
          .replaceAll('och', '')
          .trim();
      if (query.isEmpty) query = 'trending music';

      return AiCommandResult(
        action: 'YOUTUBE_OPEN',
        params: {'query': query, 'timeSeconds': seconds},
        speechText: 'YouTube da "$query" ochilmoqda.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    if (lower.contains('answer') || lower.contains('javob') || lower.contains('ko\'tar')) {
      return AiCommandResult(
        action: 'ANSWER_CALL',
        params: {},
        speechText: 'Qo\'ng\'iroqqa javob berilmoqda.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    if (lower.contains('telegram')) {
      return AiCommandResult(
        action: 'LAUNCH_APP',
        params: {'appName': 'telegram'},
        speechText: 'Telegram ilovasi ochilmoqda.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    return AiCommandResult(
      action: 'CHAT',
      params: {},
      speechText: 'Sizni eshitdim: "$input".',
      rawResponse: 'Fallback parser',
      latencyMs: latency,
    );
  }
}
