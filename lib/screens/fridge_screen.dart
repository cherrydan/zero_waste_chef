import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_waste_chef/services/auth_service.dart';
import 'dart:convert'; 
import 'recipe_screen.dart';
import 'favorites_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
    
   


class Ingredient {
  final String name;
  bool isUrgent;
  final DateTime? expiryDate; // Наше новое поле!

  Ingredient({
    required this.name,
    this.isUrgent = false,
    this.expiryDate,
  });

  // Превращаем в JSON (для сохранения в SharedPreferences и Firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isUrgent': isUrgent,
      // В JSON нельзя сохранить объект DateTime напрямую, 
      // поэтому мы превращаем его в строку формата ISO-8601 (например, "2026-07-02")
      'expiryDate': expiryDate?.toIso8601String(), 
    };
  }

  // Создаем объект из JSON (для загрузки)
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      isUrgent: json['isUrgent'] as bool,
      // Превращаем строку ISO обратно в объект DateTime (если она есть)
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
    );
  }
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

  int _portions = 2; // Количество порций по умолчанию

  final List<String> _diets = ['Обычная', 'Средиземноморская', 'Вегетарианская'];
  String _selectedDiet = 'Обычная'; // Переменная для хранения выбранной диеты

  DateTime? _selectedExpiryDate; // Временная переменная для нового продукта

  final List<PopularProduct> _popularProducts = [
    PopularProduct(name: 'Помидоры', emoji: '🍅'),
    PopularProduct(name: 'Куриное филе', emoji: '🍗'),
    PopularProduct(name: 'Сыр Фета', emoji: '🧀'),
    PopularProduct(name: 'Яйца', emoji: '🥚'),
    PopularProduct(name: 'Мясо', emoji: '🥩'),
    PopularProduct(name: 'Морепродукты', emoji: '🍤'),
    PopularProduct(name: 'Молоко', emoji: '🥛'),
  ];

  // Функция сохранения холодильника в память телефона и Firestore
  Future<void> _saveFridgeData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Используем наш новый метод toJson() для правильного сохранения дат!
    final listJson = _ingredients.map((it) => it.toJson()).toList();
    
    await prefs.setString('fridge_list', jsonEncode(listJson));

    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser; 
    
    if (user != null) {
      await db.collection('fridges').doc(user.uid).set({
        'ingredients': listJson,
      });
    }
  }

    String _formatDate(DateTime? date) {
    if (date == null) return '';
    // Дописываем ноль слева, если число меньше 10 (например, "2" станет "02")
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }


  // Функция выбора даты через календарь
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime.now(),   
      lastDate: DateTime.now().add(const Duration(days: 365)), 
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  // ==========================================
  // ДАЛЬШЕ ИДУТ ТВОИ ДРУГИЕ ФУНКЦИИ (например, _loadFridgeData, _addIngredient и т.д.)



  Future<void> _loadFridgeData() async {
    final user = FirebaseAuth.instance.currentUser;

    // Если юзер вошел - пробуем облако
    if (user != null) {
      try {
        final db = FirebaseFirestore.instance;
        final doc = await db.collection('fridges').doc(user.uid).get();

        if (!mounted) return;

        if (doc.exists && doc.data() != null) {
          final List<dynamic> cloudList = doc.data()!['ingredients'] as List<dynamic>;
                  // Было: cloudList.map((e) => Ingredient(name: e['name'], isUrgent: e['isUrgent']))
        // Станет:
        setState(() {
          _ingredients.clear();
          _ingredients.addAll(cloudList.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)));
        });

          _showInfo('Данные успешно загружены из облака! ☁️', Colors.green);
          return;
        }
      } catch (e) {
        if (!mounted) return;
        _showInfo('Офлайн-режим: не удалось загрузить из облака. ☁️', Colors.red);
      }
    }

    // Если не вошел или облако пусто — грузим локально
    final prefs = await SharedPreferences.getInstance();
    
    if (!mounted) return; // Снова проверка после await
    
    final savedString = prefs.getString('fridge_list');
    if (savedString == null || savedString.isEmpty) return;
    
    try {
      final List<dynamic> decodedList = jsonDecode(savedString);
      // Было: decodedList.map((e) => Ingredient(name: e['name'], isUrgent: e['isUrgent']))
      // Станет:
      setState(() {
        _ingredients.clear();
        _ingredients.addAll(decodedList.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)));
      });

      // Синее/оранжевое информационное сообщение
      _showInfo('Данные холодильника загружены локально из SharedPreferences. 💾', Colors.blue);
    } catch (e) {
      await prefs.remove('fridge_list');
    }
  }

  // Наша маленькая вспомогательная функция для показа сообщений
  void _showInfo(String message, Color color) {
    if (!mounted) return; // Защита: не показываем сообщения на мертвом экране
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2), // Сообщение исчезнет через 2 секунды
      ),
    );
  }




  // кастомизация промпта
    void _increasePortions() {
    setState(() {
      _portions++;
    });
  }

  void _decreasePortions() {
    setState(() {
      if (_portions > 1) {
        _portions--;
      }
    });
  }

  // выбор диеты
    void _selectDiet(String diet) {
    setState(() {
      _selectedDiet = diet; // Сохраняем выбранную диету
    });
  }


  // Контроллер для чтения текста из поля ввода
  final TextEditingController _controller = TextEditingController();

  // Функция добавления нового продукта
    void _addIngredient() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      // Добавляем ингредиент с нашей выбранной датой!
      _ingredients.add(Ingredient(
        name: _controller.text.trim(),
        expiryDate: _selectedExpiryDate, // Передаем дату сюда!
      ));
      
      _controller.clear();
      _selectedExpiryDate = null; // Очищаем временную дату для следующего продукта!
    });
    
    _saveFridgeData(); // Сохраняем в память и Firestore
  }

  bool _isProductExpiringSoon(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    
    // Считаем разницу в днях между сроком годности и сегодняшним днем
    final difference = expiryDate.difference(DateTime.now()).inDays;
    
    // Если осталось 2 дня или меньше — продукт "горит"!
    return difference <= 2;
  }



  // Добавляем новый ингридиент через меню популярных продуктов
    void _addPopularProduct(PopularProduct product) {
    setState(() {
      _ingredients.add(Ingredient(
        name: product.name,
        expiryDate: _selectedExpiryDate, // Передаем временно выбранную дату!
        // Если дата горит — умная срочность сама покрасит карточку!
      ));
      _selectedExpiryDate = null; // Сбрасываем дату для следующего продукта
    });
    _saveFridgeData(); // Синхронизируем с облаком
  }



  // Функция удаления продукта
  void _removeIngredient(int index) {
    setState(() {
     
      _ingredients.removeAt(index);
      
    });
    _saveFridgeData(); // Сохраняемся
  }

  // Функция переключения "срочности" продукта
  void _toggleUrgent(int index) {
    setState(() {
      _ingredients[index].isUrgent = !_ingredients[index].isUrgent;
    });
    _saveFridgeData(); // Сохраняемся
  }

  // Очистка списка
    void _clearAll() {
    setState(() {
      _ingredients.clear(); // Очищаем список в памяти телефона
    });
    _saveFridgeData(); // Отправляем пустой список в Firebase и SharedPreferences
  }

  // вызов диалогового окна для подтверждения очистки холодильника
    void _showConfirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Очистить всё? 🗑️'),
          content: const Text('Вы уверены, что хотите удалить все продукты из холодильника? Это действие нельзя отменить.'),
          actions: [
            // Кнопка "Отмена"
            TextButton(
              onPressed: () => Navigator.pop(context), // Просто закрываем окно
              child: const Text('Отмена'),
            ),
            // Кнопка "Удалить"
            TextButton(
              onPressed: () {
                _clearAll(); // Вызываем твою функцию очистки!
                Navigator.pop(context); // Закрываем диалоговое окно
              },
              child: const Text(
                'Удалить всё',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _controller.dispose(); // Всегда очищаем контроллеры для предотвращения утечек памяти
    super.dispose();
  }

    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFridgeData(); // Загружаем продукты из памяти смартфона
    });
  }

  Widget _buildFridgeBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Поле ввода и кнопка "+"
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
            // ДОБАВЛЯЕМ КНОПКУ КАЛЕНДАРЯ ВНУТРЬ ПОЛЯ:
            suffixIcon: IconButton(
            icon: Icon(
            Icons.calendar_month,
            // Если дата выбрана — иконка станет зеленой, если нет — серой
            color: _selectedExpiryDate != null ? Colors.green : Colors.grey,
      ),
      onPressed: () => _selectExpiryDate(context), // Вызываем наш календарь!
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

          // 2. Блок "Быстрый выбор" (Wrap)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Быстрый выбор: ⚡️',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (int i = 0; i < _popularProducts.length; i++)
                ActionChip(
                  avatar: Text(_popularProducts[i].emoji),
                  label: Text(_popularProducts[i].name),
                  onPressed: () => _addPopularProduct(_popularProducts[i]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Блок "Тип диеты" (Horizontal Scroll)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Тип диеты: 🥗',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (String diet in _diets)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(diet),
                      selected: _selectedDiet == diet,
                      selectedColor: Colors.green.shade200,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        if (selected) {
                          _selectDiet(diet);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Список добавленных продуктов
          Expanded(
            child: _ingredients.isEmpty
                ? const Center(child: Text('В холодильнике пока пусто 🏜'))
                : ListView.builder(
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                    final item = _ingredients[index];
                  
                    // Создаем временную переменную для удобства, чтобы не писать длинную формулу три раза:
                    final bool isRedStatus = item.isUrgent || _isProductExpiringSoon(item.expiryDate);

                    return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          // Твоя умная логика цвета фона!
                          color: isRedStatus ? Colors.red.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          leading: IconButton(
                            icon: Icon(
                              // Если статус красный — показываем треугольник, если нет — круг с галочкой
                              isRedStatus ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: isRedStatus ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleUrgent(index),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: isRedStatus ? FontWeight.bold : FontWeight.normal,
                              color: isRedStatus ? Colors.red.shade900 : Colors.black87,
                            ),
                          ),
                          subtitle: item.expiryDate != null 
                              ? Text('Годен до: ${_formatDate(item.expiryDate)}') 
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => _removeIngredient(index),
                          ),
                        ),
                      );

                    },
                  ),
          ),
                  // Блок настройки порций
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Порций:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
                      onPressed: _decreasePortions, // Теперь функция используется!
                    ),
                    Text(
                      '$_portions',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: _increasePortions, // Теперь функция используется!
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Кнопка "Сгенерировать"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(
                      selectedIngredients: _ingredients,
                      portions: _portions,
                      diet: _selectedDiet,
                      savedRecipe: null
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Сгенерировать меню (AI)', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zero Waste Chef 🍏'),
          backgroundColor: Colors.green.shade100,
           // ==========================================
          // ВСТАВЛЯЕМ СЮДА НАШУ КНОПКУ ОЧИСТКИ:
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: _showConfirmDeleteDialog, // Вызываем диалог подтверждения
            ), // Кнопка очистки
            
            
            IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
            await AuthService().signOut();
          },
   ), // Кнопка logout
          ],
          // ==========================================
            
   

          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.kitchen), text: 'Холодильник'),
              Tab(icon: Icon(Icons.favorite), text: 'Избранное'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFridgeBody(), // Твоя верстка теперь живет здесь
            const FavoritesScreen()
          ],
        ),
      ),
    );
  }
}