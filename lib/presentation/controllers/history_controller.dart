import 'package:flutter/foundation.dart';
import '../../data/models/scan_record.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/datasources/history_local_datasource.dart';

class HistoryController extends ChangeNotifier {
  final HistoryRepository _repository;

  HistoryController({HistoryRepository? repository})
      : _repository = repository ??
            HistoryRepositoryImpl(HistoryLocalDataSourceImpl());

  List<ScanRecord> _records = [];
  List<ScanRecord> get records => List.unmodifiable(_records);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _records = await _repository.getHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repository.deleteRecord(id);
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearHistory();
    _records = [];
    notifyListeners();
  }
}
