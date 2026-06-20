import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../auth_selection_screen.dart';
import 'home_appliances_screen.dart';
import 'others_screen.dart';
import 'vehicle_screen.dart';
import 'live_tracking_screen.dart';
import 'on_spot_booking_screen.dart';
import 'booking_details_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../language_selection_screen.dart';
import 'about_screen.dart';
import 'privacy_settings_screen.dart';
import '../provider/marketplace_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _currentIndex = 0; // Start on Explore

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userName = appState.currentUserName ?? 'Valued Guest';

    final List<Widget> tabs = [
      _buildHomeTab(context, userName, appState),
      const MarketplaceScreen(),
      _buildBookingsTab(context, appState),
      _buildProfileTab(context, userName, appState),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: SafeArea(
          child: tabs[_currentIndex],
        ),
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 10),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF151515),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A00).withValues(alpha: 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFF5A00),
                width: 2,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.storefront, color: Color(0xFFFF5A00), size: 28),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF141414),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.explore_outlined, Icons.explore, 'Explore'),
                const SizedBox(width: 40), // Space for FAB
                _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long, 'Bookings'),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFFFF5A00) : Colors.white38;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : outlineIcon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- EXPLORE TAB ---
  Widget _buildHomeTab(BuildContext context, String userName, AppState appState) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Block
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = 2; // Jump to Profile tab
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 32),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WELCOME BACK',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: const Color(0xFFFF5A00),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Location selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.15)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CountryData>(
                      value: appState.selectedCountry,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFF5A00), size: 16),
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      onChanged: (CountryData? newValue) {
                        if (newValue != null) {
                          appState.setCountry(newValue);
                        }
                      },
                      items: appState.availableCountries.map((CountryData country) {
                        return DropdownMenuItem<CountryData>(
                          value: country,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(country.flag, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text('${country.name} (${country.currencySymbol})'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.1)),
              ),
              child: TextField(
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Color(0xFFFF5A00), size: 20),
                  hintText: 'Search home repairs, car detailers...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey[700], fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Promotional Glassmorphic Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF5A00).withValues(alpha: 0.15),
                    const Color(0xFF1A1A1A),
                  ],
                ),
                border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5A00),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FIXORA BLACK',
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '20% Off Your First Home Deep Clean',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Experience premium standards with verified professionals.',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.clean_hands_rounded, color: Color(0xFFFF5A00), size: 40),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // On-the-Spot Services Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'On-the-Spot Repairs',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'OUR SPECIALS',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF5A00),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSpecialCard(context, 'Car Puncture', Icons.tire_repair, const Color(0xFF00E5FF)),
                  _buildSpecialCard(context, 'Car Breakdown', Icons.car_crash_rounded, const Color(0xFFFF5A00)),
                  _buildSpecialCard(context, 'Fan Repair &\nInstall', Icons.mode_fan_off_rounded, const Color(0xFF39FF14)),
                  _buildSpecialCard(context, 'House\nShifting', Icons.local_shipping_rounded, const Color(0xFFFF00FF)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // New Simplified Category Layout
            _buildCategoryListButton(context, 0, 'Home appliances', Icons.home_rounded),
            _buildCategoryListButton(context, 1, 'Vehicle', Icons.directions_car_rounded),
            _buildCategoryListButton(context, 2, 'Others', Icons.category_rounded),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialCard(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.3),
          highlightColor: color.withValues(alpha: 0.1),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OnSpotBookingScreen(serviceName: title.replaceAll('\\n', ' ')),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryListButton(BuildContext context, int index, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.1), // Transparent electric blue
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5A00).withValues(alpha: 0.4), // Orange ambient light
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
           color: const Color(0xFF00E5FF),
           width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.3), // Electric blue splash
          highlightColor: const Color(0xFFFF5A00).withValues(alpha: 0.2), // Orange highlight
          onTap: () {
            if (index == 0) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeAppliancesScreen(),
                ),
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VehicleScreen(),
                ),
              );
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OthersScreen(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00E5FF), size: 36),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF00E5FF), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BOOKINGS TAB ---
  Widget _buildBookingsTab(BuildContext context, AppState appState) {
    final customerBookings = appState.bookings; // Show all for demo context

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY BOOKINGS',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: const Color(0xFFFF5A00),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Service Orders',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: customerBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note_rounded, color: Colors.grey[850], size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Appointments',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'When you schedule a service, it will show up here.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: customerBookings.length,
                    itemBuilder: (context, index) {
                      final booking = customerBookings[index];
                      return _buildBookingCard(booking, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, AppState appState) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    bool showPulse = false;

    switch (booking.status) {
      case BookingStatus.findingProvider:
        statusColor = const Color(0xFFFF5A00);
        statusText = 'Finding Specialist...';
        statusIcon = Icons.hourglass_empty;
        showPulse = true;
        break;
      case BookingStatus.providerAssigned:
        statusColor = Colors.blueAccent;
        statusText = 'Specialist Assigned';
        statusIcon = Icons.directions_car_rounded;
        break;
      case BookingStatus.arrived:
        statusColor = Colors.purpleAccent;
        statusText = 'Technician Arrived';
        statusIcon = Icons.hail_rounded;
        break;
      case BookingStatus.inProgress:
        statusColor = Colors.amber;
        statusText = 'Work in Progress';
        statusIcon = Icons.construction_rounded;
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.verified_rounded;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(booking: booking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: booking.status == BookingStatus.findingProvider
                ? const Color(0xFFFF5A00).withValues(alpha: 0.2)
                : const Color(0xFFFF5A00).withValues(alpha: 0.08),
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header (ID and Status)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.id,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Row(
                    children: [
                      if (showPulse)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF5A00),
                          ),
                        ),
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white10, height: 1),

          // Middle Details (Service Name, Time, Address)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF5A00), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.date}  •  ${booking.timeSlot}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.navigation_rounded, color: Color(0xFFFF5A00), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Provider details if assigned
          if (booking.providerName != null) ...[
            const Divider(color: Colors.white10, height: 1),
            Container(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Color(0xFFFF5A00), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.providerName!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFF5A00), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              booking.providerRating?.toString() ?? '5.0',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•  Elite Partner',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: const Color(0xFFFF5A00),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFFF5A00), size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
          
          const Divider(color: Colors.white10, height: 1),

          // Bottom Price / Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Paid',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  appState.formatPrice(booking.price),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF5A00),
                  ),
                ),
              ],
            ),
          ),

          // Add Live Tracking Button if provider is assigned or arrived
          if (booking.status == BookingStatus.providerAssigned || 
              booking.status == BookingStatus.arrived || 
              booking.status == BookingStatus.inProgress) ...[
            const Divider(color: Colors.white10, height: 1),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LiveTrackingScreen(booking: booking)),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.my_location_rounded, color: Color(0xFFFF5A00), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'TRACK LIVE LOCATION',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF5A00),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  // --- PROFILE TAB ---
  Widget _buildProfileTab(BuildContext context, String userName, AppState appState) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
          // User Card
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                      border: Border.all(color: const Color(0xFFFF5A00), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Color(0xFFFF5A00), size: 36),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.currentUserEmail ?? 'customer@fixora.com',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Color(0xFFFF5A00), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'BLACK DIAMOND MEMBERSHIP',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF5A00),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Menu Options
          _buildProfileMenuItem(context, Icons.person_outline_rounded, 'Edit profile', onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          }),
          _buildProfileMenuItem(context, Icons.notifications_none_rounded, 'Notifications', onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
            );
          }),
          _buildProfileMenuItem(context, Icons.info_outline_rounded, 'About', onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          }),
          _buildProfileMenuItem(context, Icons.lock_outline_rounded, 'Privacy setting', onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
            );
          }),
          _buildProfileMenuItem(context, Icons.translate_rounded, 'Language', onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LanguageSelectionScreen(isFromOnboarding: false),
              ),
            );
          }),
          const SizedBox(height: 40),

          // Logout Button
          _buildProfileMenuItem(
            context,
            Icons.logout_rounded,
            'Log out',
            isLogout: true,
            onTap: () {
              appState.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthSelectionScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  Widget _buildProfileMenuItem(BuildContext context, IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    final bgColor = isLogout 
        ? const Color(0xFFFF3333).withValues(alpha: 0.1) 
        : const Color(0xFF151515);
    final borderColor = isLogout 
        ? const Color(0xFFFF3333).withValues(alpha: 0.3) 
        : Colors.white12;
    final iconColor = isLogout 
        ? const Color(0xFFFF3333) 
        : const Color(0xFF00E5FF);
    final textColor = isLogout 
        ? const Color(0xFFFF3333) 
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            if (!isLogout)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            if (isLogout)
              BoxShadow(
                color: const Color(0xFFFF3333).withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isLogout ? const Color(0xFFFF3333).withValues(alpha: 0.5) : Colors.white30, size: 22),
          ],
        ),
      ),
    );
  }
}
