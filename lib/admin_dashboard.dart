// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart';
import 'user_management_page.dart';
import 'content_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _adminEmail = 'Admin';

  int _totalUsersCount = 0;
  int _totalWordsSpelledAppWide = 0;
  int _totalLettersAvailable = 0;
  int _totalCategorizedWords = 0;
  bool _statsLoading = true;
  String? _statsErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadAdminEmail();
    _fetchAdminStats();
  }

  Future<void> _loadAdminEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _adminEmail = prefs.getString('admin_email') ?? 'Admin';
      });
    }
  }

  Future<void> _fetchAdminStats() async {
    if (mounted) {
      setState(() {
        _statsLoading = true;
        _statsErrorMessage = null;
      });
    }

    try {
      var url = Uri.parse("$BASE_API_URL/get_admin_stats.php");
      var response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"] == true) {
          if (mounted) {
            setState(() {
              _totalUsersCount = int.tryParse(data["stats"]["total_users"]?.toString() ?? '0') ?? 0;
              _totalWordsSpelledAppWide = int.tryParse(data["stats"]["total_words_spelled"]?.toString() ?? '0') ?? 0;
              _totalLettersAvailable = int.tryParse(data["stats"]["total_letters_available"]?.toString() ?? '0') ?? 0;
              _totalCategorizedWords = int.tryParse(data["stats"]["total_categorized_words"]?.toString() ?? '0') ?? 0;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _statsErrorMessage = data["message"];
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _statsErrorMessage = "Server error: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statsErrorMessage = "Failed to connect to the server for stats: $e";
      });
      print("Error fetching admin stats: $e");
    } finally {
      if (mounted) {
        setState(() {
          _statsLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_email');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildDashboardCard(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap}) {
    return Card(
      elevation: 8, // Slightly increased elevation for more depth
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

  Widget _buildStatItem({required String value, required String label, required IconData icon, required Color iconColor}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Stats',
            onPressed: _fetchAdminStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container( // NEW: Added Container for gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white], // Light blue to white gradient
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Row(
                children: [
                  Lottie.asset(
                    'assets/animations/welcome_admin.json',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hello Admin,",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        Text(
                          _adminEmail,
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Global Statistics Section
              _statsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _statsErrorMessage != null
                      ? Center(
                          child: Text(
                            "Error loading stats: $_statsErrorMessage",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Card(
                          elevation: 8, // Increased elevation for more depth
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "App Overview Statistics",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Divider(height: 20, thickness: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      value: _totalUsersCount.toString(),
                                      label: "Total Users",
                                      icon: Icons.group,
                                      iconColor: Colors.blue.shade600,
                                    ),
                                    _buildStatItem(
                                      value: _totalWordsSpelledAppWide.toString(),
                                      label: "Total Words Spelled",
                                      icon: Icons.spellcheck,
                                      iconColor: Colors.green.shade600,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      value: _totalLettersAvailable.toString(),
                                      label: "Total Letters Available",
                                      icon: Icons.abc,
                                      iconColor: Colors.orange.shade600,
                                    ),
                                    _buildStatItem(
                                      value: _totalCategorizedWords.toString(),
                                      label: "Total Categorized Words",
                                      icon: Icons.category,
                                      iconColor: Colors.purple.shade600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
              const SizedBox(height: 30),

              // Dashboard Grid
              const Text(
                "Management Tools",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    title: "User Management",
                    icon: Icons.people,
                    iconColor: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserManagementPage()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: "Content Management",
                    icon: Icons.video_library,
                    iconColor: Colors.green.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ContentManagementPage()),
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