import 'package:flutter/material.dart';
import 'fridge_screen.dart'; // Чтобы видеть модель Ingredient

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

  const RecipeScreen({super.key, required this.selectedIngredients});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // Имитируем, что AI уже вернул нам этот рецепт (Mock Data)
  late final Recipe _mockRecipe;

  // Списки для отслеживания галочек пользователя
  List<bool> _shoppingChecks = [];
  List<bool> _stepsChecks = [];

  @override
  void initState() {
    super.initState();

    // Создаем тестовый рецепт, который "как будто" пришел от AI
    _mockRecipe = Recipe(
      title: "Средиземноморская теплая сковорода 🍳",
      shoppingList: ["Оливковое масло", "Чеснок", "Базилик"],
      steps: [
        "Нарежь куриное филе кубиками и обжарь на сковороде с чесноком.",
        "Добавь помидоры и туши 5 минут на среднем огне.",
        "Закинь шпинат и раскроши сыр фета сверху.",
        "Подавай теплым с отваренным рисом!"
      ],
    );

    // Инициализируем списки галочек (изначально все false - ничего не выполнено)
    _shoppingChecks = List.generate(_mockRecipe.shoppingList.length, (index) => false);
    _stepsChecks = List.generate(_mockRecipe.steps.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш рецепт 🧑‍🍳'),
        backgroundColor: Colors.green.shade100,
      ),
      body: SingleChildScrollView( // Разрешаем скролл, если рецепт длинный
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Красивый заголовок рецепта
            Text(
              _mockRecipe.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Используем из холодильника: ${widget.selectedIngredients.map((e) => e.name).join(', ')}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const Divider(height: 32),

            // 2. Блок "Что нужно докупить"
            const Text(
              "Нужно докупить в магазине: 🛒",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // TODO #1: Реализуй список покупок.
            // Нам нужно вывести элементы из _mockRecipe.shoppingList.
            // Для каждого элемента нужно показать CheckboxListTile, чтобы юзер мог кликнуть и отметить галочкой.
            // Используй ListView.builder или обычный Column с обходом элементов.
            // Шаблон для одного элемента:
            /*
            CheckboxListTile(
              title: Text(название_продукта),
              value: _shoppingChecks[index],
              onChanged: (bool? value) {
                setState(() {
                  _shoppingChecks[index] = value!;
                });
              },
            )
            */
            _buildShoppingList(), // Вставляем наш интерактивный список покупок

            const Divider(height: 32),

            // 3. Блок "Пошаговый рецепт"
            const Text(
              "Пошаговый план готовки: 📝",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // TODO #2: Реализуй список шагов готовки.
            // Выведи шаги из _mockRecipe.steps.
            // Сделай так, чтобы при клике на шаг текст зачеркивался (через TextDecoration.lineThrough),
            // если шаг выполнен (_stepsChecks[index] == true).
            _buildStepsList(), // Вставляем наши интерактивные шаги готовки
          ],
        ),
      ),
    );
  }

  // Временные заглушки (удали их или перепиши внутри TODO)
  Widget _buildShoppingList() {

    // TODO #1: Реализуй список покупок.
            // Нам нужно вывести элементы из _mockRecipe.shoppingList.
            // Для каждого элемента нужно показать CheckboxListTile, чтобы юзер мог кликнуть и отметить галочкой.
            // Используй ListView.builder или обычный Column с обходом элементов.
            // Шаблон для одного элемента:
            /*
            CheckboxListTile(
              title: Text(название_продукта),
              value: _shoppingChecks[index],
              onChanged: (bool? value) {
                setState(() {
                  _shoppingChecks[index] = value!;
                });
              },
            )
            */
            return Column(
      children: [
        for (int i = 0; i < _mockRecipe.shoppingList.length; i++)
          CheckboxListTile(
            // Сдвигаем галочку влево (по умолчанию она справа)
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              _mockRecipe.shoppingList[i],
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
        for (int i = 0; i < _mockRecipe.steps.length; i++)
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              _mockRecipe.steps[i],
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