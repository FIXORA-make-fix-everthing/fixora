import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final technicianId = appState.currentUserEmail ?? 'tech_1';
    final myOrders = appState.shopOrders.where((o) => o.technicianId == technicianId).toList();

    return Scaffold(
      backgroundColor: AppColors.silverBackground,
      appBar: AppBar(
        backgroundColor: AppColors.silverBackground,
        elevation: 0,
        title: Text('My Orders', style: GoogleFonts.outfit(color: AppColors.silverPrimary)),
        iconTheme: const IconThemeData(color: AppColors.silverPrimary),
      ),
      body: SafeArea(
        child: myOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.silverPrimary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No Orders Yet',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: AppColors.silverPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: myOrders.length,
                itemBuilder: (context, index) {
                  final order = myOrders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.silverSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: order.isCollected
                            ? Colors.green.withValues(alpha: 0.3)
                            : AppColors.ambientNeon.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderId,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.isCollected
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : AppColors.ambientNeon.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.isCollected ? 'COLLECTED' : 'PENDING',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: order.isCollected ? Colors.green : AppColors.ambientNeon,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          order.product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Qty: ${order.quantity}',
                              style: GoogleFonts.outfit(color: Colors.white70),
                            ),
                            Text(
                              appState.formatPrice(order.product.price * order.quantity),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.silverPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (!order.isCollected) ...[
                          const Divider(color: Colors.white10, height: 24),
                          const SizedBox(height: 12),
                          _CollectionCodeView(collectionCode: order.collectionCode),
                        ]
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CollectionCodeView extends StatefulWidget {
  final String collectionCode;
  const _CollectionCodeView({required this.collectionCode});

  @override
  State<_CollectionCodeView> createState() => _CollectionCodeViewState();
}

class _CollectionCodeViewState extends State<_CollectionCodeView> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCode = !_showCode;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Collection Code:',
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
          _showCode
              ? Text(
                  widget.collectionCode,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.ambientNeon,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.ambientNeon.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TAP TO SHOW',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ambientNeon,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

