import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  bool isEditing = false;

  final TextEditingController _shopNameController = TextEditingController(text: "Mercer Auto & AC Works");
  final TextEditingController _shopLocationController = TextEditingController(text: "123 Industrial Pkwy, Miami, FL");
  final TextEditingController _aadharController = TextEditingController(text: "1234 5678 9012");
  final TextEditingController _panController = TextEditingController(text: "ABCDE1234F");

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopLocationController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: Text(
          'Business Details',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.check_rounded : Icons.edit_rounded,
              color: const Color(0xFFC5A059),
            ),
            onPressed: () {
              setState(() {
                if (isEditing) {
                  // Save logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Business details updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Shop Information'),
            const SizedBox(height: 16),
            _buildTextField('Shop Name', _shopNameController, Icons.storefront),
            const SizedBox(height: 16),
            _buildTextField('Shop Location', _shopLocationController, Icons.location_on),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Identity Documents'),
            const SizedBox(height: 16),
            
            _buildTextField('Aadhar Card Number', _aadharController, Icons.badge),
            const SizedBox(height: 12),
            _buildDocumentImage('Aadhar Card Picture', 'https://images.unsplash.com/photo-1621360841013-c76831f1e35d?auto=format&fit=crop&w=400&q=80'), // Mock ID pic
            
            const SizedBox(height: 24),
            _buildTextField('PAN Card Number', _panController, Icons.credit_card),
            const SizedBox(height: 12),
            _buildDocumentImage('PAN Card Picture', 'https://images.unsplash.com/photo-1621360841013-c76831f1e35d?auto=format&fit=crop&w=400&q=80'), // Mock ID pic
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFC5A059),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          style: GoogleFonts.outfit(
            color: isEditing ? Colors.white : Colors.grey[300],
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isEditing ? const Color(0xFFC5A059) : Colors.grey[600], size: 18),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC5A059)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentImage(String label, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: isEditing ? null : ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                ),
              ),
            ),
            if (isEditing)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC5A059),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
