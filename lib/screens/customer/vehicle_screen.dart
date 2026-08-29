import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'problem_description_screen.dart';

class VehicleItem {
  final String name;
  final String imagePath;

  VehicleItem(this.name, this.imagePath);
}

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  int _selectedIndex = -1;

  final List<VehicleItem> vehicles = [
    VehicleItem('Bus', 'assets/images/vehicles/bus_3d.png'),
    VehicleItem('Car', 'assets/images/vehicles/car_3d.png'),
    VehicleItem('Scooter', 'assets/images/vehicles/scooter_3d.png'),
    VehicleItem('Motor cycle', 'assets/images/vehicles/motorcycle_3d.png'),
    VehicleItem('Van', 'assets/images/vehicles/van_3d.png'),
    VehicleItem('Bicycle', 'assets/images/vehicles/bicycle_3d.png'),
    VehicleItem('Tractor', 'assets/images/vehicles/tractor_3d.png'),
    VehicleItem('Jeep', 'assets/images/vehicles/jeep_3d.png'),
    VehicleItem('Truck', 'assets/images/vehicles/truck_3d.png'),
    VehicleItem('Auto', 'assets/images/vehicles/auto_rickshaw_3d.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(Icons.directions_car_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'Vehicle',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1, // slightly taller than wide
                ),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final item = vehicles[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF39FF14).withValues(alpha: 0.1) // Transparent electric green
                            : const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF39FF14) // Electric green border
                              : const Color(0xFFFF5A00).withValues(alpha: 0.1), // Orange subtle border
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: const Color(0xFF39FF14).withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          else
                            BoxShadow(
                              color: const Color(0xFFFF5A00).withValues(alpha: 0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            color: isSelected ? const Color(0xFF39FF14) : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedIndex != -1) {
                      // Navigate to BookServiceScreen with an Auto category
                      final appState = Provider.of<AppState>(context, listen: false);
                      final targetCat = appState.categories.firstWhere(
                        (cat) => !cat.isHome, // Get a vehicle category
                        orElse: () => appState.categories.isNotEmpty ? appState.categories.last : ServiceCategory(id: 'dummy', name: 'Auto Services', iconName: 'directions_car', description: 'Auto Care', isHome: false, items: []),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProblemDescriptionScreen(category: targetCat),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A00).withValues(alpha: 0.15),
                    side: const BorderSide(color: Color(0xFFFF5A00), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF5A00),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
