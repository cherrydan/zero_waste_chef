
class Ingredient {
  final String name;
  final String? id;
  bool isUrgent;
  final DateTime? expiryDate;

  Ingredient({
    required this.name,
    this.id,
    this.isUrgent = false,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'isUrgent': isUrgent,
    'expiryDate': expiryDate?.toIso8601String(),
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json['name'] as String,
    id: json['id'] as String?,
    isUrgent: json['isUrgent'] as bool,
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
  );
}

class Recipe {
  final String title;
  final List<String> shoppingList;
  final List<String> steps;

  Recipe({required this.title, required this.shoppingList, required this.steps});

  Map<String, dynamic> toJson() => {
    'recipe_name': title,
    'shopping_list': shoppingList,
    'steps': steps,
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    title: json['recipe_name'] as String,
    shoppingList: List<String>.from(json['shopping_list']),
    steps: List<String>.from(json['steps']),
  );
}
