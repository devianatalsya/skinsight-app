import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Manages the Gemini API key without hardcoding any secret in source code.
///
/// Priority:
/// 1. Locally saved key by the user on-device (`api_config.json`)
/// 2. Compile-time key injected via `--dart-define=GEMINI_API_KEY=...`
class ApiKeyStore {
  static const String _envKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String _fileName = 'api_config.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Returns the active API key, or empty string if none is configured.
  Future<String> getApiKey() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        final localKey = (data['gemini_api_key'] as String? ?? '').trim();
        if (localKey.isNotEmpty) return localKey;
      }
    } catch (_) {
      // Ignore file read errors and fall back to compile-time key
    }
    return _envKey.trim();
  }

  /// Returns true if a compile-time key was bundled via `--dart-define`.
  bool get hasCompileTimeKey => _envKey.trim().isNotEmpty;

  /// Saves a user-provided API key locally on-device.
  Future<void> saveApiKey(String key) async {
    final file = await _getFile();
    await file.writeAsString(
      jsonEncode({'gemini_api_key': key.trim()}),
    );
  }

  /// Clears any locally saved API key.
  Future<void> clearLocalKey() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
