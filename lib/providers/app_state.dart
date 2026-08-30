import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';
import '../services/sos_service.dart';

enum UserRole {
  none,
  customer,
  provider,
  shopKeeper,
}

enum BookingStatus {
  findingProvider,
  providerAssigned,
  arrived,
  inProgress,
  completed,
}

class Booking {
  final String id;
  final String category;
  final String serviceName;
  final double price;
  final String date;
  final String timeSlot;
  final String address;
  final String customerName;
  BookingStatus status;
  String? providerId;
  String? providerName;
  String? providerPhone;
  double? providerRating;

  Booking({
    required this.id,
    required this.category,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.customerName,
    this.status = BookingStatus.findingProvider,
    this.providerId,
    this.providerName,
    this.providerPhone,
    this.providerRating,
  });
}

class ServiceCategory {
  final String id;
  final String name;
  final String iconName;
  final String description;
  final List<ServiceItem> items;
  final bool isHome; // true for Home, false for Auto

  ServiceCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.description,
    required this.items,
    required this.isHome,
  });
}

class ServiceItem {
  final String id;
  final String name;
  final double basePrice;
  final String duration;
  final String description;

  ServiceItem({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.duration,
    required this.description,
  });
}

class CountryData {
  final String code;
  final String name;
  final String currencySymbol;
  final double exchangeRate;
  final String flag;

  CountryData({
    required this.code,
    required this.name,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.flag,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String iconName;
  final String shopkeeperId;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.iconName,
    required this.shopkeeperId,
    required this.category,
  });
}

class ShopOrder {
  final String orderId;
  final Product product;
  final int quantity;
  final String technicianId;
  final String collectionCode;
  bool isCollected;

  ShopOrder({
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.technicianId,
    required this.collectionCode,
    this.isCollected = false,
  });
}


class AppState extends ChangeNotifier {
  final SosService _sosService = SosService();

  // Country & Currency State
  final List<CountryData> availableCountries = [
    CountryData(code: 'IN', name: 'India', currencySymbol: '₹', exchangeRate: 83.50, flag: '🇮🇳'),
    CountryData(code: 'US', name: 'United States', currencySymbol: '\$', exchangeRate: 1.0, flag: '🇺🇸'),
    CountryData(code: 'UK', name: 'United Kingdom', currencySymbol: '£', exchangeRate: 0.79, flag: '🇬🇧'),
    CountryData(code: 'AE', name: 'United Arab Emirates', currencySymbol: 'د.إ', exchangeRate: 3.67, flag: '🇦🇪'),
    CountryData(code: 'EU', name: 'Europe', currencySymbol: '€', exchangeRate: 0.92, flag: '🇪🇺'),
    CountryData(code: 'CN', name: 'China', currencySymbol: '¥', exchangeRate: 7.24, flag: '🇨🇳'),
  ];

  late CountryData _selectedCountry;

  AppState() {
    _selectedCountry = availableCountries[0]; // Now defaults to India
  }

  CountryData get selectedCountry => _selectedCountry;

  void setCountry(CountryData country) {
    _selectedCountry = country;
    notifyListeners();
  }

  String formatPrice(double basePriceInUSD) {
    final converted = basePriceInUSD * _selectedCountry.exchangeRate;
    return '${_selectedCountry.currencySymbol}${converted.toStringAsFixed(2)}';
  }

  // Language State
  String _selectedLanguageCode = 'en'; // default to English

  String get selectedLanguageCode => _selectedLanguageCode;

  void setLanguage(String langCode) {
    _selectedLanguageCode = langCode;
    notifyListeners();
  }

  // Authentication State
  UserRole _currentRole = UserRole.none;
  String? _currentUserEmail;
  String? _currentUserName;
  UserModel? _currentUserModel;

  UserRole get currentRole => _currentRole;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  UserModel? get currentUserModel => _currentUserModel;

