import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart'; // Import the login page for navigation
import 'constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to show a styled message (SnackBar)
  void showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      ),
    );
  }

  // Function to validate email format
  bool isValidEmail(String email) {
    // Corrected regex to be more robust and fix the typo.
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  }

  // Function to handle user registration
  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        var url = Uri.parse("$BASE_API_URL/register.php");
        var response = await http.post(
          url,
          body: {
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
          },
        );

        if (!mounted) return;
        var data = jsonDecode(response.body);

        if (data["success"]) {
          showMessage("Registration successful!", isError: false);
          // Navigate to login page on success.
          // Using pushReplacement to prevent going back to registration.
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else {
          showMessage(data["message"]);
        }
      } catch (e) {
        if (!mounted) return;
        showMessage("Failed to connect. Please check your internet connection.");
        print("Error: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? Colors.blue.shade200 : Color(0xFF1C3869);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final Color cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final Color inputFillColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final Color linkColor = isDark ? Colors.blue.shade300 : Color(0xFF294E96);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/start_bg.png"),
            fit: BoxFit.cover,
            colorFilter: isDark ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken) : null,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/logo.png', // Use your logo asset
                        height: 120,
                      ),
                      SizedBox(height: 15),
                      // Card for the form
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Color.fromARGB(255, 185, 143, 88), width: 2.0),
                        ),
                        color: cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Get Started",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                              ),
                              Text(
                                "Let’s get started by filling out the form below.",
                                style: TextStyle(fontSize: 14, color: secondaryTextColor),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              // Full Name Input
                              TextFormField(
                                controller: nameController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  prefixIcon: Icon(Icons.person, color: primaryColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                              ),
                              SizedBox(height: 16),
                              // Email Input
                              TextFormField(
                                controller: emailController,
                                style: TextStyle(color: textColor),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.email, color: primaryColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                                ),
                                validator: (value) => value!.isEmpty || !isValidEmail(value) ? 'Please enter a valid email' : null,
                              ),
                              SizedBox(height: 16),
                              // Password Input
                              TextFormField(
                                controller: passwordController,
                                style: TextStyle(color: textColor),
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: secondaryTextColor),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                ),
                                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                              ),
                              SizedBox(height: 16),
                              // Confirm Password Input
                              TextFormField(
                                controller: confirmPasswordController,
                                style: TextStyle(color: textColor),
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: "Re-type Password",
                                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: secondaryTextColor),
                                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  ),
                                ),
                                validator: (value) => value != passwordController.text ? 'Passwords do not match' : null,
                              ),
                              SizedBox(height: 24),
                              // Create Account Button
                              _isLoading
                                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor))
                                  : ElevatedButton(
                                      onPressed: registerUser,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: Size(double.infinity, 55),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 5,
                                      ),
                                      child: Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Navigation to Login Page
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: secondaryTextColor),
                            children: [
                              TextSpan(
                                text: "Sign In here",
                                style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}