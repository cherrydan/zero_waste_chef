import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Кнопка закрытия экрана, чтобы пользователь мог вернуться назад
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Верхняя часть: Иконка Premium, Заголовок и Подзаголовок
              Column(
                children: [
                  const SizedBox(height: 10),
                  // Золотая иконка Premium
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 56,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Заголовок
                  Text(
                    l10n.paywallTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Подзаголовок
                  Text(
                    l10n.paywallSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              // Средняя часть: Список преимуществ (Features List)
              Column(
                children: [
                  _buildFeatureRow(l10n.featureUnlimited),
                  _buildFeatureRow(l10n.featureFamily),
                  _buildFeatureRow(l10n.featureSupport),
                ],
              ),

              // Нижняя часть: Карточка с ценой, Кнопка купить и Восстановить покупки
              Column(
                children: [
                  // Красивая рамка с ценой
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Text(
                      l10n.premiumPrice,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Кнопка покупки
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.green.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // Здесь в будущем будет вызов покупки RevenueCat
                      },
                      child: Text(
                        l10n.subscribeButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Кнопка восстановления покупок
                  TextButton(
                    onPressed: () {
                      // Здесь в будущем будет восстановление покупок
                    },
                    child: Text(
                      l10n.restorePurchases,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для красивой строки преимуществ
  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}