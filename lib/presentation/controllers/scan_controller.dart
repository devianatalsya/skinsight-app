import 'package:flutter/foundation.dart';
import '../../core/constants/app_strings.dart';
import '../../data/datasources/history_local_datasource.dart';
import '../../data/repositories/history_repository.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';
import '../../services/ai/ai_service.dart';
import '../../services/ai/gemini_ai_service.dart';
import '../../services/ocr/ocr_service.dart';
import '../../services/service_locator.dart';

enum ScanState { idle, ocr, analyzing, done, error }

class ScanController extends ChangeNotifier {
  final AIService _aiService;
  final OcrService _ocrService;
  final HistoryRepository _historyRepository;

  ScanController({
    AIService? aiService,
    OcrService? ocrService,
    HistoryRepository? historyRepository,
  })  : _aiService = aiService ?? ServiceLocator.aiService,
        _ocrService = ocrService ?? ServiceLocator.ocrService,
        _historyRepository = historyRepository ??
            HistoryRepositoryImpl(HistoryLocalDataSourceImpl());

  ScanState _state = ScanState.idle;
  ScanState get state => _state;

  String? _imagePath;
  String? get imagePath => _imagePath;

  SkinType _skinType = SkinType.normal;
  SkinType get skinType => _skinType;

  List<String> _rawIngredients = [];
  List<String> get rawIngredients => _rawIngredients;

  String _rawOcrText = '';
  String get rawOcrText => _rawOcrText;

  AnalysisResult? _result;
  AnalysisResult? get result => _result;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isApiKeyError = false;
  bool get isApiKeyError => _isApiKeyError;

  String _statusMessage = '';
  String get statusMessage => _statusMessage;

  String get aiProviderName => _aiService.providerName;
  bool get isAiAvailable => _aiService.isAvailable;

  void setSkinType(SkinType type) {
    _skinType = type;
    notifyListeners();
  }

  void setImagePath(String path) {
    _imagePath = path;
    _state = ScanState.idle;
    _errorMessage = null;
    _isApiKeyError = false;
    notifyListeners();
  }

  void clearImage() {
    _imagePath = null;
    _state = ScanState.idle;
    _rawIngredients = [];
    _result = null;
    _errorMessage = null;
    _isApiKeyError = false;
    notifyListeners();
  }

  Future<void> analyze() async {
    if (_imagePath == null) return;

    try {
      _isApiKeyError = false;
      _setState(ScanState.ocr, AppStrings.readingIngredients);
      final rawText = await _ocrService.extractText(_imagePath!);
      _rawOcrText = rawText;
      _rawIngredients = IngredientNormalizer.normalize(rawText);

      if (_rawIngredients.isEmpty) {
        _setError(AppStrings.errorCantRead);
        return;
      }

      _setState(ScanState.analyzing, AppStrings.checkingCompatibility);
      await Future.delayed(const Duration(milliseconds: 300));

      _setStatus(AppStrings.almostThere);
      final analysisResult = await _aiService.analyzeIngredients(
        ingredients: _rawIngredients,
        skinType: _skinType,
      );

      _result = analysisResult;
      _state = ScanState.done;
      _errorMessage = null;
      notifyListeners();

      await _historyRepository.saveRecord(
        productLabel: 'Produk Skincare',
        skinType: _skinType,
        result: analysisResult,
        imagePath: _imagePath,
      );
    } on ApiKeyMissingException catch (e) {
      _isApiKeyError = true;
      _setError(e.message);
    } on AiServiceException catch (e) {
      _setError(e.message);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      _setError(_sanitizeError(msg));
    }
  }

  void _setState(ScanState state, String message) {
    _state = state;
    _statusMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ScanState.error;
    _errorMessage = message;
    _result = null;
    notifyListeners();
  }

  String _sanitizeError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('api key')) {
      _isApiKeyError = true;
      return AppStrings.errorApiKey;
    }
    if (lower.contains('timeout') || lower.contains('timeoutexception')) {
      return AppStrings.errorTimeout;
    }
    if (lower.contains('socketexception') || lower.contains('network')) {
      return AppStrings.errorNoInternet;
    }
    if (lower.contains('invalid') || lower.contains('parse')) {
      return AppStrings.errorInvalidResponse;
    }
    if (lower.contains('komposisi') || lower.contains('ingredients')) {
      return AppStrings.errorCantRead;
    }
    return AppStrings.errorUnavailable;
  }

  void reset() {
    _state = ScanState.idle;
    _imagePath = null;
    _rawIngredients = [];
    _rawOcrText = '';
    _result = null;
    _errorMessage = null;
    _isApiKeyError = false;
    _statusMessage = '';
    notifyListeners();
  }
}
