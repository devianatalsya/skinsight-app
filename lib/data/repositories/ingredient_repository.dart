import '../../domain/entities/ingredient.dart';
import '../datasources/ingredient_knowledge_datasource.dart';

/// Repository layer for ingredient knowledge.
///
/// Decouples domain/AI/UI from where ingredient data originates
/// (local JSON today, vector DB / RAG retrieval in the future).
abstract class IngredientRepository {
  Future<List<Ingredient>> getAllIngredients();
  Future<Ingredient?> getIngredientInfo(String name);
  Future<List<Ingredient>> enrichIngredients(List<String> names);
}

class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientKnowledgeDataSource _dataSource;

  IngredientRepositoryImpl(this._dataSource);

  @override
  Future<List<Ingredient>> getAllIngredients() => _dataSource.loadAll();

  @override
  Future<Ingredient?> getIngredientInfo(String name) =>
      _dataSource.findByName(name);

  @override
  Future<List<Ingredient>> enrichIngredients(List<String> names) async {
    final results = <Ingredient>[];
    for (final name in names) {
      final found = await _dataSource.findByName(name);
      if (found != null) {
        results.add(found);
      } else {
        results.add(
          Ingredient(
            name: name,
            normalizedName: name.toLowerCase().trim(),
          ),
        );
      }
    }
    return results;
  }
}
