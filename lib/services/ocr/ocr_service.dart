import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_strings.dart';
import '../ai/gemini_ai_service.dart';
import '../config/api_key_store.dart';

/// Abstract contract for OCR providers.
abstract class OcrService {
  Future<String> extractText(String imagePath);

  bool get isAvailable;
  String get providerName;
}

/// Normalizes raw OCR text into a list of ingredient names.
class IngredientNormalizer {
  IngredientNormalizer._();

  static List<String> normalize(String rawText) {
    if (rawText.trim().isEmpty) return [];

    String cleaned = rawText
        .replaceAll(RegExp(r'ingredients?:?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'komposisi:?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'inci\s*name:?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'[\*\u2022\u00b7]'), ',')
        .replaceAll(RegExp(r'\n+'), ',')
        .replaceAll(RegExp(r'\s{2,}'), ' ');

    final tokens = cleaned
        .split(RegExp(r'[,;/]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 1)
        .map(_capitalizeFirst)
        .toList();

    return tokens;
  }

  static String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Gemini Vision-based OCR implementation.
class GeminiOcrService implements OcrService {
  static const String _model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.8-flash',
  );

  static String get _baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const Duration _timeout = Duration(seconds: 30);

  final ApiKeyStore _keyStore;

  GeminiOcrService({ApiKeyStore? keyStore})
      : _keyStore = keyStore ?? ApiKeyStore();

  @override
  bool get isAvailable => _keyStore.hasCompileTimeKey;

  @override
  String get providerName => 'Gemini Vision OCR ($_model)';

  @override
  Future<String> extractText(String imagePath) async {
    final apiKey = await _keyStore.getApiKey();
    if (apiKey.isEmpty) {
      throw const ApiKeyMissingException(AppStrings.errorApiKey);
    }

    final imageBytes = await _readImageBytes(imagePath);
    final base64Image = base64Encode(imageBytes);
    final mimeType = _getMimeType(imagePath);

    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Extract ONLY the cosmetic/skincare ingredients list text from this image. '
                      'Return only the raw ingredient text separated by commas, with no commentary. '
                      'If there is NO readable skincare/cosmetic ingredients list in the image, '
                      'return exactly: NO_INGREDIENTS_FOUND',
            },
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.0,
        'maxOutputTokens': 512,
      },
    };

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

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const AiServiceException(AppStrings.errorCantRead);
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw const AiServiceException(AppStrings.errorCantRead);
      }

      final text = (parts[0]['text'] as String? ?? '').trim();
      if (text.isEmpty || text.toUpperCase().contains('NO_INGREDIENTS_FOUND')) {
        throw const AiServiceException(AppStrings.errorCantRead);
      }

      return text;
    } on TimeoutException {
      throw const AiServiceException(AppStrings.errorTimeout);
    } on SocketException {
      throw const AiServiceException(AppStrings.errorNoInternet);
    } on ApiKeyMissingException {
      rethrow;
    } on AiServiceException {
      rethrow;
    } catch (_) {
      throw const AiServiceException(AppStrings.errorCantRead);
    }
  }

  Future<List<int>> _readImageBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const AiServiceException(AppStrings.errorCantRead);
    }
    return file.readAsBytes();
  }

  String _getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

/// Mock OCR service for explicit development/test mode.
class MockOcrService implements OcrService {
  @override
  bool get isAvailable => true;

  @override
  String get providerName => 'Mock OCR (Pengembangan)';

  @override
  Future<String> extractText(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'Water, Niacinamide, Glycerin, Dimethicone, Alcohol Denat., '
        'Fragrance, Sodium Hyaluronate, Panthenol, Tocopheryl Acetate, '
        'Methylparaben, Disodium EDTA, Allantoin';
  }
}
