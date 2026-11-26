import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_waste_chef/screens/profile_screen.dart';
import 'dart:convert';
import 'recipe_screen.dart';
import 'favorites_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zero_waste_chef/utils/date_helpers.dart';
import '../l10n/app_localizations.dart';
import '../services/purchase_service.dart'; // 🟢 Для доступа к сервису покупок

class Ingredient {
  final String name; // Имя-заглушка (или то, что ввели руками)
  final String? id; // Уникальный ID для популярных продуктов
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

  int _dailyGenerationsCount = 0;
  int _maxDailyGenerations = 3;

  bool _isQuotaLoading = true;
  bool _quotaReady = false;
  bool _groupAvailable = false;
  bool _isOpeningRecipe = false;
  bool _needsInvitation = false;
  bool _testerDisabled = false;
  bool _isActivating = false;
  String? _inviteError;
  final TextEditingController _inviteController = TextEditingController();

  static const String _apiBase =
      'https://zero-waste-chef-api.danilcerepuhin.workers.dev';

  // Заменили русские строки на универсальные ID:
  final List<String> _dietIds = ['regular', 'mediterranean', 'vegetarian'];
  String _selectedDiet = 'regular'; // По умолчанию ID 'regular'

  DateTime? _selectedExpiryDate; // Временная переменная для нового продукта

  String?
      _premiumExpirationDate; // 🟢 Переменная для хранения даты окончания подписки

  final List<PopularProduct> _popularProducts = [
    PopularProduct(id: 'tomatoes', emoji: '🍅'),
    PopularProduct(id: 'chicken', emoji: '🍗'),
    PopularProduct(id: 'feta', emoji: '🧀'),
    PopularProduct(id: 'eggs', emoji: '🥚'),
    PopularProduct(id: 'meat', emoji: '🥩'),
    PopularProduct(id: 'seafood', emoji: '🍤'),
    PopularProduct(id: 'milk', emoji: '🥛'),
  ];

  bool _isUserPremium = false; // 🟢 Флаг статуса Premium

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

  // Загружаем и проверяем лимит генераций на сегодняшний день
  Future<bool> _loadDailyGenerationsLimit() async {
    if (!mounted) return false;

    setState(() {
      _isQuotaLoading = true;
      _quotaReady = false;
    });

    try {
      final user = auth.currentUser;

      if (user == null) {
        throw Exception('SIGN_IN_REQUIRED');
      }

      final token = await user.getIdToken();

      if (token == null || token.isEmpty) {
        throw Exception('SIGN_IN_REQUIRED');
      }

      final response = await http.get(
        Uri.parse('$_apiBase/quota'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 403) {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final errorCode = errorData is Map ? errorData['error'] : null;
        if (errorCode == 'TESTER_ACCESS_REQUIRED' ||
            errorCode == 'TESTER_DISABLED') {
          if (!mounted || auth.currentUser?.uid != user.uid) return false;
          setState(() {
            _needsInvitation = errorCode == 'TESTER_ACCESS_REQUIRED';
            _testerDisabled = errorCode == 'TESTER_DISABLED';
            _groupAvailable = false;
          });
          return false;
        }
      }
      if (response.statusCode != 200) {
        throw Exception('QUOTA_HTTP_${response.statusCode}');
      }

      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      final limit = data['limit'];
      final remaining = data['remaining'];
      final groupAvailable = data['group_available'];

      if (limit is! int ||
          remaining is! int ||
          groupAvailable is! bool ||
          limit < 0 ||
          remaining < 0 ||
          remaining > limit) {
        throw Exception('INVALID_QUOTA_RESPONSE');
      }

      if (!mounted) return false;

      if (auth.currentUser?.uid != user.uid) {
        throw Exception('ACCOUNT_CHANGED');
      }

      setState(() {
        _maxDailyGenerations = limit;
        _dailyGenerationsCount = limit - remaining;
        _groupAvailable = groupAvailable;
        _quotaReady = true;
        _needsInvitation = false;
        _testerDisabled = false;
        _inviteError = null;
      });

      return true;
    } catch (e) {
      debugPrint('Quota loading failed: $e');

      if (mounted) {
        _showInfo(
          AppLocalizations.of(context)!.aiErrorFallback,
          Colors.orange,
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isQuotaLoading = false;
        });
      }
    }
  }

