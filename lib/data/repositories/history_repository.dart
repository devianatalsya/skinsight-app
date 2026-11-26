import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';
import '../models/scan_record.dart';
import '../datasources/history_local_datasource.dart';

abstract class HistoryRepository {
  Future<List<ScanRecord>> getHistory();
  Future<void> saveRecord({
    required String productLabel,
    required SkinType skinType,
    required AnalysisResult result,
    String? imagePath,
  });
  Future<void> deleteRecord(String id);
  Future<void> clearHistory();
}

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<ScanRecord>> getHistory() => _dataSource.getHistory();

  @override
  Future<void> saveRecord({
    required String productLabel,
    required SkinType skinType,
    required AnalysisResult result,
    String? imagePath,
  }) {
    final record = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productLabel: productLabel,
      skinType: skinType,
      result: result,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
    );
    return _dataSource.saveRecord(record);
  }

  @override
  Future<void> deleteRecord(String id) => _dataSource.deleteRecord(id);

  @override
  Future<void> clearHistory() => _dataSource.clearHistory();
}
