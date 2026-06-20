import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/ambient_button.dart';

class ShopkeeperHome extends StatefulWidget {
  const ShopkeeperHome({super.key});

  @override
  State<ShopkeeperHome> createState() => _ShopkeeperHomeState();
}

class _ShopkeeperHomeState extends State<ShopkeeperHome> {
  void _openFulfillDialog(ShopOrder order) {
    final TextEditingController codeController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.silverSurface,
            title: const Text('Fulfill Order', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the 6-digit code provided by the technician for ${order.product.name} (x${order.quantity}).',
                  style: const TextStyle(color: AppColors.silverPrimary),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: codeController,
                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'e.g. TX-123456',
                    hintStyle: TextStyle(color: AppColors.silverPrimary.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: AppColors.silverBackground,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.silverPrimary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.ambientNeon),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isVerifying ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.silverPrimary)),
              ),
              AmbientButton(
                text: 'VERIFY',
                isLoading: isVerifying,
                onPressed: () {
                  final enteredCode = codeController.text.trim();
                  if (enteredCode.isEmpty) return;

                  final appState = Provider.of<AppState>(context, listen: false);
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  setStateDialog(() => isVerifying = true);

                  Future.delayed(const Duration(seconds: 1), () {
                    if (!mounted) return;
                    setStateDialog(() => isVerifying = false);

                    if (enteredCode == order.collectionCode) {
                      appState.verifyShopOrder(enteredCode);
                      navigator.pop();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Order Fulfilled Successfully!'), backgroundColor: Colors.green),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Invalid code!'), backgroundColor: Colors.redAccent),
                      );
                    }
                  });
                },
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingOrders = appState.shopOrders.where((o) => !o.isCollected).toList();

    return Scaffold(
      backgroundColor: AppColors.silverBackground,
      appBar: AppBar(
        backgroundColor: AppColors.silverBackground,
        elevation: 0,
        title: const Text('Incoming Orders', style: TextStyle(color: AppColors.silverPrimary)),
        iconTheme: const IconThemeData(color: AppColors.silverPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Order Feed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: AppColors.ambientNeon, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: pendingOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront, size: 80, color: AppColors.silverPrimary.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            const Text('No incoming orders yet.', style: TextStyle(color: AppColors.silverPrimary, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: pendingOrders.length,
                        itemBuilder: (context, index) {
                          final order = pendingOrders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.silverSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.silverPrimary.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Order ID: ${order.orderId}', style: const TextStyle(color: AppColors.silverPrimary, fontSize: 12)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.ambientNeon.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('NEW', style: TextStyle(color: AppColors.ambientNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  order.product.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Quantity: ${order.quantity}',
                                  style: const TextStyle(color: AppColors.silverPrimary, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      appState.formatPrice(order.product.price * order.quantity),
                                      style: const TextStyle(color: AppColors.ambientNeon, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.ambientNeon.withValues(alpha: 0.2),
                                        foregroundColor: AppColors.ambientNeon,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _openFulfillDialog(order),
                                      child: const Text('FULFILL'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
