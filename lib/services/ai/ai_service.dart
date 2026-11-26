import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';

/// Abstract contract for AI analysis providers.
/// 
/// This abstraction allows the AI backend to be swapped without
/// touching the presentation layer. Planned implementations:
/// - [MockAIService] — offline / development mode
/// - [GeminiAIService] — Google Gemini API (free tier)
/// - Future: RAGAIService, FineTunedAIService
abstract class AIService {
  /// Analyzes a list of ingredient names for a given skin type.
  /// 
  /// [ingredients] — normalized list of ingredient name strings
  /// [skinType] — the user's selected skin type
  /// 
  /// Returns a structured [AnalysisResult] that is safe to display.
  Future<AnalysisResult> analyzeIngredients({
    required List<String> ingredients,
    required SkinType skinType,
  });

  /// Returns true if this provider is properly configured and ready.
  bool get isAvailable;

  /// Human-readable identifier for this provider.
  String get providerName;
}
