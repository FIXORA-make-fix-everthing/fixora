import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_state.dart';
import 'payment_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // For simplicity, let's say step 0=Booked, 1=Received, 2=Assigned, 3=On the way, 4=Arrived, 5=In Progress, 6=Completed
    
    int activeStep = 0;
    if (booking.status == BookingStatus.findingProvider) activeStep = 1;
    if (booking.status == BookingStatus.providerAssigned) activeStep = 3; // Assigned & On the way
    if (booking.status == BookingStatus.arrived) activeStep = 4;
    if (booking.status == BookingStatus.inProgress) activeStep = 5;
    if (booking.status == BookingStatus.completed) activeStep = 6;

    Color edgeColor = Colors.redAccent;
    if (booking.status == BookingStatus.providerAssigned) {
      edgeColor = Colors.yellowAccent;
    } else if (booking.status == BookingStatus.arrived || booking.status == BookingStatus.inProgress) {
      edgeColor = Colors.greenAccent;
    } else if (booking.status == BookingStatus.completed) {
      edgeColor = const Color(0xFF00E5FF);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Dark premium background
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'BOOKING DETAILS',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: edgeColor.withValues(alpha: 0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: edgeColor.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: edgeColor.withValues(alpha: 0.05),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking ID: ${booking.id}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Expected arrival: ',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF00E5FF),
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF00E5FF),
                                ),
                              ),
                              Text(
                                'Technician arriving within 1 hr',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 24),
    
                  // Timeline Stepper
                  _buildTimelineStep(
                    title: 'Service Booked',
                    subtitle: 'Your request has been successfully submitted',
                    isCompleted: activeStep >= 0,
                    isActive: activeStep == 0,
                    isLast: false,
                    icon: Icons.check_rounded,
                  ),
                  _buildTimelineStep(
                    title: 'Request Received',
                    subtitle: 'Fixora has received your service request',
                    isCompleted: activeStep >= 1,
                    isActive: activeStep == 1,
                    isLast: false,
                    icon: Icons.check_rounded,
                  ),
                  _buildTimelineStep(
                    title: 'Technician assigned',
                    subtitle: 'A technician has been assigned to your request',
                    isCompleted: activeStep >= 2,
                    isActive: activeStep == 2,
                    isLast: false,
                    icon: Icons.build_rounded, // Tools icon like the screenshot
                  ),
                  _buildTimelineStep(
                    title: 'Technician on the way',
                    subtitle: 'A technician is traveling to your location',
                    isCompleted: activeStep >= 3,
                    isActive: activeStep == 3,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Technician Arrived',
                    subtitle: 'A technician has arrived at your location',
                    isCompleted: activeStep >= 4,
                    isActive: activeStep == 4,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Service In Progress',
                    subtitle: 'A technician is currently fixing the problem',
                    isCompleted: activeStep >= 5,
                    isActive: activeStep == 5,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Service Completed',
                    subtitle: 'The service has been successfully completed',
                    isCompleted: activeStep >= 6,
                    isActive: activeStep == 6,
                    isLast: true,
                  ),
    
                  const SizedBox(height: 40),
    
                  // Technician Profile Card (If Assigned)
                  if (booking.status != BookingStatus.findingProvider && booking.providerName != null) ...[
                    Text(
                      'TECHNICIAN PROFILE',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: const Color(0xFFFF5A00),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.05),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                                ),
                                child: const Center(
                                  child: Icon(Icons.person, color: Color(0xFF00E5FF), size: 30),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.providerName!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.storefront_rounded, color: Colors.white54, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Fixora Certified Auto Shop',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFF5A00), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${booking.providerRating ?? 5.0}  (124 Reviews)',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 12),
                          Text(
                            'ABOUT',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Expert specialist with 8+ years of experience in high-end vehicle repairs and home appliance diagnostics. Fixora Elite Partner.',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey[300],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
    
                  // Bottom Buttons
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (booking.providerPhone != null && booking.status != BookingStatus.findingProvider) {
                          // Extract just numbers and + from the phone string
                          final phoneStr = booking.providerPhone!.replaceAll(RegExp(r'[^\d+]'), '');
                          final Uri url = Uri.parse('tel:$phoneStr');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not launch phone dialer')),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No technician assigned yet.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3D1F), // Darker green background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.greenAccent, width: 1),
                        ),
                      ),
                      child: Text(
                        booking.providerPhone != null && booking.status != BookingStatus.findingProvider
                            ? 'Contact ${booking.providerPhone}'
                            : 'Contact Technician',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.greenAccent, // Electric green text
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (booking.status == BookingStatus.completed || booking.status == BookingStatus.inProgress) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => PaymentScreen(booking: booking)),
                          );
                        } else {
                          // Pop to home (Bookings tab or Home tab)
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (booking.status == BookingStatus.completed || booking.status == BookingStatus.inProgress) 
                            ? const Color(0xFFFF5A00) 
                            : const Color(0xFF0F2537),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: (booking.status == BookingStatus.completed || booking.status == BookingStatus.inProgress)
                                ? const Color(0xFFFF5A00)
                                : const Color(0xFF00E5FF),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        (booking.status == BookingStatus.completed || booking.status == BookingStatus.inProgress)
                            ? 'Proceed to Payment'
                            : 'Go to home',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: (booking.status == BookingStatus.completed || booking.status == BookingStatus.inProgress)
                              ? Colors.white
                              : const Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    IconData? icon,
  }) {
    // Custom logic to match the screenshot:
    // Completed: White Circle with Tick (or solid white)
    // Active: Blue/Purple circle with Tools icon (or whatever is passed)
    // Inactive: Small grey dot
    
    Color dotColor = Colors.white;
    if (isActive) dotColor = const Color(0xFF4A5568); // Dark greyish blue from screenshot
    if (!isCompleted && !isActive) dotColor = Colors.grey[800]!;

    Widget marker;
    if (isActive && icon != null) {
      marker = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      );
    } else if (isCompleted) {
      marker = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2), // to give it a little space
        ),
        child: const Icon(Icons.check, color: Colors.black, size: 16),
      );
    } else {
      marker = Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line & marker
          SizedBox(
            width: 40,
            child: Column(
              children: [
                marker,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? Colors.white : Colors.grey[800],
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0), // Spacing between steps
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: isActive || isCompleted ? FontWeight.w500 : FontWeight.w400,
                      color: isActive || isCompleted ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

