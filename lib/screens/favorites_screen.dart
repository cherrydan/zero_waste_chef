import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe_screen.dart'; // Нам нужна модель Recipe отсюда


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> _savedRecipes = []; // Список для хранения рецептов в памяти экрана


  @override
  void initState() {
    super.initState();
    _loadSavedRecipes(); // Вот здесь вызываем загрузку!
  }

  // Функция загрузки из SharedPreferences
    Future<void> _loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedString = prefs.getString('favorite_recipes');

    if (savedString != null && savedString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(savedString);
      setState(() {
        _savedRecipes = decodedList.map((e) => Recipe(
          title: e['recipe_name'] as String,
          shoppingList: List<String>.from(e['shopping_list']),
          steps: List<String>.from(e['steps']),
        )).toList();
      });
    } else {
      setState(() {
        _savedRecipes.clear(); 
      });
    } // <-- Скобка закрывает else
  } // <-- ЭТА скобка закрывает всю функцию _loadSavedRecipes


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои рецепты ❤️'),
        backgroundColor: Colors.green.shade100,
        // кнопка "Очистить все"
      ),
            body: _savedRecipes.isEmpty
          ? const Center(child: Text('Пока нет сохраненных рецептов ❤️'))
          : ListView.builder(
              itemCount: _savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _savedRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(recipe.title),
                    subtitle: Text('${recipe.steps.length} шагов'),
                    trailing: const Icon(Icons.chevron_right),
                               onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeScreen(
                    selectedIngredients: [], // Пустой список, так как они нам не нужны
                    portions: 0,            // Нулевые порции, т.к. рецепт уже готов
                    diet: '',               // Пустая строка диеты, т.к. рецепт уже готов
                    savedRecipe: recipe,     // <-- Вот наш спасительный рецепт!
                  ),
                ),
              );
            },

                  ),
                );
              },
            ),

    );
  }

}
