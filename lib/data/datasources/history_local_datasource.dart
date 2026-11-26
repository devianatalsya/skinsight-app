import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/scan_record.dart';

abstract class HistoryLocalDataSource {
  Future<List<ScanRecord>> getHistory();
  Future<void> saveRecord(ScanRecord record);
  Future<void> deleteRecord(String id);
  Future<void> clearHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  static const String _fileName = 'scan_history.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<List<ScanRecord>> getHistory() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
      return jsonList
          .map((e) => ScanRecord.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveRecord(ScanRecord record) async {
    final records = await getHistory();
    records.insert(0, record);
    final file = await _getFile();
    await file.writeAsString(
        jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  @override
  Future<void> deleteRecord(String id) async {
    final records = await getHistory();
    records.removeWhere((r) => r.id == id);
    final file = await _getFile();
    await file.writeAsString(
        jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  @override
  Future<void> clearHistory() async {
    final file = await _getFile();
    if (await file.exists()) await file.delete();
  }
}