  Future<void> _checkPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await PurchaseService.login(user.uid);
    }

    bool isPremium = await PurchaseService.isUserPremium();
    // 🟢 Получаем дату окончания, если пользователь Premium
    String? expirationDate =
        isPremium ? await PurchaseService.getPremiumExpirationDate() : null;

    if (!mounted) return;

    setState(() {
      _isUserPremium = isPremium;
      _premiumExpirationDate = expirationDate; // Сохраняем дату в стейт
    });
  }

  Future<void> _openRecipe() async {
    if (_isOpeningRecipe || _isQuotaLoading) return;

    setState(() {
      _isOpeningRecipe = true;
    });

    try {
      // Проверяем свежий остаток перед каждой генерацией.
      final loaded = await _loadDailyGenerationsLimit();

      if (!mounted || !loaded) return;

      final l10n = AppLocalizations.of(context)!;
      final remaining = _maxDailyGenerations - _dailyGenerationsCount;

      if (remaining <= 0) {
        _showInfo(
          l10n.freeGenerations(0, _maxDailyGenerations),
          Colors.orange,
        );
        return;
      }

      if (!_groupAvailable) {
        _showInfo(l10n.aiErrorFallback, Colors.orange);
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeScreen(
            selectedIngredients: List<Ingredient>.from(_ingredients),
            portions: _portions,
            diet: _getDietName(_selectedDiet),
            savedRecipe: null,
          ),
        ),
      );

      // Обновляем остаток и после успеха, и после ошибки генерации.
      if (!mounted) return;
      await _loadDailyGenerationsLimit();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningRecipe = false;
        });
      }
    }
  }

  // ==========================================
  // ДАЛЬШЕ ИДУТ ТВОИ ДРУГИЕ ФУНКЦИИ (например, _loadFridgeData, _addIngredient и т.д.)

  Future<void> _loadFridgeData() async {
    final user = auth.currentUser;

    final l10n = AppLocalizations.of(context)!;

    // Если юзер вошел - пробуем облако
    if (user != null) {
      try {
        final doc = await db.collection('fridges').doc(user.uid).get();

        if (!mounted) return;

        if (doc.exists && doc.data() != null) {
          final List<dynamic> cloudList =
              doc.data()!['ingredients'] as List<dynamic>;
          // Было: cloudList.map((e) => Ingredient(name: e['name'], isUrgent: e['isUrgent']))
          // Станет:
          setState(() {
            _ingredients.clear();
            _ingredients.addAll(cloudList
                .map((e) => Ingredient.fromJson(e as Map<String, dynamic>)));
          });

          _showInfo(l10n.cloudDataLoaded, Colors.green);
          return;
        }
      } catch (e) {
        if (!mounted) return;
        _showInfo(l10n.offlineModeCloudError, Colors.red);
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
        _ingredients.addAll(decodedList
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>)));
      });

      // Синее/оранжевое информационное сообщение
      _showInfo(l10n.localDataLoaded, Colors.blue);
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
        duration:
            const Duration(seconds: 2), // Сообщение исчезнет через 2 секунды
      ),
    );
  }

  String _getDietName(String id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'regular':
        return l10n.dietRegular;
      case 'mediterranean':
        return l10n.dietMediterranean;
      case 'vegetarian':
        return l10n.dietVegetarian;
      default:
        return '';
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
      _ingredients.add(Ingredient(
        name: _controller.text.trim(),
        id: null, // Четкий сигнал: «это ручной ввод, перевода нет»
        expiryDate: _selectedExpiryDate,
      ));
      // ...
    });

    _saveFridgeData(); // Сохраняем в память и Firestore
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

  // Добавляем новый ингредиент через меню популярных продуктов
  void _addPopularProduct(PopularProduct product) {
    // 1. Получаем доступ к текущему переводчику
    final l10n = AppLocalizations.of(context)!;

    // 2. Получаем правильное имя продукта на текущем языке системы
    final translatedName = getPopularProductName(product.id, l10n);

    setState(() {
      _ingredients.add(Ingredient(
        name: translatedName, // Записываем красивый перевод как снимок
        id: product.id, // Сохраняем ID для динамической смены языка на лету
        expiryDate: _selectedExpiryDate,
      ));
      _selectedExpiryDate = null; // Сбрасываем выбранную дату
    });

    _saveFridgeData(); // Синхронизируем с Firestore и локальной памятью
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
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _inviteController.dispose();
    _controller
        .dispose(); // Всегда очищаем контроллеры для предотвращения утечек памяти
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFridgeData(); // Загружаем продукты из памяти смартфона
      _loadDailyGenerationsLimit();
      _checkPremiumStatus();
    });
  }

  // Temporary beta UI strings, grouped here so no generated localization
  // files need editing. Languages match the existing app: English, Russian, Spanish.
  String _inviteText(String key) {
    const messages = <String, List<String>>{
      'title': [
        'Join the closed beta',
        'Закрытое тестирование',
        'Únete a la beta cerrada'
      ],
      'intro': [
        'Enter the invitation code you received from the developer. Access will open automatically.',
        'Введи код приглашения от разработчика. Доступ откроется автоматически.',
        'Introduce el código que recibiste del desarrollador. El acceso se activará automáticamente.'
      ],
      'label': ['Invitation code', 'Код приглашения', 'Código de invitación'],
      'activate': ['Activate access', 'Активировать доступ', 'Activar acceso'],
      'retry': [
        'Check access again',
        'Проверить доступ ещё раз',
        'Comprobar acceso de nuevo'
      ],
      'disabled': [
        'Access has been disabled. Contact the developer.',
        'Доступ отключён. Свяжись с разработчиком.',
        'El acceso está desactivado. Contacta con el desarrollador.'
      ],
      'invalid': [
        'Check the invitation code.',
        'Проверь код приглашения.',
        'Revisa el código de invitación.'
      ],
      'unavailable': [
        'This code is invalid, expired or has no places left. Ask the developer for a new code.',
        'Код неверен, истёк или все места заняты. Попроси у разработчика новый код.',
        'El código no es válido, ha caducado o no quedan plazas. Pide otro código al desarrollador.'
      ],
      'rate': [
        'Too many attempts. Try again in 15 minutes.',
        'Слишком много попыток. Повтори через 15 минут.',
        'Demasiados intentos. Inténtalo en 15 minutos.'
      ],
      'network': [
        'Could not confirm access. Check your connection and try again; retrying will not use another place.',
        'Не удалось подтвердить доступ. Проверь интернет и повтори: повторная активация не расходует ещё одно место.',
        'No se pudo confirmar el acceso. Revisa tu conexión y vuelve a intentarlo; no se consumirá otra plaza.'
      ],
      'signin': [
        'Please sign in again.',
        'Войди в аккаунт заново.',
        'Vuelve a iniciar sesión.'
      ],
    };
    final language = Localizations.localeOf(context).languageCode;
    final index = language == 'ru'
        ? 1
        : language == 'es'
            ? 2
            : 0;
    return messages[key]![index];
  }

  Future<void> _activateInvitation() async {
    if (_isActivating || _isQuotaLoading) return;
    final code =
        _inviteController.text.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    if (!RegExp(r'^[A-F0-9]{32}$').hasMatch(code)) {
      setState(() => _inviteError = 'invalid');
      return;
    }
    setState(() {
      _isActivating = true;
      _inviteError = null;
    });
    final user = auth.currentUser;
    try {
      if (user == null) {
        setState(() => _inviteError = 'signin');
        return;
      }
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _inviteError = 'signin');
        return;
      }
      final response = await http
          .post(
            Uri.parse('$_apiBase/activate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode({'code': code}),
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted || auth.currentUser?.uid != user.uid) return;
      if (response.statusCode == 200) {
        final loaded = await _loadDailyGenerationsLimit();
        if (!mounted || auth.currentUser?.uid != user.uid) return;
        if (loaded) {
          _inviteController.clear();
        } else {
          setState(() => _inviteError = 'network');
        }
        return;
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final error = data is Map ? data['error'] : null;
      setState(() {
        if (error == 'TESTER_DISABLED') {
          _testerDisabled = true;
          _needsInvitation = false;
          _inviteError = null;
        } else if (error == 'INVITE_UNAVAILABLE') {
          _inviteError = 'unavailable';
        } else if (error == 'INVITE_INVALID') {
          _inviteError = 'invalid';
        } else if (error == 'INVITE_RATE_LIMITED') {
          _inviteError = 'rate';
        } else if (response.statusCode == 401) {
          _inviteError = 'signin';
        } else {
          _inviteError = 'network';
        }
      });
    } catch (_) {
      if (mounted && auth.currentUser?.uid == user?.uid) {
        setState(() => _inviteError = 'network');
      }
    } finally {
      if (mounted) setState(() => _isActivating = false);
    }
  }

  Widget _buildInvitationScreen() {
    final busy = _isActivating || _isQuotaLoading;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const Icon(Icons.vpn_key_outlined, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          Text(_inviteText('title'),
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(_inviteText(_testerDisabled ? 'disabled' : 'intro'),
              textAlign: TextAlign.center),
          if (!_testerDisabled) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _inviteController,
              enabled: !busy,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              maxLength: 64,
              decoration: InputDecoration(
                  labelText: _inviteText('label'),
                  border: const OutlineInputBorder()),
              onSubmitted: (_) {
                if (!busy) _activateInvitation();
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: busy ? null : _activateInvitation,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16)),
              child: _isActivating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_inviteText('activate'), textAlign: TextAlign.center),
            ),
          ],
          if (_inviteError != null) ...[
            const SizedBox(height: 16),
            Text(_inviteText(_inviteError!),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700)),
          ],
          const SizedBox(height: 12),
          TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      await _loadDailyGenerationsLimit();
                    },
              child: Text(_inviteText('retry'), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildFridgeBody() {
    if (_needsInvitation || _testerDisabled) return _buildInvitationScreen();
    final l10n = AppLocalizations.of(context)!;

    // SafeArea keeps the action above Android's system navigation bar.
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
          final useScrollableFooter =
              keyboardOpen || constraints.maxHeight < 320;
          final footer = _buildGenerationActions();
          final content = ListView(
            key: const PageStorageKey<String>('fridge-content'),
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            color: _selectedExpiryDate != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () => _selectExpiryDate(
                              context), // Вызываем наш календарь!
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
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
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
                      label: Text(
                          getPopularProductName(_popularProducts[i].id, l10n)),
                      onPressed: () => _addPopularProduct(_popularProducts[i]),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Выбор диеты с переносом на следующую строку
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.dietTypeTitle,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final dietId in _dietIds)
                    ChoiceChip(
                      label: Text(_getDietName(dietId)),
                      selected: _selectedDiet == dietId,
                      selectedColor: Colors.green.shade200,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDiet = dietId);
                        }
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Список добавленных продуктов
              _ingredients.isEmpty
                  ? Center(child: Text(l10n.emptyFridge))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        final item = _ingredients[index];

                        // Рассчитываем три статуса продукта:
                        final bool isExpired =
                            isProductExpired(item.expiryDate);
                        final bool isExpiringSoon =
                            isProductExpiringSoon(item.expiryDate);
                        final bool isRedStatus =
                            item.isUrgent || isExpiringSoon;

                        // Настраиваем цвета в зависимости от статуса
                        Color cardColor = Colors.white;
                        Color contentColor = Colors.black87;
                        IconData leadingIcon = Icons.check_circle_outline;
                        Color iconColor = Colors.grey;

                        if (isExpired) {
                          cardColor = Colors.grey
                              .shade300; // Мертвый серый цвет для просрочки
                          contentColor =
                              Colors.red.shade900; // Тревожный красный текст
                          leadingIcon = Icons.dangerous; // Иконка "Опасно" 💀
                          iconColor = Colors.red.shade900;
                        } else if (isRedStatus) {
                          cardColor = Colors
                              .red.shade50; // Пастельно-красный для срочного
                          contentColor = Colors.red.shade900;
                          leadingIcon = Icons
                              .warning_amber_rounded; // Треугольник предупреждения ⚠️
                          iconColor = Colors.red;
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 4.0),
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            leading: IconButton(
                              icon: Icon(leadingIcon, color: iconColor),
                              onPressed: isExpired
                                  ? null
                                  : () => _toggleUrgent(
                                      index), // Просроченные продукты нельзя "разжаловать" из срочных!
                            ),
                            title: Text(
                              item.id != null
                                  ? getPopularProductName(
                                      item.id!, l10n) // Переводим на лету!
                                  : item
                                      .name, // Показываем ручной ввод как есть
                              style: TextStyle(
                                fontWeight: (isExpired || isRedStatus)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: contentColor,
                              ),
                            ),
                            subtitle: item.expiryDate != null
                                ? Text(
                                    isExpired
                                        ? _getExpiredDaysText(item.expiryDate)
                                        : l10n.bestBefore(formatDate(item
                                            .expiryDate)), // 🟢 Динамический перевод с датой!
                                    style: TextStyle(
                                      color: isExpired
                                          ? Colors.red.shade900
                                          : Colors.black54,
                                      fontWeight: isExpired
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.grey),
                              onPressed: () => _removeIngredient(index),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 16),
              // Блок настройки порций
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          l10n.portionsTitle,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.green),
                          onPressed:
                              _decreasePortions, // Теперь функция используется!
                        ),
                        Text(
                          '$_portions',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.green),
                          onPressed:
                              _increasePortions, // Теперь функция используется!
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isUserPremium && _premiumExpirationDate != null)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 12.0), // Отступ от надписи до кнопки
                  child: Center(
                    child: Text(
                      l10n.premiumActiveUntil(_premiumExpirationDate!),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.amber, // Золотой Premium акцент
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              if (useScrollableFooter) footer,
            ],
          );

          if (useScrollableFooter) return content;

          return Column(
            children: [
              Expanded(child: content),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: footer,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGenerationActions() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _quotaReady
              ? l10n.freeGenerations(
                  _maxDailyGenerations - _dailyGenerationsCount,
                  _maxDailyGenerations,
                )
              : '—',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _quotaReady && _dailyGenerationsCount >= _maxDailyGenerations
                ? Colors.red.shade700
                : Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: 52,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed:
                (_isQuotaLoading || _isOpeningRecipe) ? null : _openRecipe,
            child: (_isQuotaLoading || _isOpeningRecipe)
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(l10n.generateButton, textAlign: TextAlign.center),
          ),
        ),
      ],
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
                text: AppLocalizations.of(context)!
                    .fridgeTab, // вместо 'Холодильник'
              ),
              Tab(
                icon: const Icon(Icons.favorite),
                text: AppLocalizations.of(context)!
                    .favoritesTab, // вместо 'Избранное'
              ),
              Tab(
                icon: const Icon(Icons.person),
                text: AppLocalizations.of(context)!
                    .profileTab, // вместо 'Профиль'
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