  void setUserModel(UserModel userModel) {
    _currentUserModel = userModel;
    _currentRole = userModel.role;
    _currentUserEmail = userModel.email;
    _currentUserName = userModel.fullName.isNotEmpty ? userModel.fullName : userModel.email.split('@')[0];
    notifyListeners();
  }

  // Provider Specific State
  bool _isProviderRegistrationComplete = false;
  bool _isProviderOnline = false;
  bool _isGpsTrackingOn = false;
  double _providerEarnings = 350.00;
  int _completedJobsCount = 8;
  List<String> _providerSkills = ['AC Deep Cleaning', 'Premium Auto Detail', 'Brake Calibration'];
  
  bool get isProviderRegistrationComplete => _isProviderRegistrationComplete;
  bool get isProviderOnline => _isProviderOnline;
  bool get isGpsTrackingOn => _isGpsTrackingOn;
  double get providerEarnings => _providerEarnings;
  int get completedJobsCount => _completedJobsCount;
  List<String> get providerSkills => _providerSkills;
  
  void setProviderRegistrationComplete(bool isComplete) {
    _isProviderRegistrationComplete = isComplete;
    notifyListeners();
  }

  // Shopkeeper Specific State
  bool _isShopProfileComplete = false;
  String _shopName = 'Your Shop Name';
  String _shopLocation = 'Your Location';
  String _shopDescription = 'Update your shop description to attract more customers.';
  String _shopLicenseNumber = '';
  String _bankAccountNumber = '';
  double _shopRevenue = 45200.0;

  bool get isShopProfileComplete => _isShopProfileComplete;
  String get shopName => _shopName;
  String get shopLocation => _shopLocation;
  String get shopDescription => _shopDescription;
  String get shopLicenseNumber => _shopLicenseNumber;
  String get bankAccountNumber => _bankAccountNumber;
  double get shopRevenue => _shopRevenue;

  void updateShopProfile(String name, String location, String description, String license, String account) {
    _shopName = name;
    _shopLocation = location;
    _shopDescription = description;
    _shopLicenseNumber = license;
    _bankAccountNumber = account;
    _isShopProfileComplete = true;
    notifyListeners();
  }

  void withdrawFunds(double amount) {
    if (_shopRevenue >= amount) {
      _shopRevenue -= amount;
      notifyListeners();
    }
  }

  // Marketplace State
  final List<Product> _marketplaceProducts = [
    Product(id: 'p1', name: 'Premium Synthetic Engine Oil (5W-30)', price: 45.0, originalPrice: 60.0, iconName: 'water_drop', shopkeeperId: 'shop1', category: 'Auto'),
    Product(id: 'p2', name: 'Car Brake Shoe Set', price: 85.0, originalPrice: 110.0, iconName: 'car_repair', shopkeeperId: 'shop1', category: 'Auto'),
    Product(id: 'p3', name: 'AC Copper Pipe Roll (15m)', price: 120.0, originalPrice: 150.0, iconName: 'plumbing', shopkeeperId: 'shop2', category: 'Home'),
    Product(id: 'p4', name: 'R32 Refrigerant Gas Cylinder (AC Spare)', price: 95.0, originalPrice: 130.0, iconName: 'propane', shopkeeperId: 'shop2', category: 'Home'),
    Product(id: 'p5', name: 'Heavy Duty Jump Starter', price: 150.0, iconName: 'battery_charging_full', shopkeeperId: 'shop1', category: 'Auto'),
    Product(id: 'p6', name: 'Gas Stove Knob Replacement', price: 12.0, originalPrice: 15.0, iconName: 'kitchen', shopkeeperId: 'shop2', category: 'Home'),
  ];
  
  final List<ShopOrder> _shopOrders = [];
  
  List<Product> get marketplaceProducts => _marketplaceProducts;
  List<ShopOrder> get shopOrders => _shopOrders;

