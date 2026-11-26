class Ingredient {
  final String name;
  final String normalizedName;
  final String? category;
  final List<String> potentialRisks;
  final List<String> skinTypes;
  final String? compatibility;
  final String? whyItMatters;
  final String? source;

  const Ingredient({
    required this.name,
    required this.normalizedName,
    this.category,
    this.potentialRisks = const [],
    this.skinTypes = const [],
    this.compatibility,
    this.whyItMatters,
    this.source,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      normalizedName: json['normalizedName'] as String? ?? '',
      category: json['category'] as String?,
      potentialRisks: (json['potentialRisks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skinTypes: (json['skinTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      compatibility: json['compatibility'] as String?,
      whyItMatters: json['whyItMatters'] as String?,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'normalizedName': normalizedName,
      'category': category,
      'potentialRisks': potentialRisks,
      'skinTypes': skinTypes,
      'compatibility': compatibility,
      'whyItMatters': whyItMatters,
      'source': source,
    };
  }

  Ingredient copyWith({
    String? name,
    String? normalizedName,
    String? category,
    List<String>? potentialRisks,
    List<String>? skinTypes,
    String? compatibility,
    String? whyItMatters,
    String? source,
  }) {
    return Ingredient(
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      category: category ?? this.category,
      potentialRisks: potentialRisks ?? this.potentialRisks,
      skinTypes: skinTypes ?? this.skinTypes,
      compatibility: compatibility ?? this.compatibility,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      source: source ?? this.source,
    );
  }
}
