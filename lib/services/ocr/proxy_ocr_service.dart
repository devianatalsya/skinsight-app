import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_strings.dart';
import '../ai/gemini_ai_service.dart';
import 'ocr_service.dart';

/// OCR provider that sends images to a Vercel Serverless Function proxy.
class ProxyOcrService implements OcrService {
  final String baseUrl;
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 30);

  ProxyOcrService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  String get _endpoint {
    final trimmed = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$trimmed/api/ocr';
  }

  @override
  bool get isAvailable => baseUrl.trim().isNotEmpty;

  @override
  String get providerName => 'Vercel Vision OCR Proxy';

  @override
  Future<String> extractText(String imagePath) async {
    if (!isAvailable) {
      throw const AiServiceException(AppStrings.errorUnavailable);
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw const AiServiceException(AppStrings.errorCantRead);
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = _getMimeType(imagePath);

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'imageBase64': base64Image,
              'mimeType': mimeType,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 422) {
        throw const AiServiceException(AppStrings.errorCantRead);
      }
      if (response.statusCode == 429) {
        throw const AiServiceException(AppStrings.errorQuotaExceeded);
      }
      if (response.statusCode != 200) {
        throw const AiServiceException(AppStrings.errorUnavailable);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (decoded['text'] as String? ?? '').trim();
      if (text.isEmpty) {
        throw const AiServiceException(AppStrings.errorCantRead);
      }
      return text;
    } on TimeoutException {
      throw const AiServiceException(AppStrings.errorTimeout);
    } on SocketException {
      throw const AiServiceException(AppStrings.errorNoInternet);
    } on AiServiceException {
      rethrow;
    } catch (_) {
      throw const AiServiceException(AppStrings.errorCantRead);
    }
  }

  String _getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
