import 'package:flutter/foundation.dart';

class SosService {
  /// Simulates sending an SOS alert to a backend or external API (like Twilio).
  Future<bool> sendSosAlert({
    required String userEmail,
    required String location,
    String? additionalDetails,
  }) async {
    try {
      debugPrint('🚨 SOS ALERT INITIATED 🚨');
      debugPrint('User: $userEmail');
      debugPrint('Location: $location');
      if (additionalDetails != null) {
        debugPrint('Details: $additionalDetails');
      }

      // Mock network delay
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('✅ SOS Alert successfully dispatched to security dispatch center.');
      
      return true; // Simulate success
    } catch (e) {
      debugPrint('❌ Failed to send SOS alert: $e');
      return false; // Simulate failure
    }
  }
}
