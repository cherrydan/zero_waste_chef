import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_waste_chef/screens/fridge_screen.dart';

void main() {
  // Настраиваем фейковую локальную память
  SharedPreferences.setMockInitialValues({});

  group('Fridge Screen UI Tests', () {
    
    testWidgets('Должен добавлять продукт в список при вводе и нажатии кнопки +', (WidgetTester tester) async {
      // НАСТРОЙКА ЭКРАНА: Задаем идеальный размер экрана (Ширина 400, Высота 800)
      // Это стандартный размер смартфона, где ничего не будет вылезать за границы!
      await tester.binding.setSurfaceSize(const Size(400, 800));

      // 1. Arrange: Создаем фейковый Firebase в памяти
      final mockUser = MockUser(
        uid: 'test_user_123',
        email: 'test@example.com',
      );
      final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      final mockFirestore = FakeFirebaseFirestore();

      // Отрисовываем наш экран с фейковыми зависимостями
      await tester.pumpWidget(MaterialApp(
        home: FridgeScreen(
          firestore: mockFirestore,
          auth: mockAuth,
        ),
      ));

      // 2. Act: Вводим текст и кликаем на "+"
      await tester.enterText(find.byType(TextField), 'Молоко');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // Ждем перерисовки экрана

      // 3. Assert: Проверяем, что продукт появился в UI
      expect(find.text('Молоко'), findsOneWidget);
    });

  });
}
