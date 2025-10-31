// edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Required for File
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentEmail;
  final String? currentProfilePicture;

  const EditProfilePage({
    Key? key,
    required this.userId,
    required this.currentName,
    required this.currentEmail,
    this.currentProfilePicture,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  File? _selectedImage; // To store the selected image file

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      ),
    );
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80); // You can adjust imageQuality

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Function to update user profile via API (now handles file upload)
  Future<void> _updateUserProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // If validation fails, immediately return.
      return;
    }

    setState(() {
      _isSaving = true; // Show loading indicator
    });

    try {
      var uri = Uri.parse("$BASE_API_URL/update_user.php");
      var request = http.MultipartRequest('POST', uri);

      // Add text fields to the request
      request.fields['id'] = widget.userId;
      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();

      // Add image file if selected
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', // This key must match the name in your PHP script ($_FILES['profile_picture'])
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last, // Use the actual filename
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return; // Check if widget is still in the tree

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        showMessage("Profile updated successfully!", isError: false);

        // IMPORTANT: If the email was changed, update it in SharedPreferences
        // This ensures the ProfilePage fetches data by the correct email next time.
        if (_emailController.text.trim() != widget.currentEmail) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', _emailController.text.trim());
        }

        // Pop the page and send 'true' back to the previous page (ProfilePage)
        // indicating that a refresh is needed.
        Navigator.of(context).pop(true);
      } else {
        // Show error message from backend
        showMessage(data["message"]);
      }
    } catch (e) {
      if (!mounted) return;
      // Catch any network or parsing errors
      showMessage("Failed to update profile: $e");
      print("Error updating profile: $e"); // Print to console for debugging
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              // The Form widget is crucial for validation to work.
              // It must wrap the TextFormFields and the button that triggers validation.
              child: Form(
                key: _formKey, // Assign the GlobalKey<FormState> here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture Display and Selection
                    GestureDetector(
                      onTap: _pickImage, // Calls the image picker when tapped
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade100,
                            // Logic to display the image:
                            // 1. If a new image is selected (_selectedImage is not null), show it.
                            // 2. Else if a current profile picture URL exists, show the network image.
                            // 3. Otherwise, show a default person icon.
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!) // Display selected local file
                                : (widget.currentProfilePicture != null && widget.currentProfilePicture!.isNotEmpty
                                    ? NetworkImage("$BASE_API_URL/${widget.currentProfilePicture!}") // Display existing network image
                                    : null) as ImageProvider<Object>?, // Cast needed for nullability
                            child: (_selectedImage == null && (widget.currentProfilePicture == null || widget.currentProfilePicture!.isEmpty))
                                ? Icon(Icons.person, size: 60, color: Colors.blue.shade800) // Default icon
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white), // Camera icon
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Name TextField
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Email TextField
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email.';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    // Save Changes Button
                    ElevatedButton.icon(
                      // Button is disabled if _isSaving is true
                      onPressed: _isSaving ? null : _updateUserProfile,
                      icon: _isSaving ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ) : const Icon(Icons.save),
                      label: Text(_isSaving ? "Saving..." : "Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20), // Added some space at the bottom
                  ],
                ),
              ), // End of Form widget
            ),
          ),
        ),
      ),
    );
  }
}