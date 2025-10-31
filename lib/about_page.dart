import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
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
          "About App",
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
                : [Colors.blue.shade200, Colors.white], // Changed gradient for a softer look.
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60), // Added vertical padding to avoid content being under the AppBar.
            child: Card(
              // The main content is placed within a Card for a clean, contained look.
              margin: EdgeInsets.all(0), // Removed margin from here to the SingleChildScrollView padding.
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
                    // --- App Logo/Icon ---
                    Icon(
                      Icons.info_outline,
                      size: 60,
                      color: primaryColor, // Icon color adapts to the theme.
                    ),
                    SizedBox(height: 16),

                    // --- Title Section ---
                    Text(
                      "About SignSpell",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),

                    // --- Subtitle/Version ---
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),
                    Divider(
                      thickness: 1,
                      color: dividerColor, // Divider color adapts to the theme.
                    ),
                    SizedBox(height: 24),

                    // --- Description Section ---
                    Text(
                      "SignSpell is a dynamic and intuitive application designed to help users learn and practice finger-spelling in sign language. Our goal is to bridge the communication gap by providing an accessible and engaging platform for learning.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: textColor,
                      ),
                      textAlign: TextAlign.justify, // Changed alignment for better readability.
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Simply type any text, and watch as it's transformed into a clear 3D animation, spelling out each letter with precision and clarity. Whether you're a beginner or looking to improve your skills, SignSpell is your perfect learning companion.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: textColor,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 30),

                    // --- Credits Section ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Developed by:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Ikhwan Syafiq", // Replace with your name/team name.
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
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