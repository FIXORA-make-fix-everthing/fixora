import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/ambient_button.dart';

class ShopkeeperHome extends StatefulWidget {
  const ShopkeeperHome({super.key});

  @override
  State<ShopkeeperHome> createState() => _ShopkeeperHomeState();
}

class _ShopkeeperHomeState extends State<ShopkeeperHome> {
  int _currentIndex = 0;

  IconData _getIconData(String name) {
    switch (name) {
      case 'water_drop': return Icons.water_drop;
      case 'car_repair': return Icons.car_repair;
      case 'plumbing': return Icons.plumbing;
      case 'propane': return Icons.propane;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'kitchen': return Icons.kitchen;
      default: return Icons.inventory_2;
    }
  }

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

  void _showAddProductDialog() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isShopProfileComplete) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.silverSurface,
          title: const Text('Profile Incomplete', style: TextStyle(color: Colors.white)),
          content: const Text('You must complete your shop details before you can sell products.', style: TextStyle(color: AppColors.silverPrimary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppColors.ambientNeon)),
            ),
          ],
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.silverSurface,
            title: const Text('Add New Product', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: const TextStyle(color: AppColors.silverPrimary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: const TextStyle(color: AppColors.silverPrimary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Category (e.g. Auto/Home)',
                      labelStyle: const TextStyle(color: AppColors.silverPrimary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.silverPrimary)),
              ),
              AmbientButton(
                text: 'ADD',
                isLoading: isSaving,
                onPressed: () {
                  final name = nameController.text.trim();
                  final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                  final category = categoryController.text.trim().isEmpty ? 'Other' : categoryController.text.trim();

                  if (name.isEmpty || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid name and price'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }

                  final appState = Provider.of<AppState>(context, listen: false);
                  
                  final newProduct = Product(
                    id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    price: price,
                    iconName: 'storefront',
                    shopkeeperId: appState.currentUserEmail ?? 'shop',
                    category: category,
                  );

                  appState.addProduct(newProduct);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name added to shop!'), backgroundColor: Colors.green),
                  );
                },
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, AppState appState, Product product) {
    final TextEditingController priceController = TextEditingController(text: product.price.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.silverSurface,
        title: Text('Edit Price: ${product.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Price',
            labelStyle: TextStyle(color: AppColors.silverPrimary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.silverPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ambientNeon.withValues(alpha: 0.2),
              foregroundColor: AppColors.ambientNeon,
              elevation: 8,
              shadowColor: AppColors.ambientNeon.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newPrice = double.tryParse(priceController.text.trim());
              if (newPrice != null && newPrice > 0) {
                appState.updateProductPrice(product.id, newPrice);
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showEditShopDialog(AppState appState) {
    final TextEditingController nameController = TextEditingController(text: appState.shopName);
    final TextEditingController locationController = TextEditingController(text: appState.shopLocation);
    final TextEditingController descController = TextEditingController(text: appState.shopDescription);
    final TextEditingController licenseController = TextEditingController(text: appState.shopLicenseNumber);
    final TextEditingController accountController = TextEditingController(text: appState.bankAccountNumber);

    showDialog(
      context: context,
      builder: (context) {
        XFile? pickedShopPhoto;
        XFile? pickedLicensePhoto;
        final ImagePicker picker = ImagePicker();

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.silverSurface,
            title: const Text('Edit Shop Details', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    try {
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() {
                          pickedShopPhoto = image;
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open gallery: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Stack(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF151515),
                          border: Border.all(color: AppColors.ambientNeon, width: 1.5),
                          image: pickedShopPhoto != null 
                            ? DecorationImage(image: FileImage(File(pickedShopPhoto!.path)), fit: BoxFit.cover)
                            : null,
                        ),
                        child: pickedShopPhoto == null 
                          ? const Icon(Icons.storefront, color: AppColors.silverPrimary, size: 40)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.ambientNeon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Shop Name', labelStyle: TextStyle(color: AppColors.silverPrimary), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: AppColors.silverPrimary), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: AppColors.silverPrimary), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon))),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shop License / Aadhar Photo', style: TextStyle(color: AppColors.silverPrimary, fontSize: 12)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      try {
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() {
                            pickedLicensePhoto = image;
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open gallery: $e'), backgroundColor: Colors.red));
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 120, // Taller to fit image
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: pickedLicensePhoto != null ? Colors.green : Colors.white10),
                        image: pickedLicensePhoto != null
                            ? DecorationImage(image: FileImage(File(pickedLicensePhoto!.path)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: pickedLicensePhoto == null 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo_outlined, color: AppColors.ambientNeon, size: 24),
                              SizedBox(width: 12),
                              Text('Upload Document Photo', style: TextStyle(color: AppColors.ambientNeon, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Bank Account Number', labelStyle: TextStyle(color: AppColors.silverPrimary), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.silverPrimary)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ambientNeon))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.silverPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ambientNeon.withValues(alpha: 0.2), foregroundColor: AppColors.ambientNeon),
            onPressed: () {
              appState.updateShopProfile(
                nameController.text.trim(), 
                locationController.text.trim(), 
                descController.text.trim(),
                licenseController.text.trim(),
                accountController.text.trim()
              );
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
      );
    }
    );
  }

  Widget _buildOrdersTab(BuildContext context, AppState appState, List<ShopOrder> pendingOrders) {
    return SafeArea(
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
                      padding: const EdgeInsets.only(bottom: 100), // Space for floating footer
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
    );
  }

  Widget _buildMyProductsTab(BuildContext context, AppState appState) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Our Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: AppColors.ambientNeon, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: appState.marketplaceProducts.isEmpty
                  ? const Center(
                      child: Text('No products available.', style: TextStyle(color: AppColors.silverPrimary)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 120), // Space for floating footer
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.55,
                      ),
                      itemCount: appState.marketplaceProducts.length,
                      itemBuilder: (context, index) {
                        final product = appState.marketplaceProducts[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.silverSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand & Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.silverPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('PREMIUM', style: TextStyle(color: AppColors.silverPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 14),
                                      SizedBox(width: 4),
                                      Text('4.8', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                              const Spacer(),
                              // Icon
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [AppColors.silverPrimary.withValues(alpha: 0.2), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  ),
                                  child: Icon(_getIconData(product.iconName), size: 40, color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(appState.formatPrice(product.price), style: const TextStyle(color: AppColors.ambientNeon, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.silverPrimary,
                                        side: const BorderSide(color: AppColors.silverPrimary),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () => _showEditPriceDialog(context, appState, product),
                                      child: const Icon(Icons.edit, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () => appState.removeProduct(product.id),
                                      child: const Icon(Icons.delete_outline, size: 18),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(AppState appState) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Top Section: Avatar, Name, Location
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.silverSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ambientNeon, width: 2),
                      boxShadow: [BoxShadow(color: AppColors.ambientNeon.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.silverSurface,
                      child: Icon(Icons.storefront, size: 50, color: AppColors.ambientNeon),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appState.shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: AppColors.ambientNeon, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.silverPrimary, size: 16),
                      const SizedBox(width: 8),
                      Text(appState.shopLocation, style: const TextStyle(color: AppColors.silverPrimary, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appState.shopDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.silverPrimary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: AppColors.ambientNeon.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.silverSurface,
                        foregroundColor: AppColors.ambientNeon,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.ambientNeon, width: 1.5),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () => _showEditShopDialog(appState),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Analytics Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Shop Performance',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.star, 'Rating', '4.8', Colors.amber)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.inventory_2, 'Products', '${appState.marketplaceProducts.length}', AppColors.ambientNeon)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.check_circle, 'Fulfilled', '128', Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.account_balance_wallet, 'Revenue', appState.formatPrice(appState.shopRevenue), Colors.purpleAccent)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.silverSurface,
                  foregroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.greenAccent, width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.account_balance),
                label: const Text('Transfer Money to Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (appState.shopRevenue <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No funds available to transfer.'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }
                  if (appState.bankAccountNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please add your Bank Account Number in Edit Details first.'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }
                  final amount = appState.shopRevenue;
                  appState.withdrawFunds(amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${appState.formatPrice(amount)} transferred to Account ending in ${appState.bankAccountNumber.length >= 4 ? appState.bankAccountNumber.substring(appState.bankAccountNumber.length - 4) : appState.bankAccountNumber}'), backgroundColor: Colors.green),
                  );
                },
              ),
            ),
            const SizedBox(height: 120), // Bottom padding for floating footer
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.silverSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.silverPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ambientNeon.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.ambientNeon : AppColors.silverPrimary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: AppColors.ambientNeon, fontWeight: FontWeight.bold),
              )
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingOrders = appState.shopOrders.where((o) => !o.isCollected).toList();

    String getAppBarTitle() {
      switch (_currentIndex) {
        case 0: return 'Incoming Orders';
        case 1: return 'Our Products';
        case 2: return 'Shop Profile';
        default: return 'Shopkeeper';
      }
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.silverBackground,
      appBar: AppBar(
        backgroundColor: AppColors.silverBackground,
        elevation: 0,
        title: Text(getAppBarTitle(), style: const TextStyle(color: AppColors.silverPrimary)),
        iconTheme: const IconThemeData(color: AppColors.silverPrimary),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildOrdersTab(context, appState, pendingOrders),
          _buildMyProductsTab(context, appState),
          _buildProfileTab(appState),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.silverSurface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.list_alt, 0, 'Orders'),
              _buildNavItem(Icons.inventory_2, 1, 'Products'),
              _buildNavItem(Icons.person, 2, 'Profile'),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.black, size: 28),
                  onPressed: _showAddProductDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
