import '../../data/datasources/ingredient_knowledge_datasource.dart';
import '../../data/repositories/ingredient_repository.dart';
import 'ai/ai_service.dart';
import 'ai/mock_ai_service.dart';
import 'ai/gemini_ai_service.dart';
import 'ai/proxy_ai_service.dart';
import 'config/api_key_store.dart';
import 'ocr/ocr_service.dart';
import 'ocr/proxy_ocr_service.dart';

/// Service locator / factory for injectable services.
///
/// Priority:
/// 1. `USE_MOCK_AI=true` -> [MockAIService] + [MockOcrService] (dev/test only)
/// 2. `API_BASE_URL` set -> [ProxyAIService] + [ProxyOcrService] (recommended for public APK)
/// 3. Direct Gemini -> [GeminiAIService] + [GeminiOcrService] (uses `--dart-define=GEMINI_API_KEY` or local key)
class ServiceLocator {
  ServiceLocator._();

  static const bool useMockAi = bool.fromEnvironment(
    'USE_MOCK_AI',
    defaultValue: false,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://softly-skincare.vercel.app',
  );

  static bool get isUsingProxy => apiBaseUrl.trim().isNotEmpty && !useMockAi;

  static final ApiKeyStore apiKeyStore = ApiKeyStore();

  static AIService get aiService {
    if (useMockAi) return MockAIService();
    if (isUsingProxy) return ProxyAIService(baseUrl: apiBaseUrl);
    return GeminiAIService(keyStore: apiKeyStore);
  }

  static OcrService get ocrService {
    if (useMockAi) return MockOcrService();
    if (isUsingProxy) return ProxyOcrService(baseUrl: apiBaseUrl);
    return GeminiOcrService(keyStore: apiKeyStore);
  }

  static IngredientRepository get ingredientRepository {
    return IngredientRepositoryImpl(LocalJsonIngredientKnowledgeDataSource());
  }
}
