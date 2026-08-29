import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() => _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCountry;
  String? _selectedPaymentType;
  bool _isUploading = false;
  bool _isGpsEnabled = false;
  
  final List<String> _selectedSkills = [];

  final Map<String, List<String>> _skillCategories = {
    'Home Appliances': ['AC Repair', 'Fridge Repair', 'Washing Machine', 'TV Repair', 'Electrical', 'Plumbing', 'Fan/Mixer/Grinder'],
    'Car/Vehicle': ['Puncture', 'Engine Repair', 'Oil Change', 'Auto Electrical', 'Car AC Repair', 'Car Wash', 'Towing', 'Painting/Denting'],
    'Others': ['Mobile Repair', 'Laptop/PC Repair', 'Carpentry', 'Home Painting', 'CCTV Installation', 'Pest Control', 'Cleaning']
  };

  final Map<String, IconData> _categoryIcons = {
    'Home Appliances': Icons.home_rounded,
    'Car/Vehicle': Icons.directions_car_rounded,
    'Others': Icons.category_rounded,
  };

  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  
  @override
  void dispose() {
    _flatController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
  
  final Map<String, XFile?> _selectedDocuments = {};
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDocument(String label, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedDocuments[label] = image;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
  
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    } 

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fetching GPS Location...')));

    try {
      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          _areaController.text = [place.street, place.subLocality].where((e) => e != null && e.isNotEmpty).join(', ');
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';
          
          String? countryName = place.country;
          if (countryName != null) {
            bool exists = _countries.any((c) => c['name'] == countryName);
            if (exists) _selectedCountry = countryName;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location fetched successfully!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }
  
  final List<Map<String, String>> _countries = [
    {'name': 'Global Store', 'flag': '🌍'},
    {'name': 'Afghanistan', 'flag': '🇦🇫'},
    {'name': 'Albania', 'flag': '🇦🇱'},
    {'name': 'Algeria', 'flag': '🇩🇿'},
    {'name': 'Argentina', 'flag': '🇦🇷'},
    {'name': 'Australia', 'flag': '🇦🇺'},
    {'name': 'Austria', 'flag': '🇦🇹'},
    {'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'name': 'Belgium', 'flag': '🇧🇪'},
    {'name': 'Brazil', 'flag': '🇧🇷'},
    {'name': 'Canada', 'flag': '🇨🇦'},
    {'name': 'China', 'flag': '🇨🇳'},
    {'name': 'Colombia', 'flag': '🇨🇴'},
    {'name': 'Denmark', 'flag': '🇩🇰'},
    {'name': 'Egypt', 'flag': '🇪🇬'},
    {'name': 'Finland', 'flag': '🇫🇮'},
    {'name': 'France', 'flag': '🇫🇷'},
    {'name': 'Germany', 'flag': '🇩🇪'},
    {'name': 'Ghana', 'flag': '🇬🇭'},
    {'name': 'Greece', 'flag': '🇬🇷'},
    {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'Indonesia', 'flag': '🇮🇩'},
    {'name': 'Iran', 'flag': '🇮🇷'},
    {'name': 'Iraq', 'flag': '🇮🇶'},
    {'name': 'Ireland', 'flag': '🇮🇪'},
    {'name': 'Israel', 'flag': '🇮🇱'},
    {'name': 'Italy', 'flag': '🇮🇹'},
    {'name': 'Japan', 'flag': '🇯🇵'},
    {'name': 'Kenya', 'flag': '🇰🇪'},
    {'name': 'Kuwait', 'flag': '🇰🇼'},
    {'name': 'Malaysia', 'flag': '🇲🇾'},
    {'name': 'Mexico', 'flag': '🇲🇽'},
    {'name': 'Nepal', 'flag': '🇳🇵'},
    {'name': 'Netherlands', 'flag': '🇳🇱'},
    {'name': 'New Zealand', 'flag': '🇳🇿'},
    {'name': 'Nigeria', 'flag': '🇳🇬'},
    {'name': 'Norway', 'flag': '🇳🇴'},
    {'name': 'Pakistan', 'flag': '🇵🇰'},
    {'name': 'Philippines', 'flag': '🇵🇭'},
    {'name': 'Poland', 'flag': '🇵🇱'}
  ];

  void _submitRegistration() {
    final requiredDocs = [
      'ID Proof*',
      'Aadhar Card Photo*',
      'PAN Card Photo*',
      'GST Bill*',
      'Shop Location GPS Photo*',
      'Shop Ownership Certificate*',
      'Shop Photo*'
    ];
    
    bool hasAllDocs = requiredDocs.every((doc) => _selectedDocuments.containsKey(doc) && _selectedDocuments[doc] != null);

    if (_formKey.currentState!.validate() && _selectedCountry != null && hasAllDocs) {
      setState(() {
        _isUploading = true;
      });
      
      // Simulate network request
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setProviderRegistrationComplete(true);
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registration Approved! Welcome to Fixora.',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.goldSilkS,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      });
    } else if (!hasAllDocs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload all mandatory documents (including Shop Ownership Certificate).',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a Country',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Technician information',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Ambient Gold Light 1 (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldSilkS.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Ambient Gold Light 2 (Bottom Left)
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldSilkS.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                
                _buildInputField('Shop name:', Icons.storefront_rounded, ''),
                const SizedBox(height: 20),
                _buildInputField('Phone number:', Icons.phone_rounded, '', isNumber: true),
                const SizedBox(height: 20),
                _buildInputField('E-mail:', Icons.email_rounded, ''),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Address:',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location, color: Colors.black, size: 16),
                      label: Text('Get GPS Location', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldSilkS,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInputField('Flat,House no,Building,company,Apartment*', Icons.business_rounded, '', controller: _flatController),
                const SizedBox(height: 20),
                _buildInputField('Area,Street,Section,Village*', Icons.map_rounded, '', controller: _areaController),
                const SizedBox(height: 20),
                _buildInputField('Landmark*', Icons.map_rounded, 'E.g.near Apollo Hospital', controller: _landmarkController),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(child: _buildInputField('Town/City', Icons.location_city_rounded, '', controller: _cityController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('State', Icons.map_rounded, '', controller: _stateController)),
                  ],
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(child: _buildInputField('Pincode', Icons.pin_drop_rounded, '', isNumber: true, controller: _pincodeController)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Country/Region',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.goldSilkS.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldSilkS.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1E1E1E),
                                value: _selectedCountry,
                                hint: Text('Select', style: GoogleFonts.outfit(color: Colors.white38)),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                                items: _countries.map((Map<String, String> country) {
                                  return DropdownMenuItem<String>(
                                    value: country['name'],
                                    child: Row(
                                      children: [
                                        Text(country['flag']!, style: const TextStyle(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            country['name']!,
                                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCountry = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Professional Details',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specialized Skills (Select from Categories):',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _skillCategories.keys.map((category) {
                        return InkWell(
                          onTap: () => _showSkillSelectionSheet(category),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.goldSilkS.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(color: AppColors.goldSilkS.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 0),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(_categoryIcons[category], color: AppColors.goldSilkS, size: 28),
                                const SizedBox(height: 8),
                                Text(
                                  category.split(' ')[0],
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedSkills.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSkills.map((skill) {
                          return Chip(
                            label: Text(skill, style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
                            backgroundColor: AppColors.goldSilkS,
                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black),
                            onDeleted: () {
                              setState(() {
                                _selectedSkills.remove(skill);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.goldSilkS.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gps_fixed_rounded, color: AppColors.goldSilkS, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Enable GPS Live Tracking',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isGpsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _isGpsEnabled = val;
                          });
                        },
                        activeThumbColor: AppColors.goldSilkS,
                        activeTrackColor: AppColors.goldSilkS.withValues(alpha: 0.3),
                        inactiveThumbColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[800],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Mandatory Documents',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadField('ID Proof*'),
                const SizedBox(height: 20),
                _buildDocumentUploadField('Aadhar Card Photo*'),
                const SizedBox(height: 20),
                _buildDocumentUploadField('PAN Card Photo*'),
                const SizedBox(height: 20),
                _buildDocumentUploadField('GST Bill*'),
                const SizedBox(height: 20),
                _buildDocumentUploadField('Shop Location GPS Photo*'),
                const SizedBox(height: 20),
                _buildDocumentUploadField('Shop Ownership Certificate*'),
                const SizedBox(height: 20),
                _buildDocumentUploadField('Shop Photo*'),
                const SizedBox(height: 32),
                
                // --- Payment Details Section ---
                Text(
                  'Payment Details',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Payment type:',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      value: _selectedPaymentType,
                      hint: Text('Select Payment Type', style: GoogleFonts.outfit(color: Colors.white38)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                      items: ['Bank Transfer', 'UPI', 'PayPal'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPaymentType = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildInputField('Account Holder Name:', Icons.person_rounded, 'Enter account holder name'),
                const SizedBox(height: 20),
                _buildInputField('Bank Name:', Icons.account_balance_rounded, 'Enter bank name'),
                const SizedBox(height: 20),
                _buildInputField('Account Number:', Icons.numbers_rounded, 'Enter account number', isNumber: true),
                const SizedBox(height: 20),
                _buildInputField('IFSC Code:', Icons.account_balance_wallet_rounded, 'Enter IFSC code'),
                const SizedBox(height: 20),
                _buildInputField('UPI ID (Optional):', Icons.payment_rounded, 'Enter UPI ID (e.g., yourname@upi)'),
                const SizedBox(height: 20),
                _buildInputField('PAN Card No:', Icons.badge_rounded, 'Enter PAN card number'),
                
                const SizedBox(height: 48),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldSilkS,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: AppColors.goldSilkS.withValues(alpha: 0.5),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Text(
                            'Submit Registration',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost there!',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please fill out the following information to verify your profile.',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, IconData icon, String hint, {bool isNumber = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldSilkS.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.goldSilkS.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.goldSilkS.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.goldSilkS),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.goldSilkS.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldSilkS.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedDocuments[label]?.name ?? 'Upload file',
                  style: GoogleFonts.outfit(
                    color: _selectedDocuments[label] != null ? Colors.white : Colors.white38,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () => _pickDocument(label, ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldSilkS.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: AppColors.goldSilkS, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _pickDocument(label, ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldSilkS.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.goldSilkS, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSkillSelectionSheet(String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_categoryIcons[category], color: AppColors.goldSilkS, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _skillCategories[category]!.map((skill) {
                      bool isSelected = _selectedSkills.contains(skill);
                      return ChoiceChip(
                        label: Text(skill, style: GoogleFonts.outfit(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
                        selected: isSelected,
                        selectedColor: AppColors.goldSilkS,
                        backgroundColor: const Color(0xFF2A2A2A),
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                          setState(() {}); 
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldSilkS,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Done', style: GoogleFonts.outfit(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
