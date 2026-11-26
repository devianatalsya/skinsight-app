import 'dart:async';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';
import 'ai_service.dart';

/// Mock AI provider for development, testing, and demo mode (`--dart-define=USE_MOCK_AI=true`).
class MockAIService implements AIService {
  @override
  bool get isAvailable => true;

  @override
  String get providerName => 'Mock (Pengembangan)';

  static const _knownConcerns = {
    'alcohol denat.': FlaggedIngredient(
      name: 'Alcohol Denat.',
      risk: 'Berpotensi mengiritasi',
      reason: 'Dapat terasa mengiritasi pada sebagian kulit sensitif atau kering.',
    ),
    'alcohol': FlaggedIngredient(
      name: 'Alcohol',
      risk: 'Berpotensi mengiritasi',
      reason: 'Kadar tinggi dapat membuat kulit terasa lebih kering.',
    ),
    'fragrance': FlaggedIngredient(
      name: 'Fragrance',
      risk: 'Potensi alergen',
      reason: 'Sering memicu reaksi pada kulit yang sensitif.',
    ),
    'parfum': FlaggedIngredient(
      name: 'Parfum',
      risk: 'Potensi alergen',
      reason: 'Campuran pewangi yang kurang ideal untuk kulit sensitif.',
    ),
    'sodium lauryl sulfate': FlaggedIngredient(
      name: 'Sodium Lauryl Sulfate',
      risk: 'Berpotensi mengiritasi',
      reason: 'Surfaktan kuat yang dapat mengikis kelembapan alami kulit.',
    ),
    'mineral oil': FlaggedIngredient(
      name: 'Mineral Oil',
      risk: 'Potensi komedogenik',
      reason: 'Dapat terasa berat atau menyumbat pori pada sebagian kulit berminyak.',
    ),
    'isopropyl myristate': FlaggedIngredient(
      name: 'Isopropyl Myristate',
      risk: 'Potensi komedogenik',
      reason: 'Berpotensi menyumbat pori pada kulit berminyak atau rentan berjerawat.',
    ),
    'methylparaben': FlaggedIngredient(
      name: 'Methylparaben',
      risk: 'Perlu diperhatikan',
      reason: 'Sebagian orang memilih menghindari paraben pada kulit sensitif.',
    ),
    'propylparaben': FlaggedIngredient(
      name: 'Propylparaben',
      risk: 'Perlu diperhatikan',
      reason: 'Sebagian orang memilih menghindari paraben pada kulit sensitif.',
    ),
    'formaldehyde': FlaggedIngredient(
      name: 'Formaldehyde',
      risk: 'Berpotensi mengiritasi',
      reason: 'Dikenal dapat memicu sensitisasi pada kulit.',
    ),
  };

  static const _oilyProblematic = {'mineral oil', 'isopropyl myristate'};
  static const _dryProblematic = {
    'alcohol denat.',
    'alcohol',
    'sodium lauryl sulfate',
  };
  static const _sensitiveProblematic = {
    'fragrance',
    'parfum',
    'alcohol denat.',
    'formaldehyde',
  };

  @override
  Future<AnalysisResult> analyzeIngredients({
    required List<String> ingredients,
    required SkinType skinType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final lowered = ingredients.map((e) => e.toLowerCase().trim()).toList();
    final flagged = <FlaggedIngredient>[];

    for (final ingredient in lowered) {
      if (_knownConcerns.containsKey(ingredient)) {
        final concern = _knownConcerns[ingredient]!;
        bool relevant = true;
        switch (skinType) {
          case SkinType.oily:
            relevant = _oilyProblematic.contains(ingredient);
          case SkinType.dry:
            relevant = _dryProblematic.contains(ingredient);
          case SkinType.sensitive:
            relevant = _sensitiveProblematic.contains(ingredient) ||
                _knownConcerns.containsKey(ingredient);
          case SkinType.combination:
          case SkinType.normal:
            relevant = _knownConcerns.containsKey(ingredient);
        }
        if (relevant) flagged.add(concern);
      }
    }

    final status =
        flagged.isEmpty ? OverallStatus.safe : OverallStatus.warning;

    final summary = flagged.isEmpty
        ? 'Tidak ditemukan indikator risiko utama untuk kulit ${skinType.label.toLowerCase()} berdasarkan data yang tersedia.'
        : 'Beberapa bahan perlu diperhatikan untuk kulit ${skinType.label.toLowerCase()}.';

    return AnalysisResult(
      overallStatus: status,
      summary: summary,
      flaggedIngredients: flagged,
      detectedIngredients: const [],
      warnings: flagged.isEmpty
          ? const []
          : const ['Bukan diagnosis medis. Disarankan melakukan patch test.'],
      confidence: 0.75,
      analyzedAt: DateTime.now(),
    );
  }
}
