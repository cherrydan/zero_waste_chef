import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // 🟢 Импорт для работы с Package
import '../services/purchase_service.dart'; // 🟢 Наш сервис покупок
import '../l10n/app_localizations.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Package? _package; // Переменная для хранения загруженного пакета подписки

  @override
  void initState() {
    super.initState();
    _loadOffering(); // 🟢 Загружаем наше предложение при старте экрана
  }

  Future<void> _loadOffering() async {
    final offering = await PurchaseService.getMonthlyOffering();
    if (offering != null && mounted) {
      setState(() {
        _package = offering.monthly; // Получаем наш месячный пакет ($rc_monthly)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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

              // Средняя часть: Список преимуществ
              Column(
                children: [
                  _buildFeatureRow(l10n.featureUnlimited),
                  _buildFeatureRow(l10n.featureFamily),
                  _buildFeatureRow(l10n.featureSupport),
                ],
              ),

              // Нижняя часть: Динамическая цена, Кнопка купить и Восстановить покупки
              Column(
                children: [
                  // 🟢 Динамическая цена из магазина (или '...' пока грузится)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Text(
                      _package?.storeProduct.priceString ?? '...', 
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
                    // Кнопка неактивна, пока пакет загружается из сети
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
                                                onPressed: _package == null 
                          ? null 
                          : () async {
                              // 1. Запускаем покупку пакета
                              final success = await PurchaseService.purchasePackage(_package!);
                              
                              // 2. Проверяем mounted у BuildContext, чтобы линтер спал спокойно
                              if (!context.mounted) return;

                              // 3. Обрабатываем результат
                              if (success) {
                                Navigator.of(context).pop(); // Успех — закрываем экран оплаты
                              } else {
                                // 🟢 Не улетели — показываем локализованную ошибку
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.paymentFailed),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
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

                  TextButton(
                    onPressed: () {
                      // Восстановление покупок
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