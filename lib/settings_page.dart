import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'about_page.dart';
import 'credits_page.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';
import 'how_to_use_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2; // Settings is the default selected tab

  // Function to navigate to a sub-page while keeping the bottom navigation bar.
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Function to handle bottom navigation bar taps.
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      Widget nextPage;
      switch (index) {
        case 0:
          nextPage = HomePage();
          break;
        case 1:
          nextPage = ProfilePage();
          break;
        case 2:
          // Stay on the same page.
          return;
        default:
          return;
      }
      // Use pushReplacement to replace the current page in the navigation stack.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

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
      // The body container holds the background gradient.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade900, Colors.white], // Consistent gradient.
          ),
        ),
        // SafeArea ensures content doesn't get obscured by system UI.
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Page Title ---
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 32, // Larger font size for prominence.
                    fontWeight: FontWeight.bold,
                    color: textColor, // Color adapts to the theme.
                  ),
                ),
                SizedBox(height: 16),
                Divider(
                  color: dividerColor, // Divider color adapts to the theme.
                  thickness: 1.5,
                ),
                SizedBox(height: 16),

                // --- Settings Cards List ---
                Expanded( // Use Expanded to make the SingleChildScrollView fill available space.
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // About App
                        _settingsCard("About App", Icons.info_outline, () {
                          _navigateToPage(AboutPage());
                        }, isDark),

                        // How to Use This App
                        _settingsCard("How to Use This App", Icons.help_outline, () {
                          _navigateToPage(HowToUsePage());
                        }, isDark),

                        // Credits
                        _settingsCard("Credits", Icons.people_alt_outlined, () {
                          _navigateToPage(CreditsPage());
                        }, isDark),

                        // Terms of Service
                        _settingsCard("Terms of Service", Icons.description_outlined, () {
                          _navigateToPage(TermsPage());
                        }, isDark),

                        // Privacy Policy
                        _settingsCard("Privacy Policy", Icons.privacy_tip_outlined, () {
                          _navigateToPage(PrivacyPolicyPage());
                        }, isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.translate_rounded), label: "Generate"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Adapts to theme's primary color.
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper widget to build a styled settings card.
  Widget _settingsCard(String title, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Card( // Using Card widget directly for consistent styling.
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Consistent border radius.
        ),
        elevation: 8, // Increased elevation for a prominent shadow.
        shadowColor: Colors.black.withOpacity(0.1), // Consistent shadow.
        color: isDark ? Colors.grey.shade800 : Colors.white, // Color adapts to theme.
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 28, // Slightly larger icon.
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade800, // Icon color adapts to theme.
                  ),
                  SizedBox(width: 15),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87, // Text color adapts to theme.
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}