import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'constants.dart'; // NEW: Import the constants file

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Map<String, dynamic>? _userDetails;
  List<Map<String, dynamic>> _spellingHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsAndHistory();
  }

  Future<void> _fetchUserDetailsAndHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use BASE_API_URL from the constants file
      var url = Uri.parse("$BASE_API_URL/get_user_details_and_history.php?id=${widget.userId}"); // FIXED URL ACCESS
      var response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            _userDetails = Map<String, dynamic>.from(data["user_details"]);
            _spellingHistory = List<Map<String, dynamic>>.from(data["spelling_history"]);
          });
        } else {
          setState(() {
            _errorMessage = data["message"];
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to connect to the server: $e";
      });
      print("Error fetching user details and history: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userDetails?['name'] ?? 'User Details'),
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          "Error: $_errorMessage",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchUserDetailsAndHistory,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView( // Allow scrolling for potentially long history
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Details Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blue.shade100,
                                  backgroundImage: _userDetails?['profile_picture'] != null && _userDetails!['profile_picture'].isNotEmpty
                                      ? NetworkImage(_userDetails!['profile_picture'])
                                      : null,
                                  child: _userDetails?['profile_picture'] == null || _userDetails!['profile_picture'].isEmpty
                                      ? Icon(Icons.person, size: 50, color: Colors.blue.shade800)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userDetails?['name'] ?? 'N/A',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _userDetails?['email'] ?? 'N/A',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              if (_userDetails?['created_at'] != null)
                                Text(
                                  'Joined: ${DateFormat.yMMMd().format(DateTime.parse(_userDetails!['created_at']))}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const Text(
                        "Spelling History",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),

                      _spellingHistory.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'This user has no spelling history yet.',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true, // Crucial for ListView inside SingleChildScrollView
                              physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                              itemCount: _spellingHistory.length,
                              itemBuilder: (context, index) {
                                final historyItem = _spellingHistory[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(historyItem['word'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                      historyItem['created_at'] != null
                                          ? DateFormat.yMMMd().add_jm().format(DateTime.parse(historyItem['created_at']))
                                          : 'N/A',
                                    ),
                                    leading: const Icon(Icons.fingerprint_rounded, color: Colors.blue),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}