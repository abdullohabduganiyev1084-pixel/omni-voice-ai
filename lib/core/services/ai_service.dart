import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

enum AiProvider { groq, gemini }

class AiCommandResult {
  final String action; // 'YOUTUBE_OPEN', 'ANSWER_CALL', 'END_CALL', 'LAUNCH_APP', 'GLOBAL_NAV', 'VOLUME', 'CLICK_TEXT', 'CHAT'
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
   Misol: "YouTube ga kirib lofi musiqani 5-minutidan qo'y" -> action: "YOUTUBE_OPEN", params: {"query": "lofi hip hop chill beats", "timeSeconds": 300}, speech: "YouTube da Lofi musiqani 5-daqiqasidan qo'ymoqdaman."

2. "ANSWER_CALL":
   - Foydalanuvchi "answer the call", "qo'ng'iroqqa javob ber", "ol", "ko'tar" desa.
   - params: {}
   - speech: "Qo'ng'iroqqa javob berildi."

3. "END_CALL":
   - Foydalanuvchi "rad et", "go'shakni qo'y", "decline" desa.
   - params: {}
   - speech: "Qo'ng'iroq tugatildi."

4. "LAUNCH_APP":
   - "appName": "youtube", "telegram", "camera", "settings", "chrome", "phone", yoki boshqa ilova nomi.
   - speech: "Telegram ilovasi ochilmoqda."

5. "GLOBAL_NAV":
   - "type": "home" | "back" | "recents" | "notifications" | "scroll_down" | "scroll_up"
   - speech: "Bajarildi."

6. "VOLUME":
   - "level": 0 dan 100 gacha raqam
   - speech: "Ovoz balandligi 80 foizga o'rnatildi."

7. "CLICK_TEXT":
   - "text": "ekranda bosilishi kerak bo'lgan tugma matni"
   - speech: "Tugma bosildi."

8. "CHAT":
   - Foydalanuvchi savol so'rasa yoki shunchaki suhbatlashsa.
   - params: {}
   - speech: "To'g'ridan-to'g'ri foydalanuvchiga qisqa va aniq javob."

Qat'iy qoida: FAQAT va FAQAT toza JSON formatida javob bering, hech qanday markdown ```json yoki ortiqcha so'z qo'shmang!
''';

  /// Buyruqni tahlil qilish va bajarish
  static Future<AiCommandResult> processCommand(String userVoiceInput) async {
    final stopwatch = Stopwatch()..start();

    try {
      if (activeProvider == AiProvider.groq) {
        return await _callGroq(userVoiceInput, stopwatch);
      } else {
        return await _callGemini(userVoiceInput, stopwatch);
      }
    } catch (e) {
      debugPrint('AI Processing error: $e. Falling back...');
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

  /// Groq API orqali chaqirish (Ultra-tez Llama 3.3 70B)
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

  /// Google Gemini API orqali chaqirish
  static Future<AiCommandResult> _callGemini(String prompt, Stopwatch sw) async {
    // Agar API kalit boshida AQ. bo'lsa yoki standart kalit bo'lsa
    final cleanKey = customGeminiKey.trim();
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$cleanKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [{'text': systemInstruction}]
        },
        'contents': [
          {
            'parts': [{'text': prompt}]
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
      // Clean JSON if code fences exist
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

  /// Offline / Fallback qoidalar (Tarmoq yoki API sekin bo'lsa darhol ishlash uchun)
  static AiCommandResult _localHeuristicFallback(String input, int latency) {
    final lower = input.toLowerCase();

    // YouTube buyrug'i
    if (lower.contains('youtube') || lower.contains('yutub') || lower.contains('video') || lower.contains('qo\'y')) {
      int seconds = 0;
      final minMatch = RegExp(r'(\d+)\s*(?:minut|daqiqa|min)').firstMatch(lower);
      if (minMatch != null) {
        seconds = (int.tryParse(minMatch.group(1) ?? '0') ?? 0) * 60;
      }

      String query = input
          .replaceAll(RegExp(r'youtube(?:ga)?|yutub(?:ga)?|videoni|qo\'y|och|kirib|minutiga|daqiqa', caseSensitive: false), '')
          .trim();
      if (query.isEmpty) query = 'trending music';

      return AiCommandResult(
        action: 'YOUTUBE_OPEN',
        params: {'query': query, 'timeSeconds': seconds},
        speechText: 'YouTube da "$query" qidirilmoqda ${seconds > 0 ? "$seconds soniyadan" : ""}.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    // Qo'ng'iroqqa javob berish
    if (lower.contains('answer') || lower.contains('javob ber') || lower.contains('ko\'tar') || lower.contains('ol')) {
      return AiCommandResult(
        action: 'ANSWER_CALL',
        params: {},
        speechText: 'Qo\'ng\'iroqqa javob berilmoqda.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    // Telegram
    if (lower.contains('telegram') || lower.contains('telefram')) {
      return AiCommandResult(
        action: 'LAUNCH_APP',
        params: {'appName': 'telegram'},
        speechText: 'Telegram ilovasi ochilmoqda.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    // Home / Back
    if (lower.contains('orqaga') || lower.contains('back')) {
      return AiCommandResult(
        action: 'GLOBAL_NAV',
        params: {'type': 'back'},
        speechText: 'Orqaga qaytildi.',
        rawResponse: 'Fallback parser',
        latencyMs: latency,
      );
    }

    return AiCommandResult(
      action: 'CHAT',
      params: {},
      speechText: 'Sizni eshitdim: "$input". Sizga qanday yordam bera olaman?',
      rawResponse: 'Fallback parser',
      latencyMs: latency,
    );
  }
}
