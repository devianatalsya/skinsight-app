import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/ingredient.dart';

/// Abstraction for ingredient knowledge sources.
///
/// Future implementations can retrieve from:
/// - Local SQLite / Isar database
/// - Vector database (for RAG)
/// - Remote validated cosmetic API (e.g., BPOM / CosIng)
abstract class IngredientKnowledgeDataSource {
  Future<List<Ingredient>> loadAll();
  Future<Ingredient?> findByName(String normalizedName);
}

class LocalJsonIngredientKnowledgeDataSource
    implements IngredientKnowledgeDataSource {
  static const String _assetPath = 'assets/data/ingredients_knowledge.json';
  List<Ingredient>? _cache;

  @override
  Future<List<Ingredient>> loadAll() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final list = jsonDecode(raw) as List<dynamic>;
      _cache = list
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cache!;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Ingredient?> findByName(String normalizedName) async {
    final all = await loadAll();
    final target = normalizedName.toLowerCase().trim();
    for (final item in all) {
      if (item.normalizedName.toLowerCase() == target ||
          item.name.toLowerCase() == target) {
        return item;
      }
    }
    return null;
  }
}
