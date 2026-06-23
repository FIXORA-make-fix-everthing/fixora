import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../auth_selection_screen.dart';
import '../../utils/app_colors.dart';
import '../../widgets/neumorphic_button.dart';
import '../../utils/page_transitions.dart';
import 'provider_registration_screen.dart';
import 'business_details_screen.dart';
import 'edit_profile_screen.dart';
import 'live_location_screen.dart';
import 'marketplace_screen.dart';
import 'my_orders_screen.dart';

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key});

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  int _currentIndex = 0;
  XFile? _pickedIdProof;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isOnline = appState.isProviderOnline;

    final List<Widget> tabs = [
      _buildJobsBoardTab(context, appState, isOnline),
      _buildMyTasksTab(context, appState),
      const MarketplaceScreen(),
      _buildEarningsTab(context, appState),
      _buildProfileTab(context, appState),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: SafeArea(
          child: Column(
            children: [
              if (!appState.isProviderRegistrationComplete)
                _buildRegistrationAlert(context),
              // Shared status bar header at the very top for Provider
              _buildProviderHeader(context, appState),
              Expanded(child: tabs[_currentIndex]),
            ],
          ),
        ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.dashboard_customize_outlined, Icons.dashboard_customize, 'Jobs'),
              _buildNavItem(1, Icons.assignment_turned_in_outlined, Icons.assignment_turned_in, 'Tasks'),
              
              // Center Marketplace Button
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE5C07B), Color(0xFFC5A059)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.goldSilkS.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.storefront, color: Colors.black, size: 28),
                ),
              ),

              _buildNavItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Earnings'),
              _buildNavItem(4, Icons.badge_outlined, Icons.badge, 'Profile'),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildNavItem(int index, IconData outlineIcon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.goldSilkS : Colors.white38;
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

  Widget _buildRegistrationAlert(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProviderRegistrationScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(color: Color(0xFFFF5A00)),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.black,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your proper registration',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Tap to complete your profile to receive jobs',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _showIncompleteProfileAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text(
              'Profile Incomplete',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'You must complete your proper registration profile before you can go online or accept customer jobs.',
          style: GoogleFonts.outfit(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.grey[500]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProviderRegistrationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5A059),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Complete Registration',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SHARED HEADER ---
  Widget _buildProviderHeader(BuildContext context, AppState appState) {
    final isOnline = appState.isProviderOnline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFC5A059).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.gps_fixed, color: Color(0xFFC5A059), size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LiveLocationScreen(),
                    ),
                  );
                },
                tooltip: 'Live Location Tracking',
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC5A059).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFFC5A059), width: 1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.engineering,
                    color: Color(0xFFC5A059),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALEX MERCER',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFC5A059),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '4.95',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•  Elite Partner',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: const Color(0xFFC5A059),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Online/Offline switch
              GestureDetector(
                onTap: () {
                  if (!appState.isProviderRegistrationComplete) {
                    _showIncompleteProfileAlert(context);
                    return;
                  }
                  appState.toggleProviderOnline();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 105,
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF1E3A1E)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOnline
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? const Color(0xFF4CAF50)
                              : Colors.white24,
                        ),
                      ),
                      Text(
                        isOnline ? 'ONLINE' : 'OFFLINE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isOnline
                              ? const Color(0xFF81C784)
                              : Colors.white38,
                        ),
                      ),
                      Icon(
                        isOnline ? Icons.toggle_on : Icons.toggle_off,
                        color: isOnline
                            ? const Color(0xFF81C784)
                            : Colors.white38,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // GPS Tracking switch
              GestureDetector(
                onTap: () {
                  if (!appState.isProviderRegistrationComplete) {
                    _showIncompleteProfileAlert(context);
                    return;
                  }
                  appState.toggleGpsTracking();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 105,
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: appState.isGpsTrackingOn
                        ? const Color(0xFF1E3A1E)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: appState.isGpsTrackingOn
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        color: appState.isGpsTrackingOn
                            ? const Color(0xFF4CAF50)
                            : Colors.white24,
                        size: 14,
                      ),
                      Text(
                        appState.isGpsTrackingOn ? 'GPS ON' : 'GPS OFF',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: appState.isGpsTrackingOn
                              ? const Color(0xFF81C784)
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- JOBS BOARD ---
  Widget _buildJobsBoardTab(
    BuildContext context,
    AppState appState,
    bool isOnline,
  ) {
    if (!appState.isProviderRegistrationComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_ind_rounded,
                color: Colors.grey[850],
                size: 70,
              ),
              const SizedBox(height: 20),
              Text(
                'Registration Incomplete',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You must complete your profile registration before you can view and accept customer requests.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[650],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProviderRegistrationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldSilkS,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Complete Registration',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isOnline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.grey[850], size: 70),
              const SizedBox(height: 20),
              Text(
                'You are currently Offline',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toggle status to ONLINE above to start receiving premium service requests near your area.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[650],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter for requests seeking providers, matching provider's specialization
    final availableJobs = appState.bookings.where((b) {
      bool isFinding = b.status == BookingStatus.findingProvider;
      if (!isFinding) return false;
      
      // Match against provider's skills
      if (appState.providerSkills.isEmpty) return true; // Show all if no skills defined
      
      return appState.providerSkills.any((skill) {
        final skillLower = skill.toLowerCase();
        return b.serviceName.toLowerCase().contains(skillLower) || 
               b.category.toLowerCase().contains(skillLower) ||
               skillLower.contains(b.category.toLowerCase());
      });
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVAILABLE REQUESTS',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: const Color(0xFFC5A059),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Matching Your Skills',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: availableJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.satellite_alt_rounded,
                          color: Colors.grey[850],
                          size: 55,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scanning for requests...',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[650],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'New client bookings will appear here instantly.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[750],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: availableJobs.length,
                    itemBuilder: (context, index) {
                      final job = availableJobs[index];
                      return _buildJobOfferCard(context, job, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobOfferCard(
    BuildContext context,
    Booking job,
    AppState appState,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFC5A059).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  job.category.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC5A059),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Text(
                '★ 2.4 miles away',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.serviceName,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Color(0xFFC5A059),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                job.customerName,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.navigation_outlined,
                color: Color(0xFFC5A059),
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.address,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFC5A059),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${job.date} (${job.timeSlot.split(' ')[0]})',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payout Offer',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    appState.formatPrice(job.price),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC5A059),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[800]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'DECLINE',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeumorphicButton(
                    baseColor: const Color(0xFFC5A059),
                    onPressed: () {
                      appState.acceptBooking(job.id);
                      // Switch to my tasks tab
                      setState(() {
                        _currentIndex = 1;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Job ${job.id} Accepted. Navigating to Task checklist.',
                          ),
                          backgroundColor: const Color(0xFFC5A059),
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      'ACCEPT',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MY TASKS TAB (In-Progress checklist) ---
  Widget _buildMyTasksTab(BuildContext context, AppState appState) {
    // Find active jobs assigned to provider (not completed)
    final activeJobs = appState.bookings.where((b) {
      return (b.providerName == "Alex Mercer" ||
              b.providerName == "Alex Mercer (You)") &&
          (b.status != BookingStatus.completed);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE PROJECT',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: const Color(0xFFC5A059),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Task Checklist',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: activeJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          color: Colors.grey[850],
                          size: 55,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Tasks',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[650],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Go to the Jobs Board to accept a new work request.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[750],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: activeJobs.length,
                    itemBuilder: (context, index) {
                      final job = activeJobs[index];
                      return _buildActiveJobTrackerCard(context, job, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobTrackerCard(
    BuildContext context,
    Booking job,
    AppState appState,
  ) {
    int stepIndex = 0;
    String ctaText = 'ARRIVED AT SITE';
    if (job.status == BookingStatus.providerAssigned) {
      stepIndex = 1;
      ctaText = 'I HAVE ARRIVED';
    } else if (job.status == BookingStatus.arrived) {
      stepIndex = 2;
      ctaText = 'START SERVICE WORK';
    } else if (job.status == BookingStatus.inProgress) {
      stepIndex = 3;
      ctaText = 'AMOUNT RECEIVED';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC5A059).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.id,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Payout: ${appState.formatPrice(job.price)}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFFC5A059),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.serviceName,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Divider(color: Colors.white10, height: 24),

          // Customer Details block
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFFC5A059), size: 16),
              const SizedBox(width: 8),
              Text(
                job.customerName,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.navigation, color: Color(0xFFC5A059), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.address,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone, color: Color(0xFFC5A059), size: 16),
              const SizedBox(width: 8),
              Text(
                '+1 (555) 123-4567', // Customer phone mockup
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Navigation Button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Maps & Live Navigation...')));
              },
              icon: const Icon(Icons.directions_rounded, size: 18, color: Colors.black),
              label: Text('Get to Live Location', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldSilkS,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Problem Reference Picture:',
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=300&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Custom interactive workflow checkpoints
          Text(
            'PROGRESS TRACKER',
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildStepRow('1', 'Accepted & Dispatched', stepIndex > 0),
          _buildLineConnector(stepIndex > 1),
          _buildStepRow('2', 'Arrived at Site Location', stepIndex > 1),
          _buildLineConnector(stepIndex > 2),
          _buildStepRow('3', 'Service Diagnostics & Repairs', stepIndex > 2),
          _buildLineConnector(stepIndex > 3),
          _buildStepRow('4', 'Final Invoice & Customer Review', stepIndex > 3),
          const SizedBox(height: 28),

          // Workflow trigger CTA button
          SizedBox(
            height: 48,
            child: NeumorphicButton(
              baseColor: const Color(0xFFC5A059),
              onPressed: () {
                appState.advanceBookingStatus(job.id);
                if (job.status == BookingStatus.inProgress) {
                  // After transition out, if complete, show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Job Completed. Earnings credited to your wallet!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(
                ctaText,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String stepNum, String title, bool active) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFFC5A059) : Colors.transparent,
            border: Border.all(
              color: active ? const Color(0xFFC5A059) : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Center(
            child: active
                ? const Icon(Icons.check, size: 12, color: Colors.black)
                : Text(
                    stepNum,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.white38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: active ? FontWeight.w500 : FontWeight.w300,
            color: active
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white30,
          ),
        ),
      ],
    );
  }

  Widget _buildLineConnector(bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
      width: 1.5,
      height: 18,
      color: active ? const Color(0xFFC5A059) : Colors.white10,
    );
  }

  // --- EARNINGS TAB ---
  Widget _buildEarningsTab(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'FINANCIAL OVERVIEW',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: const Color(0xFFC5A059),
              ),
            ),
            const SizedBox(height: 12),

            // Premium Large Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
                ),
                border: Border.all(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Available Balance',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<CountryData>(
                          value: appState.selectedCountry,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFFC5A059),
                          ),
                          dropdownColor: const Color(0xFF1E1E1E),
                          items: appState.availableCountries.map((
                            CountryData country,
                          ) {
                            return DropdownMenuItem<CountryData>(
                              value: country,
                              child: Text('${country.flag} ${country.code}'),
                            );
                          }).toList(),
                          onChanged: (CountryData? newValue) {
                            if (newValue != null) {
                              appState.setCountry(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      appState.formatPrice(appState.providerEarnings),
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC5A059),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: NeumorphicButton(
                      baseColor: const Color(0xFFC5A059),
                      onPressed: () {},
                      child: Text(
                        'PAYOUT TO BANK',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Performance Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatMiniCard(
                    'Jobs Finished',
                    '${appState.completedJobsCount}',
                    Icons.done_all_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatMiniCard(
                    'Provider Rating',
                    '4.95 / 5',
                    Icons.star_rate_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Earnings breakdown list
            Text(
              'RECENT STATEMENTS',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: const Color(0xFFC5A059),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatementItem(
              'AC Repair & Valve Calibr.',
              'May 29',
              '+${appState.formatPrice(120.00)}',
            ),
            _buildStatementItem(
              'Premium Auto Detailing',
              'May 28',
              '+${appState.formatPrice(150.00)}',
            ),
            _buildStatementItem(
              'Brake Pad Tuning',
              'May 25',
              '+${appState.formatPrice(135.00)}',
            ),
            _buildStatementItem(
              'Bank Account Payout',
              'May 24',
              '-${appState.formatPrice(310.00)}',
              positive: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMiniCard(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC5A059).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC5A059), size: 18),
          const SizedBox(height: 12),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementItem(
    String desc,
    String date,
    String amount, {
    bool positive = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: positive ? const Color(0xFF81C784) : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  // --- PROFILE TAB ---
  Widget _buildProfileTab(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Portfolio Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFC5A059).withValues(alpha: 0.08),
                      border: Border.all(
                        color: const Color(0xFFC5A059),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.engineering_rounded,
                        color: Color(0xFFC5A059),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Alex Mercer',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Senior HVAC & Automotive Technician',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF81C784),
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'FIXORA ELITE CERTIFIED',
                          style: GoogleFonts.outfit(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF81C784),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Skills Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SPECIALIZED SKILLS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: const Color(0xFFC5A059),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditSkillsDialog(context, appState),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFFC5A059),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: appState.providerSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.grey[300],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // ID Proof Section
            Text(
              'IDENTITY VERIFICATION',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: const Color(0xFFC5A059),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: _pickedIdProof != null ? 80 : 50,
                    height: _pickedIdProof != null ? 60 : 50,
                    decoration: BoxDecoration(
                      color: _pickedIdProof != null ? Colors.green.withValues(alpha: 0.1) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _pickedIdProof != null ? Colors.green : Colors.white10),
                      image: _pickedIdProof != null 
                        ? DecorationImage(image: FileImage(File(_pickedIdProof!.path)), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _pickedIdProof == null 
                      ? const Icon(Icons.add_a_photo_outlined, color: Colors.white54)
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pickedIdProof != null ? 'ID Proof Uploaded' : 'Upload ID Proof Photo',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _pickedIdProof != null ? Colors.green : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aadhar, Driver License, or Passport',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _pickedIdProof = image;
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open gallery: $e'), backgroundColor: Colors.red));
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _pickedIdProof != null ? Colors.green : const Color(0xFFC5A059)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _pickedIdProof != null ? 'CHANGE' : 'UPLOAD',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: _pickedIdProof != null ? Colors.green : const Color(0xFFC5A059)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Profile actions menu
            _buildProfileMenuItem(
              context,
              Icons.person_outline_rounded,
              'Edit Profile',
              'Update Name, Contact Info, Bio, Experience',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            _buildProfileMenuItem(
              context,
              Icons.inventory_2_rounded,
              'My Orders',
              'View your marketplace purchases and collection codes',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyOrdersScreen(),
                  ),
                );
              },
            ),
            _buildProfileMenuItem(
              context,
              Icons.business_center_rounded,
              'Business Details',
              'Registered LLC and Insurance policies',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BusinessDetailsScreen(),
                  ),
                );
              },
            ),
            _buildProfileMenuItem(
              context,
              Icons.lock_rounded,
              'Login Security',
              'Credentials, biometrics configuration',
              onTap: () => _showLoginSecurityDialog(context),
            ),
            _buildProfileMenuItem(
              context,
              Icons.public_rounded,
              'Region & Currency',
              '${appState.selectedCountry.name} (${appState.selectedCountry.currencySymbol})',
              onTap: () => _showCurrencySelection(context, appState),
            ),
            _buildProfileMenuItem(
              context,
              Icons.notifications_active_rounded,
              'Notification Preferences',
              'High-priority SMS & Pushes',
              onTap: () => _showNotificationPreferences(context),
            ),
            _buildProfileMenuItem(
              context,
              Icons.help_center_rounded,
              'Partner Helpdesk',
              '24/7 dedicated support desk',
              onTap: () => _showHelpDeskDialog(context),
            ),

            const SizedBox(height: 30),

            // Sign out Button
            OutlinedButton(
              onPressed: () {
                appState.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  RollingPageRoute(page: const AuthSelectionScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'SIGN OUT',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC5A059),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC5A059), size: 18),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white24,
          size: 10,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showCurrencySelection(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Region & Currency',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...appState.availableCountries.map((country) {
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(
                    country.name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    country.currencySymbol,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFC5A059),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    appState.setCountry(country);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEditSkillsDialog(BuildContext context, AppState appState) {
    final TextEditingController skillsController = TextEditingController(
      text: appState.providerSkills.join(', '),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Specialized Skills',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter skills separated by commas:',
                style: GoogleFonts.outfit(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skillsController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFC5A059)),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: Colors.grey[500]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newSkills = skillsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                appState.updateProviderSkills(newSkills);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A059),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showNotificationPreferences(BuildContext context) {
    String selectedRange = '< 10 km'; // Mock state for UI

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Notification Distance',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Receive alerts for new jobs within your preferred radius.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDistanceRadioOption('< 10 km', 'Nearby jobs only', selectedRange, (val) {
                    setModalState(() => selectedRange = val);
                  }),
                  _buildDistanceRadioOption('> 10 km', 'Further away jobs', selectedRange, (val) {
                    setModalState(() => selectedRange = val);
                  }),
                  _buildDistanceRadioOption('Any Distance', 'All available jobs in city', selectedRange, (val) {
                    setModalState(() => selectedRange = val);
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5A059),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save Preferences',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDistanceRadioOption(String title, String subtitle, String groupValue, Function(String) onChanged) {
    bool isSelected = title == groupValue;
    return GestureDetector(
      onTap: () => onChanged(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A059).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFC5A059) : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFC5A059) : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginSecurityDialog(BuildContext context) {
    bool isBiometricsEnabled = true;
    bool is2FAEnabled = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security_rounded, color: Color(0xFFC5A059), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Login Security',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account security and authentication methods.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Change Password
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.password_rounded, color: Colors.white70, size: 20),
                    ),
                    title: Text(
                      'Change Password',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Last changed 3 months ago',
                      style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                    onTap: () {
                      // Placeholder for change password logic
                    },
                  ),
                  const Divider(color: Colors.white10),

                  // Biometrics Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFC5A059),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: Colors.white70, size: 20),
                    ),
                    title: Text(
                      'Biometric Login',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Use fingerprint or Face ID',
                      style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 11),
                    ),
                    value: isBiometricsEnabled,
                    onChanged: (val) {
                      setModalState(() => isBiometricsEnabled = val);
                    },
                  ),
                  const Divider(color: Colors.white10),

                  // 2FA Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFC5A059),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phonelink_lock_rounded, color: Colors.white70, size: 20),
                    ),
                    title: Text(
                      'Two-Factor Authentication',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Add an extra layer of security',
                      style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 11),
                    ),
                    value: is2FAEnabled,
                    onChanged: (val) {
                      setModalState(() => is2FAEnabled = val);
                    },
                  ),
                  const Divider(color: Colors.white10),

                  // Active Sessions
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.devices_rounded, color: Colors.white70, size: 20),
                    ),
                    title: Text(
                      'Active Sessions',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Manage logged-in devices',
                      style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpDeskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              const Icon(Icons.support_agent, color: Color(0xFFC5A059)),
              const SizedBox(width: 10),
              Text(
                'Partner Helpdesk',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Fixora',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC5A059),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fixora is a premium on-demand service platform connecting verified experts with customers needing top-tier home and auto solutions. We provide 24/7 dedicated support for our partners.',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.white54, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '+1 (800) 555-0199',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.white54, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'partnersupport@fixora.com',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.outfit(color: const Color(0xFFC5A059)),
              ),
            ),
          ],
        );
      },
    );
  }
}
