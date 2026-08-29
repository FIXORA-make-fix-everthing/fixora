import '../providers/app_state.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.location,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  // Role conversion helpers
  static UserRole roleFromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'provider':
      case 'technician':
        return UserRole.provider;
      case 'shopkeeper':
      case 'shop_keeper':
        return UserRole.shopKeeper;
      default:
        return UserRole.none;
    }
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'customer';
      case UserRole.provider:
        return 'provider';
      case UserRole.shopKeeper:
        return 'shopKeeper';
      default:
        return 'none';
    }
  }

  // Convert UserModel to Map for Firestore write
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'location': location,
      'role': roleToString(role),
      'createdAt': createdAt != null ? createdAt!.toIso8601String() : DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Factory constructor from Firestore DocumentSnapshot / Map
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic date) {
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    return UserModel(
      uid: map['uid'] ?? docId,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      role: roleFromString(map['role'] ?? 'none'),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}
