import 'package:flutter/material.dart';
import 'fridge_screen.dart'; // Чтобы видеть модель Ingredient
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zero_waste_chef/services/app_logger.dart'; // Наш логгер
import 'package:zero_waste_chef/utils/date_helpers.dart'; 
import '../l10n/app_localizations.dart';


// Модель данных рецепта (из Шага 1)
class Recipe {
  final String title;
  final List<String> steps;
  final List<String> shoppingList;

  Recipe({
    required this.title,
    required this.steps,
    required this.shoppingList,
  });

  Map<String, dynamic> toJson() {
  return {
    'recipe_name': title,
    'shopping_list': shoppingList,
    'steps': steps,
  };
}

}

class RecipeScreen extends StatefulWidget {
  final List<Ingredient> selectedIngredients;

  final int portions; // Новое поле для количества порций

  final String diet; // новое поле для выбранной диеты

  final Recipe? savedRecipe;

  const RecipeScreen({super.key, required this.selectedIngredients, required this.portions, required this.diet,
   this.savedRecipe});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // Имитируем, что AI уже вернул нам этот рецепт (Mock Data)
     Recipe? _recipe; // Изначально равен null (пусто), пока ИИ думает
    String? _errorMessage;  
    bool _isFavorite = false; // Состояние сердечка "Избранное". По умолчанию рецепт не в избранном

    Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;

    // 1. Сначала пробуем загрузить из облака (Firestore)
    if (user != null) {
      try {
        final db = FirebaseFirestore.instance;
        final doc = await db.collection('favorites').doc(user.uid).get();

        if (doc.exists && doc.data() != null && doc.data()!['recipes'] != null) {
          final List<dynamic> cloudRecipes = doc.data()!['recipes'] as List<dynamic>;
          
          setState(() {
            _favoriteRecipes = cloudRecipes.map((e) => Recipe(
              title: e['recipe_name'] as String,
              shoppingList: List<String>.from(e['shopping_list']),
              steps: List<String>.from(e['steps']),
            )).toList();

            // Проверяем, есть ли наш текущий рецепт в этом списке
            _isFavorite = _favoriteRecipes.any((r) => r.title == _recipe!.title);
          });
          return; // Успешно загрузили из облака, выходим!
        }
      } catch (e) {
        logger.e("Ошибка загрузки избранного из Firestore: $e");
      }
    }

    // 2. Если не вошли или нет интернета — используем локальный SharedPreferences (твой текущий код)
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('favorite_recipes');

