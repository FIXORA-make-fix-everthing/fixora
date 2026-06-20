import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/ambient_button.dart';

class CartCheckoutScreen extends StatefulWidget {
  final Product product;

  const CartCheckoutScreen({super.key, required this.product});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  int quantity = 1;
  bool isOrdering = false;

  void _placeOrder() {
    setState(() {
      isOrdering = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final appState = Provider.of<AppState>(context, listen: false);
      final code = appState.placeShopOrder(widget.product, quantity);

      setState(() {
        isOrdering = false;
      });

      _showCodeDialog(code);
    });
  }

  void _showCodeDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.silverSurface,
        title: const Text('Order Placed!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Show this code to the shopkeeper to collect your items.',
              style: TextStyle(color: AppColors.silverPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.silverBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ambientNeon),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  color: AppColors.ambientNeon,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return to marketplace
            },
            child: const Text('Done', style: TextStyle(color: AppColors.ambientNeon)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final totalPrice = widget.product.price * quantity;

    return Scaffold(
      backgroundColor: AppColors.silverBackground,
      appBar: AppBar(
        backgroundColor: AppColors.silverBackground,
        elevation: 0,
        title: const Text('Checkout', style: TextStyle(color: AppColors.silverPrimary)),
        iconTheme: const IconThemeData(color: AppColors.silverPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.silverSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.formatPrice(widget.product.price),
                          style: const TextStyle(
                            color: AppColors.ambientNeon,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.silverPrimary),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => quantity++);
                              },
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.silverPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.silverSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppColors.silverPrimary, fontSize: 16)),
                    Text(
                      appState.formatPrice(totalPrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: AppColors.ambientNeon, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              AmbientButton(
                text: 'PLACE ORDER',
                onPressed: _placeOrder,
                isLoading: isOrdering,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
