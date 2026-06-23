import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import 'cart_checkout_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final Color darkBackground = const Color(0xFF0F0F0F);
  final Color darkSurface = const Color(0xFF141414);
  String _selectedCategory = 'All';


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.marketplaceProducts;
    
    final bool isCustomer = appState.currentRole == UserRole.customer;
    final Color themeColor = isCustomer ? const Color(0xFFFF5A00) : const Color(0xFFC5A059);

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(themeColor),
              const SizedBox(height: 24),
              _buildCategorySection(themeColor),
              const SizedBox(height: 24),
              _buildPopularPartsSection(products, appState, themeColor),
              const SizedBox(height: 24),
              _buildBottomFeaturesRow(themeColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(Color themeColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: darkSurface,
        border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: themeColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'FIXORA',
                      style: GoogleFonts.outfit(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VERIFIED',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            'Buy Genuine',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
          ),
          Text(
            'Spares for Your',
            style: GoogleFonts.outfit(color: themeColor, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
          ),
          Text(
            'Vehicle',
            style: GoogleFonts.outfit(color: themeColor, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
          ),
          const SizedBox(height: 12),
          Text(
            'Best Quality • Best Price • Fast Delivery',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          // 3 Icons
          Row(
            children: [
              _buildBannerFeature(Icons.verified_outlined, '100% Genuine\nParts', themeColor),
              const SizedBox(width: 24),
              _buildBannerFeature(Icons.local_shipping_outlined, 'Fast & Safe\nDelivery', themeColor),
              const SizedBox(width: 24),
              _buildBannerFeature(Icons.engineering_outlined, 'Technician\nVerified', themeColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerFeature(IconData icon, String label, Color themeColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeColor.withValues(alpha: 0.1),
            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: themeColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCategorySection(Color themeColor) {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view},
      {'name': 'Engine Oil', 'icon': Icons.water_drop},
      {'name': 'Brake Parts', 'icon': Icons.stop_circle_outlined},
      {'name': 'Tyres', 'icon': Icons.tire_repair},
      {'name': 'Battery', 'icon': Icons.battery_charging_full},
      {'name': 'Filters', 'icon': Icons.filter_alt_outlined},
      {'name': 'Lights', 'icon': Icons.lightbulb_outline},
      {'name': 'Tools', 'icon': Icons.build},
      {'name': 'Bike Spares', 'icon': Icons.two_wheeler},
      {'name': 'Car Spares', 'icon': Icons.directions_car},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  Text('View All', style: GoogleFonts.outfit(fontSize: 12, color: themeColor, fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_forward, size: 14, color: themeColor),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryName = categories[index]['name'] as String;
              final isSelected = _selectedCategory == categoryName;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = categoryName;
                  });
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor.withValues(alpha: 0.2) : darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? themeColor : themeColor.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categories[index]['icon'] as IconData, color: isSelected ? themeColor : Colors.white70, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        categoryName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? themeColor : Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularPartsSection(List<Product> products, AppState appState, Color themeColor) {
    List<Product> displayedProducts = products;
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'Engine Oil') {
        displayedProducts = products.where((p) => p.name.toLowerCase().contains('oil') || p.iconName == 'water_drop').toList();
      } else if (_selectedCategory == 'Brake Parts') {
        displayedProducts = products.where((p) => p.name.toLowerCase().contains('brake') || p.iconName == 'car_repair').toList();
      } else if (_selectedCategory == 'Battery') {
        displayedProducts = products.where((p) => p.iconName == 'battery_charging_full').toList();
      } else if (_selectedCategory == 'Tools') {
        displayedProducts = products.where((p) => p.iconName == 'build').toList();
      } else if (_selectedCategory == 'Bike Spares' || _selectedCategory == 'Car Spares') {
        displayedProducts = products.where((p) => p.category == 'Auto').toList();
      } else {
        displayedProducts = []; 
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Parts',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  Text('See All', style: GoogleFonts.outfit(fontSize: 12, color: themeColor, fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_forward, size: 14, color: themeColor),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayedProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(displayedProducts[index], appState, themeColor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product, AppState appState, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Icon area
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForProduct(product.iconName),
                      size: 40,
                      color: themeColor,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: themeColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, color: themeColor, size: 8),
                        const SizedBox(width: 2),
                        Text(
                          'FIXORA VERIFIED',
                          style: GoogleFonts.outfit(color: themeColor, fontSize: 6, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.favorite_border, color: Colors.white38, size: 16),
                ),
              ],
            ),
          ),
          // Details area
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.category} Part',
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '4.7 (96)',
                      style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  appState.formatPrice(product.price),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: themeColor),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartCheckoutScreen(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor.withValues(alpha: 0.15),
                      foregroundColor: themeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: themeColor.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text('Add to Cart', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFeaturesRow(Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildBottomFeatureItem(Icons.verified_outlined, '100% Genuine Parts', 'Original parts with brand warranty', themeColor)),
              Expanded(child: _buildBottomFeatureItem(Icons.local_shipping_outlined, 'Fast Delivery', 'Quick delivery to your doorstep', themeColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBottomFeatureItem(Icons.inventory_2_outlined, 'Easy Returns', '7 days easy return policy', themeColor)),
              Expanded(child: _buildBottomFeatureItem(Icons.support_agent_outlined, 'Expert Support', 'Support from auto experts', themeColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFeatureItem(IconData icon, String title, String subtitle, Color themeColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: themeColor, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.outfit(fontSize: 9, color: Colors.white54)),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForProduct(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'car_repair':
        return Icons.car_repair;
      case 'plumbing':
        return Icons.plumbing;
      case 'propane':
        return Icons.propane;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'kitchen':
        return Icons.kitchen;
      default:
        return Icons.build;
    }
  }
}
