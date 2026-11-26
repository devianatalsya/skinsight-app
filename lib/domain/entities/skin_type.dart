enum SkinType {
  oily,
  dry,
  combination,
  sensitive,
  normal;

  String get label {
    switch (this) {
      case SkinType.oily:
        return 'Berminyak';
      case SkinType.dry:
        return 'Kering';
      case SkinType.combination:
        return 'Kombinasi';
      case SkinType.sensitive:
        return 'Sensitif';
      case SkinType.normal:
        return 'Normal';
    }
  }

  String get description {
    switch (this) {
      case SkinType.oily:
        return 'Cenderung mengilap dan pori tampak besar';
      case SkinType.dry:
        return 'Mudah terasa kaku atau mengelupas';
      case SkinType.combination:
        return 'T-zone berminyak, area lain cenderung kering';
      case SkinType.sensitive:
        return 'Mudah bereaksi terhadap bahan tertentu';
      case SkinType.normal:
        return 'Seimbang dan umumnya toleran';
    }
  }

  String get value => name;
}
