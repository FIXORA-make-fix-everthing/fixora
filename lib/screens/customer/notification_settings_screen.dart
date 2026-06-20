import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _specialDeals = true;
  bool _bookingUpdates = true;
  bool _promotionalMessages = false;
  String _selectedTune = 'Default (Fixora Chime)';

  final List<String> _tunes = [
    'Default (Fixora Chime)',
    'Classic Bell',
    'Modern Pulse',
    'Soft Beep',
    'Silent (Vibrate Only)'
  ];

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: _allNotifications || title == 'Allow All Notifications' ? onChanged : null,
            activeColor: const Color(0xFFFF5A00),
            activeTrackColor: const Color(0xFFFF5A00).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'NOTIFICATION SETTINGS',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GENERAL',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00E5FF),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Allow All Notifications',
              subtitle: 'Enable or disable all notifications from Fixora',
              value: _allNotifications,
              onChanged: (val) {
                setState(() {
                  _allNotifications = val;
                  if (!val) {
                    _specialDeals = false;
                    _bookingUpdates = false;
                    _promotionalMessages = false;
                  } else {
                    _specialDeals = true;
                    _bookingUpdates = true;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            Text(
              'CATEGORIES',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00E5FF),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Booking Updates',
              subtitle: 'Get notified when technician arrives, starts work, etc.',
              value: _bookingUpdates,
              onChanged: (val) => setState(() => _bookingUpdates = val),
            ),
            _buildSwitchTile(
              title: 'Special Deals',
              subtitle: 'Receive exclusive discounts and special offers',
              value: _specialDeals,
              onChanged: (val) => setState(() => _specialDeals = val),
            ),
            _buildSwitchTile(
              title: 'Promotional Messages',
              subtitle: 'Stay updated with new features and services',
              value: _promotionalMessages,
              onChanged: (val) => setState(() => _promotionalMessages = val),
            ),
            const SizedBox(height: 24),

            Text(
              'SOUND & TUNE',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00E5FF),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTune,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E1E1E),
                  icon: const Icon(Icons.music_note_rounded, color: Color(0xFFFF5A00)),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: _allNotifications
                      ? (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTune = newValue;
                            });
                          }
                        }
                      : null,
                  items: _tunes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the sound that plays when you receive a notification.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notification settings saved!',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                      backgroundColor: Colors.green[800],
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF232D3F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Save Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
