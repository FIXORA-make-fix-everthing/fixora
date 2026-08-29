import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareAnalytics = true;
  bool _personalizedAds = false;
  bool _locationAccess = true;
  bool _contactSync = false;

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF00E5FF),
            activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
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
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
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
          'PRIVACY SETTINGS',
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
              'DATA & PERMISSIONS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF5A00),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Precise Location Access',
              subtitle: 'Allow Fixora to access your exact location to find nearby technicians faster.',
              value: _locationAccess,
              onChanged: (val) => setState(() => _locationAccess = val),
            ),
            _buildSwitchTile(
              title: 'Share Usage Analytics',
              subtitle: 'Help us improve by sharing anonymous usage data and crash reports.',
              value: _shareAnalytics,
              onChanged: (val) => setState(() => _shareAnalytics = val),
            ),
            _buildSwitchTile(
              title: 'Personalized Ads',
              subtitle: 'Allow us to show ads and offers tailored to your interests.',
              value: _personalizedAds,
              onChanged: (val) => setState(() => _personalizedAds = val),
            ),
            _buildSwitchTile(
              title: 'Sync Contacts',
              subtitle: 'Find friends on Fixora and easily share referral codes.',
              value: _contactSync,
              onChanged: (val) => setState(() => _contactSync = val),
            ),
            
            const SizedBox(height: 24),
            Text(
              'DATA MANAGEMENT',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF5A00),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              title: 'Download My Data',
              subtitle: 'Request a copy of your personal data stored by Fixora',
              icon: Icons.download_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data download request sent to your email.')),
                );
              },
            ),
            _buildActionTile(
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all associated data',
              icon: Icons.delete_forever_rounded,
              onTap: () {
                // Show confirmation dialog in real app
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
