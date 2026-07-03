import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_waste_chef/screens/fridge_screen.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  group('Fridge Screen UI Tests', () {
    
    testWidgets('Должен добавлять продукт в список при вводе и нажатии кнопки +', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      final mockUser = MockUser(
        uid: 'test_user_123',
        email: 'test@example.com',
      );
      final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: FridgeScreen(
          firestore: mockFirestore,
          auth: mockAuth,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Молоко');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Молоко'), findsOneWidget);
    });

    testWidgets('Должен автоматически помечать продукт как срочный, если срок годности истекает завтра', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      final mockUser = MockUser(uid: 'test_user_123');
      final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      final mockFirestore = FakeFirebaseFirestore();

      // Arrange: Создаем продукт, который портится ЗАВТРА
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      await mockFirestore.collection('fridges').doc('test_user_123').set({
        'ingredients': [
          {
            'name': 'Испорченное Молоко',
            'isUrgent': false, 
            'expiryDate': tomorrow.toIso8601String(), 
          }
        ]
      });

      // Act: Отрисовываем экран
      await tester.pumpWidget(MaterialApp(
        home: FridgeScreen(
          firestore: mockFirestore,
          auth: mockAuth,
        ),
      ));
      
      // Ждем завершения загрузки данных
      await tester.pumpAndSettle(); 

      // Assert: Проверяем твою строчку!
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

  });
}