  Future<void> addProduct(Product product) async {
    _marketplaceProducts.add(product);
    notifyListeners();

    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('products');
      await ref.child(product.id).set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'originalPrice': product.originalPrice,
        'iconName': product.iconName,
        'shopkeeperId': product.shopkeeperId,
        'category': product.category,
        'createdAt': DateTime.now().toIso8601String(),
      });
      debugPrint('Product saved to Firebase successfully!');
    } catch (e) {
      debugPrint('Error saving to Firebase: $e');
    }
  }

  void removeProduct(String id) {
    _marketplaceProducts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateProductPrice(String id, double newPrice) {
    final index = _marketplaceProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = _marketplaceProducts[index];
      _marketplaceProducts[index] = Product(
        id: old.id,
        name: old.name,
        price: newPrice,
        originalPrice: old.originalPrice,
        iconName: old.iconName,
        shopkeeperId: old.shopkeeperId,
        category: old.category,
      );
      notifyListeners();
    }
  }

  
  String placeShopOrder(Product product, int quantity) {
    // Generate a 6-digit code
    final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    final order = ShopOrder(
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      quantity: quantity,
      technicianId: _currentUserEmail ?? 'tech_1',
      collectionCode: code,
    );
    _shopOrders.add(order);
    notifyListeners();
    return code;
  }
  
  bool verifyShopOrder(String collectionCode) {
    final index = _shopOrders.indexWhere((o) => o.collectionCode == collectionCode && !o.isCollected);
    if (index != -1) {
      _shopOrders[index].isCollected = true;
      notifyListeners();
      return true;
    }
    return false;
  }


  // Global Bookings List
  final List<Booking> _bookings = [
    Booking(
      id: 'FX-9105',
      category: 'AC Services',
      serviceName: 'AC Maintenance & Deep Cleaning',
      price: 110.00,
      date: '2026-06-20',
      timeSlot: '09:00 AM - 11:00 AM',
      address: '123 Ocean Drive, Miami',
      customerName: 'Sarah Connor',
      status: BookingStatus.findingProvider,
    ),
    Booking(
      id: 'FX-9112',
      category: 'Auto Mechanic',
      serviceName: 'Brake Pad Replacement & Calibration',
      price: 135.00,
      date: '2026-06-21',
      timeSlot: '01:00 PM - 03:00 PM',
      address: '456 Industrial Pkwy, Miami',
      customerName: 'Tony Stark',
      status: BookingStatus.findingProvider,
    ),
    Booking(
      id: 'FX-9082',
      category: 'Home Solutions',
      serviceName: 'AC Maintenance & Deep Cleaning',
      price: 85.00,
      date: '2026-05-30',
      timeSlot: '10:00 AM - 12:00 PM',
      address: '742 Evergreen Terrace, Springfield',
      customerName: 'Homer Simpson',
      status: BookingStatus.completed,
      providerName: 'Alex Mercer (You)',
      providerPhone: '+1 (555) 987-6543',
      providerRating: 4.9,
    ),
    Booking(
      id: 'FX-8841',
      category: 'Auto Solutions',
      serviceName: 'Full Exterior Detail & Ceramic Wax',
      price: 150.00,
      date: '2026-05-28',
      timeSlot: '02:00 PM - 04:00 PM',
      address: '1000 Richmond Way, Beverly Hills',
      customerName: 'Bruce Wayne',
      status: BookingStatus.completed,
      providerName: 'Alex Mercer (You)',
      providerPhone: '+1 (555) 987-6543',
      providerRating: 4.9,
    )
  ];

  List<Booking> get bookings => _bookings;

  // Available Service Directory
  final List<ServiceCategory> categories = [
    // Home Categories
    ServiceCategory(
      id: 'home_ac',
      name: 'AC Services',
      iconName: 'ac_unit',
      description: 'Premium cooling solutions & vent cleaning.',
      isHome: true,
      items: [
        ServiceItem(id: 'ac_clean', name: 'AC Deep Cleaning & Disinfection', basePrice: 89.0, duration: '1.5 hrs', description: 'Complete filter, coil, and drain tray wash with antibacterial coating.'),
        ServiceItem(id: 'ac_repair', name: 'AC Repair & Troubleshooting', basePrice: 120.0, duration: '2 hrs', description: 'Gas leak checks, compressor diagnostic, electrical repair.'),
        ServiceItem(id: 'ac_install', name: 'Full Unit Installation', basePrice: 250.0, duration: '3 hrs', description: 'Mounting, copper piping, vacuuming, testing of new split AC.'),
      ]
    ),
    ServiceCategory(
      id: 'home_electrical',
      name: 'Electrical Solutions',
      iconName: 'bolt',
      description: 'Certified electricians for smart home & power restoration.',
      isHome: true,
      items: [
        ServiceItem(id: 'elec_fixture', name: 'Smart Light & Fixture Fitting', basePrice: 59.0, duration: '1 hr', description: 'Secure installation of chandeliers, sconces, or smart switches.'),
        ServiceItem(id: 'elec_rewire', name: 'Short Circuit & Wiring Fault Diagnosis', basePrice: 99.0, duration: '1.5 hrs', description: 'Trace and repair unstable currents, tripping breakers, or heat damage.'),
      ]
    ),
    ServiceCategory(
      id: 'home_cleaning',
      name: 'Deep Cleaning',
      iconName: 'clean_hands',
      description: 'Hotel-grade sanitization for home environments.',
      isHome: true,
      items: [
        ServiceItem(id: 'clean_full', name: 'Premium Villa/Appt Deep Clean', basePrice: 199.0, duration: '4 hrs', description: 'Full upholstery vacuuming, window track cleaning, floor steam wash.'),
        ServiceItem(id: 'clean_sofa', name: 'Sofa & Carpet Shampoing', basePrice: 79.0, duration: '2 hrs', description: 'Lifting stains, pet odor extraction, and fiber refreshment.'),
      ]
    ),
    ServiceCategory(
      id: 'home_plumbing',
      name: 'Expert Plumbing',
      iconName: 'plumbing',
      description: 'Quick leak patching, pressure adjustment & fixtures.',
      isHome: true,
      items: [
        ServiceItem(id: 'plumb_leak', name: 'Pipe Repair & Leak Stopping', basePrice: 65.0, duration: '1 hr', description: 'Fix undersink leaks, pipe joint adjustments, high-pressure sealing.'),
        ServiceItem(id: 'plumb_install', name: 'Premium Tap & Commode Fitting', basePrice: 110.0, duration: '1.5 hrs', description: 'Install high-end fixtures with precise alignment & sealing.'),
      ]
    ),

    // Auto Categories
    ServiceCategory(
      id: 'auto_detailing',
      name: 'Premium Detailing',
      iconName: 'directions_car',
      description: 'Showroom shine delivered to your garage.',
      isHome: false,
      items: [
        ServiceItem(id: 'auto_ceramic', name: 'Ceramic Coating & Paint Polish', basePrice: 299.0, duration: '5 hrs', description: 'Dual-action clay bar, fine polish, and application of 9H shield.'),
        ServiceItem(id: 'auto_wash', name: 'Interior & Exterior Premium Wash', basePrice: 75.0, duration: '1.5 hrs', description: 'Foam wash, alloy cleaning, vacuuming, interior leather conditioning.'),
      ]
    ),
    ServiceCategory(
      id: 'auto_mechanic',
      name: 'Mobile Mechanic',
      iconName: 'build',
      description: 'Brake pads, diagnostic scan, oil changes on the go.',
      isHome: false,
      items: [
        ServiceItem(id: 'mech_oil', name: 'Engine Oil & Filter Swap', basePrice: 85.0, duration: '45 mins', description: 'Synthetic oil replacement, new filter, fluid level checks.'),
        ServiceItem(id: 'mech_brake', name: 'Brake Pad Replacement & Calibration', basePrice: 135.0, duration: '1.5 hrs', description: 'Replace front/rear brake pads, inspection of calipers and fluid.'),
      ]
    ),
    ServiceCategory(
      id: 'auto_roadside',
      name: 'Roadside Help',
      iconName: 'support_agent',
      description: 'Battery jumpstarts, tyre patch, and fuel delivery.',
      isHome: false,
      items: [
        ServiceItem(id: 'road_battery', name: 'Jumpstart & Battery Health Check', basePrice: 49.0, duration: '30 mins', description: 'Portable jump start and testing alternator output.'),
        ServiceItem(id: 'road_tyre', name: 'Tyre Swap / Puncture Fix', basePrice: 55.0, duration: '45 mins', description: 'Mounting spare tyre or patching nail holes on-site.'),
      ]
    )
  ];

  // Logic Functions
  void selectRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  bool login(String email, String password, UserRole role) {
    if (email.isEmpty || password.isEmpty) return false;
    
    // Simulate generic validation
    _currentRole = role;
    _currentUserEmail = email;
    _currentUserName = email.split('@')[0].toUpperCase();
    
    if (role == UserRole.provider) {
      _currentUserName = "Alex Mercer"; // Service Person Name
    } else if (role == UserRole.shopKeeper) {
      _currentUserName = "Shop Owner";
    } else {
      if (_currentUserName == "CUSTOMER") _currentUserName = "John Doe";
    }

    notifyListeners();
    return true;
  }

  void logout() {
    _currentRole = UserRole.none;
    _currentUserEmail = null;
    _currentUserName = null;
    _currentUserModel = null;
    _isProviderOnline = false;
    notifyListeners();
  }

  // Provider actions
  void toggleProviderOnline() {
    _isProviderOnline = !_isProviderOnline;
    notifyListeners();
    
    final providerId = _currentUserEmail?.replaceAll('.', '_') ?? 'unknown_provider';
    final DatabaseReference locRef = FirebaseDatabase.instance.ref('providers/$providerId/location');
    
    // Update online status in Firebase
    locRef.update({
      'isOnline': _isProviderOnline,
    });
  }

  StreamSubscription<Position>? _providerLocationStream;

  void toggleGpsTracking() async {
    _isGpsTrackingOn = !_isGpsTrackingOn;
    notifyListeners();

    final providerId = _currentUserEmail?.replaceAll('.', '_') ?? 'unknown_provider';
    final DatabaseReference locRef = FirebaseDatabase.instance.ref('providers/$providerId/location');

    if (_isGpsTrackingOn) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      _providerLocationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position position) {
        locRef.set({
          'lat': position.latitude,
          'lng': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'isOnline': _isProviderOnline,
          'name': _currentUserName,
        });
      });
    } else {
      _providerLocationStream?.cancel();
      locRef.remove();
    }
  }

  void updateProviderSkills(List<String> newSkills) {
    _providerSkills = newSkills;
    notifyListeners();
  }

  // Booking actions
  Future<void> createBooking({
    required String categoryName,
    required String serviceName,
    required double price,
    required String date,
    required String timeSlot,
    required String address,
  }) async {
    final bookingId = 'FX-${(1000 + _bookings.length * 3 + 17).toString()}';
    final customerId = _currentUserEmail?.replaceAll('.', '_') ?? 'unknown_customer';
    
    final newBooking = Booking(
      id: bookingId,
      category: categoryName,
      serviceName: serviceName,
      price: price,
      date: date,
      timeSlot: timeSlot,
      address: address,
      customerName: _currentUserName ?? 'Valued Customer',
      status: BookingStatus.findingProvider,
    );
    
    _bookings.insert(0, newBooking); // Insert locally
    notifyListeners();

    try {
      // 1. Get customer location
      final customerPos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

      // 2. Query all providers from Firebase
      final DatabaseReference providersRef = FirebaseDatabase.instance.ref('providers');
      final snapshot = await providersRef.get();
      
      String? closestProviderId;
      double minDistance = double.infinity;

      if (snapshot.exists) {
        final providers = snapshot.value as Map<dynamic, dynamic>;
        
        providers.forEach((provId, data) {
          if (data['location'] != null) {
            final loc = data['location'];
            final isOnline = loc['isOnline'] ?? false;
            
            if (isOnline) {
              final double provLat = (loc['lat'] as num).toDouble();
              final double provLng = (loc['lng'] as num).toDouble();
              
              final distance = Geolocator.distanceBetween(
                customerPos.latitude, customerPos.longitude,
                provLat, provLng
              );
              
              if (distance < minDistance) {
                minDistance = distance;
                closestProviderId = provId;
              }
            }
          }
        });
      }

      // 3. Dispatch to the closest provider
      if (closestProviderId != null) {
        debugPrint('Dispatching to closest provider: $closestProviderId (Distance: ${minDistance.toStringAsFixed(0)}m)');
        
        final reqRef = FirebaseDatabase.instance.ref('providers/$closestProviderId/requests/$bookingId');
        await reqRef.set({
          'bookingId': bookingId,
          'customerId': customerId,
          'customerName': newBooking.customerName,
          'serviceName': serviceName,
          'address': address,
          'price': price,
          'status': 'pending',
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        // Listen to this specific request for acceptance
        reqRef.onValue.listen((event) {
          if (event.snapshot.exists) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            if (data['status'] == 'accepted') {
              // Provider accepted!
              final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
              if (bookingIndex != -1) {
                _bookings[bookingIndex].status = BookingStatus.providerAssigned;
                _bookings[bookingIndex].providerId = closestProviderId;
                _bookings[bookingIndex].providerName = data['providerName'] ?? 'Technician';
                _bookings[bookingIndex].providerPhone = data['providerPhone'] ?? '+1 555-0000';
                _bookings[bookingIndex].providerRating = 5.0;
                notifyListeners();
              }
            }
          }
        });
        
      } else {
        debugPrint('No online providers found nearby.');
      }
      
    } catch (e) {
      debugPrint('Error dispatching booking: $e');
    }
  }

  void acceptBooking(String bookingId) {
    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex != -1) {
      _bookings[bookingIndex].status = BookingStatus.providerAssigned;
      _bookings[bookingIndex].providerName = _currentUserName ?? "Alex Mercer";
      _bookings[bookingIndex].providerPhone = "+1 (555) 302-8841";
      _bookings[bookingIndex].providerRating = 4.95;
      notifyListeners();
      
      // Update Firebase if this is a live request
      final providerId = _currentUserEmail?.replaceAll('.', '_') ?? 'unknown_provider';
      final reqRef = FirebaseDatabase.instance.ref('providers/$providerId/requests/$bookingId');
      reqRef.update({
        'status': 'accepted',
        'providerName': _bookings[bookingIndex].providerName,
        'providerPhone': _bookings[bookingIndex].providerPhone,
      });
    }
  }

  void advanceBookingStatus(String bookingId) {
    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex != -1) {
      final currentStatus = _bookings[bookingIndex].status;
      if (currentStatus == BookingStatus.providerAssigned) {
        _bookings[bookingIndex].status = BookingStatus.arrived;
      } else if (currentStatus == BookingStatus.arrived) {
        _bookings[bookingIndex].status = BookingStatus.inProgress;
      } else if (currentStatus == BookingStatus.inProgress) {
        _bookings[bookingIndex].status = BookingStatus.completed;
        // Credit the provider
        _providerEarnings += _bookings[bookingIndex].price;
        _completedJobsCount += 1;
      }
      notifyListeners();
    }
  }

  // SOS State
  bool _isSosActive = false;
  bool get isSosActive => _isSosActive;

  Future<void> triggerSos() async {
    _isSosActive = true;
    notifyListeners();

    final success = await _sosService.sendSosAlert(
      userEmail: _currentUserEmail ?? 'unknown_user',
      location: 'Current GPS Coordinates (Mocked)',
    );

    if (success) {
      // Keep it active or handle success logic
    } else {
      _isSosActive = false; // revert if failed
      notifyListeners();
    }
  }

  void cancelSos() {
    _isSosActive = false;
    notifyListeners();
  }
}
