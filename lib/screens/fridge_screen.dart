import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_waste_chef/screens/profile_screen.dart';
import 'dart:convert'; 
import 'recipe_screen.dart';
import 'favorites_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zero_waste_chef/utils/date_helpers.dart';    
import '../l10n/app_localizations.dart';
   
   


class Ingredient {
  final String name; // Имя-заглушка (или то, что ввели руками)
  final String? id;  // Уникальный ID для популярных продуктов
  bool isUrgent;
  final DateTime? expiryDate;

  Ingredient({
    required this.name,
    this.id, // <-- Наше новое поле!
    this.isUrgent = false,
    this.expiryDate,
  });

  // Превращаем в JSON (добавляем id)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id, // <-- Сохраняем ID
      'isUrgent': isUrgent,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  // Создаем из JSON (считываем id)
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      id: json['id'] as String?, // <-- Считываем ID
      isUrgent: json['isUrgent'] as bool,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
    );
  }
}


// Популярные продукты в виде иконок для быстрого добавления
class PopularProduct {
  final String id; // <--- Теперь используем уникальный ID вместо имени
  final String emoji;

  PopularProduct({required this.id, required this.emoji});
}




class FridgeScreen extends StatefulWidget {
  

  final FirebaseFirestore? firestore; // опциональная база
  final FirebaseAuth? auth; // опциональная аутентификация

  const FridgeScreen({super.key, this.firestore, this.auth});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();

  
}

class _FridgeScreenState extends State<FridgeScreen> {

  // Геттеры для базы данных и авторизации:
  FirebaseFirestore get db => widget.firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  // Список продуктов в нашем холодильнике
  final List<Ingredient> _ingredients = [
    Ingredient(name: 'Помидоры', isUrgent: true),
    Ingredient(name: 'Куриное филе'),
  ];

  int _portions = 2; // Количество порций по умолчанию

  // Заменили русские строки на универсальные ID:
  final List<String> _dietIds = ['regular', 'mediterranean', 'vegetarian'];
  String _selectedDiet = 'regular'; // По умолчанию ID 'regular'


  DateTime? _selectedExpiryDate; // Временная переменная для нового продукта

  final List<PopularProduct> _popularProducts = [
    PopularProduct(id: 'tomatoes', emoji: '🍅'),
    PopularProduct(id: 'chicken', emoji: '🍗'),
    PopularProduct(id: 'feta', emoji: '🧀'),
    PopularProduct(id: 'eggs', emoji: '🥚'),
    PopularProduct(id: 'meat', emoji: '🥩'),
    PopularProduct(id: 'seafood', emoji: '🍤'),
    PopularProduct(id: 'milk', emoji: '🥛'),
  ];

  // Функция сохранения холодильника в память телефона и Firestore
  Future<void> _saveFridgeData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Используем наш новый метод toJson() для правильного сохранения дат!
    final listJson = _ingredients.map((it) => it.toJson()).toList();
    
    await prefs.setString('fridge_list', jsonEncode(listJson));

    
    final user = auth.currentUser; 
    
    if (user != null) {
      await db.collection('fridges').doc(user.uid).set({
        'ingredients': listJson,
      });
    }
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
    final user = auth.currentUser;

