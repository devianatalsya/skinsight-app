import 'package:flutter_test/flutter_test.dart';
import 'package:softly/core/constants/app_strings.dart';
import 'package:softly/data/repositories/history_repository.dart';
import 'package:softly/data/models/scan_record.dart';
import 'package:softly/domain/entities/analysis_result.dart';
import 'package:softly/domain/entities/skin_type.dart';
import 'package:softly/main.dart';
import 'package:softly/presentation/controllers/scan_controller.dart';
import 'package:softly/services/ai/ai_service.dart';
import 'package:softly/services/ai/gemini_ai_service.dart';
import 'package:softly/services/ai/mock_ai_service.dart';
import 'package:softly/services/ocr/ocr_service.dart';

class _FailingOcrService implements OcrService {
  @override
  bool get isAvailable => true;

  @override
  String get providerName => 'Failing OCR';

  @override
  Future<String> extractText(String imagePath) async {
    throw const AiServiceException(AppStrings.errorCantRead);
  }
}

class _MissingKeyAiService implements AIService {
  @override
  bool get isAvailable => false;

  @override
  String get providerName => 'Missing Key AI';

  @override
  Future<AnalysisResult> analyzeIngredients({
    required List<String> ingredients,
    required SkinType skinType,
  }) async {
    throw const ApiKeyMissingException(AppStrings.errorApiKey);
  }
}

class _InMemoryHistoryRepo implements HistoryRepository {
  final List<ScanRecord> _items = [];

  @override
  Future<void> clearHistory() async => _items.clear();

  @override
  Future<void> deleteRecord(String id) async =>
      _items.removeWhere((e) => e.id == id);

  @override
  Future<List<ScanRecord>> getHistory() async => _items;

  @override
  Future<void> saveRecord({
    required String productLabel,
    required SkinType skinType,
    required AnalysisResult result,
    String? imagePath,
  }) async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoftlyApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('softly'), findsOneWidget);
  });

  test('IngredientNormalizer splits and cleans Indonesian/English OCR text', () {
    const raw = 'Komposisi: Water, niacinamide; Alcohol Denat.\nFragrance';
    final result = IngredientNormalizer.normalize(raw);
    expect(result, ['Water', 'Niacinamide', 'Alcohol Denat.', 'Fragrance']);
  });

  test('MockAIService flags sensitive skin irritants in Indonesian', () async {
    final service = MockAIService();
    final result = await service.analyzeIngredients(
      ingredients: ['Water', 'Niacinamide', 'Alcohol Denat.', 'Fragrance'],
      skinType: SkinType.sensitive,
    );
    expect(result.overallStatus, OverallStatus.warning);
    expect(result.flaggedIngredients.length, 2);
    expect(result.overallStatus.label, 'Waspada');
  });

  test('ScanController surfaces error state when OCR fails without fake result',
      () async {
    final controller = ScanController(
      aiService: MockAIService(),
      ocrService: _FailingOcrService(),
      historyRepository: _InMemoryHistoryRepo(),
    );
    controller.setImagePath('dummy.jpg');
    await controller.analyze();

    expect(controller.state, ScanState.error);
    expect(controller.result, isNull);
    expect(controller.errorMessage, AppStrings.errorCantRead);
  });

  test('ScanController flags API key error when key is missing', () async {
    final controller = ScanController(
      aiService: _MissingKeyAiService(),
      ocrService: MockOcrService(),
      historyRepository: _InMemoryHistoryRepo(),
    );
    controller.setImagePath('dummy.jpg');
    await controller.analyze();

    expect(controller.state, ScanState.error);
    expect(controller.isApiKeyError, isTrue);
    expect(controller.result, isNull);
  });

  test('AnalysisResult.fromJson parses structured response safely', () {
    final json = {
      'overall_status': 'warning',
      'summary': 'Perlu diperhatikan untuk kulit sensitif.',
      'flagged_ingredients': [
        {
          'name': 'Alcohol Denat.',
          'risk': 'Berpotensi mengiritasi',
          'reason': 'Dapat terasa mengiritasi pada kulit sensitif.',
        }
      ],
      'warnings': ['Bukan diagnosis medis.'],
      'confidence': 0.9,
    };

    final parsed = AnalysisResult.fromJson(json);
    expect(parsed.overallStatus, OverallStatus.warning);
    expect(parsed.flaggedIngredients.first.name, 'Alcohol Denat.');
    expect(parsed.confidence, 0.9);
  });
}
