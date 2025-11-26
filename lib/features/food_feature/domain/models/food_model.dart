class FoodModel {
  final int? id;
  final String name; // Now includes serving size (e.g., "250g Chicken Breast")
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final DateTime createdAt;

  FoodModel({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    // Handle migration from old format with servingSize and servingUnit
    String foodName = json['name'] as String;

    // If old format detected, migrate by combining serving info into name
    if (json.containsKey('servingSize') && json.containsKey('servingUnit')) {
      final servingSize = json['servingSize'];
      final servingUnit = json['servingUnit'] as String;
      // Only prepend if name doesn't already start with a number (avoid double migration)
      if (!RegExp(r'^\d').hasMatch(foodName)) {
        foodName = '$servingSize$servingUnit $foodName';
      }
    }

    return FoodModel(
      id: json['id'] as int?,
      name: foodName,
      calories: json['calories'] as int? ?? json['numOfCal'] as int? ?? 0,
      protein: json['protein'] as int? ?? json['numOfPro'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fats: json['fats'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FoodModel copyWith({
    int? id,
    String? name,
    int? calories,
    int? protein,
    int? carbs,
    int? fats,
    DateTime? createdAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