    // Если юзер вошел - пробуем облако
    if (user != null) {
      try {
        
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


    String _getDietName(String id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'regular': return l10n.dietRegular;
      case 'mediterranean': return l10n.dietMediterranean;
      case 'vegetarian': return l10n.dietVegetarian;
      default: return '';
    }
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

    String _getPopularProductName(String id) {

    final l10n = AppLocalizations.of(context)!;  

    switch (id) {
      case 'tomatoes': return l10n.popTomatoes;
      case 'chicken': return l10n.popChicken;
      case 'feta': return l10n.popFeta;
      case 'eggs': return l10n.popEggs;
      case 'meat': return l10n.popMeat;
      case 'seafood': return l10n.popSeafood;
      case 'milk': return l10n.popMilk;
      default: return '';
    }
  }


      String _getExpiredDaysText(DateTime? expiryDate) {
    if (expiryDate == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    
    final diff = today.difference(expiry).inDays;
    
    // Получаем l10n и вызываем метод как функцию, передавая туда число дней!
    final l10n = AppLocalizations.of(context)!;
    return l10n.expiredDaysText(diff); // <-- Передали параметр!
  }




  // Добавляем новый ингридиент через меню популярных продуктов
      void _addPopularProduct(PopularProduct product) {
    setState(() {
      _ingredients.add(Ingredient(
        name: product.id, // В имя временно кладем ID как заглушку
        id: product.id,   // <-- Передаем ID!
        expiryDate: _selectedExpiryDate,
      ));
      _selectedExpiryDate = null;
    });
    _saveFridgeData();
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
    final l10n = AppLocalizations.of(context)!;  

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.clearAllDialogTitle),
          content: Text(l10n.clearAllDialogContent),
          actions: [
            // Кнопка "Отмена"
            TextButton(
              onPressed: () => Navigator.pop(context), // Просто закрываем окно
              child: Text(l10n.cancelButton),
            ),
            // Кнопка "Удалить"
            TextButton(
              onPressed: () {
                _clearAll(); // Вызываем твою функцию очистки!
                Navigator.pop(context); // Закрываем диалоговое окно
              },
              child: Text(
                l10n.deleteAllButton,
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

    final l10n = AppLocalizations.of(context)!;
   


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
                hintText: l10n.addIngredientHint,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.quickSelectTitle,
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
                  label: Text(_getPopularProductName(_popularProducts[i].id)),
                  onPressed: () => _addPopularProduct(_popularProducts[i]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Блок "Тип диеты" (Horizontal Scroll)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.dietTypeTitle,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
                    SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (String dietId in _dietIds) // Проходим по ID диет
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      // Переводим ID на лету для экрана:
                      label: Text(_getDietName(dietId)), 
                      selected: _selectedDiet == dietId, // Сравниваем ID
                      selectedColor: Colors.green.shade200,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedDiet = dietId; // Сохраняем выбранный ID
                          });
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
                ?  Center(child: Text(l10n.emptyFridge))
                : ListView.builder(
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                     final item = _ingredients[index];
                      
                      // Рассчитываем три статуса продукта:
                      final bool isExpired = isProductExpired(item.expiryDate);
                      final bool isExpiringSoon = isProductExpiringSoon(item.expiryDate);
                      final bool isRedStatus = item.isUrgent || isExpiringSoon;

                      // Настраиваем цвета в зависимости от статуса
                      Color cardColor = Colors.white;
                      Color contentColor = Colors.black87;
                      IconData leadingIcon = Icons.check_circle_outline;
                      Color iconColor = Colors.grey;

                      if (isExpired) {
                        cardColor = Colors.grey.shade300; // Мертвый серый цвет для просрочки
                        contentColor = Colors.red.shade900; // Тревожный красный текст
                        leadingIcon = Icons.dangerous; // Иконка "Опасно" 💀
                        iconColor = Colors.red.shade900;
                      } else if (isRedStatus) {
                        cardColor = Colors.red.shade50; // Пастельно-красный для срочного
                        contentColor = Colors.red.shade900;
                        leadingIcon = Icons.warning_amber_rounded; // Треугольник предупреждения ⚠️
                        iconColor = Colors.red;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: cardColor, // Наш динамический цвет
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
                            icon: Icon(leadingIcon, color: iconColor),
                            onPressed: isExpired ? null : () => _toggleUrgent(index), // Просроченные продукты нельзя "разжаловать" из срочных!
                          ),
                          title: Text(
                                 item.id != null 
                                ? _getPopularProductName(item.id!) // Переводим на лету!
                                : item.name, // Показываем ручной ввод как есть
                            style: TextStyle(
                              fontWeight: (isExpired || isRedStatus) ? FontWeight.bold : FontWeight.normal,
                              color: contentColor,
                            ),
                          ),

                                                    subtitle: item.expiryDate != null 
                              ? Text(
                                  isExpired 
                                      ? _getExpiredDaysText(item.expiryDate)
                                      : l10n.bestBefore(formatDate(item.expiryDate)), // 🟢 Динамический перевод с датой!
                                  style: TextStyle(
                                    color: isExpired ? Colors.red.shade900 : Colors.black54,
                                    fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                                  ),
                                )
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
                Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      l10n.portionsTitle,
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
                      // ПЕРЕДАЕМ ПЕРЕВЕДЕННЫЙ ТЕКСТ ДЛЯ OpenAI:
                      diet: _getDietName(_selectedDiet), 
                      savedRecipe: null
                    ),
                  ),
                );
              },
              // ...

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.generateButton, style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }


   @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // <--- Меняем на 3!
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zero Waste Chef 🍏'),
          backgroundColor: Colors.green.shade100,
          actions: [
            // Кнопку Logout мы отсюда скоро уберем, но пока пусть повисит
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: _showConfirmDeleteDialog,
            ),
          ],
            bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.kitchen), 
                text: AppLocalizations.of(context)!.fridgeTab, // вместо 'Холодильник'
              ),
              Tab(
                icon: const Icon(Icons.favorite), 
                text: AppLocalizations.of(context)!.favoritesTab, // вместо 'Избранное'
              ),
              Tab(
                icon: const Icon(Icons.person), 
                text: AppLocalizations.of(context)!.profileTab, // вместо 'Профиль'
              ),
            ],
          ),

        ),
        body: TabBarView(
          children: [
            _buildFridgeBody(),
            const FavoritesScreen(),
            const Center(child: ProfileScreen()), 
          ],
        ),
      ),
    );
  }
}