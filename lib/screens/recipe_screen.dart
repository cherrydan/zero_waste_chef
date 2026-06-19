import 'package:flutter/material.dart';
import 'fridge_screen.dart'; // Чтобы видеть модель Ingredient

class RecipeScreen extends StatelessWidget {
  final List<Ingredient> selectedIngredients;

  const RecipeScreen({super.key, required this.selectedIngredients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Идея меню 🧑‍🍳'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Вы выбрали продукты:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Выводим список переданных продуктов
            Text(selectedIngredients.map((e) => e.name).join(', ')),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Крутилка, имитирующая загрузку AI
          ],
        ),
      ),
    );
  }
}
