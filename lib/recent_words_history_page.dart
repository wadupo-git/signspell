import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';


class RecentWordsHistoryPage extends StatefulWidget {
  const RecentWordsHistoryPage({Key? key}) : super(key: key);

  @override
  _RecentWordsHistoryPageState createState() => _RecentWordsHistoryPageState();
}

class _RecentWordsHistoryPageState extends State<RecentWordsHistoryPage> {
  List<String> _allSpelledWords = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAllSpelledWords();
  }

  Future<void> _fetchAllSpelledWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');

    if (userEmail == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in.';
        });
      }
      return;
    }

    try {
      final response = await http.post(
        // NEW: This is a new endpoint you need to create on your backend
        Uri.parse('$BASE_API_URL/get_all_spelled_words.php'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"email": userEmail},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body.trim());
        if (data['success']) {
          if (mounted) {
            setState(() {
              _allSpelledWords = List<String>.from(data['words'] ?? []);
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = data['message'] ?? 'Failed to load history.';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spelling History'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red),
                          SizedBox(height: 16),
                          Text(_errorMessage, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                : _allSpelledWords.isEmpty
                    ? const Center(
                        child: Text(
                          'No spelled words found in your history.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _allSpelledWords.length,
                        itemBuilder: (context, index) {
                          final word = _allSpelledWords[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(Icons.fingerprint_rounded, color: Colors.blue.shade600),
                              title: Text(
                                word,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              // You can add an onTap to re-spell the word if needed
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Spelling: $word')),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}