    if (favoritesString != null && favoritesString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(favoritesString);
      setState(() {
        _favoriteRecipes = decodedList.map((e) => Recipe(
          title: e['recipe_name'] as String,
          shoppingList: List<String>.from(e['shopping_list']),
          steps: List<String>.from(e['steps']),
        )).toList();
        
        _isFavorite = _favoriteRecipes.any((r) => r.title == _recipe!.title);
      });
    }
  }


    Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_isFavorite) {
        _favoriteRecipes.removeWhere((r) => r.title == _recipe!.title);
        _isFavorite = false;
      } else {
        _favoriteRecipes.add(_recipe!);
        _isFavorite = true;
      }
    });

    // 1. Локальное сохранение
    String encodedData = jsonEncode(_favoriteRecipes.map((e) => e.toJson()).toList());
    await prefs.setString('favorite_recipes', encodedData);

    // 2. Облачное сохранение
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final db = FirebaseFirestore.instance;
        final recipesJson = _favoriteRecipes.map((e) => e.toJson()).toList();

        await db.collection('favorites').doc(user.uid).set({
          'recipes': recipesJson, // Исправили на recipesJson!
        });
      } catch (e) {
        logger.e("Не удалось сохранить рецепт в облако: $e");
      }
    }
  }






  // Списки для отслеживания галочек пользователя
  List<bool> _shoppingChecks = [];
  List<bool> _stepsChecks = [];

  // Список для хранения избранных рецептов 
  List<Recipe> _favoriteRecipes = []; // Список избранных рецептов


    @override
  void initState() {
    super.initState();
    
    if (widget.savedRecipe != null) {
      // 1. Если рецепт ПЕРЕДАН из избранного:
      _recipe = widget.savedRecipe;
      
      _shoppingChecks = List.generate(_recipe!.shoppingList.length, (index) => false);
      _stepsChecks = List.generate(_recipe!.steps.length, (index) => false);
      
      // Ждем отрисовки первого кадра перед загрузкой избранного (на всякий случай)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFavorites();
      });
    } else {
      // 2. Если пришли из холодильника:
      // Ждем отрисовки первого кадра, когда context будет на 100% готов, 
      // и только потом запускаем генерацию ИИ!
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecipeFromAI();
      });
    }
  }

      // Определяем, запрещен ли ингредиент текущей диетой
  bool _isIngredientForbiddenByDiet(Ingredient ingredient, String dietType) {
    if (dietType == 'Вегетарианская' || dietType == 'Vegetarian' || dietType == 'Vegetariana') {
      // Это вегетарианская диета. Ингредиенты, которые надо исключить:
      final forbiddenIds = ['chicken', 'meat', 'seafood']; // Используем ID для универсальности!
      // Проверяем, если ингредиент из запрещенных ID
      if (ingredient.id != null && forbiddenIds.contains(ingredient.id)) {
        return true;
      }
      // Если это не популярный продукт, но его имя явно указывает на запрещенный продукт
      final forbiddenNames = ['курица', 'мясо', 'рыба', 'морепродукты', 'chicken', 'meat', 'fish', 'seafood', 'pollo', 'carne', 'pescado', 'mariscos'];
      final lowerCaseName = ingredient.name.toLowerCase();
      if (forbiddenNames.any((name) => lowerCaseName.contains(name))) {
        return true;
      }
    }
    // Добавь сюда логику для других диет, если они будут (например, без глютена)
    return false;
  }



    Future<void> _loadRecipeFromAI() async {
    // Вся работа заворачивается в блок try!
    try {
      final l10n = AppLocalizations.of(context)!;

      // 🟢 ФИЛЬТРУЕМ ЗАПРЕЩЕННЫЕ ИНГРЕДИЕНТЫ ДО СОСТАВЛЕНИЯ ПРОМПТА!
      final List<Ingredient> filteredIngredients = widget.selectedIngredients
          .where((ingredient) => !_isIngredientForbiddenByDiet(ingredient, widget.diet))
          .toList();

      // 1. Форматируем список продуктов для ИИ на текущем языке системы
      final ingredientsPromptList = filteredIngredients.map((e) {
        final bool isExpired = isProductExpired(e.expiryDate);
        final bool isExpiringSoon = e.isUrgent || isProductExpiringSoon(e.expiryDate);

        final String translatedName = e.id != null 
            ? getPopularProductName(e.id!, l10n) 
            : e.name;

        if (isExpired) {
          return '$translatedName${l10n.ingredientExpiredTag}';
        } else if (isExpiringSoon) {
          return '$translatedName${l10n.ingredientUrgentTag}';
        } else {
          return translatedName;
        }
      }).join(', ');

      // 2. Формируем промпт на нужном языке
      var aiPrompt = l10n.aiRecipePrompt(
        widget.portions,       // 1. portions (int)
        ingredientsPromptList, // 2. ingredientsList (String)
        widget.diet,           // 3. dietType (String)
      );

      // 3. Отправляем запрос в OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myKey', // Убедись, что твой ключ на месте!
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // или gpt-4o-mini
          'messages': [
            {
              'role': 'user',
              'content': aiPrompt,
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final String reply = data['choices'][0]['message']['content'] as String;
        
        final Map<String, dynamic> decodedRecipe = jsonDecode(reply);

        setState(() {
          _recipe = Recipe(
            title: decodedRecipe['recipe_name'] as String,
            shoppingList: List<String>.from(decodedRecipe['shopping_list']),
            steps: List<String>.from(decodedRecipe['steps']),
          );
           // 🟢 ВОТ ЧТО МЫ ЗАБЫЛИ! Добавь эти две строчки сюда:
          _shoppingChecks = List.generate(_recipe!.shoppingList.length, (index) => false);
          _stepsChecks = List.generate(_recipe!.steps.length, (index) => false);
        });
      } else {
        // Если сервер OpenAI вернул ошибку (например, статус 429 или 401)
        throw Exception('Ошибка сервера OpenAI: код ${response.statusCode}');
      }

    } catch (e) {
      // Блок catch поймает ЛЮБУЮ ошибку (сети, парсинга JSON, несовместимости типов)
      logger.e("Критическая ошибка генерации рецепта: $e");
      
      if (mounted) {
        // Показываем красивое уведомление об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Упс! Ошибка: $e. Пожалуйста, попробуйте еще раз!'),
            backgroundColor: Colors.red,
          ),
        );
        // Закрываем зависший экран и возвращаем пользователя назад в холодильник
        Navigator.pop(context);
      }
    }
  }



  @override
  Widget build(BuildContext context) {

  final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
        title: Text(_recipe?.title ?? l10n.recipeTitle),
        backgroundColor: Colors.green.shade100,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border, // Красное сердечко или пустое
              color: _isFavorite ? Colors.red : Colors.grey, // Цвет сердечка
            ),
            onPressed: () {
              
              _toggleFavorite();
            },
          ),
        ],
      ),

