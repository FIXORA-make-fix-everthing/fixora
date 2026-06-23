import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isEditing = false;
  XFile? _pickedProfilePhoto;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController(text: "Alex Mercer");
  final TextEditingController _phoneController = TextEditingController(text: "+1 (555) 987-6543");
  final TextEditingController _emailController = TextEditingController(text: "alex.mercer@example.com");
  final TextEditingController _experienceController = TextEditingController(text: "5 Years");
  final TextEditingController _bioController = TextEditingController(text: "Certified technician specializing in AC and Auto repair. Providing top-tier service across the city.");

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
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
          'Edit Profile',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile details updated successfully!'),
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
            Center(
              child: InkWell(
                onTap: isEditing ? () async {
                  try {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _pickedProfilePhoto = image;
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open gallery: $e'), backgroundColor: Colors.red));
                    }
                  }
                } : null,
                borderRadius: BorderRadius.circular(50),
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _pickedProfilePhoto != null ? Colors.green : const Color(0xFFC5A059), width: 2),
                        image: DecorationImage(
                          image: _pickedProfilePhoto != null 
                            ? FileImage(File(_pickedProfilePhoto!.path)) as ImageProvider
                            : const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC5A059),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),
            _buildTextField('Full Name', _nameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', _phoneController, Icons.phone),
            const SizedBox(height: 16),
            _buildTextField('Email Address', _emailController, Icons.email),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Professional Background'),
            const SizedBox(height: 16),
            _buildTextField('Years of Experience', _experienceController, Icons.work_history),
            const SizedBox(height: 16),
            _buildTextField('Short Bio', _bioController, Icons.description, maxLines: 3),
            
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
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
          maxLines: maxLines,
          style: GoogleFonts.outfit(
            color: isEditing ? Colors.white : Colors.grey[300],
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: isEditing ? const Color(0xFFC5A059) : Colors.grey[600], size: 18) : null,
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
}
