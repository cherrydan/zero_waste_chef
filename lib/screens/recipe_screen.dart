import 'package:flutter/material.dart';
import 'fridge_screen.dart'; // Чтобы видеть модель Ingredient
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';


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
}

class RecipeScreen extends StatefulWidget {
  final List<Ingredient> selectedIngredients;

  final int portions; // Новое поле для количества порций

  const RecipeScreen({super.key, required this.selectedIngredients, required this.portions});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // Имитируем, что AI уже вернул нам этот рецепт (Mock Data)
     Recipe? _recipe; // Изначально равен null (пусто), пока ИИ думает
    String? _errorMessage;  


  // Списки для отслеживания галочек пользователя
  List<bool> _shoppingChecks = [];
  List<bool> _stepsChecks = [];

  @override
  void initState() {
    super.initState();
    
    _loadRecipeFromAI();
   
  }


  // ==========================================
  // ВОТ ИДЕАЛЬНОЕ МЕСТО ДЛЯ ТВОЕЙ ФУНКЦИИ:
  Future<void> _loadRecipeFromAI() async {
    // Пишем логику отправки запроса сюда!
    var headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $myKey',
  };
      var aiPrompt = '''
Приготовь блюдо строго на ${widget.portions} порции(й) из следующих продуктов: ${widget.selectedIngredients.map((e) => e.name).join(', ')}. 
Добавь не больше 2 дешевых ингредиентов.

Ответ верни СТРОГО в формате JSON с ключами: 
- 'recipe_name' (строка)
- 'shopping_list' (массив строк)
- 'steps' (массив строк).
''';



    var body = jsonEncode({
    'model': 'gpt-4o-mini',
    'response_format': {'type': 'json_object'},
    'messages': [
      {
        'role': 'user',
        'content': aiPrompt,
      }
    ]
  });


   
    

    var url = Uri.parse('https://api.openai.com/v1/chat/completions');
    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      String replyText = decodedData['choices'][0]['message']['content'];
      var recipeJson = jsonDecode(replyText);
            // Создаем объект рецепта из JSON
      Recipe realRecipe = Recipe(
        title: recipeJson['recipe_name'],
        shoppingList: List<String>.from(recipeJson['shopping_list']),
        steps: List<String>.from(recipeJson['steps']),
      );

      // Обновляем состояние экрана!
      setState(() {
        _recipe = realRecipe;
        // Генерируем новые пустые списки галочек (false) под размер нового рецепта
        _shoppingChecks = List.generate(_recipe!.shoppingList.length, (index) => false);
        _stepsChecks = List.generate(_recipe!.steps.length, (index) => false);
      });

    
    } else { 
      
      setState(() {
        _errorMessage = 'Ой, что-то пошло не так. Не удалось получить рецепт от ИИ. 😢';
      });

    }

  }
  // ==========================================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш рецепт 🧑‍🍳'),
        backgroundColor: Colors.green.shade100,
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('ИИ придумывает рецепт... 🧑‍🍳'),
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
                    _recipe!.title, // Обрати внимание: теперь везде используем _recipe! вместо _mockRecipe
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
            
           
            _buildShoppingList(), // Вставляем наш интерактивный список покупок

            const Divider(height: 32),

            // 3. Блок "Пошаговый рецепт"
            const Text(
              "Пошаговый план готовки: 📝",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            
            _buildStepsList(), // Вставляем наши интерактивные шаги готовки
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