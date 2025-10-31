import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the current theme is dark mode.
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors for the light and dark themes for better maintainability.
    final Color primaryColor = isDark ? Colors.blue.shade200 : Colors.blue.shade600;
    final Color cardBackgroundColor = isDark ? Colors.grey.shade900 : Colors.white;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color dividerColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Scaffold(
      // The app bar extends behind the body content for a seamless gradient.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87, // Title color adjusts to the theme.
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Makes the AppBar background transparent.
        elevation: 0, // Removes the shadow under the AppBar.
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87, // Back button color.
        ),
      ),
      body: Container(
        // Use a gradient for the background to match the app's branding.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade200, Colors.white], // Consistent gradient.
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60), // Padding to avoid AppBar overlap.
            child: Card(
              // The main content is placed within a Card for a clean, contained look.
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Increased border-radius for a softer look.
                side: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              elevation: 8, // Increased elevation for a more prominent shadow.
              shadowColor: Colors.black.withOpacity(0.1), // Subtle shadow for depth.
              color: cardBackgroundColor, // Card background color adapts to the theme.
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Icon Section ---
                    Icon(
                      Icons.description_outlined, // Icon for terms and conditions.
                      size: 60,
                      color: primaryColor, // Icon color adapts to the theme.
                    ),
                    SizedBox(height: 16),

                    // --- Title Section ---
                    Text(
                      "Terms of Use",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Divider(
                      thickness: 1,
                      color: dividerColor, // Divider color adapts to the theme.
                    ),
                    SizedBox(height: 24),

                    // --- Terms and Conditions Content ---
                    _buildSection(
                      context,
                      "1. Acceptance of Terms",
                      "By accessing or using the SignSpell application, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use the application.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "2. Use of the App",
                      "The app is provided for educational and personal use only. You may not use the app for any commercial purpose without prior written consent. The content, including 3D animations, is the property of the developers.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "3. User Accounts",
                      "You are responsible for maintaining the confidentiality of your account information. You agree to notify us immediately of any unauthorized use of your account. We reserve the right to terminate accounts that violate these terms.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "4. Disclaimer",
                      "The animations provided in this app are for educational purposes and are a representation of finger-spelling. While we strive for accuracy, the animations may not represent all dialects or variations of sign language.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "5. Changes to Terms",
                      "We reserve the right to modify these terms at any time. Your continued use of the app after any changes signifies your acceptance of the new terms.",
                      isDark,
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

  // Helper method to build a consistent terms section.
  Widget _buildSection(BuildContext context, String title, String content, bool isDark) {
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color primaryColor = isDark ? Colors.blue.shade100 : Colors.blue.shade800;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: textColor,
          ),
          textAlign: TextAlign.justify, // Use justify for paragraphs.
        ),
      ],
    );
  }
}