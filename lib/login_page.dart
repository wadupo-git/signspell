import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import 'constants.dart';

import 'home_page.dart';
import 'register_page.dart';
import 'admin_login_page.dart'; // Import the new admin login page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController _secretCodeController = TextEditingController(); // New: Controller for secret code

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _showSecretCodeField = false; // New: Controls visibility of secret code input

  int _logoTapCount = 0; // New: Tracks taps on the logo
  final int _adminTapThreshold = 7; // New: Number of taps required to reveal
  final String _secretCode = "admin123"; // Your secret code

  void showMessage(String message, {bool isError = true}) {
    // Ensure the context is still valid before showing the SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating, // Often looks better
        duration: const Duration(seconds: 3), // Added duration for consistency
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Added shape for consistency
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20), // Added margin for consistency
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$").hasMatch(email);
  }

  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showMessage("Email and password are required!");
      return;
    }

    if (!isValidEmail(emailController.text)) {
      showMessage("Invalid email format!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse("$BASE_API_URL/login.php");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      print("Response: ${response.body}"); // Debugging

      // Ensure the widget is still mounted before processing response and setting state
      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', emailController.text);

        showMessage("Login successful!", isError: false);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        showMessage(data["message"]);
      }
    } catch (e) {
      // Ensure the widget is still mounted before showing message
      if (!mounted) return;
      showMessage("Failed to connect. Check your internet.");
      print("Error: $e");
    } finally {
      // Ensure the widget is still mounted before setting state in finally block
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // New: Function to handle logo taps
  void _handleLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= _adminTapThreshold) {
      setState(() {
        _showSecretCodeField = true; // Show the secret code input field
      });
      _logoTapCount = 0; // Reset count after showing the field
      showMessage("Admin Mode: Enter secret code", isError: false);
    }
  }

  // New: Function to check the entered secret code
  void _checkSecretCode() {
    if (_secretCodeController.text == _secretCode) {
      // Navigate to AdminLoginPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginPage()),
      );
      // Optional: Clear fields and hide secret code field after successful navigation
      _secretCodeController.clear();
      if (mounted) { // Check mounted before setState
        setState(() {
          _showSecretCodeField = false; // Hide the field again
        });
      }
    } else {
      showMessage("Invalid secret code!", isError: true);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _secretCodeController.dispose(); // New: Dispose secret code controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/start_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie Animation
                    Lottie.asset(
                      'assets/animations/sign_language.json',
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    // Card Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 185, 143, 88),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Logo - Wrapped with GestureDetector
                          GestureDetector(
                            onTap: _handleLogoTap, // Call the new handler
                            child: Image.asset(
                              'assets/logo.png',
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Fill out the information below to access your account",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Email Input
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Color.fromARGB(255, 28, 56, 105),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            textInputAction: TextInputAction.next, // For keyboard navigation
                          ),
                          const SizedBox(height: 12),
                          // Password Input
                          TextField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Color.fromARGB(255, 28, 56, 105),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            onSubmitted: (_) => loginUser(), // Trigger login on 'Done'
                            textInputAction: TextInputAction.done, // For keyboard navigation
                          ),
                          const SizedBox(height: 20),

                          // New: Secret Code Field (conditionally visible)
                          if (_showSecretCodeField) ...[
                            TextField(
                              controller: _secretCodeController,
                              decoration: InputDecoration(
                                labelText: "Secret Admin Code",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(
                                  Icons.vpn_key,
                                  color: Color.fromARGB(255, 28, 56, 105),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              obscureText: true, // Keep the secret code hidden
                              onSubmitted: (_) => _checkSecretCode(), // Check code on 'Go'
                              textInputAction: TextInputAction.go, // For keyboard navigation
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _checkSecretCode, // Call the new checker function
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 185, 143, 88), // Distinct color for admin button
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  "Go to Admin Login",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20), // Spacing after admin button
                          ],

                          // Login Button (Original)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 28, 56, 105),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Navigation to Register Page
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage())),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don’t have an account? ",
                          style: TextStyle(
                              color: Color.fromARGB(255, 85, 81, 81)),
                          children: [
                            TextSpan(
                              text: "Sign Up here",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 41, 78, 180),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}