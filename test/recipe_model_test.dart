import 'package:flutter_test/flutter_test.dart';
import 'package:zero_waste_chef/screens/recipe_screen.dart'; // Путь к твоей модели

void main() {
  // Группируем тесты для модели Recipe
  group('Recipe Model Tests', () {
    
    test('Should correctly convert Recipe to JSON and back', () {
      // 1. Arrange (Подготовка данных)
      final originalRecipe = Recipe(
        title: 'Тестовый суп',
        shoppingList: ['Вода', 'Соль'],
        steps: ['Вскипятить', 'Посолить'],
      );

      // 2. Act (Выполнение действия)
      // Превращаем в JSON (то, что мы делаем при сохранении)
      final json = originalRecipe.toJson();
      
      // Имитируем загрузку из JSON обратно в объект
      final restoredRecipe = Recipe(
        title: json['recipe_name'],
        shoppingList: List<String>.from(json['shopping_list']),
        steps: List<String>.from(json['steps']),
      );

      // 3. Assert (Проверка результата)
      expect(restoredRecipe.title, originalRecipe.title);
      expect(restoredRecipe.shoppingList, originalRecipe.shoppingList);
      expect(restoredRecipe.steps, originalRecipe.steps);
    });
    
  });
}
