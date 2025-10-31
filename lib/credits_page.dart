import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
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
          "Credits",
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
                      Icons.people_alt_outlined, // A more modern icon for credits.
                      size: 60,
                      color: primaryColor, // Icon color adapts to the theme.
                    ),
                    SizedBox(height: 16),

                    // --- Title Section ---
                    Text(
                      "Our Contributors",
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

                    // --- Credits List ---
                    _buildCreditItem(
                      context,
                      'Development & UI/UX Design',
                      'Ikhwan Syafiq Mohamad Shaipudin',
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildCreditItem(
                      context,
                      '3D Hand Animation & Assets',
                      'Danial Syakir',
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildCreditItem(
                      context,
                      'Font & Icons',
                      'Google Fonts (Poppins, Inter), Material Icons',
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildCreditItem(
                      context,
                      'Framework',
                      'Flutter & Dart',
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

  // Helper method to build a consistent credit item.
  Widget _buildCreditItem(BuildContext context, String role, String name, bool isDark) {
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color primaryColor = isDark ? Colors.blue.shade200 : Colors.blue.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          role,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blue.shade100 : Colors.blue.shade800, // Highlight the role.
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}