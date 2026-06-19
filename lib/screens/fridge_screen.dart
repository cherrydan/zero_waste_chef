import 'package:flutter/material.dart';
import 'recipe_screen.dart'; // Импортируем будущий экран рецептов

// Сначала создадим модель нашего ингредиента
class Ingredient {
  final String name;
  bool isUrgent; // Флаг: нужно ли съесть срочно (актуально для южных стран!)

  Ingredient({required this.name, this.isUrgent = false});
}

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  // Список продуктов в нашем холодильнике
  final List<Ingredient> _ingredients = [
    Ingredient(name: 'Помидоры', isUrgent: true),
    Ingredient(name: 'Куриное филе'),
  ];

  // Контроллер для чтения текста из поля ввода
  final TextEditingController _controller = TextEditingController();

  // Функция добавления нового продукта
  void _addIngredient() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      // TODO #1: Добавь новый ингредиент в список _ingredients.
      // Имя ингредиента должно браться из _controller.text.
      // После добавления обязательно очисти поле ввода с помощью _controller.clear().

      _ingredients.add(Ingredient(name: _controller.text.trim())); 
      _controller.clear();
    });
  }

  // Функция удаления продукта
  void _removeIngredient(int index) {
    setState(() {
      // TODO #2: Напиши код, который удаляет элемент из списка _ingredients по индексу index.
      _ingredients.removeAt(index);
      
    });
  }

  // Функция переключения "срочности" продукта
  void _toggleUrgent(int index) {
    setState(() {
      _ingredients[index].isUrgent = !_ingredients[index].isUrgent;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Всегда очищаем контроллеры для предотвращения утечек памяти
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Холодильник 🍏'),
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Поле ввода и кнопка "+"
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Например: Шпинат, Сыр...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Список добавленных продуктов
            Expanded(
              child: _ingredients.isEmpty
                  ? const Center(child: Text('В холодильнике пока пусто 🏜️'))
                  : ListView.builder(
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        final item = _ingredients[index];
                        return Card(
                          color: item.isUrgent ? Colors.red.shade50 : null,
                          child: ListTile(
                            // Иконка срочности (меняет цвет при тапе)
                            leading: IconButton(
                              icon: Icon(
                                item.isUrgent ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                color: item.isUrgent ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _toggleUrgent(index),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: item.isUrgent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            // Кнопка удаления
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _removeIngredient(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Кнопка "Сгенерировать план"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO #3: Напиши переход на экран RecipeScreen.
                  // Передай туда наш список ингредиентов _ingredients, чтобы мы могли отправить его в AI.
                  // Подсказка: используй Navigator.push(...)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeScreen(selectedIngredients: _ingredients),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Сгенерировать меню (AI)', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}