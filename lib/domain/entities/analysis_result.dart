import 'ingredient.dart';

enum OverallStatus {
  safe,
  warning,
  caution;

  String get label {
    switch (this) {
      case OverallStatus.safe:
        return 'Aman dicoba';
      case OverallStatus.warning:
        return 'Waspada';
      case OverallStatus.caution:
        return 'Perlu diperhatikan';
    }
  }
}

class FlaggedIngredient {
  final String name;
  final String risk;
  final String reason;

  const FlaggedIngredient({
    required this.name,
    required this.risk,
    required this.reason,
  });

  factory FlaggedIngredient.fromJson(Map<String, dynamic> json) {
    return FlaggedIngredient(
      name: json['name'] as String? ?? '',
      risk: json['risk'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'risk': risk,
        'reason': reason,
      };
}

class AnalysisResult {
  final OverallStatus overallStatus;
  final String summary;
  final List<FlaggedIngredient> flaggedIngredients;
  final List<Ingredient> detectedIngredients;
  final List<String> warnings;
  final double? confidence;
  final String? rawOcrText;
  final DateTime analyzedAt;

  const AnalysisResult({
    required this.overallStatus,
    required this.summary,
    this.flaggedIngredients = const [],
    this.detectedIngredients = const [],
    this.warnings = const [],
    this.confidence,
    this.rawOcrText,
    required this.analyzedAt,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final statusStr = json['overall_status'] as String? ?? 'safe';
    final status = switch (statusStr) {
      'warning' => OverallStatus.warning,
      'caution' => OverallStatus.caution,
      _ => OverallStatus.safe,
    };

    return AnalysisResult(
      overallStatus: status,
      summary: json['summary'] as String? ?? '',
      flaggedIngredients: (json['flagged_ingredients'] as List<dynamic>?)
              ?.map((e) => FlaggedIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      detectedIngredients: [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble(),
      rawOcrText: json['raw_ocr_text'] as String?,
      analyzedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_status': overallStatus.name,
        'summary': summary,
        'flagged_ingredients':
            flaggedIngredients.map((e) => e.toJson()).toList(),
        'detected_ingredients':
            detectedIngredients.map((e) => e.toJson()).toList(),
        'warnings': warnings,
        'confidence': confidence,
        'raw_ocr_text': rawOcrText,
        'analyzed_at': analyzedAt.toIso8601String(),
      };
}