body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context), // Кнопка возврата назад в холодильник
                      child: const Text('Вернуться назад'),
                    ),
                  ],
                ),
              ),
            )

      // ПРОВЕРЯЕМ: Если рецепт еще не загрузился, показываем крутилку
      : _recipe == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(l10n.aiThinking),
                ],
              ),
            )
          // ЕСЛИ РЕЦЕПТ ЗАГРУЗИЛСЯ — показываем наш обычный экран
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Красивый заголовок рецепта
                  Text(
                    l10n.recipeTitle, // Обрати внимание: теперь везде используем _recipe! вместо _mockRecipe
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
            
           
            _buildShoppingList(), // Вставляем наш интерактивный список покупок

            const Divider(height: 32),

            // 3. Блок "Пошаговый рецепт"
            Text(
              l10n.steps,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            
            _buildStepsList(), // Вставляем наши интерактивные шаги готовки

                      // ... твои шаги готовки или другие виджеты ...
          
          const SizedBox(height: 24), // Отступ перед дисклеймером

          // НАШ ЮРИДИЧЕСКИЙ ДИСКЛЕЙМЕР:
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel_rounded, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Дисклеймер: ИИ предлагает варианты рецептов на основе ваших продуктов, но не оценивает их реальную свежесть. Всегда проверяйте запах, вид и срок годности ингредиентов самостоятельно перед употреблением. Разработчики не несут ответственности за возможные пищевые расстройства.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16), // Отступ до самого низа экрана

          ],
        ),
      ),
    );
  }

  
  Widget _buildShoppingList() {

            return Column(
      children: [
        for (int i = 0; i < _recipe!.shoppingList.length; i++)
          CheckboxListTile(
            // Сдвигаем галочку влево (по умолчанию она справа)
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
               _recipe!.shoppingList[i],
              style: TextStyle(
                // Если галочка стоит — зачеркиваем текст, иначе оставляем обычным
                decoration: _shoppingChecks[i] ? TextDecoration.lineThrough : null,
                // Если галочка стоит — делаем текст серым
                color: _shoppingChecks[i] ? Colors.grey : Colors.black87,
              ),
            ),
            value: _shoppingChecks[i],
            onChanged: (bool? value) {
              setState(() {
                _shoppingChecks[i] = value!;
              });
            },
            activeColor: Colors.green, // Цвет галочки при нажатии
          ),
      ],
    );
  }

  Widget _buildStepsList() {
    return Column(
      children: [
        for (int i = 0; i <  _recipe!.steps.length; i++)
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
               _recipe!.steps[i],
              style: TextStyle(
                decoration: _stepsChecks[i] ? TextDecoration.lineThrough : null,
                color: _stepsChecks[i] ? Colors.grey : Colors.black87,
              ),
            ),
            value: _stepsChecks[i],
            onChanged: (bool? value) {
              setState(() {
                _stepsChecks[i] = value!;
              });
            },
            activeColor: Colors.green,
          ),
      ],
    );
  }
}