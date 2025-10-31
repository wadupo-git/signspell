import 'package:flutter/material.dart';
import 'home_page.dart'; // Assuming HomePage is in this path

class HowToUsePage extends StatelessWidget {
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
          "How to Use",
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
                    // --- App Icon ---
                    Icon(
                      Icons.touch_app, // A more descriptive icon.
                      size: 60,
                      color: primaryColor, // Icon color adapts to the theme.
                    ),
                    SizedBox(height: 16),

                    // --- Title Section ---
                    Text(
                      "How to Use SignSpell",
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

                    // --- Instructions List ---
                    Align( // Align instructions to the left.
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstructionStep(
                            context,
                            "1. Input Text:",
                            "On the main screen, simply type any word or phrase into the provided text box. For example, try typing 'hello' or 'project'.",
                            isDark,
                          ),
                          SizedBox(height: 20),
                          _buildInstructionStep(
                            context,
                            "2. Generate Signs:",
                            "Tap the 'Generate Signs' button. The app will then process your input and prepare the corresponding sign language animations.",
                            isDark,
                          ),
                          SizedBox(height: 20),
                          _buildInstructionStep(
                            context,
                            "3. Watch and Learn:",
                            "Observe the 3D hand model animate each letter of your input. You can navigate through individual letters using the arrows or by tapping the letter buttons below the animation.",
                            isDark,
                          ),
                          SizedBox(height: 20),
                          _buildInstructionStep(
                            context,
                            "4. Control Speed:",
                            "Adjust the animation speed using the slider to match your learning pace. You can also pause and replay the sequence as needed.",
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // --- "Try it" Button ---
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to the HomePage. Using pushReplacement to prevent going back to HowToUse.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Button color adapts to theme.
                        foregroundColor: isDark ? Colors.black : Colors.white, // Text color.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners for the button.
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        elevation: 5, // Adds a subtle shadow to the button.
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      icon: Icon(Icons.play_arrow_rounded, size: 28),
                      label: Text(
                        "Try it now!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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

  // Helper method to build consistent instruction steps.
  Widget _buildInstructionStep(BuildContext context, String title, String description, bool isDark) {
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blue.shade100 : Colors.blue.shade800, // Highlight step titles.
          ),
        ),
        SizedBox(height: 5),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: textColor,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}