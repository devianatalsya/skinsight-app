import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_strings.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';
import 'ai_service.dart';
import 'gemini_ai_service.dart';

/// AI provider that communicates with a Vercel Serverless Function proxy.
///
/// The Gemini API key stays safely on the server (`GEMINI_API_KEY` env var),
/// so end users do not need to configure any key on their device.
class ProxyAIService implements AIService {
  final String baseUrl;
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 30);

  ProxyAIService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  String get _endpoint {
    final trimmed = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$trimmed/api/analyze';
  }

  @override
  bool get isAvailable => baseUrl.trim().isNotEmpty;

  @override
  String get providerName => 'Vercel AI Proxy';

  @override
  Future<AnalysisResult> analyzeIngredients({
    required List<String> ingredients,
    required SkinType skinType,
  }) async {
    if (!isAvailable) {
      throw const AiServiceException(AppStrings.errorUnavailable);
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'skinType': skinType.label,
              'ingredients': ingredients,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 429) {
        throw const AiServiceException(AppStrings.errorQuotaExceeded);
      }
      if (response.statusCode == 500) {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          if (decoded['error']?.toString().contains('API key') == true) {
            throw const AiServiceException('GEMINI_API_KEY belum disetting di Vercel Settings -> Environment Variables.');
          }
        } catch (e) {
          if (e is AiServiceException) rethrow;
        }
        throw const AiServiceException(AppStrings.errorUnavailable);
      }
      if (response.statusCode != 200) {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final err = decoded['error'] ?? decoded['details'];
          if (err != null) {
            throw AiServiceException('Server Vercel: $err');
          }
        } catch (e) {
          if (e is AiServiceException) rethrow;
        }
        throw const AiServiceException(AppStrings.errorUnavailable);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (!decoded.containsKey('overall_status') ||
          !decoded.containsKey('summary')) {
        throw const AiServiceException(AppStrings.errorInvalidResponse);
      }

      return AnalysisResult.fromJson(decoded);
    } on TimeoutException {
      throw const AiServiceException(AppStrings.errorTimeout);
    } on SocketException {
      throw const AiServiceException(AppStrings.errorNoInternet);
    } on AiServiceException {
      rethrow;
    } catch (_) {
      throw const AiServiceException(AppStrings.errorInvalidResponse);
    }
  }
}
