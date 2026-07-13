import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe_screen.dart'; // Нам нужна модель Recipe отсюда
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zero_waste_chef/services/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Импорт базы данных
import '../l10n/app_localizations.dart';
   

   



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
    final user = FirebaseAuth.instance.currentUser;

    // 1. Сначала пробуем загрузить из Firestore
    if (user != null) {
      try {
        final db = FirebaseFirestore.instance;
        final doc = await db.collection('favorites').doc(user.uid).get();

        if (!mounted) return;

        if (doc.exists && doc.data() != null && doc.data()!['recipes'] != null) {
          final List<dynamic> cloudRecipes = doc.data()!['recipes'] as List<dynamic>;
          setState(() {
            _savedRecipes = cloudRecipes.map((e) => Recipe(
              title: e['recipe_name'] as String,
              shoppingList: List<String>.from(e['shopping_list']),
              steps: List<String>.from(e['steps']),
            )).toList();
          });
          logger.i("Рецепты успешно загружены из облака Firestore! ☁️");
          return; // Успешно загрузили, выходим!
        }
      } catch (e) {
        logger.e("Ошибка загрузки избранного из Firestore: $e");
      }
    }

    // 2. Офлайн-режим: если не вошли или нет сети — грузим локально
    final prefs = await SharedPreferences.getInstance();
    
    if (!mounted) return;
    
    final String? savedString = prefs.getString('favorite_recipes');
    
    if (savedString == null || savedString.isEmpty) {
      setState(() {
        _savedRecipes.clear();
      });
      return;
    }

    try {
      final List<dynamic> decodedList = jsonDecode(savedString);
      setState(() {
        _savedRecipes = decodedList.map((e) => Recipe(
          title: e['recipe_name'] as String,
          shoppingList: List<String>.from(e['shopping_list']),
          steps: List<String>.from(e['steps']),
        )).toList();
      });
      logger.i("Рецепты загружены локально из SharedPreferences. 💾");
    } catch (e) {
      await prefs.remove('favorite_recipes');
    }
  }


 @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
   

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        backgroundColor: Colors.green.shade100,
        // кнопка "Очистить все"
      ),
            body: _savedRecipes.isEmpty
          ? Center(child: Text(l10n.noSavedRecipes))
          : ListView.builder(
              itemCount: _savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _savedRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(l10n.recipeStepsCount(recipe.steps.length)),
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
