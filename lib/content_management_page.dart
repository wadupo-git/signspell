// content_management_page.dart
import 'package:flutter/material.dart';
// No http, video_player, etc. needed here anymore, as it's a dashboard
// Only imports for navigation pages
import 'manage_letters_page.dart'; // NEW: Import manage letters page
import 'manage_words_page.dart';   // NEW: Import manage words page

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  // All specific content management logic (fetching, CRUD, video preview)
  // has been moved to manage_letters_page.dart and manage_words_page.dart

  // Helper method to create dashboard cards (reused from admin_dashboard for consistency)
  Widget _buildDashboardCard(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: iconColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Content Management Dashboard"),
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container( // Added Container for background consistency
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white], // Light blue to white gradient
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manage Your Content",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2, // 2 cards per row
                shrinkWrap: true, // Wrap content to avoid unbounded height errors
                physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
                mainAxisSpacing: 16, // Vertical spacing between cards
                crossAxisSpacing: 16, // Horizontal spacing between cards
                children: [
                  _buildDashboardCard(
                    title: "Manage Letters",
                    icon: Icons.abc,
                    iconColor: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageLettersPage()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: "Manage Words",
                    icon: Icons.library_books,
                    iconColor: Colors.green.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageWordsPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}