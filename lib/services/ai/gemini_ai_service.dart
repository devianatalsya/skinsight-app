import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_strings.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';
import '../config/api_key_store.dart';
import 'ai_service.dart';

class ApiKeyMissingException implements Exception {
  final String message;
  const ApiKeyMissingException([this.message = AppStrings.errorApiKey]);
  @override
  String toString() => message;
}

class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);
  @override
  String toString() => message;
}

/// Google Gemini AI provider implementation.
///
/// Uses Gemini 2.5 Flash (free tier) via REST API.
/// API key is loaded from [ApiKeyStore] (saved local key or `--dart-define=GEMINI_API_KEY=...`).
class GeminiAIService implements AIService {
  static const String _model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );

  static String get _baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const Duration _timeout = Duration(seconds: 30);

  final ApiKeyStore _keyStore;

  GeminiAIService({ApiKeyStore? keyStore})
      : _keyStore = keyStore ?? ApiKeyStore();

  @override
  bool get isAvailable => _keyStore.hasCompileTimeKey;

  @override
  String get providerName => 'Gemini ($_model)';

  @override
  Future<AnalysisResult> analyzeIngredients({
    required List<String> ingredients,
    required SkinType skinType,
  }) async {
    final apiKey = await _keyStore.getApiKey();
    if (apiKey.isEmpty) {
      throw const ApiKeyMissingException(AppStrings.errorApiKey);
    }

    final prompt = _buildPrompt(ingredients: ingredients, skinType: skinType);
    final requestBody = _buildRequestBody(prompt);

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiKeyMissingException(AppStrings.errorInvalidApiKey);
      }
      if (response.statusCode == 429) {
        throw const AiServiceException(AppStrings.errorQuotaExceeded);
      }
      if (response.statusCode != 200) {
        throw const AiServiceException(AppStrings.errorUnavailable);
      }

      return _parseResponse(response.body);
    } on TimeoutException {
      throw const AiServiceException(AppStrings.errorTimeout);
    } on SocketException {
      throw const AiServiceException(AppStrings.errorNoInternet);
    } on ApiKeyMissingException {
      rethrow;
    } on AiServiceException {
      rethrow;
    } catch (_) {
      throw const AiServiceException(AppStrings.errorUnavailable);
    }
  }

  String _buildPrompt({
    required List<String> ingredients,
    required SkinType skinType,
  }) {
    final ingredientList = ingredients.map((i) => '"$i"').join(', ');
    return '''
Kamu adalah asisten informasi keamanan bahan skincare dan kosmetik. Analisis daftar bahan berikut untuk pengguna dengan jenis kulit ${skinType.label}.

ATURAN PENTING:
- JANGAN memberikan diagnosis medis.
- Gunakan bahasa Indonesia yang informatif, tenang, dan singkat seperti "Berpotensi mengiritasi", "Perlu diperhatikan", "Kurang ideal untuk kulit sensitif", atau "Tidak ditemukan indikator risiko utama berdasarkan data yang tersedia".
- Jangan mengklaim produk pasti aman 100% atau pasti menyebabkan penyakit.
- Hanya tandai bahan yang memang relevan untuk jenis kulit ${skinType.label}.
- Kembalikan HANYA JSON valid sesuai skema di bawah.

Jenis kulit: ${skinType.value} (${skinType.label})
Daftar bahan: [$ingredientList]

Kembalikan JSON persis sesuai skema ini:
{
  "overall_status": "safe|warning|caution",
  "summary": "Satu kalimat ringkasan singkat dalam bahasa Indonesia.",
  "flagged_ingredients": [
    {
      "name": "Nama Bahan",
      "risk": "Label risiko singkat (mis. Berpotensi mengiritasi)",
      "reason": "Penjelasan satu kalimat dalam bahasa Indonesia."
    }
  ],
  "warnings": ["Catatan singkat opsional dalam bahasa Indonesia"],
  "confidence": 0.85
}

Kembalikan hanya objek JSON. Tanpa markdown, tanpa blok kode, tanpa teks tambahan.
''';
  }

  Map<String, dynamic> _buildRequestBody(String prompt) {
    return {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 1024,
        'responseMimeType': 'application/json',
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE',
        }
      ],
    };
  }

  AnalysisResult _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const AiServiceException(AppStrings.errorInvalidResponse);
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw const AiServiceException(AppStrings.errorInvalidResponse);
      }

      final text = parts[0]['text'] as String? ?? '';
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final result = jsonDecode(cleaned) as Map<String, dynamic>;
      if (!result.containsKey('overall_status') ||
          !result.containsKey('summary')) {
        throw const AiServiceException(AppStrings.errorInvalidResponse);
      }
      return AnalysisResult.fromJson(result);
    } on AiServiceException {
      rethrow;
    } catch (_) {
      throw const AiServiceException(AppStrings.errorInvalidResponse);
    }
  }
}
