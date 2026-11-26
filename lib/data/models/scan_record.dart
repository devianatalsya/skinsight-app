import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/skin_type.dart';

class ScanRecord {
  final String id;
  final String productLabel;
  final SkinType skinType;
  final AnalysisResult result;
  final String? imagePath;
  final DateTime scannedAt;

  const ScanRecord({
    required this.id,
    required this.productLabel,
    required this.skinType,
    required this.result,
    this.imagePath,
    required this.scannedAt,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    final skinTypeStr = json['skin_type'] as String? ?? 'normal';
    final skinType = SkinType.values.firstWhere(
      (s) => s.value == skinTypeStr,
      orElse: () => SkinType.normal,
    );

    return ScanRecord(
      id: json['id'] as String? ?? '',
      productLabel: json['product_label'] as String? ?? 'Produk Skincare',
      skinType: skinType,
      result: AnalysisResult.fromJson(
          json['result'] as Map<String, dynamic>? ?? {}),
      imagePath: json['image_path'] as String?,
      scannedAt: DateTime.tryParse(json['scanned_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_label': productLabel,
        'skin_type': skinType.value,
        'result': result.toJson(),
        'image_path': imagePath,
        'scanned_at': scannedAt.toIso8601String(),
      };

  String get relativeDate {
    final now = DateTime.now();
    final diff = now.difference(scannedAt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }
}
