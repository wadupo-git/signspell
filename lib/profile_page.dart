import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import 'constants.dart';



import 'recent_words_history_page.dart';
import 'daily_challenge_page.dart';
import 'edit_profile_page.dart'; // NEW: Import the EditProfilePage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 1;
  String name = "Loading...";
  String email = "Loading...";
  String profilePicture = "";
  DateTime? joinedDate; 
  
  // --- State variables for personalized stats and content ---
  int totalSpelledWords = 0;
  List<String> recentWords = [];
  int? _userId; // NEW: To store the user's ID for editing

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');

    if (userEmail == null) {
      print("Email not found in SharedPreferences");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$BASE_API_URL/get_user.php'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"email": userEmail},
      );
      
      final data = json.decode(response.body.trim());

      if (data['success']) {
        if (mounted) {
          setState(() {
            _userId = int.tryParse(data['user']['id']?.toString() ?? ''); // NEW: Populate userId
            name = data['user']['name'];
            email = data['user']['email'];
            profilePicture = data['user']['profile_picture'] ?? "";
            
            joinedDate = data['user']['created_at'] != null 
                ? DateTime.parse(data['user']['created_at']) 
                : null;
                
            totalSpelledWords = data['user']['total_words_spelled'] ?? 0;
            recentWords = List<String>.from(data['user']['recent_words'] ?? []);
          });
        }
      } else {
        print("Error fetching user data: ${data['message']}");
      }
    } catch (e) {
      print("Fetch error: $e");
      if (mounted) {
        setState(() {
          name = "Error";
          email = "Check connection";
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      Widget nextPage;
      switch (index) {
        case 0:
          nextPage = HomePage();
          break;
        case 2:
          nextPage = SettingsPage();
          break;
        default:
          return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? Colors.blue.shade200 : Colors.blue.shade600;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final Color cardColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: textColor,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/profile_page_bg.png'),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade900, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60),

                  // --- Profile Picture Section ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        backgroundImage: (profilePicture.isNotEmpty) ? NetworkImage("$BASE_API_URL/$profilePicture") : null,
                        child: (profilePicture.isEmpty)
                            ? Icon(Icons.person, size: 60, color: secondaryTextColor)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: primaryColor,
                          child: Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.black : Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // --- Name and Email ---
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (joinedDate != null)
                    Text(
                      'Joined: ${DateFormat.yMMMd().format(joinedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  SizedBox(height: 24),

                  // --- Action Buttons ---
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      // UPDATED: OnPressed to navigate to EditProfilePage
                      onPressed: () async {
                        // Ensure user data is loaded before navigating
                        if (name == "Loading..." || email == "Loading..." || _userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please wait for profile data to load.')),
                          );
                          return;
                        }

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              userId: _userId!.toString(), // Pass the fetched user ID
                              currentName: name, // Pass current name
                              currentEmail: email, // Pass current email
                              currentProfilePicture: profilePicture, // Pass current profile picture URL
                            ),
                          ),
                        );
                        // If EditProfilePage popped with true (indicating a save), refresh profile data
                        if (result == true) {
                          fetchUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Edit Profile", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed: logout,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade400, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Log Out", style: TextStyle(color: Colors.red.shade400, fontSize: 18)),
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // --- User Activity Summary Section ---
                  _buildActivitySummaryCard(cardColor, textColor, secondaryTextColor, primaryColor),
                  
                  SizedBox(height: 40),

                  // --- Daily Challenge Button ---
                  // ... inside your _ProfilePageState class, in the build method
// --- Daily Challenge Button ---

                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.translate_rounded), label: "Generate"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  // --- Widget for user activity summary ---
  Widget _buildActivitySummaryCard(Color cardColor, Color textColor, Color secondaryTextColor, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            "Your Activity",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      value: '$totalSpelledWords',
                      label: 'Words Spelled',
                      icon: Icons.spellcheck,
                      iconColor: Colors.green,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                    _buildStatItem(
                      value: '${recentWords.length}',
                      label: 'Recent Spells',
                      icon: Icons.history,
                      iconColor: Colors.purple,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'Recent Words',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Divider(height: 16, thickness: 1),
                recentWords.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            'No words spelled yet. Start using the app to see your history!',
                            style: TextStyle(fontStyle: FontStyle.italic, color: secondaryTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: recentWords.length > 5 ? 5 : recentWords.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.fingerprint_rounded, color: primaryColor),
                            title: Text(
                              recentWords[index],
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: secondaryTextColor),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Spelling: ${recentWords[index]}')),
                              );
                            },
                          );
                        },
                      ),
                if (totalSpelledWords > 5)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecentWordsHistoryPage()),
                          );
                        },
                        child: Text(
                          'View All Spelled Words',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // NOTE: This widget is moved to daily_challenge_page.dart
  Widget _buildChallengeSection(Color cardColor, Color textColor, Color primaryColor, bool isDark, Color secondaryTextColor) {
    return Container(); // Placeholder, as this widget is no longer used here
  }

  // Helper widget to build a single stat item.
  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: iconColor),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}