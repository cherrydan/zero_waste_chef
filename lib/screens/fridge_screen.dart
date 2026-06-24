import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe_screen.dart'; // Импортируем будущий экран рецептов
import 'dart:convert'; 

// Сначала создадим модель нашего ингредиента
class Ingredient {
  final String name;
  bool isUrgent; // Флаг: нужно ли съесть срочно (актуально для южных стран!)

  Ingredient({required this.name, this.isUrgent = false});
}

// Популярные продукты в виде иконок для быстрого добавления
class PopularProduct {
  final String name;
  final String emoji;

  PopularProduct({required this.name, required this.emoji});
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

final List<PopularProduct> _popularProducts = [
  PopularProduct(name: 'Помидоры', emoji: '🍅'),
  PopularProduct(name: 'Куриное филе', emoji: '🍗'),
  PopularProduct(name: 'Сыр Фета', emoji: '🧀'),
  PopularProduct(name: 'Яйца', emoji: '🥚'),
  
  PopularProduct(name: 'Мясо', emoji: '🥩'),
  PopularProduct(name: 'Морепродукты', emoji: '🍤'),
  PopularProduct(name: 'Молоко', emoji: '🥛'),
];

  // Функция сохранения холодильника в память телефона (в формате JSON)
  Future<void> _saveFridgeData() async {
    final prefs = await SharedPreferences.getInstance();
    // Превращаем список объектов Ingredient в список простых карт (Map)
    final listJson = _ingredients.map((it) => {
      'name': it.name, 
      'isUrgent': it.isUrgent
    }).toList();
    
    // Кодируем в одну большую JSON-строку и сохраняем
    await prefs.setString('fridge_list', jsonEncode(listJson));
  }

  // Функция загрузки холодильника из памяти телефона при старте
  Future<void> _loadFridgeData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedString = prefs.getString('fridge_list');
    
    // Если в памяти еще ничего нет (первый запуск) — ничего не делаем
    if (savedString == null || savedString.isEmpty) return;
    
    try {
      final List<dynamic> decodedList = jsonDecode(savedString);
      setState(() {
        _ingredients.clear(); // Очищаем дефолтные продукты
        // Заполняем список тем, что прочитали из памяти
        _ingredients.addAll(decodedList.map((e) => Ingredient(
          name: e['name'] as String,
          isUrgent: e['isUrgent'] as bool,
        )));
      });
    } catch (e) {
      // Если данные вдруг повредились — очищаем ключ
      await prefs.remove('fridge_list');
    }
  }


  // Контроллер для чтения текста из поля ввода
  final TextEditingController _controller = TextEditingController();

  // Функция добавления нового продукта
  void _addIngredient() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {

      _ingredients.add(Ingredient(name: _controller.text.trim())); 
      _controller.clear();
    });
    _saveFridgeData();
  }

  // Добавляем новый ингридиент через меню популярных продуктов
  void _addPopularProduct(PopularProduct product) {
  setState(() {
    // Добавь новый ингредиент в наш список _ingredients.
    // Имя ингредиента должно браться из product.name.
    _ingredients.add(Ingredient(name: product.name));

  });
}


  // Функция удаления продукта
  void _removeIngredient(int index) {
    setState(() {
     
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
  void initState() {
    super.initState();
    _loadFridgeData(); // Загружаем продукты из памяти смартфона
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

            // Маленький красивый заголовок для блока быстрых кнопок
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Быстрый выбор: ⚡️',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),

            // Наш исправленный Wrap без лишних скобок
            Wrap(
              spacing: 8.0, 
              runSpacing: 8.0, 
              children: [
                for (int i = 0; i < _popularProducts.length; i++) 
                  ActionChip(
                    avatar: Text(_popularProducts[i].emoji),
                    label: Text(_popularProducts[i].name),
                    onPressed: () => _addPopularProduct(_popularProducts[i]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16), 
            
            // Список добавленных продуктов
            Expanded(
              child: _ingredients.isEmpty
                  ? const Center(child: Text('В холодильнике пока пусто 🏜'))
                  : ListView.builder(
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        final item = _ingredients[index];
                        return Container(
  // 1. Настраиваем отступы СНАРУЖИ, чтобы карточки не слипались
  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
  
  // 2. Настраиваем нашу космическую декорацию
  decoration: BoxDecoration(
    // Твоя умная строчка выбора цвета:
    color: item.isUrgent ? Colors.red.shade50 : Colors.white,
    // Скругляем углы карточки на 16 пикселей
    borderRadius: BorderRadius.circular(16.0),
    // Твоя глубокая и мягкая тень:
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04), // всего 4% видимости тени для ультра-мягкости
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  
  // 3. Внутрь контейнера кладем наш ListTile с контентом
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Отступы внутри ListTile
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
        color: item.isUrgent ? Colors.red.shade900 : Colors.black87, // Делаем текст срочных продуктов темно-красным
      ),
    ),
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