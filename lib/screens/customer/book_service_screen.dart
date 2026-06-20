import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/neumorphic_button.dart';
import 'searching_technician_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BookServiceScreen extends StatefulWidget {
  final ServiceCategory category;

  const BookServiceScreen({
    super.key,
    required this.category,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  ServiceItem? _selectedItem;
  final _addressController = TextEditingController(text: '1000 Richmond Way, Beverly Hills, CA');
  String _selectedDate = 'Tomorrow, May 30';
  String _selectedSlot = '10:00 AM - 12:00 PM';

  String _selectedLocation = 'Beverly Hills, CA';
  final Map<String, double> _locationFees = {
    'Beverly Hills, CA': 10.0,
    'Los Angeles, CA': 25.0,
    'Santa Monica, CA': 40.0,
    'Pasadena, CA': 30.0,
  };
  final List<String> _dateOptions = [
    'Today, May 29',
    'Tomorrow, May 30',
    'Sunday, May 31',
    'Monday, Jun 01',
  ];

  final List<String> _slots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '01:00 PM - 03:00 PM',
    '03:00 PM - 05:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  bool _isLoadingLocation = false;

  Future<void> _fetchLiveLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String newCity = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
        String state = place.administrativeArea ?? '';
        String fullAddress = '${place.street}, $newCity, $state';
        
        // Check if city is in our fees list
        String locationKey = state.isNotEmpty ? '$newCity, $state' : newCity;
        if (!_locationFees.containsKey(locationKey)) {
          // If not found, add it with a default $20 fee
          _locationFees[locationKey] = 20.0;
        }

        setState(() {
          _selectedLocation = locationKey;
          _addressController.text = fullAddress;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Default select first item
    if (widget.category.items.isNotEmpty) {
      _selectedItem = widget.category.items.first;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _confirmBooking() {
    if (_selectedItem == null) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Create the booking
    final double locationFee = _locationFees[_selectedLocation] ?? 0.0;
    final double basePrice = _selectedItem!.basePrice + locationFee;
    appState.createBooking(
      categoryName: widget.category.name,
      serviceName: _selectedItem!.name,
      price: basePrice,
      date: _selectedDate,
      timeSlot: _selectedSlot,
      address: _addressController.text.trim(),
    );

    // Navigate to Searching Technician Screen
    final newBooking = appState.bookings.first;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SearchingTechnicianScreen(bookingId: newBooking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.category.name.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: const Color(0xFFFF5A00),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Service Items List Selection
              Text(
                'SELECT SOLUTION',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: widget.category.items.map((item) {
                  final isSelected = _selectedItem?.id == item.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedItem = item;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E1C15) : const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFFFF5A00).withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey[500],
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Color(0xFFFF5A00), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Duration: ${item.duration}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            appState.formatPrice(item.basePrice),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF5A00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Service Location Selection
              Text(
                'SERVICE LOCATION',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF151515),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF5A00)),
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                    items: _locationFees.keys.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLocation = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Service Address Configuration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DELIVERY ADDRESS',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: const Color(0xFF888888),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isLoadingLocation ? null : _fetchLiveLocation,
                    child: Row(
                      children: [
                        _isLoadingLocation
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5A00)),
                              )
                            : const Icon(Icons.my_location_rounded, color: Color(0xFFFF5A00), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Use Live Location',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF5A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFFF5A00), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF151515),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFFF5A00).withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF5A00)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Date Selection
              Text(
                'DATE',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dateOptions.length,
                  itemBuilder: (context, index) {
                    final date = _dateOptions[index];
                    final isSelected = _selectedDate == date;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFF151515),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFFFF5A00).withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            date,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.black : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 5. Time Slot Selection
              Text(
                'PREMIUM TIME SLOTS',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots.map((slot) {
                  final isSelected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFFFF5A00).withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // 6. Billing details summary
              if (_selectedItem != null) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'BILLING SUMMARY',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: const Color(0xFFFF5A00),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBillRow('Base Service Cost', appState.formatPrice(_selectedItem!.basePrice)),
                      const SizedBox(height: 6),
                      _buildBillRow('Location Fee ($_selectedLocation)', appState.formatPrice(_locationFees[_selectedLocation]!)),
                      const SizedBox(height: 6),
                      _buildBillRow('Luxury Guarantee Fee (5%)', appState.formatPrice((_selectedItem!.basePrice + _locationFees[_selectedLocation]!) * 0.05)),
                      const SizedBox(height: 6),
                      _buildBillRow('VAT / Sales Tax (8%)', appState.formatPrice((_selectedItem!.basePrice + _locationFees[_selectedLocation]!) * 0.08)),
                      const Divider(color: Colors.white10, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            appState.formatPrice((_selectedItem!.basePrice + _locationFees[_selectedLocation]!) * 1.13),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF5A00),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),

              // Booking CTA Button
              NeumorphicButton(
                baseColor: _selectedItem == null ? Colors.grey[850]! : const Color(0xFFFF5A00),
                onPressed: _selectedItem == null ? () {} : _confirmBooking,
                child: Text(
                  'CONFIRM APPOINTMENT',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w300),
        ),
        Text(
          amount,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
