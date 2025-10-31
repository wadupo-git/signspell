import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
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
          "Privacy Policy",
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
                      Icons.privacy_tip_outlined, // Icon for privacy.
                      size: 60,
                      color: primaryColor, // Icon color adapts to the theme.
                    ),
                    SizedBox(height: 16),

                    // --- Title Section ---
                    Text(
                      "Privacy Policy",
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

                    // --- Privacy Policy Content ---
                    _buildSection(
                      context,
                      "1. Information We Collect",
                      "We collect information that you provide directly to us when you create an account, such as your full name and email address. We do not collect any sensitive personal data.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "2. How We Use Your Information",
                      "The information we collect is used to manage your account, provide app services, and improve your user experience. We may use your email to send you important updates about the app. Your data is not shared with third parties for marketing purposes.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "3. Data Security",
                      "We are committed to protecting your data. We implement industry-standard security measures to protect against unauthorized access, alteration, disclosure, or destruction of your personal information.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "4. Third-Party Services",
                      "The app may use third-party services, such as a cloud backend for data storage. These services have their own privacy policies. We are not responsible for the privacy practices of these third-party services.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "5. Your Rights",
                      "You have the right to access, update, or delete your personal information. You can do this through your account settings or by contacting us directly.",
                      isDark,
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      "6. Policy Updates",
                      "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page. We encourage you to review this policy periodically.",
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

  // Helper method to build a consistent section with a title and content.
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