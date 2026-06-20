import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'add_own_service_screen.dart';
import 'problem_description_screen.dart';

class OtherItem {
  final String name;
  final IconData icon;

  OtherItem(this.name, this.icon);
}

class OthersScreen extends StatefulWidget {
  const OthersScreen({super.key});

  @override
  State<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends State<OthersScreen> {
  int _selectedIndex = -1;

  final List<OtherItem> othersItems = [
    OtherItem('Plumbing', Icons.plumbing_rounded),
    OtherItem('Cleaning', Icons.cleaning_services_rounded),
    OtherItem('Electrician', Icons.power_rounded),
    OtherItem('CCTV', Icons.camera_outdoor_rounded),
    OtherItem('Gas stove', Icons.local_fire_department_rounded),
    OtherItem('Trimming', Icons.content_cut_rounded),
    OtherItem('Acting driver', Icons.drive_eta_rounded),
    OtherItem('Painting', Icons.format_paint_rounded),
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
            const Icon(Icons.category_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'Others',
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
            // "Add own" button at the top, nice and bold
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddOwnServiceScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
                  label: Text(
                    'Add own',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800, // Nice and bold
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                    elevation: 8,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1, // slightly taller than wide
                ),
                itemCount: othersItems.length,
                itemBuilder: (context, index) {
                  final item = othersItems[index];
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
                          Icon(
                            item.icon,
                            size: 48,
                            color: isSelected 
                                ? const Color(0xFF39FF14) // Electric green icon when selected
                                : Colors.white,
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
                      // Navigate to BookServiceScreen with a generic category
                      final appState = Provider.of<AppState>(context, listen: false);
                      final targetCat = appState.categories.isNotEmpty 
                          ? appState.categories.last 
                          : ServiceCategory(id: 'dummy', name: 'Other Services', iconName: 'category', description: 'Other Services', isHome: true, items: []);
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
